package flixel.util;

import massive.munit.Assert;

using flixel.util.FlxArrayUtil;

class FlxArrayUtilTest
{
	@Test
	function testFlatten2DArray()
	{
		var array = [[1, 2, 3], [3, 2, 1], [2, 1, 3]];

		var flattened = FlxArrayUtil.flatten2DArray(array);
		Assert.isTrue([1, 2, 3, 3, 2, 1, 2, 1, 3].equals(flattened));
	}

	@Test
	function testEqualsNullNull()
	{
		Assert.isTrue((null : Array<Int>).equals(null));
	}

	@Test
	function testEqualsNullNotNull()
	{
		Assert.isFalse((null : Array<Int>).equals([]));
	}

	@Test
	function testEqualsNotNullNull()
	{
		Assert.isFalse([].equals(null));
	}

	@Test
	function testEqualsEmptyEmpty()
	{
		Assert.isTrue([].equals([]));
	}

	@Test
	function testEqualsDifferentLength()
	{
		Assert.isFalse([1, 2, 3].equals([1, 2]));
	}

	@Test
	function testEqualsSame()
	{
		Assert.isTrue([1, 2, 3].equals([1, 2, 3]));
	}

	@Test
	function testEqualsSameLengthButDifferent()
	{
		Assert.isFalse([1, 2, 3].equals([3, 2, 1]));
	}

	@Test
	function testLastNullArray()
	{
		Assert.isNull((null : Array<Int>).last());
	}

	@Test
	function testLastEmptyArray()
	{
		Assert.isNull([].last());
	}

	@Test
	function testLast()
	{
		Assert.areEqual(1, [1].last());
		Assert.areEqual(3, [1, 2, 3].last());
	}

	@Test
	function testSwapByIndex()
	{
		Assert.isTrue([0, 1, 2, 3, 4, 5].swapByIndex(2, 4).equals([0, 1, 4, 3, 2, 5]));
	}

	@Test
	function testSafeSwapByIndex()
	{
		Assert.isTrue([0, 1, 2, 3].safeSwapByIndex(0, 3).equals([3, 1, 2, 0]));
		Assert.isTrue([0, 1, 2, 3].safeSwapByIndex(2, 4).equals([0, 1, 2, 3]));
		Assert.isTrue([0, 1, 2, 3].safeSwapByIndex(-1, 2).equals([0, 1, 2, 3]));
	}

	@Test
	function testSwap()
	{
		Assert.isTrue([0, 1, 2, 3, 4, 5].swap(1, 3).equals([0, 3, 2, 1, 4, 5]));
	}

	@Test
	function testSafeSwap()
	{
		Assert.isTrue([0, 1, 2, 3, 4, 5].safeSwap(0, 2).equals([2, 1, 0, 3, 4, 5]));
		Assert.isTrue([0, 1, 2, 3, 4, 5].safeSwap(1, 6).equals([0, 1, 2, 3, 4, 5]));
	}

	@Test
	@:haxe.warning("-WDeprecated")
	function testSetLength()
	{
		final arr = [0, 1, 2, 3, 4, 5];
		
		// ignores negative numbers
		arr.setLength(-1);
		FlxAssert.arraysEqual([0, 1, 2, 3, 4, 5], arr);
		
		// expected usage
		arr.setLength(3);
		FlxAssert.arraysEqual([0, 1, 2], arr);
		
		// can't make arrays bigger
		arr.setLength(5);
		FlxAssert.arraysEqual([0, 1, 2], arr);
	}
}
