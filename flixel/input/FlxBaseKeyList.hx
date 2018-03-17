package flixel.input;

import flixel.input.FlxInput.FlxInputState;

class FlxBaseKeyList
{
	var status:FlxInputState;
	var keyManager:FlxKeyManager<Dynamic, Dynamic>;

	public function new(status:FlxInputState, keyManager:FlxKeyManager<Dynamic, Dynamic>)
	{
		this.status = status;
		this.keyManager = keyManager;
	}

	inline function check(keyCode:Int):Bool
	{
		return keyManager.checkStatus(keyCode, status);
	}

	public var ANY(get, never):Bool;

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
}