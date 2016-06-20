package flixel.util;

import flash.display.BitmapData;
import massive.munit.Assert;

class FlxStringUtilTest
{
	@Test
	function testBitmapToCSVSimple()
	{
		var bitmapData = new BitmapData(3, 3);
		bitmapData.setPixel32(0, 0, FlxColor.BLACK);
		bitmapData.setPixel32(1, 1, FlxColor.BLACK);
		bitmapData.setPixel32(2, 2, FlxColor.BLACK);
		
		var expected =
			"1, 0, 0\n" +
			"0, 1, 0\n" +
			"0, 0, 1";
		var actual = FlxStringUtil.bitmapToCSV(bitmapData);
		
		Assert.areEqual(expected, actual);
	}
	
	@Test
	function testBitmapToCSVInverted()
	{
		var bitmapData = new BitmapData(3, 3, true, FlxColor.BLACK);
		bitmapData.setPixel32(0, 0, FlxColor.WHITE);
		bitmapData.setPixel32(1, 1, FlxColor.WHITE);
		bitmapData.setPixel32(2, 2, FlxColor.WHITE);
		
		var expected =
			"1, 0, 0\n" +
			"0, 1, 0\n" +
			"0, 0, 1";
		var actual = FlxStringUtil.bitmapToCSV(bitmapData, true);
		
		Assert.areEqual(expected, actual);
	}
	
	@Test
	function testBitmapToCSVWithScale()
	{
		var bitmapData = new BitmapData(2, 2);
		bitmapData.setPixel32(0, 0, FlxColor.BLACK);
		bitmapData.setPixel32(1, 1, FlxColor.BLACK);
		
		var expected =
			"1, 1, 0, 0\n" +
			"1, 1, 0, 0\n" +
			"0, 0, 1, 1\n" +
			"0, 0, 1, 1";
		var actual = FlxStringUtil.bitmapToCSV(bitmapData, false, 2);
		
		Assert.areEqual(expected, actual);
	}
	
	@Test
	function testBitmapToCSVWithColorMap()
	{
		var bitmapData = new BitmapData(3, 3);
		bitmapData.setPixel32(0, 0, FlxColor.BLACK);
		bitmapData.setPixel32(1, 1, FlxColor.RED);
		bitmapData.setPixel32(2, 2, FlxColor.YELLOW);
		
		var expected =
			"1, 0, 0\n" +
			"0, 2, 0\n" +
			"0, 0, 3";
			
		var colorMap = [FlxColor.WHITE, FlxColor.BLACK, FlxColor.RED, FlxColor.YELLOW];
		var actual = FlxStringUtil.bitmapToCSV(bitmapData, false, 1, colorMap);
		
		Assert.areEqual(expected, actual);
	}
	
	@Test
	function testFormatMoney()
	{
		Assert.areEqual("110.20", FlxStringUtil.formatMoney(110.2));
		Assert.areEqual("110", FlxStringUtil.formatMoney(110.2, false));
		Assert.areEqual("100,000,000.00", FlxStringUtil.formatMoney(100000000));
		Assert.areEqual("100.000.000,00", FlxStringUtil.formatMoney(100000000, true, false));
		Assert.areEqual("0.60", FlxStringUtil.formatMoney(0.6)); // #1754
		Assert.areEqual("0", FlxStringUtil.formatMoney(0.6, false));
		Assert.areEqual("0.00", FlxStringUtil.formatMoney(0));

		Assert.areEqual("-100,000,000.00", FlxStringUtil.formatMoney(-100000000));
		Assert.areEqual("-110.20", FlxStringUtil.formatMoney(-110.2));
		Assert.areEqual("-0.60", FlxStringUtil.formatMoney(-0.6));
	}
	
	@Test
	function testIsNullOrEmpty()
	{
		Assert.isTrue(FlxStringUtil.isNullOrEmpty(null));
		Assert.isTrue(FlxStringUtil.isNullOrEmpty(""));
		Assert.isFalse(FlxStringUtil.isNullOrEmpty("."));
		Assert.isFalse(FlxStringUtil.isNullOrEmpty("Hello World"));
	}
}