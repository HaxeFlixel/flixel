package flixel.system.layer.frames;

class FlxSpriteFrames
{
	public var frames:Array<FlxFrame>;
	public var framesHash:Map<String, FlxFrame>;
	public var name:String;
	
	public function new(name:String)
	{
		this.name = name;
		frames = [];
		framesHash = new Map<String, FlxFrame>();
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
	}	
}