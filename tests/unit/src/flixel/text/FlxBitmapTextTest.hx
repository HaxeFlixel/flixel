package flixel.text;

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