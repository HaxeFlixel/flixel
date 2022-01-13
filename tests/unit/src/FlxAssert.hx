package;

import flixel.math.FlxPoint;
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

	public static function arraysNotEqual<T>(expected:Array<T>, actual:Array<T>, ?info:PosInfos):Void
	{
		if (!expected.equals(actual))
			Assert.assertionCount++;
		else
			Assert.fail('\nValue\n   ${actual}\nwas equal to\n   ${expected}\n', info);
	}

	public static function pointsEqual(expected:FlxPoint, actual:FlxPoint, ?msg:String, ?info:PosInfos)
	{
		if (expected.equals(actual))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail("Value [" + actual + "] was not equal to expected value [" + expected + "]", info);
	}

	public static function pointsNotEqual(expected:FlxPoint, actual:FlxPoint, ?msg:String, ?info:PosInfos)
	{
		if (!expected.equals(actual))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail("Value [" + actual + "] was equal to value [" + expected + "]", info);
	}
}
