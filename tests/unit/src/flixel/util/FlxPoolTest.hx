package flixel.util;

import flixel.math.FlxPoint;
import massive.munit.Assert;

class FlxPoolTest extends FlxTest
{
	var ppool:FlxPool<FlxBasePoint>;

	@Before
	function before():Void
	{
		ppool = new FlxPool(FlxBasePoint.new.bind(0, 0));
	}

	@Test
	function testLegacy():Void
	{
		final pool = new FlxPool(FlxBasePoint);
	}

	@Test
	function putNull():Void
	{
		ppool.put(null);
		ppool.putUnsafe(null);
		Assert.areEqual(ppool.length, 0);
	}

	@Test
	function putDuplicateSafe():Void
	{
		var pt:FlxPoint = ppool.get();
		ppool.put(pt);
		ppool.put(pt);
		Assert.areEqual(ppool.length, 1);
	}

	@Test
	function putDuplicateUnsafe():Void
	{
		var pt = ppool.get();
		ppool.putUnsafe(pt);
		ppool.putUnsafe(pt);
		var old = ppool.clear();
		Assert.areEqual(old[0], old[1]);
	}

	@Test
	function testPreAllocate():Void
	{
		ppool.preAllocate(5);
		ppool.preAllocate(5);
		Assert.areEqual(ppool.length, 10);
	}

	@Test
	function putGetComplex():Void
	{
		ppool.preAllocate(5);

		var pt1 = ppool.get();
		var pt2 = ppool.get();
		var pt3 = ppool.get();
		ppool.get();
		var pt5 = ppool.get();
		// accessible | inaccessible
		ppool.put(pt3); // 3|4321
		ppool.put(pt2); // 32|321
		ppool.put(pt5); // 325|21
		ppool.get(); // 32|521
		ppool.put(pt1); // 321|21
		ppool.put(pt5); // 3215|1

		var old = ppool.clear();

		FlxAssert.arraysEqual([pt3, pt2, pt1, pt5, pt1], old);
	}
}
