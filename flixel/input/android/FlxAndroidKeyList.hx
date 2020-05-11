package flixel.input.android;

#if android
import flixel.input.FlxBaseKeyList;

/**
 * A helper class for Android key input (back button and menu button).
 * Provides optimized key checking using direct array access.
 */
class FlxAndroidKeyList extends FlxBaseKeyList
{
	public var BACK(get, never):Bool;

	inline function get_BACK()
		return check(FlxAndroidKey.BACK);

	public var MENU(get, never):Bool;

	inline function get_MENU()
		return check(FlxAndroidKey.MENU);
}
#end
