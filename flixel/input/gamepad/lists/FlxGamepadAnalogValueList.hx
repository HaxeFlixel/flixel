package flixel.input.gamepad.lists;

import flixel.input.gamepad.FlxGamepadInputID;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 */
@:keep
class FlxGamepadAnalogValueList
{
	var gamepad:FlxGamepad;

	public var LEFT_STICK_X(get, never):Float;

	inline function get_LEFT_STICK_X()
		return getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);

	public var LEFT_STICK_Y(get, never):Float;

	inline function get_LEFT_STICK_Y()
		return getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);

	public var RIGHT_STICK_X(get, never):Float;

	inline function get_RIGHT_STICK_X()
		return getXAxis(FlxGamepadInputID.RIGHT_ANALOG_STICK);

	public var RIGHT_STICK_Y(get, never):Float;

	inline function get_RIGHT_STICK_Y()
		return getYAxis(FlxGamepadInputID.RIGHT_ANALOG_STICK);

	public var LEFT_TRIGGER(get, never):Float;

	inline function get_LEFT_TRIGGER()
		return getAxis(FlxGamepadInputID.LEFT_TRIGGER);

	public var RIGHT_TRIGGER(get, never):Float;

	inline function get_RIGHT_TRIGGER()
		return getAxis(FlxGamepadInputID.RIGHT_TRIGGER);

	public var POINTER_X(get, never):Float;

	inline function get_POINTER_X()
		return getAxis(FlxGamepadInputID.POINTER_X);

	public var POINTER_Y(get, never):Float;

	inline function get_POINTER_Y()
		return getAxis(FlxGamepadInputID.POINTER_Y);

	public function new(gamepad:FlxGamepad)
	{
		this.gamepad = gamepad;
	}

	inline function getAxis(id:FlxGamepadInputID):Float
	{
		return gamepad.getAxis(id);
	}

	inline function getXAxis(id:FlxGamepadInputID):Float
	{
		return gamepad.getXAxis(id);
	}

	inline function getYAxis(id:FlxGamepadInputID):Float
	{
		return gamepad.getYAxis(id);
	}
}
