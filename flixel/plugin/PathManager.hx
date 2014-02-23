package flixel.plugin;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPath;

class PathManager extends FlxPlugin
{
	private var _paths:Array<FlxPath>;
	
	/**
	 * Instantiates a new debug path display manager.
	 */
	public function new()
	{
		super();
		_paths = new Array<FlxPath>();
		visible = false; // No draw-calls needed 
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
			if (!path.paused)
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
	override public function drawDebug():Void
	{
		if (FlxG.debugger.drawDebug && !ignoreDrawDebug)
		{
			for (camera in cameras)
			{
				drawDebugOnCamera(camera);
			}
		}
	}
	
	/**
	 * Similar to FlxObject's drawDebug() functionality,
	 * this function calls drawDebug() on each FlxPath for the specified camera.
	 * Very helpful for debugging!
	 * 
	 * @param	Camera	Which FlxCamera object to draw the debug data to.
	 */
	override public function drawDebugOnCamera(?Camera:FlxCamera):Void
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		var i:Int = _paths.length - 1;
		var path:FlxPath;
		
		while (i >= 0)
		{
			path = _paths[i--];
			
			if ((path != null) && !path.ignoreDrawDebug)
			{
				path.drawDebug(Camera);
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
		if (FlxArrayUtil.indexOf(_paths, Path) < 0) 
		{
			_paths.push(Path);
		}
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
		
		if (ReturnInPool)
		{
			FlxPath.put(Path);
		}
	}
	
	/**
	 * Removes all the paths from the path debug display manager.
	 */
	public function clear():Void
	{
		while (_paths.length > 0)
		{
			var path:FlxPath = _paths.pop();
			FlxPath.put(path);
		}
	}
	
	override public inline function onStateSwitch():Void
	{
		clear();
	}
}