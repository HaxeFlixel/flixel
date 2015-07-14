package flixel.input.gamepad.id;
import flixel.input.gamepad.FlxGamepad;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 */
@:keep
class FlxGamepadPointerValueList
{
	private var gamepad:FlxGamepad;
	
	@:allow(flixel.input.gamepad.FlxGamepad)
	public var available(default, null):Bool = true;
	
	public var X        (get, never):Float; inline function get_X()        { return getAxis (FlxGamepadInputID.POINTER_X);      }
	public var Y        (get, never):Float; inline function get_Y()        { return getAxis (FlxGamepadInputID.POINTER_Y);      }
	
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