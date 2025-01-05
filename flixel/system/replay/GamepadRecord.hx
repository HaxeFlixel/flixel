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
	 * Instantiate a new mouse input record.
	 *
	 * @param   GamepadID	The ID of the gamepad being recorded
	 * @param	Buttons		An array referring to digital gamepad buttons and it's state.
	 */
	public function new(gamepadID:Int, buttons:Array<CodeValuePair>)
	{
		this.gamepadID =gamepadID;
		this.buttons = buttons;	
	}
}
