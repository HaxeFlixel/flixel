package flixel.input.android;

#if android
/**
 * Keeps track of Android system key presses (Back/Menu)
 */
class FlxAndroidKeys extends FlxKeyManager<FlxAndroidKey, FlxAndroidKeyList>
{
	public function new()
	{
		super(FlxAndroidKeyList.new);

		// BACK button
		var back:FlxAndroidKeyInput = new FlxAndroidKeyInput(FlxAndroidKey.BACK);
		_keyListArray.push(back);
		_keyListMap.set(back.ID, back);

		// MENU button
		var menu:FlxAndroidKeyInput = new FlxAndroidKeyInput(FlxAndroidKey.MENU);
		_keyListArray.push(menu);
		_keyListMap.set(menu.ID, menu);
	}
}

typedef FlxAndroidKeyInput = FlxInput<FlxAndroidKey>;
#end
