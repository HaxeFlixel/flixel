package flixel;

import flixel.FlxG;
import massive.munit.Assert;

class FlxGTest extends FlxTest
{
	@Test
	public function stateNull():Void 
	{
		Assert.isNotNull(FlxG.state);
	}
	
	@Test
	public function gameNull():Void 
	{
		Assert.isNotNull(FlxG.game);
	}

	@Test
	public function testFlxGDimensions():Void
	{
		Assert.isTrue(FlxG.width == 640);
		Assert.isTrue(FlxG.height == 480);
	}
}