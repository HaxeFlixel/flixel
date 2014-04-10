package flixel.interfaces;

import flixel.FlxCamera;

interface IFlxBasic
{
	public var ID:Int;
	public var active(default, set):Bool;
	public var visible(default, set):Bool;
	public var alive(default, set):Bool;
	public var exists(default, set):Bool;

	public function draw():Void;
	public function update():Void;
	public function destroy():Void;
	
	public function kill():Void;
	public function revive():Void;
	
	public function toString():String;
}
