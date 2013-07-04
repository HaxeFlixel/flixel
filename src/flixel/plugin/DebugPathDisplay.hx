package flixel.plugin;

#if !FLX_NO_DEBUG
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxArray;
import flixel.util.FlxPath;

/**
 * A simple manager for tracking and drawing FlxPath debug data to the screen.
 */
class DebugPathDisplay extends FlxBasic
{
	private var _paths:Array<FlxPath>;
	
	/**
	 * Instantiates a new debug path display manager.
	 */
	public function new()
	{
		super();
		
		_paths = new Array<FlxPath>();
		
		// Don't call update on this plugin
		active = false; 
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
	
	/**
	 * Called by <code>FlxG.plugins.draw()</code> after the game state has been drawn.
	 * Cycles through cameras and calls <code>drawDebug()</code> on each one.
	 */
	override public function drawDebug():Void
	{
		if (!FlxG.debugger.visualDebug || ignoreDrawDebug)
		{
			return;	
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		
		var i:Int = 0;
		var l:Int = cameras.length;
		
		while (i < l)
		{
			drawDebugOnCamera(cameras[i++]);
		}
	}
	
	/**
	 * Similar to <code>FlxObject</code>'s <code>drawDebug()</code> functionality,
	 * this function calls <code>drawDebug()</code> on each <code>FlxPath</code> for the specified camera.
	 * Very helpful for debugging!
	 * 
	 * @param	Camera	Which <code>FlxCamera</code> object to draw the debug data to.
	 */
	override public function drawDebugOnCamera(?Camera:FlxCamera):Void
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		var i:Int = _paths.length - 1;
		var path:FlxPath;
		
		while(i >= 0)
		{
			path = _paths[i--];
			
			if ((path != null) && !path.ignoreDrawDebug)
			{
				path.drawDebug(Camera);
			}
		}
	}
	
	/**
	 * Add a path to the path debug display manager.
	 * Usually called automatically by <code>FlxPath</code>'s constructor.
	 * 
	 * @param	Path	The <code>FlxPath</code> you want to add to the manager.
	 */
	public function add(Path:FlxPath):Void
	{
		_paths.push(Path);
	}
	
	/**
	 * Remove a path from the path debug display manager.
	 * Usually called automatically by <code>FlxPath</code>'s <code>destroy()</code> function.
	 * 
	 * @param	Path	The <code>FlxPath</code> you want to remove from the manager.
	 */
	public function remove(Path:FlxPath):Void
	{
		var index:Int = FlxArray.indexOf(_paths, Path);
		
		if (index >= 0)
		{
			_paths.splice(index,1);
		}
	}
	
	/**
	 * Removes all the paths from the path debug display manager.
	 */
	public function clear():Void
	{
		if (_paths != null)
		{
			var i:Int = _paths.length - 1;
			var path:FlxPath;
			
			while(i >= 0)
			{
				path = _paths[i--];
				
				if (path != null)
				{
					path.destroy();
				}
			}
		}
		
		_paths = [];
	}
}
#end