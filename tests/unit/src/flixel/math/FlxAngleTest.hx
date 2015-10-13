package flixel.math;

import flixel.math.FlxAngle;
import massive.munit.Assert;

class FlxAngleTest
{
	@Test // #1610
	function testWrapAngle()
	{
		var testAngle = function(expected, toWrap)
			Assert.areEqual(expected, FlxAngle.wrapAngle(toWrap));
		
		testAngle(-170, 190);
		testAngle(170, -190);
		testAngle(-90, 270);
		testAngle(0, 360);
		testAngle(-160, 920);
		testAngle(173, 533);
		testAngle(0, 0);
		testAngle(180, 180);
		testAngle(-180, -180);
	}
}