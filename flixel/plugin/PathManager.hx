package flixel.plugin;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPath;

class PathManager extends FlxPlugin
{
	private var _paths:Array<FlxPath> = [];
	
	public function new()
	{
		super();
		#if !FLX_NO_DEBUG
		visible = false; // No draw-calls needed 
		#end
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		clear();
		_paths = null;
		
		super.destroy();
	}
	
	override public function update():Void
	{
		for (path in _paths)
		{
			if (path.active)
			{
				path.update();
			}
		}
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Called by FlxG.plugins.draw() after the game state has been drawn.
	 * Cycles through cameras and calls drawDebug() on each one.
	 */
	override public function draw():Void
	{
		super.draw();
		if (FlxG.debugger.drawDebug)
		{
			for (path in _paths)
			{
				if ((path != null) && !path.ignoreDrawDebug)
				{
					path.drawDebug();
				}
			}
		}
	}
	#end
	
	/**
	 * Add a path to the path debug display manager.
	 * Usually called automatically by FlxPath's constructor.
	 * 
	 * @param	Path	The FlxPath you want to add to the manager.
	 */
	public function add(Path:FlxPath):Void
	{
		_paths.push(Path);
	}
	
	/**
	 * Remove a path from the path debug display manager.
	 * Usually called automatically by FlxPath's destroy() function.
	 * 
	 * @param	Path	The FlxPath you want to remove from the manager.
	 */
	public function remove(Path:FlxPath, ReturnInPool:Bool = true):Void
	{
		FlxArrayUtil.fastSplice(_paths, Path);
	}
	
	/**
	 * Removes all the paths from the path debug display manager.
	 */
	public inline function clear():Void
	{
		FlxArrayUtil.clearArray(_paths);
	}
	
	override public inline function onStateSwitch():Void
	{
		clear();
	}
}