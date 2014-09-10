package;

import haxe.PosInfos;
import massive.munit.Assert;

class FlxAssert
{
	public static function arraysAreEqual<T>(expected:Array<T>, actual:Array<T>, ?info:PosInfos)
	{
		Assert.assertionCount++;
		
		var fail = function()
		{
			Assert.fail('Value $actual was not equal to expected value $expected', info);
		}
		
		if (expected == null && actual == null)
			return;
		if (expected == null && actual != null)
			fail();
		if (expected != null && actual == null)
			fail();
		if (expected.length != actual.length)
			fail();
		
		for (i in 0...expected.length)
		{
			if (expected[i] != actual[i])
			{
				fail();
			}
		}
	}
}