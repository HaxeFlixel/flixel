package flixel.input.gamepad.lists;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

class FlxBaseGamepadList
{
	private var status:FlxInputState;
	private var gamepad:FlxGamepad;
	
	public function new(status:FlxInputState, gamepad:FlxGamepad)
	{
		this.status = status;
		this.gamepad = gamepad;
	}
	
	private inline function check(id:FlxGamepadInputID):Bool
	{
		return gamepad.checkStatus(id, status);
	}
	
	private inline function checkRaw(id:Int):Bool
	{
		return gamepad.checkStatusRaw(id, status);
	}
	
	public var ANY(get, never):Bool; 
	
	private function get_ANY():Bool
	{
		for (button in gamepad.buttons)
		{
			if (button != null && checkRaw(button.ID))
			{
				return true;
			}
		}
		
		return false;
	}
}