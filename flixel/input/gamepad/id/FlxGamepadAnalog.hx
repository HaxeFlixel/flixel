package flixel.input.gamepad.id;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad.FlxGamepadAnalogStick;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 * 
 */
@:keep
class FlxGamepadAnalog
{
	public var value(default, null):FlxGamepadAnalogList;
	public var justMoved(default, null):FlxGamepadAnalogStateList;
	public var justReleased(default, null):FlxGamepadAnalogStateList;
	
	public function new(gamepad:FlxGamepad)
	{
		value        = new FlxGamepadAnalogList(gamepad);
		justMoved    = new FlxGamepadAnalogStateList(JUST_PRESSED,  gamepad);
		justReleased = new FlxGamepadAnalogStateList(JUST_RELEASED, gamepad);
	}
}