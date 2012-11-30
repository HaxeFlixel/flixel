package org.flixel.system.layer;

class DrawStackItem
{
	public var atlas:Atlas;
	public var colored:Bool;
	public var blending:Int;
	public var drawData:Array<Float>;
	public var position:Int;
	
	public function new()
	{
		drawData = new Array<Float>();
	}
	
	public function dispose():Void
	{
		atlas = null;
		drawData = null;
	}
	
	public inline function match(item:DrawStackItem):Bool
	{
		return (atlas == item.atlas && colored == item.colored && blending == item.blending);
	}
}