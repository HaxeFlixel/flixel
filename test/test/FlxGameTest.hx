package ;

import flixel.FlxG;

import massive.munit.Assert;
import massive.munit.Assert;

class FlxGameTest 
{
	public function new() {}

	@Test
	public function state():Void {
		Assert.isTrue(FlxG.state != null);
	}

	@Test
	public function testFlxGDimensions():Void
	{
		Assert.isTrue(FlxG.width == 640);
		Assert.isFalse(FlxG.width == 480);

		Assert.isTrue(FlxG.height == 480);
		Assert.isFalse(FlxG.height == 640);
	}

}