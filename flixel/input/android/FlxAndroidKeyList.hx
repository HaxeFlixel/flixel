package flixel.input.android;

#if android
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.android.FlxAndroidKeys;

/**
 * A helper class for Android key input (back button and menu button).
 * Provides optimized key checking using direct array access.
 */
class FlxAndroidKeyList
{
	private var checkStatus:FlxInputState;
	
	public function new(checkStatus:FlxInputState)
	{
		this.checkStatus = checkStatus;
	}
	
	public var BACK          (get, never):Bool; inline function get_BACK()           { return check(FlxAndroidKey.BACK);    }
	public var MENU          (get, never):Bool; inline function get_MENU()           { return check(FlxAndroidKey.MENU);    }
	public var ANY           (get, never):Bool; inline function get_ANY()            { return BACK || MENU; }
	
	private inline function check(keyCode:Int):Bool
	{
		return FlxG.android.checkStatus(keyCode, checkStatus);
	}
}
#end