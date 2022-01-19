package;

import flixel.math.FlxRect;
import haxe.PosInfos;
import massive.munit.Assert;

using flixel.util.FlxArrayUtil;

class FlxAssert
{
	public static function areNear(expected:Float, actual:Float, margin:Float = 0.001, ?info:PosInfos):Void
	{
		if (areNearHelper(expected, actual))
			Assert.assertionCount++;
		else
			Assert.fail('Value [$actual] is not within [$margin] of [$expected]', info);
	}

	public static function rectsNear(expected:FlxRect, actual:FlxRect, margin:Float = 0.001, ?info:PosInfos):Void
	{
		var areNear = areNearHelper(expected.x, actual.x, margin)
			&& areNearHelper(expected.y, actual.y, margin)
			&& areNearHelper(expected.width, actual.width, margin)
			&& areNearHelper(expected.height, actual.height, margin);
		
		if (areNear)
			Assert.assertionCount++;
		else
			Assert.fail('Value [$actual] is not within [$margin] of [$expected]', info);
	}

	static function areNearHelper(expected:Float, actual:Float, margin:Float = 0.001):Bool
	{
		return actual >= expected - margin && actual <= expected + margin;
	}

	public static function arraysEqual<T>(expected:Array<T>, actual:Array<T>, ?info:PosInfos):Void
	{
		if (expected.equals(actual))
			Assert.assertionCount++;
		else
			Assert.fail('\nExpected\n   ${expected}\nbut was\n   ${actual}\n', info);
	}
}
