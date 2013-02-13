package org.flixel.addons.taskManager;

import org.flixel.FlxBasic;
import org.flixel.FlxG;

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
	private static var _COUNTER:Int = 0;
	
	/**
	 * This function will be called when all tasks in the task manager will be completed
	 */
	public var onComplete:Void->Void;
	
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
	 * @param	aCycle
	 * @param	onComplete
	 */
	public function new(aCycle:Bool = false, onComplete:Void->Void = null)
	{
		super();
		
		ID = _COUNTER;
		_COUNTER++;
		
		_taskList = null;
		_isStarted = false;
		_isPaused = false;
		_result = false;
		_cycle = aCycle;
		_delay = 0;
		
		this.onComplete = onComplete;
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
	 * @param	aFunc	 Method-task to be executed in sequence.
	 * @param	aArgs	 An array of arguments that can be passed to the task-method.
	 * @param	aIgnoreCycle	 If true then the task will be deleted from the manager immediately after execution.
	 */
	public function addTask(aFunc:Dynamic, aArgs:Array<Dynamic> = null, aIgnoreCycle:Bool = false):Void
	{
		push(new AntTask(aFunc, aArgs, aIgnoreCycle, false));
		start();
	}
	
	/**
	 * Adds a task to the end of queue, the method will be executed only ONCE, after that we go to the next task.
	 * Добавляет задачу в конец очереди, указанный метод будет выполнен только один раз, после чего будет осуществлен
	 * переход к следующей задачи не зависимо от того, что вернет метод-задача и вернет ли вообще.
	 * 
	 * @param	aFunc	 Method-task to be executed in sequence.
	 * @param	aArgs	 An array of arguments that can be passed to the task-method.
	 * @param	aIgnoreCycle	 If true then the task will be deleted from the manager immediately after execution.
	 */
	public function addInstantTask(aFunc:Dynamic, aArgs:Array<Dynamic> = null, aIgnoreCycle:Bool = false):Void
	{
		push(new AntTask(aFunc, aArgs, aIgnoreCycle, true));
		start();
	}
	
	/**
	 * Adds a task to the top of the queue, the method will be executed while it returns <code>false</code>.
	 * The task will be completed only when the method will return <code>true</code>, and the manager will move to the next task.
	 * 
	 * @param	aFunc	 Method-task to be executed in sequence.
	 * @param	aArgs	 An array of arguments that can be passed to the task-method.
	 * @param	aIgnoreCycle	 If true then the task will be deleted from the manager immediately after execution.
	 */
	public function addUrgentTask(aFunc:Dynamic, aArgs:Array<Dynamic> = null, aIgnoreCycle:Bool = false):Void
	{
		unshift(new AntTask(aFunc, aArgs, aIgnoreCycle, false));
		start();
	}
	
	/**
	 * Adds a task to the top of the queue, the method will be executed only ONCE, after that we go to the next task.
	 * 
	 * @param	aFunc	 Method-task to be executed in sequence.
	 * @param	aArgs	 An array of arguments that can be passed to the task-method.
	 * @param	aIgnoreCycle	 If true then the task will be deleted from the manager immediately after execution.
	 */
	public function addUrgentInstantTask(aFunc:Dynamic, aArgs:Array<Dynamic> = null, aIgnoreCycle:Bool = false):Void
	{
		unshift(new AntTask(aFunc, aArgs, aIgnoreCycle, true));
		start();
	}
	
	/**
	 * Adds a pause between tasks
	 * @param	aDelay	 Pause duration
	 * @param	aIgnoreCycle	 If true, the pause will be executed only once per cycle
	 */
	public function addPause(aDelay:Float, aIgnoreCycle:Bool = false):Void
	{
		addTask(taskPause, [aDelay], aIgnoreCycle);
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
	 * @param	aIgnoreCycle	 Specifies whether to leave the previous problem in the manager
	 */
	public function nextTask(aIgnoreCycle:Bool = false):Void
	{
		if (_cycle && !aIgnoreCycle)
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
			_result = Reflect.callMethod(this, _taskList.func, _taskList.args);
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
			FlxG.addPlugin(this);
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
			FlxG.removePlugin(this);
			_isStarted = false;
		}
	}
	
	/**
	 * Method-task for a pause between tasks
	 * @param	aDelay	 Delay
	 * @return		Returns true when the task is completed
	 */
	private function taskPause(aDelay:Float):Bool
	{
		_delay += FlxG.elapsed;
		if (_delay > aDelay)
		{
			_delay = 0;
			return true;
		}
		
		return false;
	}
	
	/**
	 * Adds the specified object to the end of the list
	 * @param	aObj	 The object to be added.
	 * @return		Returns a pointer to the added object.
	 */
	private function push(aTask:AntTask):AntTask
	{
		if (aTask == null)
		{
			return null;
		}
		
		if (_taskList == null)
		{
			_taskList = aTask;
			return aTask;
		}
		
		var cur:AntTask = _taskList;
		while (cur.next != null)
		{
			cur = cur.next;
		}

		cur.next = aTask;
		return aTask;
	}
	
	/**
	 * Adds task to the top of task list
	 * @param	aObj	 The object to be added
	 * @return		Returns a pointer to the added object
	 */
	private function unshift(aTask:AntTask):AntTask
	{
		if (_taskList == null)
		{
			return aTask;
		}
		
		var item:AntTask = _taskList;
		_taskList = aTask;
		_taskList.next = item;
		return aTask;
	}
	
	/**
	 * Removes first task
	 * @return		The task that has been removed
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
	public var pause(get_pause, set_pause):Bool;
	
	private function set_pause(value:Bool):Bool
	{
		if (value && !_isPaused)
		{
			if (_isStarted)
			{
				FlxG.removePlugin(this);
			}
			_isPaused = true;
		}
		else
		{
			if (_isStarted)
			{
				FlxG.addPlugin(this);
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
	public var isStarted(get_isStarted, null):Bool;
	
	private function get_isStarted():Bool
	{
		return _isStarted;
	}
	
	/**
	 * Number of tasks
	 */
	public var length(get_lenght, null):Int;
	
	private function get_lenght():Int
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