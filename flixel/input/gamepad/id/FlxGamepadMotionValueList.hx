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
	public var isSupported(default, null):Bool = true;
	
	public var TILT_PITCH   (get, never):Float; inline function get_TILT_PITCH() { return getAxis (FlxGamepadInputID.TILT_PITCH);}
	public var TILT_ROLL    (get, never):Float; inline function get_TILT_ROLL()  { return getAxis (FlxGamepadInputID.TILT_ROLL); }
	
	public function new(gamepad:FlxGamepad)
	{
		this.gamepad = gamepad;
	}
	
	private inline function getAxis(id:FlxGamepadInputID):Float
	{
		if (!isSupported) return 0;
		return gamepad.getAxis(id);
	}
}