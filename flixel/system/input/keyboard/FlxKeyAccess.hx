package flixel.system.input.keyboard;

import flixel.FlxG;

/**
 * A helper class for keyboard input.
 */
class FlxKeyAccess
{
	/**
	 * Helper class to check if a keys is pressed.
	 */
	public var pressed:FlxKeyList;
	/**
	 * Helper class to check if a keys was just pressed.
	 */
	public var justPressed:FlxKeyList;
	/**
	 * Helper class to check if a keys was just released.
	 */
	public var justReleased:FlxKeyList;
	
	public function new()
	{
		pressed = new FlxKeyList(FlxG.keyboard.pressed);
		justPressed = new FlxKeyList(FlxG.keyboard.justPressed);
		justReleased = new FlxKeyList(FlxG.keyboard.justReleased);
	}
}