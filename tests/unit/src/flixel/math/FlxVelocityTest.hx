package flixel.math;

import flixel.FlxSprite;
import massive.munit.Assert;

class FlxVelocityTest extends FlxTest
{
	@Test // #1833
	function testAccelerateFromAngleNegativeMaxVelocity()
	{
		var sprite = new FlxSprite();
		FlxVelocity.accelerateFromAngle(sprite, FlxAngle.TO_RAD * -90, 50, 100);

		Assert.isTrue(sprite.velocity.equals(FlxPoint.get(0, 0)));
		Assert.isTrue(sprite.maxVelocity.equals(FlxPoint.get(0, 100)));
		Assert.isTrue(sprite.acceleration.equals(FlxPoint.get(0, -50)));
	}
}
