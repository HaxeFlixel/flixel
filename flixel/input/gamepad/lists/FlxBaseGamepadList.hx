package flixel.input.gamepad.lists;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

class FlxBaseGamepadList
{
	var status:FlxInputState;
	var gamepad:FlxGamepad;

	public function new(status:FlxInputState, gamepad:FlxGamepad)
	{
		this.status = status;
		this.gamepad = gamepad;
	}

	inline function check(id:FlxGamepadInputID):Bool
	{
		return gamepad.checkStatus(id, status);
	}

	inline function checkRaw(id:Int):Bool
	{
		return gamepad.checkStatusRaw(id, status);
	}

	public var ANY(get, never):Bool;

	function get_ANY():Bool
	{
		return gamepad.anyButton(status);
	}

	public var ALL(get, never):Bool;

	function get_ALL():Bool
	{
		return gamepad.anyButton(status);
	}

	public var NONE(get, never):Bool;

	function get_NONE():Bool
	{
		return !ALL;
	}
}
