package flixel.input.gamepad.lists;

import flixel.input.gamepad.FlxGamepad;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 */
@:keep
class FlxGamepadAnalogList
{
	public var value(default, null):FlxGamepadAnalogValueList;
	public var justMoved(default, null):FlxGamepadAnalogStateList;
	public var justReleased(default, null):FlxGamepadAnalogStateList;

	public function new(gamepad:FlxGamepad)
	{
		value = new FlxGamepadAnalogValueList(gamepad);
		justMoved = new FlxGamepadAnalogStateList(JUST_PRESSED, gamepad);
		justReleased = new FlxGamepadAnalogStateList(JUST_RELEASED, gamepad);
	}
}
