package flixel.text;

import flixel.text.FlxBitmapText;

class FlxBitmapTextTest extends FlxTest
{
	var text:FlxBitmapText;
	
	@Before
	function before():Void
	{
		text = new FlxBitmapText();
		destroyable = text;
	}
}