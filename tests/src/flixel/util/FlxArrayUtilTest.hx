package flixel.util;

import flixel.util.FlxArrayUtil;
import FlxAssert;

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
		
		FlxAssert.arraysAreEqual([1, 2, 3, 3, 2, 1, 2, 1, 3], flattened);
	}
}