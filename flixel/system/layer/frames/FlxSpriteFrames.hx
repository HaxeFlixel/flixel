package flixel.system.layer.frames;

class FlxSpriteFrames
{
	public var frames:Array<FlxFrame>;
<<<<<<< HEAD:src/org/flixel/system/layer/frames/FlxSpriteFrames.hx
=======
	public var framesHash:Map<String, FlxFrame>;
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/layer/frames/FlxSpriteFrames.hx
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
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/layer/frames/FlxSpriteFrames.hx
	}
	
	public function destroy():Void
	{
		frames = null;
		name = null;
	}	
}