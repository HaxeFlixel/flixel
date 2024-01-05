package;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import haxe.PosInfos;
import massive.munit.Assert;

using flixel.util.FlxArrayUtil;

class FlxAssert
{
	public static function areNear(expected:Float, actual:Float, margin = 0.001, ?msg:String, ?info:PosInfos):Void
	{
		if (areNearHelper(expected, actual))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('Value [$actual] is not within [$margin] of [$expected]', info);
	}

	public static function rectsNear(expected:FlxRect, actual:FlxRect, margin = 0.001, ?msg:String, ?info:PosInfos):Void
	{
		var areNear = areNearHelper(expected.x, actual.x, margin)
			&& areNearHelper(expected.y, actual.y, margin)
			&& areNearHelper(expected.width, actual.width, margin)
			&& areNearHelper(expected.height, actual.height, margin);
		
		if (areNear)
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('Value [$actual] is not within [$margin] of [$expected]', info);
	}

	static function areNearHelper(expected:Float, actual:Float, margin = 0.001):Bool
	{
		return actual >= expected - margin && actual <= expected + margin;
	}

	public static function arraysEqual<T>(expected:Array<T>, actual:Array<T>, ?msg:String, ?info:PosInfos):Void
	{
		if (expected.equals(actual))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('\nExpected\n   ${expected}\nbut was\n   ${actual}\n', info);
	}

	public static function arraysNotEqual<T>(expected:Array<T>, actual:Array<T>, ?msg:String, ?info:PosInfos):Void
	{
		if (!expected.equals(actual))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
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

	public static function pointsNear(expected:FlxPoint, actual:FlxPoint, margin:Float = 0.001, ?msg:String, ?info:PosInfos)
	{
		var areNear = areNearHelper(expected.x, actual.x, margin)
			&& areNearHelper(expected.y, actual.y, margin);
		
		if (areNear)
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('Value [$actual] is not within [$margin] of [$expected]', info);
	}

	public static function pointNearXY(expectedX:Float, expectedY:Float, actual:FlxPoint, margin:Float = 0.001, ?msg:String, ?info:PosInfos)
	{
		var areNear = areNearHelper(expectedX, actual.x, margin)
			&& areNearHelper(expectedY, actual.y, margin);
		
		if (areNear)
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('Value [$actual] is not within [$margin] of [( x:$expectedX | y:$expectedY )]', info);
	}
}
