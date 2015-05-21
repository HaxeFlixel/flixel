package flixel.input.gamepad.id;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadID;
import flixel.input.gamepad.FlxGamepad.FlxGamepadAnalogStick;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 * 
 */
@:keep
class FlxGamepadAnalogList
{
	private var gamepad:FlxGamepad;
	
	public var LEFT_STICK_X   (get, never):Float; inline function get_LEFT_STICK_X()     { return getXAxis(FlxGamepadID.LEFT_ANALOG_STICK);      }
	public var LEFT_STICK_Y   (get, never):Float; inline function get_LEFT_STICK_Y()     { return getYAxis(FlxGamepadID.LEFT_ANALOG_STICK);      }
	public var RIGHT_STICK_X  (get, never):Float; inline function get_RIGHT_STICK_X()    { return getXAxis(FlxGamepadID.RIGHT_ANALOG_STICK);     }
	public var RIGHT_STICK_Y  (get, never):Float; inline function get_RIGHT_STICK_Y()    { return getYAxis(FlxGamepadID.RIGHT_ANALOG_STICK);     }
	public var LEFT_TRIGGER   (get, never):Float; inline function get_LEFT_TRIGGER()     { return getAxis (FlxGamepadID.LEFT_TRIGGER);           }
	public var RIGHT_TRIGGER  (get, never):Float; inline function get_RIGHT_TRIGGER()    { return getAxis (FlxGamepadID.RIGHT_TRIGGER);          }
	
	public function new(Gamepad:FlxGamepad)
	{
		gamepad = Gamepad;
	}
	
	private inline function getAxis(id:FlxGamepadID):Float
	{
		return gamepad.getAxis(id);
	}
	
	private inline function getXAxis(id:FlxGamepadID):Float
	{
		return gamepad.getXAxis(id);
	}
	
	private inline function getYAxis(id:FlxGamepadID):Float
	{
		return gamepad.getYAxis(id);
	}
}