package flixel.input;

import flixel.input.FlxInput.FlxInputState;

class FlxBaseKeyList
{
	public var ANY(get, never):Bool;

	/**
	 * @since 4.8.0
	 */
	public var NONE(get, never):Bool;

	var status:FlxInputState;
	var keyManager:FlxKeyManager<Dynamic, Dynamic>;

	public function new(status:FlxInputState, keyManager:FlxKeyManager<Dynamic, Dynamic>)
	{
		this.status = status;
		this.keyManager = keyManager;
	}

	inline function check(keyCode:Int):Bool
	{
		return keyManager.checkStatusUnsafe(keyCode, status);
	}

	function get_ANY():Bool
	{
		for (key in keyManager._keyListArray)
		{
			if (key != null && check(key.ID))
			{
				return true;
			}
		}
		return false;
	}

	function get_NONE():Bool
	{
		for (key in keyManager._keyListArray)
		{
			if (key != null && check(key.ID))
			{
				return false;
			}
		}
		return true;
	}
}
