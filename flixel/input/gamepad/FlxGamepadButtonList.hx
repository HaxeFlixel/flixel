package flixel.input.gamepad;

import flixel.input.gamepad.FlxBaseGamepadButtonList;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.ButtonID;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 */
@:keep
class FlxGamepadButtonList extends FlxBaseGamepadButtonList
{
	public var A              (get, never):Bool; inline function get_A()                 { return check(ButtonID.A);                 }
	public var B              (get, never):Bool; inline function get_B()                 { return check(ButtonID.B);                 }
	public var X              (get, never):Bool; inline function get_X()                 { return check(ButtonID.X);                 }
	public var Y              (get, never):Bool; inline function get_Y()                 { return check(ButtonID.Y);                 }
	public var LEFT_SHOULDER  (get, never):Bool; inline function get_LEFT_SHOULDER()     { return check(ButtonID.LEFT_SHOULDER);     }
	public var RIGHT_SHOULDER (get, never):Bool; inline function get_RIGHT_SHOULDER()    { return check(ButtonID.RIGHT_SHOULDER);    }
	public var BACK           (get, never):Bool; inline function get_BACK()              { return check(ButtonID.BACK);              }
	public var START          (get, never):Bool; inline function get_START()             { return check(ButtonID.START);             }
	public var LEFT_STICK_BTN (get, never):Bool; inline function get_LEFT_STICK_BTN()    { return check(ButtonID.LEFT_STICK_BTN);    }
	public var RIGHT_STICK_BTN(get, never):Bool; inline function get_RIGHT_STICK_BTN()   { return check(ButtonID.RIGHT_STICK_BTN);   }
	public var GUIDE          (get, never):Bool; inline function get_GUIDE()             { return check(ButtonID.GUIDE);             }
	public var DPAD_UP        (get, never):Bool; inline function get_DPAD_UP()           { return check(ButtonID.DPAD_UP);           }
	public var DPAD_DOWN      (get, never):Bool; inline function get_DPAD_DOWN()         { return check(ButtonID.DPAD_DOWN);         }
	public var DPAD_LEFT      (get, never):Bool; inline function get_DPAD_LEFT()         { return check(ButtonID.DPAD_LEFT);         }
	public var DPAD_RIGHT     (get, never):Bool; inline function get_DPAD_RIGHT()        { return check(ButtonID.DPAD_RIGHT);        }
	public var LEFT_TRIGGER   (get, never):Bool; inline function get_LEFT_TRIGGER()      { return check(ButtonID.LEFT_TRIGGER);      }
	public var RIGHT_TRIGGER  (get, never):Bool; inline function get_RIGHT_TRIGGER()     { return check(ButtonID.RIGHT_TRIGGER);     }
	
	public function new(status:FlxInputState, gamepad:FlxGamepad)
	{
		super(status, gamepad);
	}
}