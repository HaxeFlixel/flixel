package flixel.tweens.motion;

import massive.munit.Assert;

class QuadMotionTest
{
	@Test // #1978
	function testUseOptions()
	{
		var tween = FlxTween.quadMotion(new FlxObject(), 0, 0, 0, 0, 0, 0, 1, true, { type: FlxTween.LOOPING });
		Assert.isTrue((tween.type & FlxTween.LOOPING) > 0);
	}
}