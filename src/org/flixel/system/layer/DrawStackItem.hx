package org.flixel.system.layer;

class DrawStackItem
{
	public var atlas:Atlas;
	public var drawData:Array<Float>;
	public var position:Int = 0;
	public var next:DrawStackItem;
	
	#if !js
	public var colored:Bool = false;
	public var blending:Int = 0;
	#else
	public var useAlpha:Bool = false;
	#end
	
	public var initialized:Bool = false;
	
	public function new()
	{
		drawData = new Array<Float>();
	}
	
	inline public function reset():Void
	{
		atlas = null;
		initialized = false;
		position = 0;
	}
	
	public function dispose():Void
	{
		atlas = null;
		drawData = null;
		next = null;
	}
}