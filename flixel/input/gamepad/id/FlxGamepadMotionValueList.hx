package flixel.input.gamepad.id;
import flixel.input.gamepad.FlxGamepad;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 */
@:keep
class FlxGamepadMotionValueList
{
	private var gamepad:FlxGamepad;
	
	@:allow(flixel.input.gamepad.FlxGamepad)
	public var available(default, null):Bool = true;
	
	public var TILT_PITCH   (get, never):Float; inline function get_TILT_PITCH() { return getAxis (FlxGamepadInputID.TILT_PITCH);}
	public var TILT_ROLL    (get, never):Float; inline function get_TILT_ROLL()  { return getAxis (FlxGamepadInputID.TILT_ROLL); }
	public var TILT_YAW     (get, never):Float; inline function get_TILT_YAW()   { return getAxis (FlxGamepadInputID.TILT_YAW);  }
	
	public var TRANSLATE_UP_DOWN    (get, never):Float; inline function get_TRANSLATE_UP_DOWN()    { return getAxis (FlxGamepadInputID.TRANSLATE_UP_DOWN);    }
	public var TRANSLATE_FORE_BACK  (get, never):Float; inline function get_TRANSLATE_FORE_BACK()  { return getAxis (FlxGamepadInputID.TRANSLATE_FORE_BACK);  }
	public var TRANSLATE_LEFT_RIGHT (get, never):Float; inline function get_TRANSLATE_LEFT_RIGHT() { return getAxis (FlxGamepadInputID.TRANSLATE_LEFT_RIGHT); }
	
	public function new(gamepad:FlxGamepad)
	{
		this.gamepad = gamepad;
	}
	
	private inline function getAxis(id:FlxGamepadInputID):Float
	{
		if (!available) return 0;
		return gamepad.getAxis(id);
	}
}