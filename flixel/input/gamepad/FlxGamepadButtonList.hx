package flixel.input.gamepad;

import flixel.input.gamepad.FlxBaseGamepadButtonList;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadButtonID;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 */
@:keep
class FlxGamepadButtonList extends FlxBaseGamepadButtonList
{
	public var A              (get, never):Bool; inline function get_A()                 { return check(FlxGamepadButtonID.A);                 }
	public var B              (get, never):Bool; inline function get_B()                 { return check(FlxGamepadButtonID.B);                 }
	public var X              (get, never):Bool; inline function get_X()                 { return check(FlxGamepadButtonID.X);                 }
	public var Y              (get, never):Bool; inline function get_Y()                 { return check(FlxGamepadButtonID.Y);                 }
	public var LEFT_SHOULDER  (get, never):Bool; inline function get_LEFT_SHOULDER()     { return check(FlxGamepadButtonID.LEFT_SHOULDER);     }
	public var RIGHT_SHOULDER (get, never):Bool; inline function get_RIGHT_SHOULDER()    { return check(FlxGamepadButtonID.RIGHT_SHOULDER);    }
	public var BACK           (get, never):Bool; inline function get_BACK()              { return check(FlxGamepadButtonID.BACK);              }
	public var START          (get, never):Bool; inline function get_START()             { return check(FlxGamepadButtonID.START);             }
	public var LEFT_STICK_BTN (get, never):Bool; inline function get_LEFT_STICK_BTN()    { return check(FlxGamepadButtonID.LEFT_STICK_BTN);    }
	public var RIGHT_STICK_BTN(get, never):Bool; inline function get_RIGHT_STICK_BTN()   { return check(FlxGamepadButtonID.RIGHT_STICK_BTN);   }
	public var GUIDE          (get, never):Bool; inline function get_GUIDE()             { return check(FlxGamepadButtonID.GUIDE);             }
	public var DPAD_UP        (get, never):Bool; inline function get_DPAD_UP()           { return check(FlxGamepadButtonID.DPAD_UP);           }
	public var DPAD_DOWN      (get, never):Bool; inline function get_DPAD_DOWN()         { return check(FlxGamepadButtonID.DPAD_DOWN);         }
	public var DPAD_LEFT      (get, never):Bool; inline function get_DPAD_LEFT()         { return check(FlxGamepadButtonID.DPAD_LEFT);         }
	public var DPAD_RIGHT     (get, never):Bool; inline function get_DPAD_RIGHT()        { return check(FlxGamepadButtonID.DPAD_RIGHT);        }
	public var LEFT_TRIGGER   (get, never):Bool; inline function get_LEFT_TRIGGER()      { return check(FlxGamepadButtonID.LEFT_TRIGGER);      }
	public var RIGHT_TRIGGER  (get, never):Bool; inline function get_RIGHT_TRIGGER()     { return check(FlxGamepadButtonID.RIGHT_TRIGGER);     }
	
	public function new(status:FlxInputState, gamepad:FlxGamepad)
	{
		super(status, gamepad);
	}
}