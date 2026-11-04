package flixel.system.frontEnds;

import flixel.graphics.FlxGraphic;
import massive.munit.Assert;
import openfl.display.BitmapData;

class BitmapFrontEndTest
{
	@Test
	function testGetUniqueKey()
	{
		final key = "test";

		Assert.isFalse(FlxG.bitmap.exists(key));
		Assert.areEqual(key, FlxG.bitmap.getUniqueKey(key));

		FlxG.bitmap.add(FlxGraphic.fromBitmapData(new BitmapData(1, 1)), true, key);
		Assert.isTrue(FlxG.bitmap.exists(key));

		var newKey = FlxG.bitmap.getUniqueKey(key);
		Assert.areNotEqual(key, newKey);
	}
	
	@Test
	function testExists()
	{
		final key = "testExists";
		
		Assert.isFalse(FlxG.bitmap.exists(key));
		FlxG.bitmap.add(new BitmapData(1, 1), true, key);
		Assert.isTrue(FlxG.bitmap.exists(key));
	}
}
