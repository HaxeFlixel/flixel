package flixel.input.gamepad.lists;

import flixel.input.gamepad.FlxGamepad;

/**
 * A helper class for gamepad input. Returns X/Y analog coordinate values between `0.0` and `1.0`
 * Provides optimized gamepad button checking using direct array access.
 */
@:keep
class FlxGamepadPointerValueList
{
	var gamepad:FlxGamepad;

	/**
	 * Whether the current gamepad model supports any pointer features (IR Camera, touch surface, etc.).
	 */
	@:allow(flixel.input.gamepad.FlxGamepad)
	public var isSupported(get, never):Bool;

	/**
	 * Horizontal position (`0.0` to `1.0`) on the touch-surface or pointer-space.
	 */
	public var X(get, never):Float;

	inline function get_X()
		return getAxis(FlxGamepadInputID.POINTER_X);

	/**
	 * Vertical position (`0.0` to `1.0`) on the touch-surface or pointer-space.
	 */
	public var Y(get, never):Float;

	inline function get_Y()
		return getAxis(FlxGamepadInputID.POINTER_Y);

	public function new(gamepad:FlxGamepad)
	{
		this.gamepad = gamepad;
	}

	inline function getAxis(id:FlxGamepadInputID):Float
	{
		if (!isSupported)
			return 0;
		return gamepad.getAxis(id);
	}

	inline function get_isSupported():Bool
	{
		return gamepad.mapping.supportsPointer;
	}
}
