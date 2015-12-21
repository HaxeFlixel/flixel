package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import massive.munit.Assert;

class VarTweenTest extends FlxTest
{
	var int:Int;
	
	@Before
	function before()
	{
		int = 0;
	}
	
	@Test // #1609
	function testIntRemainsInt()
	{
		FlxTween.tween(this, { int: 0.1 }, 0.01);
		step();
		Assert.isTrue(Std.is(int, Int));
	}
}