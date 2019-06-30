package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

/**
 * A helper class for the frame records, part of the replay/demo/recording system.
 */
class MouseRecord
{
	public var x(default, null):Int;
	public var y(default, null):Int;

	/**
	 * The state of the left mouse button.
	 */
	public var button(default, null):FlxInputState;

	/**
	 * The state of the mouse wheel.
	 */
	public var wheel(default, null):Int;

	/**
	 * Instantiate a new mouse input record.
	 *
	 * @param   X        The main X value of the mouse in screen space.
	 * @param   Y        The main Y value of the mouse in screen space.
	 * @param   Button   The state of the left mouse button.
	 * @param   Wheel    The state of the mouse wheel.
	 */
	public function new(x:Int, y:Int, button:FlxInputState, wheel:Int)
	{
		this.x = x;
		this.y = y;
		this.button = button;
		this.wheel = wheel;
	}
}
