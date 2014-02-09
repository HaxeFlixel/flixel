package flixel.system.replay;

import flixel.util.FlxPoint;

/**
 * A helper class for the frame records, part of the replay/demo/recording system.
 */
class MouseRecord extends FlxPoint
{
	/**
	 * The state of the left mouse button.
	 */
	public var button:Int;
	/**
	 * The state of the mouse wheel.
	 */
	public var wheel:Int;
	
	/**
	 * Instantiate a new mouse input record.
	 * 
	 * @param   X        The main X value of the mouse in screen space.
	 * @param   Y        The main Y value of the mouse in screen space.
	 * @param   Button   The state of the left mouse button.
	 * @param   Wheel    The state of the mouse wheel.
	 */
	public function new(X:Int, Y:Int, Button:Int, Wheel:Int)
	{
		super(X, Y);
		
		button = Button;
		wheel = Wheel;
	}
}