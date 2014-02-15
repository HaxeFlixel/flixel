package flixel;

import flixel.FlxG;
import massive.munit.Assert;

class FlxGameTest extends FlxTest
{
	@Test
	public function state():Void 
	{
		Assert.isNotNull(FlxG.state);
	}

	@Test
	public function testFlxGDimensions():Void
	{
		Assert.isTrue(FlxG.width == 640);
		Assert.isTrue(FlxG.height == 480);
	}
}