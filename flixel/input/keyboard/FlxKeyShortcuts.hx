package flixel.input.keyboard;

import flixel.FlxG;

/**
 * A helper class for keyboard input.
 */
class FlxKeyShortcuts
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
		pressed = new FlxKeyList(FlxKey.PRESSED);
		justPressed = new FlxKeyList(FlxKey.JUST_PRESSED);
		justReleased = new FlxKeyList(FlxKey.JUST_RELEASED);
	}
}