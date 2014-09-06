package flixel.util;

import flash.display.BitmapData;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
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
}