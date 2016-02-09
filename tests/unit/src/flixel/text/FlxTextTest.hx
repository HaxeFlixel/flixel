package flixel.text;

import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
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
	
	@Test // #1629
	function testSetFormatAlignmentReset()
	{
		text.alignment = FlxTextAlign.RIGHT;
		text.setFormat();
		
		Assert.areEqual(FlxTextAlign.RIGHT, text.alignment);
	}
	
	@Test // #1706
	function testGraphicInitializedAfterConstructor()
	{
		text = new FlxText(0, 0, 0, "Text");
		
		Assert.isNotNull(text.graphic);
		Assert.areNotEqual(0, text.frameWidth);
		Assert.areNotEqual(0, text.frameHeight);
	}
}