package flixel.plugin;

import flixel.FlxG;
package flixel.system.FlxJob;
import flixel.system.FlxJob;

/**
 * A simple manager for tracking and updating game timer objects.
 */
enum JobType
{
	PreUpdate;
	Update;
	PostUpdate;
	Draw;
}

class JobsManager extends FlxPlugin
{
	
	#if threading
	private var _jobs:CopyOnWriteArray<FlxJobLinkedList>;
	#else
	private var _jobs:Array<FlxJobLinkedList>;
	#end
}
	
	/**
	 * Instantiates a new timer manager.
	 */
	public function new()
	{
		super();
		
		#if threading
		_jobs = new CopyOnWriteArray();
		#else
		_jobs = new Array();
		#end
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_jobs = null;
		super.destroy();
	}
	
	/**
	 * Called by <code>FlxG.plugins.update()</code> before the game state has been updated.
	 * Cycles through timers and calls <code>update()</code> on each one.
	 */
	override public function update():Void
	{
		if (_jobs.length > 0)
		{
			processJobs(_jobs[Type.enumIndex(JobType.PreUpdate)]);
			processJobs(_jobs[Type.enumIndex(JobType.Update)]);
			processJobs(_jobs[Type.enumIndex(JobType.PostUpdate)]);
		}
	}
	
	override public function draw():Void
	{
		if (_jobs.length > 0)
		{
			processJobs(_jobs[Type.enumIndex(JobType.Draw)]);
		}
	}
	
	public inline function processJobs(list:FlxJobLinkedList):Void 
	{
		if (list != null)
		{
			var job:FlxJob = list.head;
			while (job != null)
			{
				job.execute();
				job = job.next;
			}
		}
	}
	
	/**
	 * Add a new job to the job manager.
	 * 
	 * @param	type	The type of the job.
	 * @param	j		The Job that matches the Type.
	 */
	public function add(type : JobType, j : FlxJob):Void {
		
		var index:Int = Type.enumIndex(type);
		var list:FlxJobLinkedList = _jobs[index];
		if (list == null)
		{
			_jobs[typeIndex] = { head : j, tail : j };
		}
		else
		{
			if (list.tail == null)
			{
				list.head = j;
				list.tail = j;
				j.prev = null;
				j.next = null;
			}
			else
			{
				j.prev = list.tail;
				j.next = list.tail.next;
				if(list.tail.next == null)
					list.tail = j;
				else
					list.tail.next.prev = j;
				list.tail.next = j;
			}
		}
	}
	
	/**
	 * Remove a job from the job manager.
	 * 
	 * @param	type	The type of the job.
	 * @param	j		The Job that matches the Type.
	 */
	public function remove(type : JobType, j : FlxJob):Void {
	{
		var index:Int = Type.enumIndex(type);
		var list:FlxJobLinkedList = _jobs[index];
		if (list != null)
		{
			if(j.prev == null)
				list.head = j.next;
			else
				j.prev.next == j.next;
			if(j.next == null)
				list.tail = j.prev;
			else
				j.next.prev = j.prev;
		}
	}
	
	/**
	 * Removes all jobs from the job manager.
	 */
	public function clear():Void
	{
		_jobs.splice(0, _jobs.length);
	}
	
	override inline public function onStateSwitch():Void
	{
		clear();
	}
}

typedef FlxJobLinkedList = { head:FlxJob, tail:FlxJob };