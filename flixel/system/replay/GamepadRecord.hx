package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

/**
 * A helper class for the frame records, part of the replay/demo/recording system.
 */
class GamepadRecord
{
	/**
	 * The ID of the gamepad being recorded.
	 */
	public var gamepadID(default, null):Int;

	/**
	 * An array referring to digital gamepad buttons and it's state.
	 */
	public var buttons(default, null):Array<CodeValuePair>;
	/**
	 * An array referring to analog gamepad inputs and their state.
	 */
	public var analog(default, null):Array<IntegerFloatPair>;

	/**
	 * Instantiate a new gamepad input record.
	 *
	 * @param   GamepadID	The ID of the gamepad being recorded
	 * @param	Buttons		An array referring to digital gamepad buttons and it's state.
	 */
	public function new(gamepadID:Int, buttons:Array<CodeValuePair>, analog:Array<IntegerFloatPair>)
	{
		this.gamepadID = gamepadID;
		this.buttons = buttons;	
		this.analog = analog;
	}
}
