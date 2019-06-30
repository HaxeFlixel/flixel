package flixel.tweens.motion;

import massive.munit.Assert;
import flixel.tweens.FlxTween.FlxTweenType;

class QuadMotionTest
{
	@Test // #1978
	function testUseOptions()
	{
		var tween = FlxTween.quadMotion(new FlxObject(), 0, 0, 0, 0, 0, 0, 1, true, {type: FlxTweenType.LOOPING});
		Assert.isTrue((tween.type & FlxTweenType.LOOPING) > 0);
	}
}
