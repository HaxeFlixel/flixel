package flixel.math;

import massive.munit.Assert;

class FlxAngleTest
{
	@Test // #1610
	function testWrapAngle()
	{
		function testAngle(expected, degrees)
		{
			Assert.areEqual(expected, FlxAngle.wrapAngle(degrees));
		}
		
		testAngle(-170, 190);
		testAngle( 170,-190);
		testAngle(-90 , 270);
		testAngle( 0  , 360);
		testAngle(-160, 920);
		testAngle( 173, 533);
		testAngle( 0  , 0  );
		testAngle( 180, 180);
		testAngle(-180,-180);
	}
}
