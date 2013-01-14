package org.flixel.addons.taskManager;
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
	 * Constructor
	 */
	public function new(func:Dynamic, args:Array<Dynamic> = null, ignoreCycle:Bool = false, instant:Bool = false, next:AntTask = null)
	{
		this.func = func;
		if (args == null)	args = new Array<Dynamic>();
		this.args = args;
		this.ignoreCycle = ignoreCycle;
		this.instant = instant;
		this.next = next;
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
		func = null;
		args = null;
	}
}