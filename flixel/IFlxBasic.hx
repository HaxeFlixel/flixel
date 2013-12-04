package flixel;

interface IFlxBasic
{
	public var ID:Int;
	public var cameras:Array<FlxCamera>;
	public var active(default, set):Bool;
	public var visible(default, set):Bool;
	public var alive(default, set):Bool;
	public var exists(default, set):Bool;

	public function draw():Void;
	public function update():Void;
	public function destroy():Void;
	
	public function kill():Void;
	public function revive():Void;

	#if !FLX_NO_DEBUG
	public var ignoreDrawDebug:Bool;
	public function drawDebug():Void;
	public function drawDebugOnCamera(?Camera:FlxCamera):Void;
	#end
	
	public function toString():String;
}
