package flixel.text;

import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;
import massive.munit.Assert;

class FlxBitmapTextTest extends FlxTest
{
	var text:FlxBitmapText;

	@Before
	function before():Void
	{
		text = new FlxBitmapText();
		destroyable = text;
	}
	
	@Test // #1526 and #2750
	function testCreateSpriteSkipPosition()
	{
		final text1 = new FlxBitmapText("test");
		final text2 = new FlxBitmapText(FlxBitmapFont.getDefaultFont());

		Assert.areEqual(0, text1.x);
		Assert.areEqual(0, text1.y);
		Assert.areEqual(0, text2.x);
		Assert.areEqual(0, text2.y);

		Assert.isNotNull(text1.text);
		Assert.areEqual(text1.font, text2.font);
	}
}
