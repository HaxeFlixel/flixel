package flixel.math;

import haxe.PosInfos;
import massive.munit.Assert;

class FlxBasePointTest extends FlxTest
{
	var point1:FlxBasePoint;
	var point2:FlxBasePoint;

	@Before
	function before()
	{
		point1 = new FlxBasePoint();
		point2 = new FlxBasePoint();
	}

	@Test
	function testEqualsTrue()
	{
		point1.set(10, 10);
		point2.set(10, 10);

		Assert.isTrue(point1.equals(point2));

		FlxAssert.pointsEqual(point1, point2);
	}

	@Test
	function testEqualsFalse()
	{
		point1.set(10, 10.1);
		point2.set(10, 10);

		Assert.isFalse(point1.equals(point2));

		FlxAssert.pointsNotEqual(point1, point2);
	}

	@Test
	function testAngleTo()
	{
		//              x1,  y1,  x2,  y2, expected angle
		assertdegreesTo(   0,   0,   0,   0,   0);
		assertdegreesTo(   0,   0, 100,   0,   0);
		assertdegreesTo(   0,   0, 100, 100,  45);
		assertdegreesTo(   0,   0,   0, 100,  90);
		assertdegreesTo(   0,   0,-100, 100, 135);
		assertdegreesTo( 100,   0,   0,   0, 180);
		assertdegreesTo( 600,-200, 500,-300,-135);
		assertdegreesTo( 600,-200, 600,-300, -90);
		assertdegreesTo( 600,-200, 700,-300, -45);

		var sqrt3 = Math.sqrt(3);
		assertdegreesTo(0, 0, sqrt3, 1, 30);
		assertdegreesTo(0, 0, 1, sqrt3, 60);
	}

	function assertdegreesTo(x1, y1, x2, y2, expected:Float, precision = 0.0001, ?msg:String, ?info:PosInfos)
	{
		var actual = point1.set(x1, y1).degreesTo(point2.set(x2, y2));
		Assert.areEqual(expected, Math.round(actual / precision) * precision, msg, info);
	}
}
