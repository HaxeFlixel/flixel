package flixel.text;

import flixel.system.FlxAssets;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
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
		Assert.areEqual(text.font, FlxAssets.FONT_DEFAULT);
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

	#if !html5
	@Test // #1422
	function testBlurryLines()
	{
		text = new FlxText(0, 0, 120, "Text with some blur\none line without blur\nand another with blur");
		text.alignment = FlxTextAlign.CENTER;
		text.drawFrame();

		var graphic = text.updateFramePixels();
		for (x in 0...graphic.width)
		{
			for (y in 0...graphic.height)
			{
				var color = graphic.getPixel32(x, y);
				Assert.isFalse(color != FlxColor.WHITE && color != FlxColor.TRANSPARENT);
			}
		}
	}
	#end
}
