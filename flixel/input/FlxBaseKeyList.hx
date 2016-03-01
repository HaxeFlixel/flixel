package flixel.input;

import flixel.input.FlxInput;
import flixel.input.FlxKeyManager;

class FlxBaseKeyList
{
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
	
	public var ANY(get, never):Bool; 
	
	private function get_ANY():Bool
	{
		for (key in keyManager._keyListArray)
		{
			if (key != null)
			{
				if (check(key.ID))
				{
					return true;
				}
			}
		}
		
		return false;
	}
}