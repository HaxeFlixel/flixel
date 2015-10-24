package flixel.text;

import flixel.text.FlxText;
import massive.munit.Assert;

class FlxTextTest extends FlxTest
{
	var text:FlxText;
	
	@Before
	function before()
	{
		text = new FlxText();
		destroyable = text;
	}
	
	@Test
	function testFontDefaultValue()
	{
		Assert.areEqual(text.font, "Nokia Cellphone FC Small");
	}
	
	#if neko
	@Test // #1641
	function testNullBorderColorNoCrash()
	{
		text.borderColor = null;
	}
	#end
}