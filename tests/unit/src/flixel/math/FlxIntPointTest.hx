package tests.unit.src.flixel.math;

package flixel.math;

import haxe.PosInfos;
import massive.munit.Assert;

class FlxPointTest extends FlxTest
{
	var point1:FlxIntPoint;
	var point2:FlxIntPoint;

	@Before
	function before():Void
	{
		point1 = new FlxIntPoint();
		point2 = new FlxIntPoint();
	}

	@Test
	function testSetEquals()
	{
		point1.set(10, 10);
		point2.set(10, 10);

		Assert.isTrue(point1.equals(point2));
		
		point2.y = 1;

		Assert.isFalse(point1.equals(point2));
	}

	@Test
	function testCopy()
	{
		point1.set(10, 10);
		final copy = point1.copy();
		copy.x += 1;

		Assert.isTrue(point1.equals(10, 10));
		Assert.isFalse(copy.equals(1, 10));
	}

	@Test
	function testAdd():Void
	{
		point1.set(1, 2);
		point2.set(3, 5);
		
		final result = point1 + point2;

		Assert.isTrue(point1.equals(1, 2));
		Assert.isTrue(point2.equals(3, 5));
		Assert.isTrue(result.equals(4, 7));
		
		point1 += point2;
		
		Assert.isTrue(point1.equals(4, 7));
		Assert.isTrue(point2.equals(3, 5));
	}

	@Test
	function testSubtract():Void
	{
		point1.set(1, 2);
		point2.set(3, 5);
		
		final result = point1 - point2;
		
		Assert.isTrue(point1.equals(1, 2));
		Assert.isTrue(point2.equals(3, 5));
		Assert.isTrue(result.equals(-2, -3));
		
		point1 -= point2;
		
		Assert.isTrue(point1.equals(-2, -3));
		Assert.isTrue(point2.equals(3, 5));
	}

	@Test
	function testScale():Void
	{
		point1.set(1, 2);
		
		final result = point1 * 2;
		
		Assert.isTrue(point1.equals(1, 2));
		Assert.isTrue(result.equals(2, 4));
		
		final result = 3 * point1;
		
		Assert.isTrue(point1.equals(1, 2));
		Assert.isTrue(result.equals(3, 6));
		
		point1 *= 2;
		Assert.isTrue(point1.equals(2, 4));
	}

	@Test
	function testLength():Void
	{
		point1.set(3, 4);
		
		Assert.areEqual(point1.lengthSquared, 25);
		Assert.areEqual(point1.length, 5);
		
		point1.set(1, 1);
		Assert.areEqual(point1.lengthSquared, 2);
		final length = point1.length;
		Assert.isTrue(length > 1 && length < 2);
	}
}
