package;

import haxe.PosInfos;
import massive.munit.Assert;
using flixel.util.FlxArrayUtil;

class FlxAssert
{
	public static function arraysEqual<T>(array1:Array<T>, array2:Array<T>, ?info:PosInfos):Void
	{
		if (array1.equals(array2))
			Assert.assertionCount++;
		else
			Assert.fail('\nExpected\n   ${array1}\nbut was\n   ${array2}\n', info);
	}
}