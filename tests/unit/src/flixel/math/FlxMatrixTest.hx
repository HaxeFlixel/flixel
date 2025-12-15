package flixel.math;

import flixel.util.FlxStringUtil;
import massive.munit.Assert;

class FlxMatrixTest extends FlxTest
{
	var matrix:FlxMatrix;

	@Before
	function before()
	{
		matrix = new FlxMatrix();
	}

	@Test // #1326
	function testDefaultValues()
	{
		Assert.areEqual(1, matrix.a);
		Assert.areEqual(0, matrix.b);
		Assert.areEqual(0, matrix.c);
		Assert.areEqual(1, matrix.d);
		Assert.areEqual(0, matrix.tx);
		Assert.areEqual(0, matrix.ty);
	}
	
	@Test
	function testIsIdentity()
	{
		Assert.isTrue(matrix.isIdentity());
		matrix.a = 2;
		Assert.isFalse(matrix.isIdentity());
		matrix.a = 1;
		Assert.isTrue(matrix.isIdentity());
		matrix.b = 1;
		Assert.isFalse(matrix.isIdentity());
		matrix.b = 0;
		Assert.isTrue(matrix.isIdentity());
		matrix.c = 1;
		Assert.isFalse(matrix.isIdentity());
		matrix.c = 0;
		Assert.isTrue(matrix.isIdentity());
		matrix.d = 0;
		Assert.isFalse(matrix.isIdentity());
		matrix.d = 1;
		Assert.isTrue(matrix.isIdentity());
		matrix.tx = 1;
		Assert.isFalse(matrix.isIdentity());
		matrix.tx = 0;
		Assert.isTrue(matrix.isIdentity());
		matrix.ty = 1;
		Assert.isFalse(matrix.isIdentity());
		matrix.ty = 0;
		Assert.isTrue(matrix.isIdentity());
	}
	
	@Test
	function testSkew()
	{
		matrix.skewDegrees(45, 60);
		assertNearXY(1, Math.sqrt(3), 1, 1, 0, 0, matrix);
		
		matrix.setTo(1, 0, 0, 1, 0, 0);
		matrix.skewRadians(Math.PI / 4, Math.PI / 3);
		assertNearXY(1, Math.sqrt(3), 1, 1, 0, 0, matrix);
	}
	
	@Test
	function testRotate()
	{
		matrix.translate(1, 2);
		
		// rotate CW 90, total:90
		matrix.rotateByPositive90();
		assertNearXY(0, 1, -1, 0, -2, 1, matrix);
		
		// rotate CCW 90, total:0
		matrix.rotateByNegative90();
		assertNearXY(1, 0, 0, 1, 1, 2, matrix);
		
		// rotate CW 90, total:90
		matrix.rotateWithTrig(0, 1);// cos(90), sin(90)
		assertNearXY(0, 1, -1, 0, -2, 1, matrix);
		
		// rotate CW 180, total:270
		matrix.rotateBy180();
		assertNearXY(0, -1, 1, 0, 2, -1, matrix);
		
		// rotate CW 90, total:0
		matrix.rotateWithTrig(0, 1);// cos(90), sin(90)
		assertNearXY(1, 0, 0, 1, 1, 2, matrix);
	}
	
	@Test
	function testTransform()
	{
		matrix.scale(2, 4);
		FlxAssert.areNear(0, matrix.transformX(0, 0));
		FlxAssert.areNear(0, matrix.transformY(0, 0));
		FlxAssert.areNear(2, matrix.transformX(1, 1));
		FlxAssert.areNear(4, matrix.transformY(1, 1));
		
		matrix.translate(5, 10);
		FlxAssert.areNear( 5, matrix.transformX(0, 0));
		FlxAssert.areNear(10, matrix.transformY(0, 0));
		FlxAssert.areNear( 7, matrix.transformX(1, 1));
		FlxAssert.areNear(14, matrix.transformY(1, 1));
		
		matrix.scale(2, 4);
		FlxAssert.areNear(10, matrix.transformX(0, 0));
		FlxAssert.areNear(40, matrix.transformY(0, 0));
		FlxAssert.areNear(14, matrix.transformX(1, 1));
		FlxAssert.areNear(56, matrix.transformY(1, 1));
		
		matrix.rotateByPositive90();
		FlxAssert.areNear(-40, matrix.transformX(0, 0));
		FlxAssert.areNear(10, matrix.transformY(0, 0));
		FlxAssert.areNear(-56, matrix.transformX(1, 1));
		FlxAssert.areNear(14, matrix.transformY(1, 1));
	}
	
