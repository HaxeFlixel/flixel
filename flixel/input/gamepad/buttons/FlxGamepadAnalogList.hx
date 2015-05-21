package flixel.input.gamepad.buttons;

import flixel.input.gamepad.buttons.FlxBaseGamepadButtonList;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadButtonID;
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
	
	public var LEFT_STICK_X   (get, never):Float; inline function get_LEFT_STICK_X()     { return getXAxis(FlxGamepadButtonID.LEFT_ANALOG_STICK);      }
	public var LEFT_STICK_Y   (get, never):Float; inline function get_LEFT_STICK_Y()     { return getYAxis(FlxGamepadButtonID.LEFT_ANALOG_STICK);      }
	public var RIGHT_STICK_X  (get, never):Float; inline function get_RIGHT_STICK_X()    { return getXAxis(FlxGamepadButtonID.RIGHT_ANALOG_STICK);     }
	public var RIGHT_STICK_Y  (get, never):Float; inline function get_RIGHT_STICK_Y()    { return getYAxis(FlxGamepadButtonID.RIGHT_ANALOG_STICK);     }
	public var LEFT_TRIGGER   (get, never):Float; inline function get_LEFT_TRIGGER()     { return getAxis (FlxGamepadButtonID.LEFT_TRIGGER);           }
	public var RIGHT_TRIGGER  (get, never):Float; inline function get_RIGHT_TRIGGER()    { return getAxis (FlxGamepadButtonID.RIGHT_TRIGGER);          }
	
	public function new(Gamepad:FlxGamepad)
	{
		gamepad = Gamepad;
	}
	
	private inline function getAxis(id:FlxGamepadButtonID):Float
	{
		return gamepad.getAxis(id);
	}
	
	private inline function getXAxis(id:FlxGamepadButtonID):Float
	{
		return gamepad.getXAxis(id);
	}
	
	private inline function getYAxis(id:FlxGamepadButtonID):Float
	{
		return gamepad.getYAxis(id);
	}
}