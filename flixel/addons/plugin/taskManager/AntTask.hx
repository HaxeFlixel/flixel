package flixel.addons.plugin.taskManager;

/**
 * @author Anton Karlov
 * @since  08.22.2012
 * @author Zaphod
 * @since  11.19.2012
 */
class AntTask
{
	/**
	 * Method-task to be executed
	 */
	public var func:Dynamic;
	/**
	 * An object to call func from
	 */
	public var obj:Dynamic;
	/**
	 * An array of arguments that can be passed to the task-method.
	 */
	public var args:Array<Dynamic>;
	/**
	 * If true then the task will be deleted from the manager immediately after execution.
	 */
	public var ignoreCycle:Bool;
	/**
	 * If true the task will be completed right after it's first call
	 */
	public var instant:Bool;
	/**
	 * Pointer to the next task.
	 */
	public var next:AntTask;
	
	/**
	 * Creates a new <code>AntTask</code>
	 */
	public function new(Obj:Dynamic, Func:Dynamic, ?Args:Array<Dynamic>, IgnoreCycle:Bool = false, Instant:Bool = false, ?Next:AntTask)
	{
		obj = Obj;
		func = Func;
		
		if (args == null)	
		{
			args = new Array<Dynamic>();
		}
		
		args = Args;
		ignoreCycle = IgnoreCycle;
		instant = Instant;
		next = Next;
	}
	
	/**
	 * Destroys the list.
	 */
	public function dispose():Void
	{
		if (next != null)
		{
			next.dispose();
		}
		
		next = null;
		obj = null;
		func = null;
		args = null;
	}
}