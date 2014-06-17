package flixel.math;

import massive.munit.Assert;
import flixel.math.FlxRandom;

class FlxRandomTest extends FlxTest
{
	@Test
	// issue 1172
	function testIntExcludes():Void
	{
		for (i in 0...20)
		{
			Assert.areEqual(0, FlxRandom.int(0, 1, [1]));
		}
	}
}