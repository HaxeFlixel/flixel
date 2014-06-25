package flixel.input.android;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.FlxInput.FlxInputState;

#if android
import flixel.input.android.FlxAndroidKeys;
#end

/**
 * A helper class for keyboard input.
 * Provides optimized key checking using direct array access.
 */
class FlxAndroidKeyList
{
	#if android
	private var checkStatus:FlxInputState;
	
	public function new(checkStatus:FlxInputState)
	{
		this.checkStatus = checkStatus;
	}
	
	public var BACK          (get, never):Bool; inline function get_BACK()           { return check(FlxAndroidKey.BACK);    }
	public var MENU          (get, never):Bool; inline function get_MENU()           { return check(FlxAndroidKey.MENU);    }
	
	public var ANY(get, never):Bool; 
	
	private function get_ANY():Bool
	{
		var key:FlxAndroidKeyInput = null;
		var keyCode:Int = FlxAndroidKeys.TOTAL;
		while (keyCode-- >= 0)
		{
			key = FlxG.android._keyList[keyCode];
			if (key != null)
			{
				if (check(keyCode))
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	private inline function check(keyCode:Int):Bool
	{
		return FlxG.android.checkStatus(keyCode, checkStatus);
	}
	#end
}