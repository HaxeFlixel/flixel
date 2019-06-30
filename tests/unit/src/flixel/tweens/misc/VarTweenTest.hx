package flixel.tweens.misc;

import flixel.group.FlxSpriteGroup;
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
		FlxTween.tween(this, {float: 0.5}, 0.01);
		step();
		Assert.areEqual(0.5, float);
	}

	@Test // #2152
	function testTweenSubProperties()
	{
		var spriteGroup = new FlxSpriteGroup();

		Assert.areEqual(1, spriteGroup.scale.x);
		Assert.areEqual(1, spriteGroup.group.camera.alpha);

		FlxTween.tween(spriteGroup, {"scale.x": 2, "group.camera.alpha": 0}, 0.0001);
		step();

		Assert.areEqual(2, spriteGroup.scale.x);
		Assert.areEqual(0, spriteGroup.group.camera.alpha);
	}
}
