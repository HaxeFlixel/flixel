package flixel.system.layer.frames;

class FlxSpriteFrames
{
	public var frames:Array<FlxFrame>;
<<<<<<< HEAD:src/org/flixel/system/layer/frames/FlxSpriteFrames.hx
=======
	public var framesHash:Map<String, FlxFrame>;
>>>>>>> origin/dev:flixel/system/layer/frames/FlxSpriteFrames.hx
	public var name:String;
	
	public function new(name:String)
	{
		this.name = name;
		frames = [];
<<<<<<< HEAD:src/org/flixel/system/layer/frames/FlxSpriteFrames.hx
=======
		framesHash = new Map<String, FlxFrame>();
	}
	
	public function addFrame(frame:FlxFrame):Void
	{
		frames.push(frame);
		framesHash.set(frame.name, frame);
>>>>>>> origin/dev:flixel/system/layer/frames/FlxSpriteFrames.hx
	}
	
	public function destroy():Void
	{
		frames = null;
		name = null;
	}	
}