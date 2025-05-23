package flixel.math;

import haxe.PosInfos;
import massive.munit.Assert;

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
	function testGetRotatedBounds()
	{
		var pivot = FlxPoint.get();
		var expected = FlxRect.get();
		
		rect1.set(0, 0, 1, 1);
		
		rect2 = rect1.getRotatedBounds(45, null, rect2);
		var sqrt2 = Math.sqrt(2);
		expected.set(-0.5 * sqrt2, 0, sqrt2, sqrt2);
		FlxAssert.rectsNear(expected, rect2);
		
		rect1.set(0, 0, 1, 1);
		pivot.set(0.5, 0.5);
		FlxAssert.rectsNear(rect1, rect1.getRotatedBounds( 90, pivot, rect2), 0.0001);
		FlxAssert.rectsNear(rect1, rect1.getRotatedBounds(180, pivot, rect2), 0.0001);
		FlxAssert.rectsNear(rect1, rect1.getRotatedBounds(270, pivot, rect2), 0.0001);
		FlxAssert.rectsNear(rect1, rect1.getRotatedBounds(360, pivot, rect2), 0.0001);
		
		pivot.set(1, 1);
		rect2 = rect1.getRotatedBounds(210, pivot, rect2);
		var sumSinCos30 = 0.5 + Math.cos(30/180*Math.PI);//sin30 = 0.5;
		expected.set(0.5, 1, sumSinCos30, sumSinCos30);
		FlxAssert.rectsNear(expected, rect2);
		
		pivot.put();
		expected.put();
	}

	@Test
	function testGetRotatedBoundsSelf()
	{
		var pivot = FlxPoint.get();
		var expected = FlxRect.get();
		
		rect1.set(0, 0, 1, 1);
		
		rect1.getRotatedBounds(45, null, rect1);
		var sqrt2 = Math.sqrt(2);
		expected.set(-0.5 * sqrt2, 0, sqrt2, sqrt2);
		FlxAssert.rectsNear(expected, rect1);
		
		rect1.set(0, 0, 1, 1);
		pivot.set(0.5, 0.5);
		expected.copyFrom(rect1);
		FlxAssert.rectsNear(expected, rect1.getRotatedBounds( 90, pivot, rect1), 0.0001);
		FlxAssert.rectsNear(expected, rect1.getRotatedBounds(180, pivot, rect1), 0.0001);
		FlxAssert.rectsNear(expected, rect1.getRotatedBounds(270, pivot, rect1), 0.0001);
		FlxAssert.rectsNear(expected, rect1.getRotatedBounds(360, pivot, rect1), 0.0001);
		
		rect1.set(0, 0, 1, 1);
		pivot.set(1, 1);
		rect1.getRotatedBounds(210, pivot, rect1);
		var sumSinCos30 = 0.5 + Math.cos(30/180*Math.PI);//sin30 = 0.5;
		expected.set(0.5, 1, sumSinCos30, sumSinCos30);
		FlxAssert.rectsNear(expected, rect1);
		
		pivot.put();
		expected.put();
	}
	
	@Test
	function testIntersection()
	{
		rect1.set(0, 0, 100, 100);
		rect2.set(50, 50, 100, 100);
		
		final expected = FlxRect.get(50, 50, 50, 50);
		final result = FlxRect.get();
		rect1.intersection(rect2, result);
		FlxAssert.rectsNear(expected, result, 0.0001);
		
		expected.put();
		result.put();
	}
	
	@Test
	function testIntersectionEmpty()
	{
		rect1.set(0, 0, 100, 100);
		rect2.set(200, 200, 100, 100);
		
		final expected = FlxRect.get(0, 0, 0, 0);
		final result = FlxRect.get(1000, 1000, 1000, 1000);
		rect1.intersection(rect2, result);
		FlxAssert.rectsNear(expected, result, 0.0001);
		
		expected.put();
		result.put();
	}
	
	@Test
	function testClipTo()
	{
		rect1.set(0, 0, 100, 100);
		rect2.set(50, 50, 100, 100);
		
		final expected = FlxRect.get(50, 50, 50, 50);
		rect1.clipTo(rect2);
		FlxAssert.rectsNear(expected, rect1, 0.0001);
		
		expected.put();
	}
	
	@Test
	function testClipToEmpty()
	{
		rect1.set(0, 0, 100, 100);
		rect2.set(200, 200, 100, 100);
		
		final expected = FlxRect.get(0, 0, 0, 0);
		rect1.clipTo(rect2);
		FlxAssert.rectsNear(expected, rect1, 0.0001);
		
		expected.put();
	}
	
	@Test
	function testContins()
	{
		rect1.set(0, 0, 100, 100);
		
		inline function assertContains(x, y, width = 50, height = 50, ?pos:PosInfos)
		{
			Assert.isTrue(rect1.contains(rect2.set(x, y, width, height)), pos);
		}
		
		inline function assertNotContains(x, y, width = 50, height = 50, ?pos:PosInfos)
		{
			Assert.isFalse(rect1.contains(rect2.set(x, y, width, height)), pos);
		}
		
		assertContains(25, 25);
		assertContains(0, 0);
		assertNotContains(-1, -1);
		assertContains(50, 50);
		assertNotContains(51, 51);
		assertContains(0, 0, 100, 100);
		assertNotContains(-1, -1, 101, 101);
	}
}
