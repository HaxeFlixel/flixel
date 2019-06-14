package;

import haxe.PosInfos;
import massive.munit.Assert;

using flixel.util.FlxArrayUtil;

class FlxAssert
{
	public static function arraysEqual<T>(expected:Array<T>, actual:Array<T>, ?info:PosInfos):Void
	{
		if (expected.equals(actual))
			Assert.assertionCount++;
		else
			Assert.fail('\nExpected\n   ${expected}\nbut was\n   ${actual}\n', info);
	}
}
