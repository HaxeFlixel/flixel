package flixel.input.android;

import flixel.FlxG;

/**
 * A helper class for android input.
 */
class FlxAndroidKeyList
{
	#if !FLX_NO_KEYBOARD
	public function new(CheckFunction:String->Bool)
	{
		check = CheckFunction;
	}
	
	private var check:String->Bool;
	
	public var BACK(get, never):Bool; inline function get_BACK() { return check("BACK"); }
	public var MENU(get, never):Bool; inline function get_MENU() { return check("MENU"); }
	#end
}
