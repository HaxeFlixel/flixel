package flixel.system.layer.frames;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class FlxSpriteFrames implements IFlxDestroyable
{
	public var frames = new Array<FlxFrame>();
	public var framesHash = new Map<String, FlxFrame>();
	public var name:String;
	
	@:isVar
	public var original(get, set):FlxSpriteFrames;
	
	public function new(name:String)
	{
		this.name = name;
	}
	
	public function addFrame(frame:FlxFrame):Void
	{
		frames.push(frame);
		framesHash.set(frame.name, frame);
	}
	
	public function destroy():Void
	{
		frames = null;
		framesHash = null;
		name = null;
		original = null;
	}
	
	private function set_original(value:FlxSpriteFrames):FlxSpriteFrames
	{
		return original = value;
	}
	
	private function get_original():FlxSpriteFrames
	{
		if (original != null)
		{
			var originalFrames:FlxSpriteFrames = original.original;
			if (originalFrames != null)
			{
				return originalFrames;
			}
		}
		
		return original;
	}
}