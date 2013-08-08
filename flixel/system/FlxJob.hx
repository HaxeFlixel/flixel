package flixel.system;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.plugin.JobsManager;

// For static typing and safe storage in JobManager
interface IJob {
	function execute():Void; 
}
/**
 * A miniature linked list class.
 * Useful for optimizing time-critical or highly repetitive tasks!
 * See <code>FlxQuadTree</code> for how to use it, IF YOU DARE.
 */

class FlxJob implements IJob
{
	// doubly linked list node
	public var prev:FlxJob;
	public var next:FlxJob;
	
	var _target:FlxBasic;
	function new(target:FlxBasic) { _target = target; }
	
	/**
	 * Read-only: The <code>TimerManager</code> instance.
	 */
	static public var manager:JobsManager;
}

class UpdateJob implements FlxJob<FlxBasic>
{
	function execute():Void { _target.update(); }
}

class OnScreenJob implements FlxJob<FlxSprite>
{
	function execute():Void { _target.onScreen(); }
}

class DrawJob implements FlxJob<FlxBasic>
{
	function execute():Void { _target.draw(); }
}