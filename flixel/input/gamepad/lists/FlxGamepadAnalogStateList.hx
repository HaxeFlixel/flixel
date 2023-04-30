package flixel.input.gamepad.lists;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 */
@:keep
class FlxGamepadAnalogStateList
{
	var gamepad:FlxGamepad;
	var status:FlxInputState;

	public var LEFT_STICK(get, never):Bool;

	inline function get_LEFT_STICK()
		return checkXY(FlxGamepadInputID.LEFT_ANALOG_STICK);

	public var LEFT_STICK_X(get, never):Bool;

	inline function get_LEFT_STICK_X()
		return checkX(FlxGamepadInputID.LEFT_ANALOG_STICK);

	public var LEFT_STICK_Y(get, never):Bool;

	inline function get_LEFT_STICK_Y()
		return checkY(FlxGamepadInputID.LEFT_ANALOG_STICK);

	public var RIGHT_STICK(get, never):Bool;

	inline function get_RIGHT_STICK()
		return checkXY(FlxGamepadInputID.RIGHT_ANALOG_STICK);

	public var RIGHT_STICK_X(get, never):Bool;

	inline function get_RIGHT_STICK_X()
		return checkX(FlxGamepadInputID.RIGHT_ANALOG_STICK);

	public var RIGHT_STICK_Y(get, never):Bool;

	inline function get_RIGHT_STICK_Y()
		return checkY(FlxGamepadInputID.RIGHT_ANALOG_STICK);

	public function new(status:FlxInputState, gamepad:FlxGamepad)
	{
		this.status = status;
		this.gamepad = gamepad;
	}

	/**
	 * Checks if the entire stick itself is in the given state
	 */
	function checkXY(id:FlxGamepadInputID):Bool
	{
		var stick = gamepad.mapping.getAnalogStick(id);
		if (stick == null)
			return false;

		// no matter what status we're checking for, we do two tests:
		// easy : both values are exactly the same (both JUST_PRESSED, both JUST_RELEASED)
		// !easy: one axis == status, other axis == RELEASED || JUST_RELEASED

		// if we're checking for JUST_RELEASED: one axis must be released and the other not pressed  (you just released one axis, and the other one is not pressed either)
		// if we're checking for JUST_PRESSED:  one axis must be pressed  and the other not pressed  (it was released before, but now you have just moved it)

		var xVal = checkRaw(stick.x, status);
		var yVal = checkRaw(stick.y, status);

		if (xVal && yVal)
		{
			return true;
		}

		if (xVal)
		{
			var yReleased = checkRaw(stick.y, RELEASED);
			var yJustReleased = checkRaw(stick.y, JUST_RELEASED);
			if (yReleased || yJustReleased)
			{
				return true;
			}
		}

		if (yVal)
		{
			var xReleased = checkRaw(stick.x, RELEASED);
			var xJustReleased = checkRaw(stick.x, JUST_RELEASED);
			if (xReleased || xJustReleased)
			{
				return true;
			}
		}

		return false;
	}

	inline function checkX(id:FlxGamepadInputID):Bool
	{
		var stick = gamepad.mapping.getAnalogStick(id);
		if (stick == null)
			return false;
		return checkRaw(stick.x, status);
	}

	inline function checkY(id:FlxGamepadInputID):Bool
	{
		var stick = gamepad.mapping.getAnalogStick(id);
		if (stick == null)
			return false;
		return checkRaw(stick.y, status);
	}

	inline function checkRaw(RawID:Int, Status:FlxInputState):Bool
	{
		#if FLX_JOYSTICK_API
		// in legacy this is the axis index and not the RawID,
		// so we do a reverse lookup to get the rawID for a "fake" button
		RawID = gamepad.mapping.axisIndexToRawID(RawID);
		#end
		return gamepad.checkStatusRaw(RawID, Status);
	}
}
