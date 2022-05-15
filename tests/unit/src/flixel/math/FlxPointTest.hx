package flixel.math;

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
}
