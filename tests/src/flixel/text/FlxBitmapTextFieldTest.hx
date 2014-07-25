package flixel.text;

import flixel.text.FlxBitmapTextField;

class FlxBitmapTextFieldTest extends FlxTest
{
	var text:FlxBitmapTextField;
	
	@Before
	function before():Void
	{
		text = new FlxBitmapTextField();
		destroyable = text;
	}
}