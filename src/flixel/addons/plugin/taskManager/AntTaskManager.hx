package flixel.addons.plugin.taskManager;

import flixel.FlxBasic;
import flixel.FlxG;

/**
 * The Task Manager is used to perform tasks (call methods) in specified order.
 * Allows you to quickly and easily program any action, such as the appearance of the buttons in the game menus.
 * Task Manager is started automatically when you add at least one task, and stops when all tasks are done.
 * 
 * @author Anton Karlov
 * @since  08.22.2012
 * @author Zaphod
 * @since  11.19.2012
 */
class AntTaskManager extends FlxBasic
{
	/**
	 * This function will be called when all tasks in the task manager will be completed
	 */
	public var onComplete:Void->Void;
	
	static private var _COUNTER:Int = 0;
	
	/**
	 * The list of active tasks
	 */
	private var _taskList:AntTask;
	/**
	 * Defines a manager's job is running
	 * @default    false
	 */
	private var _isStarted:Bool;
	/**
	 * Determines whether the tasks put on pause
	 * @default    false
	 */
	private var _isPaused:Bool;
	/**
	 * Helper to determine the end of the current task
	 * @default    false
	 */
	private var _result:Bool;
	/**
	 * Determines whether tasks are performed in a loop
	 * @default    false
	 */
	private var _cycle:Bool;
	/**
	 * Used to calculate the current pause between tasks
	 * @default    0
	 */
	private var _delay:Float;
	
	/**
	 * Constructor
	 * 
	 * @param	Cycle
	 * @param	OnComplete
	 */
	public function new(Cycle:Bool = false, ?OnComplete:Void->Void)
	{
		super();
		
		ID = _COUNTER;
		_COUNTER++;
		
		_taskList = null;
		_isStarted = false;
		_isPaused = false;
		_result = false;
		_cycle = Cycle;
		_delay = 0;
		
		onComplete = OnComplete;
	}
	
	override public function destroy():Void
	{
		clear();
		onComplete = null;
		kill();
	}
	
	/**
	 * Adds a task to the end of queue, the method will be executed while it returns <code>false</code>.
	 * The task will be completed only when the method will return <code>true</code>. And manager will switch to the next task.
	 * 
	 * @param	Object				An object to call method-task from
	 * @param	Function			Method-task to be executed in sequence.
	 * @param	Arguments	 		An array of arguments that can be passed to the task-method.
	 * @param	IgnoreCycle		If true then the task will be deleted from the manager immediately after execution.
	 */
	public function addTask(Object:Dynamic, Function:Dynamic, ?Arguments:Array<Dynamic>, IgnoreCycle:Bool = false):Void
	{
		push(new AntTask(Object, Function, Arguments, IgnoreCycle, false));
		start();
	}
	
	/**
	 * Adds a task to the end of queue, the method will be executed only ONCE, after that we go to the next task.
	 * Добавляет задачу в конец очереди, указанный метод будет выполнен только один раз, после чего будет осуществлен
	 * переход к следующей задачи не зависимо от того, что вернет метод-задача и вернет ли вообще.
	 * 
	 * @param	Object	 			An object to call method-task from
	 * @param	Function	 		Method-task to be executed in sequence.
	 * @param	Arguments	 		An array of arguments that can be passed to the task-method.
	 * @param	IgnoreCycle		If true then the task will be deleted from the manager immediately after execution.
	 */
	public function addInstantTask(Object:Dynamic, Function:Dynamic, ?Arguments:Array<Dynamic>, IgnoreCycle:Bool = false):Void
	{
		push(new AntTask(Object, Function, Arguments, IgnoreCycle, true));
		start();
	}
	
	/**
	 * Adds a task to the top of the queue, the method will be executed while it returns <code>false</code>.
	 * The task will be completed only when the method will return <code>true</code>, and the manager will move to the next task.
	 * 
	 * @param	Object	 			An object to call method-task from
	 * @param	Function	 		Method-task to be executed in sequence.
	 * @param	Arguments	 		An array of arguments that can be passed to the task-method.
	 * @param	IgnoreCycle	 	If true then the task will be deleted from the manager immediately after execution.
	 */
	public function addUrgentTask(Object:Dynamic, Function:Dynamic, ?Arguments:Array<Dynamic>, IgnoreCycle:Bool = false):Void
	{
		unshift(new AntTask(Object, Function, Arguments, IgnoreCycle, false));
		start();
	}
	
	/**
	 * Adds a task to the top of the queue, the method will be executed only ONCE, after that we go to the next task.
	 * 
	 * @param	Object	 			An object to call method-task from
	 * @param	Function	 		Method-task to be executed in sequence.
	 * @param	Arguments	 		An array of arguments that can be passed to the task-method.
	 * @param	IgnoreCycle	 	If true then the task will be deleted from the manager immediately after execution.
	 */
	public function addUrgentInstantTask(Object:Dynamic, Function:Dynamic, ?Arguments:Array<Dynamic>, IgnoreCycle:Bool = false):Void
	{
		unshift(new AntTask(Object, Function, Arguments, IgnoreCycle, true));
		start();
	}
	
