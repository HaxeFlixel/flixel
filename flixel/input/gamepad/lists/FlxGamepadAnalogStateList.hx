package flixel.input.gamepad.lists;

import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.FlxInput.FlxAnalogState;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 */
@:keep
class FlxGamepadAnalogStateList
{
	var gamepad:FlxGamepad;
	var status:FlxAnalogState;

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

	public function new(status:FlxAnalogState, gamepad:FlxGamepad)
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
		
		var x = getInput(stick.x);
		var y = getInput(stick.y);
		
		return switch (status)
		{
			case MOVED:
				return x.moved || y.moved;
			case STOPPED:
				return x.stopped && y.stopped;
			case JUST_MOVED:
				return (x.justMoved && (y.justMoved || y.current == STOPPED))
					|| (y.justMoved && (x.justMoved || x.current == STOPPED));
			case JUST_STOPPED:
				return (x.justStopped && y.stopped) || (y.justStopped && x.stopped);
		}
	}

	inline function checkX(id:FlxGamepadInputID):Bool
	{
		var stick = gamepad.mapping.getAnalogStick(id);
		if (stick == null)
			return false;
		return check(stick.x, status);
	}

	inline function checkY(id:FlxGamepadInputID):Bool
	{
		var stick = gamepad.mapping.getAnalogStick(id);
		if (stick == null)
			return false;
		return check(stick.y, status);
	}
	
	inline function getRawID(id:Int):Int
	{
		#if FLX_JOYSTICK_API
		// in legacy this is the axis index and not the RawID,
		// so we do a reverse lookup to get the rawID for a "fake" button
		return gamepad.mapping.axisIndexToRawID(id);
		#else
		return id;
		#end
	}
	
	inline function check(id:Int, status:FlxAnalogState):Bool
	{
		return gamepad.checkAnalogStatusRaw(getRawID(id), status);
	}
	
	inline function getInput(id:Int):FlxGamepadAxis
	{
		return gamepad.getAxisInput(getRawID(id));
	}
}
