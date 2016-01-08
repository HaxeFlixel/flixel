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
			Assert.fail('Expected $array1 but was $array2', info);
	}
}