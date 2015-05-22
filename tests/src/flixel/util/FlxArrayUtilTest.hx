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
		var array:Array<Int> = null;
		Assert.isTrue(array.equals(null));
	}
	
	@Test
	function testEqualsNullNotNull()
	{
		var array:Array<Int> = null;
		Assert.isFalse(array.equals([]));
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
		Assert.isTrue([1, 2, 3].equals([1, 2]));
	}
	
	@Test
	function testEqualsSame()
	{
		Assert.isTrue([1, 2, 3].equals([1, 2, 3]));
	}
}