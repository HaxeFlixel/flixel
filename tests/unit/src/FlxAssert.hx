package;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
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
		rectsNearXYWH(expected.x, expected.y, expected.width, expected.height, actual, margin, msg, info);
	}
	
	public static function rectsNearLTRD(expectedL:Float, expectedT:Float, expectedR:Float, expectedD:Float, actual:FlxRect, margin = 0.001, ?msg:String, ?info:PosInfos):Void
	{
		rectsNearXYWH(expectedL, expectedT, expectedR - expectedL, expectedD - expectedT, actual, margin, msg, info);
	}
	
	public static function rectsNearXYWH(expectedX:Float, expectedY:Float, expectedW:Float, expectedH:Float, actual:FlxRect, margin = 0.001, ?msg:String, ?info:PosInfos):Void
	{
		var areNear = areNearHelper(expectedX, actual.x, margin)
			&& areNearHelper(expectedY, actual.y, margin)
			&& areNearHelper(expectedW, actual.width, margin)
			&& areNearHelper(expectedH, actual.height, margin);
		
		if (areNear)
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('Value [$actual] is not within [$margin] of [${toRectString(expectedX, expectedY, expectedW, expectedH)}]', info);
	}
	
	static function toRectString(x:Float, y:Float, w:Float, h:Float):String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("x", x),
			LabelValuePair.weak("y", y),
			LabelValuePair.weak("w", w),
			LabelValuePair.weak("h", h)
		]);
	}

	public static function areNearHelper(expected:Float, actual:Float, margin = 0.001):Bool
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

	public static function arrayContains<T>(array:Array<T>, item:T, ?msg:String, ?info:PosInfos):Void
	{
		if (array.contains(item))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('\nValue\n   ${item}\nwas not found in array\n   ${array}\n', info);
	}

	public static function arrayNotContains<T>(array:Array<T>, item:T, ?msg:String, ?info:PosInfos):Void
	{
		if (!array.contains(item))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('\nValue\n   ${item}\nwas found in array\n   ${array}\n', info);
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

	public static function pointsEqualXY(expectedX:Float, expectedY:Float, actual:FlxPoint, ?msg:String, ?info:PosInfos)
	{
		if (FlxMath.equal(expectedX, actual.x) && FlxMath.equal(expectedY, actual.y))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('Value [$actual] was not equal to expected value [( x: $expectedX | y: $expectedY )]', info);
	}
	
	public static function pointsNotEqual(expected:FlxPoint, actual:FlxPoint, ?msg:String, ?info:PosInfos)
	{
		if (!expected.equals(actual))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('Value [$actual] was equal to value [$expected]', info);
	}
	
	public static function pointsNotEqualXY(expectedX:Float, expectedY:Float, actual:FlxPoint, ?msg:String, ?info:PosInfos)
	{
		if (!FlxMath.equal(expectedX, actual.x) || !FlxMath.equal(expectedY, actual.y))
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('Value [$actual] was equal to value [( x: $expectedX | y: $expectedY )]', info);
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
	
	
	public static function colorsEqual(expected:FlxColor, actual:FlxColor, ?msg:String, ?info:PosInfos):Void
	{
		if (expected == actual)
			Assert.assertionCount++;
		else if (msg != null)
			Assert.fail(msg, info);
		else
			Assert.fail('Value [${actual.toHexString()}] is not equal to [${expected.toHexString()}]', info);
	}
}
