package flixel.text;

import flixel.text.FlxText;
import helper.TestUtil;
import massive.munit.Assert;

class FlxTextTest extends FlxTest
{
	var text:FlxText;
	
	@Before
	function before():Void
	{
		text = new FlxText();
	}
	
	@Test
	function testFontDefaultValue():Void
	{
		Assert.areEqual(text.font, "Nokia Cellphone FC Small");
	}
	
	@Test
	function testDestroy():Void
	{
		TestUtil.testDestroy(text);
	}
}