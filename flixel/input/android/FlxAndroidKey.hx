package flixel.input.android;

#if android
import flixel.system.macros.FlxMacroUtil;

/**
 * Maps enum values and strings to integer keycodes.
 */
enum abstract FlxAndroidKey(Int) from Int to Int
{
	public static var fromStringMap(default, null):Map<String, FlxAndroidKey> = FlxMacroUtil.buildMap("flixel.input.android.FlxAndroidKey");
	public static var toStringMap(default, null):Map<FlxAndroidKey, String> = FlxMacroUtil.buildMap("flixel.input.android.FlxAndroidKey", true);
	var ANY = -2;
	var NONE = -1;
	var MENU = 0x4000010C;
	var BACK = 0x4000010E;

	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}

	@:to
	public inline function toString():String
	{
		return toStringMap.get(this);
	}
}
#end
