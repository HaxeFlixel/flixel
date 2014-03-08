package flixel.system.layer;

import flixel.util.loaders.CachedGraphics;

class DrawStackItem
{
	public var graphics:CachedGraphics;
	public var drawData:Array<Float>;
	public var position:Int = 0;
	public var next:DrawStackItem;
	
	public var colored:Bool = false;
	public var blending:Int = 0;
	
	public var initialized:Bool = false;
	
	public var antialiasing:Bool = false;
	
	public function new()
	{
		drawData = new Array<Float>();
	}
	
	public inline function reset():Void
	{
		graphics = null;
		initialized = false;
		antialiasing = false;
		position = 0;
	}
	
	public inline function dispose():Void
	{
		graphics = null;
		drawData = null;
		next = null;
	}
}