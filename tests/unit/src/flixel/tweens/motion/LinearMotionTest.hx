package flixel.tweens.motion;

import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import massive.munit.Assert;

class LinearMotionTest extends FlxTest
{
	var object:FlxObject;
	var tween:FlxTween;

	@Before
	function before()
	{
		object = new FlxObject();
		FlxG.state.add(object);

		tween = null;
	}

	@Test
	function testImmovableValueAfterCompletionNotModfied()
	{
		Assert.isFalse(object.immovable);

		startTween();
		finishTween(tween);

		Assert.isFalse(object.immovable);
	}

	@Test
	function testImmovableValueAfterCancelNotModfied()
	{
		Assert.isFalse(object.immovable);

		startTween();
		tween.cancel();

		Assert.isFalse(object.immovable);
	}

	function startTween()
	{
		tween = FlxTween.linearMotion(object, 0, 0, 1, 1, 0.01);
	}
}
