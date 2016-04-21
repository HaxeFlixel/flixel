package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import massive.munit.Assert;

class VarTweenTest extends FlxTest
{
	var float:Float;
	
	@Before
	function before()
	{
		float = 0;
	}
	
	@Test
	function testTweenFloat()
	{
		FlxTween.tween(this, { float: 0.5 }, 0.01);
		step();
		Assert.areEqual(0.5, float);
	}
}