	/**
	 * Adds a pause between tasks
	 * 
	 * @param	Delay		 Pause duration
	 * @param	IgnoreCycle	 If true, the pause will be executed only once per cycle
	 */
	public function addPause(Delay:Float, IgnoreCycle:Bool = false):Void
	{
		addTask(this, taskPause, [Delay], IgnoreCycle);
	}
	
	/**
	 * Removes all the tasks from manager and stops it
	 */
	public function clear():Void
	{
		stop();
		
		if (_taskList != null)
		{
			_taskList.dispose();
			_taskList = null;
		}
		
		_delay = 0;
	}
	
	/**
	 * Move to the next task
	 * 
	 * @param	IgnoreCycle 	Specifies whether to leave the previous problem in the manager
	 */
	public function nextTask(IgnoreCycle:Bool = false):Void
	{
		if (_cycle && !IgnoreCycle)
		{
			push(shift());
		}
		else
		{
			var task:AntTask = shift();
			task.dispose();
		}
	}
	
	/**
	 * Current task processing
	 */
	override public function update():Void
	{
		if (_taskList != null && _isStarted)
		{
			_result = Reflect.callMethod(_taskList.obj, _taskList.func, _taskList.args);
			
			if (_isStarted && (_taskList.instant || _result))
			{
				nextTask(_taskList.ignoreCycle);
			}
		}
		else
		{
			stop();
			
			if (onComplete != null)
			{
				onComplete();
			}
		}
	}
	
	/**
	 * Starts the task manager processing
	 */
	private function start():Void
	{
		if (!_isStarted)
		{
			FlxG.plugins.add(this);
			_isStarted = true;
			_isPaused = false;
		}
	}
	
	/**
	 * Stops the task manager
	 */
	private function stop():Void
	{
		if (_isStarted)
		{
			FlxG.plugins.remove(this);
			_isStarted = false;
		}
	}
	
	/**
	 * Method-task for a pause between tasks
	 * 
	 * @param	Delay	 Delay
	 * @return	Returns true when the task is completed
	 */
	private function taskPause(Delay:Float):Bool
	{
		_delay += FlxG.elapsed;
		
		if (_delay > Delay)
		{
			_delay = 0;
			return true;
		}
		
		return false;
	}
	
	/**
	 * Adds the specified object to the end of the list
	 * 
	 * @param	Task	The <code>AntTask</code> to be added.
	 * @return	Returns a pointer to the added <code>AntTask</code>.
	 */
	private function push(Task:AntTask):AntTask
	{
		if (Task == null)
		{
			return null;
		}
		
		if (_taskList == null)
		{
			_taskList = Task;
			return Task;
		}
		
		var cur:AntTask = _taskList;
		
		while (cur.next != null)
		{
			cur = cur.next;
		}

		cur.next = Task;
		
		return Task;
	}
	
	/**
	 * Adds task to the top of task list
	 * 
	 * @param	Task	The <code>AntTask</code> to be added.
	 * @return	Returns a pointer to the added <code>AntTask</code>
	 */
	private function unshift(Task:AntTask):AntTask
	{
		if (_taskList == null)
		{
			return Task;
		}
		
		var item:AntTask = _taskList;
		_taskList = Task;
		_taskList.next = item;
		
		return Task;
	}
	
	/**
	 * Removes first task
	 * 
	 * @return	The task that has been removed
	 */
	private function shift():AntTask
	{
		if (_taskList == null)
		{
			return null;
		}
		
		var item:AntTask = _taskList;
		_taskList = item.next;
		item.next = null;
		
		return item;
	}
	
	/**
	 * Sets and gets pause status of this task manager
	 */
	public var pause(get, set):Bool;
	
	private function set_pause(Value:Bool):Bool
	{
		if (Value && !_isPaused)
		{
			if (_isStarted)
			{
				FlxG.plugins.remove(this);
			}
			_isPaused = true;
		}
		else
		{
			if (_isStarted)
			{
				FlxG.plugins.add(this);
			}
			_isPaused = false;
		}
		
		return _isPaused;
	}
	
	private function get_pause():Bool
	{
		return _isPaused;
	}
	
	/**
	 * Tells if this manager has been started
	 */
	public var isStarted(get, never):Bool;
	
	private function get_isStarted():Bool
	{
		return _isStarted;
	}
	
	/**
	 * Number of tasks
	 */
	public var length(get, never):Int;
	
	private function get_length():Int
	{
		if (_taskList == null)
		{
			return 0;
		}
		
		var num:Int = 1;
		var cur:AntTask = _taskList;
		
		while (cur.next != null)
		{
			cur = cur.next;
			num++;
		}
		
		return num;
	}
	
	override public function toString():String 
	{
		var name:String = super.toString() + ID;
		return name;
	}
}