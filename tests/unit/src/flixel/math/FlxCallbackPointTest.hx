package flixel.math;

import massive.munit.Assert;
import flixel.math.FlxPoint;

class FlxCallbackPointTest extends FlxTest
{
	var point:FlxCallbackPoint;
	var a:Int;

	@Before
	function before()
	{
		point = new FlxCallbackPoint(function(_) a = 5);
		a = 0;
	}

	@Test
	function testCallback()
	{
		point.set(10, 10);
		Assert.isTrue(a == 5);
	}
}
