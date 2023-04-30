package flixel.util;

import massive.munit.Assert;

class FlxGradientTest extends FlxTest
{
	@Test
	function testCreateGradientMatrix()
	{
		var colors = [FlxColor.GREEN, FlxColor.BLACK, FlxColor.WHITE];
		var matrix = FlxGradient.createGradientMatrix(10, 10, colors);

		Assert.areEqual(colors.length, matrix.ratio.length);
	}

	@Test
	function testCreateGradientBitmapData()
	{
		var colors = [FlxColor.GREEN, FlxColor.BLACK, FlxColor.WHITE];
		var bitmapData = FlxGradient.createGradientBitmapData(10, 10, colors);

		var uniqueColors = [];
		for (i in 0...10)
		{
			var pixel = bitmapData.getPixel(0, i);
			if (uniqueColors.indexOf(pixel) < 0)
				uniqueColors.push(pixel);
		}
		Assert.isTrue(uniqueColors.length >= 3);
	}
}