	function assertScalersNearXY(expectedScaleX:Float, expectedScaleY:Float, actual:FlxMatrix, margin = 0.001, ?msg:String, ?pos)
	{
		if (!FlxAssert.areNearHelper(expectedScaleX, actual.a, margin))
			Assert.fail(msg != null ? msg : 'Matrix A value [${actual.a}] is not within [$margin] of [$expectedScaleX]', pos);
		else if (!FlxAssert.areNearHelper(expectedScaleY, actual.d, margin))
			Assert.fail(msg != null ? msg : 'Matrix D value [${actual.d}] is not within [$margin] of [$expectedScaleX]', pos);
		else
			Assert.assertionCount++;
	}
	
	function assertSkewsNearXY(expectedSkewX:Float, expectedSkewY:Float, actual:FlxMatrix, margin = 0.001, ?msg:String, ?pos)
	{
		if (!FlxAssert.areNearHelper(expectedSkewX, actual.c, margin))
			Assert.fail(msg != null ? msg : 'Matrix C value [${actual.c}] is not within [$margin] of [$expectedSkewX]', pos);
		else if (!FlxAssert.areNearHelper(expectedSkewY, actual.b, margin))
			Assert.fail(msg != null ? msg : 'Matrix B value [${actual.b}] is not within [$margin] of [$expectedSkewX]', pos);
		else
			Assert.assertionCount++;
	}
	
	function assertPosNearXY(expectedTX:Float, expectedTY:Float, actual:FlxMatrix, margin = 0.001, ?msg:String, ?pos)
	{
		if (!FlxAssert.areNearHelper(expectedTX, actual.tx, margin))
			Assert.fail(msg != null ? msg : 'Matrix TX value [${actual.tx}] is not within [$margin] of [$expectedTX]', pos);
		else if (!FlxAssert.areNearHelper(expectedTY, actual.ty, margin))
			Assert.fail(msg != null ? msg : 'Matrix TY value [${actual.ty}] is not within [$margin] of [$expectedTY]', pos);
		else
			Assert.assertionCount++;
	}
	
	function assertNearXY(expA:Float, expB:Float, expC:Float, expD:Float, expX:Float, expY:Float,
		actual:FlxMatrix, margin = 0.001, ?msg:String, ?pos)
	{
		if (FlxAssert.areNearHelper(expA, actual.a, margin)
			&& FlxAssert.areNearHelper(expB, actual.b, margin)
			&& FlxAssert.areNearHelper(expC, actual.c, margin)
			&& FlxAssert.areNearHelper(expD, actual.d, margin)
			&& FlxAssert.areNearHelper(expX, actual.tx, margin)
			&& FlxAssert.areNearHelper(expY, actual.ty, margin))
		{
			Assert.assertionCount++;
		}
		else if (msg == null)
			Assert.fail('Matrix [$actual] is not within [$margin] of [${matrixToString(expA, expB, expC, expD, expX, expY)}]', pos);
		else
			Assert.fail(msg, pos);
	}
	
	static public function matrixToString(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float)
	{
		return FlxStringUtil.getDebugString
		([
			LabelValuePair.weak("a", a),
			LabelValuePair.weak("b", b),
			LabelValuePair.weak("c", c),
			LabelValuePair.weak("d", d),
			LabelValuePair.weak("tx", tx),
			LabelValuePair.weak("ty", ty)
		]);
	}
	function assertNear(expected:FlxMatrix, actual:FlxMatrix, margin = 0.001, ?msg:String, ?pos)
	{
		assertNearXY(expected.a, expected.b, expected.c, expected.d, expected.tx, expected.ty, actual, margin, msg, pos);
	}
}
