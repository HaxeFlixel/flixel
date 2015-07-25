package flixel.util;

import massive.munit.Assert;
using flixel.util.FlxArrayUtil;

class FlxArrayUtilTest
{
	@Test
	function testFlatten2DArray()
	{
		var array = [
			[1, 2, 3],
			[3, 2, 1],
			[2, 1, 3]];
			
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
}