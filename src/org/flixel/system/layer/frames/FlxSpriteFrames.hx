package org.flixel.system.layer.frames;

class FlxSpriteFrames
{
	public var frames:Array<FlxFrame>;
	public var name:String;
	
	public function new(name:String)
	{
		this.name = name;
		frames = [];
	}
	
	public function destroy():Void
	{
		frames = null;
		name = null;
	}	
}