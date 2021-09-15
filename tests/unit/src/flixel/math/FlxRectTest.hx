package flixel.math;

import massive.munit.Assert;
import haxe.PosInfos;

class FlxRectTest extends FlxTest
{
	var rect1:FlxRect;
	var rect2:FlxRect;

	@Before
	function before()
	{
		rect1 = new FlxRect();
		rect2 = new FlxRect();
	}

	@Test
	function testEqualsTrue()
	{
		rect1.set(0, 0, 10, 10);
		rect2.set(0, 0, 10, 10);

		Assert.isTrue(rect1.equals(rect2));
	}

	@Test
	function testEqualsFalse()
	{
		rect1.set(0, 0, 10, 10.1);
		rect2.set(0, 0, 10, 10);

		Assert.isFalse(rect1.equals(rect2));
	}

	@Test
	function testgetRotatedBounds()
	{
		var pivot = FlxPoint.get();
		var expected = FlxRect.get();
		
		rect1.set(0, 0, 1, 1);
		
		rect2 = rect1.getRotatedBounds(45, null, rect2);
		var sqrt2 = Math.sqrt(2);
		expected.set(-0.5 * sqrt2, 0, sqrt2, sqrt2);
		assertRectsNear(rect2, expected);
		
		rect1.set(0, 0, 1, 1);
		pivot.set(0.5, 0.5);
		assertRectsNear(rect1.getRotatedBounds( 90, pivot, rect2), rect1, 0.0001);
		assertRectsNear(rect1.getRotatedBounds(180, pivot, rect2), rect1, 0.0001);
		assertRectsNear(rect1.getRotatedBounds(270, pivot, rect2), rect1, 0.0001);
		assertRectsNear(rect1.getRotatedBounds(360, pivot, rect2), rect1, 0.0001);
		
		pivot.set(1, 1);
		rect2 = rect1.getRotatedBounds(210, pivot, rect2);
		var sumSinCos30 = 0.5 + Math.cos(30/180*Math.PI);//sin30 = 0.5;
		expected.set(0.5, 1, sumSinCos30, sumSinCos30);
		assertRectsNear(rect2, expected);
		
		pivot.put();
		expected.put();
	}

	@Test
	function testgetRotatedBoundsSelf()
	{
		var pivot = FlxPoint.get();
		var expected = FlxRect.get();
		
		rect1.set(0, 0, 1, 1);
		
		rect1.getRotatedBounds(45, null, rect1);
		var sqrt2 = Math.sqrt(2);
		expected.set(-0.5 * sqrt2, 0, sqrt2, sqrt2);
		assertRectsNear(rect1, expected);
		
		rect1.set(0, 0, 1, 1);
		pivot.set(0.5, 0.5);
		expected.copyFrom(rect1);
		assertRectsNear(rect1.getRotatedBounds( 90, pivot, rect1), expected, 0.0001);
		assertRectsNear(rect1.getRotatedBounds(180, pivot, rect1), expected, 0.0001);
		assertRectsNear(rect1.getRotatedBounds(270, pivot, rect1), expected, 0.0001);
		assertRectsNear(rect1.getRotatedBounds(360, pivot, rect1), expected, 0.0001);
		
		rect1.set(0, 0, 1, 1);
		pivot.set(1, 1);
		rect1.getRotatedBounds(210, pivot, rect1);
		var sumSinCos30 = 0.5 + Math.cos(30/180*Math.PI);//sin30 = 0.5;
		expected.set(0.5, 1, sumSinCos30, sumSinCos30);
		assertRectsNear(rect1, expected);
		
		pivot.put();
		expected.put();
	}
	
	static function assertIsNear(actual:Float, expected:Float, margin:Float = 0.001, ?info:PosInfos):Void
	{
		if (isNear(actual, expected, margin))
			Assert.assertionCount++;
		else
			Assert.fail('\nExpected\n   $expected (+/- $margin)\nbut was\n   $actual\n', info);
	}
	
	static function isNear(actual:Float, expected:Float, margin:Float = 0.001):Bool
	{
		return actual >= expected - margin && actual <= expected + margin;
	}
	
	static function assertRectsNear(actual:FlxRect, expected:FlxRect, margin:Float = 0.001, ?info:PosInfos):Void
	{
		var areNear = isNear(actual.x, expected.x, margin)
			&& isNear(actual.y, expected.y, margin)
			&& isNear(actual.width, expected.width, margin)
			&& isNear(actual.height, expected.height, margin);
		
		if (areNear)
			Assert.assertionCount++;
		else
			Assert.fail('\nExpected\n   ($expected (+/- $margin)\nbut was\n   $actual\n', info);
		
	}
}
