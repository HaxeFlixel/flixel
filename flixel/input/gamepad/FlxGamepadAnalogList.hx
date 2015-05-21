package flixel.input.gamepad;

import flixel.input.gamepad.FlxBaseGamepadButtonList;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.ButtonID;
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
	
	public var LEFT_STICK_X   (get, never):Float; inline function get_LEFT_STICK_X()     { return getXAxis(ButtonID.LEFT_ANALOG_STICK);      }
	public var LEFT_STICK_Y   (get, never):Float; inline function get_LEFT_STICK_Y()     { return getYAxis(ButtonID.LEFT_ANALOG_STICK);      }
	public var RIGHT_STICK_X  (get, never):Float; inline function get_RIGHT_STICK_X()    { return getXAxis(ButtonID.RIGHT_ANALOG_STICK);     }
	public var RIGHT_STICK_Y  (get, never):Float; inline function get_RIGHT_STICK_Y()    { return getYAxis(ButtonID.RIGHT_ANALOG_STICK);     }
	public var LEFT_TRIGGER   (get, never):Float; inline function get_LEFT_TRIGGER()     { return getAxis (ButtonID.LEFT_TRIGGER);           }
	public var RIGHT_TRIGGER  (get, never):Float; inline function get_RIGHT_TRIGGER()    { return getAxis (ButtonID.RIGHT_TRIGGER);          }
	
	public function new(Gamepad:FlxGamepad)
	{
		gamepad = Gamepad;
	}
	
	private inline function getAxis(id:ButtonID):Float
	{
		return gamepad.getAxis(id);
	}
	
	private inline function getXAxis(id:ButtonID):Float
	{
		return gamepad.getXAxis(id);
	}
	
	private inline function getYAxis(id:ButtonID):Float
	{
		return gamepad.getYAxis(id);
	}
}