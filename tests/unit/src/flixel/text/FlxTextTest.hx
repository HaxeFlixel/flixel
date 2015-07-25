package flixel.text;

import flixel.text.FlxText;
import massive.munit.Assert;

class FlxTextTest extends FlxTest
{
	var text:FlxText;
	
	@Before
	function before():Void
	{
		text = new FlxText();
		destroyable = text;
	}
	
	@Test
	function testFontDefaultValue():Void
	{
		Assert.areEqual(text.font, "Nokia Cellphone FC Small");
	}
}