package flixel.system.frontEnds;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import massive.munit.Assert;

class BitmapFrontEndTest
{
	@Test
	function testGetUniqueKey()
	{
		var key = "test";

		Assert.isFalse(FlxG.bitmap.checkCache(key));
		Assert.areEqual(key, FlxG.bitmap.getUniqueKey(key));

		FlxG.bitmap.add(FlxGraphic.fromBitmapData(new BitmapData(1, 1)), true, key);
		Assert.isTrue(FlxG.bitmap.checkCache(key));

		var newKey = FlxG.bitmap.getUniqueKey("test");
		Assert.areNotEqual(key, newKey);
	}
}
