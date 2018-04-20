package flixel.input;

import flixel.input.FlxInput.FlxInputState;

class FlxBaseKeyList
{
	public var ANY(get, never):Bool;
	
	private var status:FlxInputState;
	private var keyManager:FlxKeyManager<Dynamic, Dynamic>;
	
	public function new(status:FlxInputState, keyManager:FlxKeyManager<Dynamic, Dynamic>)
	{
		this.status = status;
		this.keyManager = keyManager;
	}
	
	private inline function check(keyCode:Int):Bool
	{
		return keyManager.checkStatus(keyCode, status);
	}
	
	private function get_ANY():Bool
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
