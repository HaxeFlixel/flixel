package flixel.math;

import haxe.PosInfos;
import massive.munit.Assert;

class FlxPointTest extends FlxTest
{
	var point1:FlxPoint;
	var point2:FlxPoint;

	@Before
	function before():Void
	{
		point1 = new FlxPoint();
		point2 = new FlxPoint();
	}

	@Test
	function testZeroVectorSetLength():Void
	{
		point1.length = 10;

		Assert.isTrue(point1.equals(new FlxPoint(0, 0)));
	}

	@Test
	function testSetLengthToZero():Void
	{
		point1.set(1, 1);
		point1.length = 0;

		Assert.isTrue(point1.equals(new FlxPoint(0, 0)));
	}

	@Test
	function testUnitVectorSetLength():Void
	{
		point1.set(1, 1);
		point1.length = Math.sqrt(2) * 2;

		var xIsInRange = (point1.x > 1.999 && point1.x < 2.001);
		var yIsInRange = (point1.y > 1.999 && point1.y < 2.001);
		Assert.isTrue(xIsInRange);
		Assert.isTrue(yIsInRange);
	}

	@Test
	function testDegreesBetween():Void
	{
		point1.set(0, 1);
		point2.set(1, 0);

		Assert.areEqual(90, point1.degreesBetween(point2));
	}

	@Test
	function testAddNew():Void
	{
		point1.set(1, 2);
		point2.set(3, 5);

		Assert.isTrue(point1.addNew(point2).equals(new FlxPoint(4, 7)));
		Assert.isTrue(point1.equals(new FlxPoint(1, 2)));
	}

	@Test
	function testSubtractNew():Void
	{
		point1.set(1, 2);
		point2.set(3, 5);

		Assert.isTrue(point1.subtractNew(point2).equals(new FlxPoint(-2, -3)));
		Assert.isTrue(point1.equals(new FlxPoint(1, 2)));
	}

	@Test // #1959
	function testNormalizeZero():Void
	{
		point1.set(0, 0);
		var normalized = point1.normalize();
		Assert.isTrue(normalized.equals(new FlxPoint(0, 0)));
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

	@Test
	function testOperators()
	{
		point1.set(1, 2);
		point2.set(4, 8);

		assertPointEquals(point1 + point2, 5, 10);
		assertPointEquals(point1 - point2, -3, -6);
		assertPointEquals(point2 - point1, 3, 6);
		assertPointEquals(point1 * 2.0, 2, 4);
		assertPointEquals(point1 * 2, 2, 4);
		point1 += point2;
		assertPointEquals(point1, 5, 10);
		point1 -= point2;
		assertPointEquals(point1, 1, 2);
		point1 *= 10;
		assertPointEquals(point1, 10, 20);
		point1 /= 10;
		assertPointEquals(point1, 1, 2);

		var pointF = point2.copyToFlash();

		assertPointEquals(point1 + pointF, 5, 10);
		assertPointEquals(point1 - pointF, -3, -6);
		assertPointEquals(pointF - point1, 3, 6);
		point1 += pointF;
		assertPointEquals(point1, 5, 10);
		point1 -= pointF;
		assertPointEquals(point1, 1, 2);
	}

	@Test
	function testPivotDegrees() {
		// Pivot around point in same quadrant
		point1.set(10, 10);
		point2.set(5, 5);
		assertPointNearlyEquals(point1.pivotDegrees(point2, 180), 0, 0);

		// pivot around origin
		point1.set(1, 10);
		point2.set();
		assertPointNearlyEquals(point1.pivotDegrees(point2, 90), -10, 1);

		// pivot around point in different quadrant
		point1.set(10, 10);
		point2.set(-1, -1);
		assertPointNearlyEquals(point1.pivotDegrees(point2, 45), -1, 14.55);
	}

	function assertPointEquals(p:FlxPoint, x:Float, y:Float, ?msg:String, ?info:PosInfos)
	{
		assertPointNearlyEquals(p, x, y, 0.0, msg, info);
	}

	function assertPointNearlyEquals(p:FlxPoint, x:Float, y:Float, tolerance:Float = .01, ?msg:String, ?info:PosInfos)
		{
			if (msg == null)
				msg = 'Expected (x: $x | y: $y) but was $p';

			Assert.isTrue(Math.abs(x - p.x) <= tolerance && Math.abs(y -p.y) <= tolerance, msg, info);
		}
}
