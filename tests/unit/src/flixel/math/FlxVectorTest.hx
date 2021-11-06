package flixel.math;

import massive.munit.Assert;

@:access(flixel.math.FlxPoint)
class FlxVectorTest extends FlxTest
{
	var vector:FlxVector;
	var vector2:FlxVector;

	@Before
	function before():Void
	{
		vector = new FlxVector();
		vector2 = new FlxVector();
	}

	@Test
	function testZeroVectorSetLength():Void
	{
		vector.length = 10;

		Assert.isTrue(vector.equals(new FlxVector(0, 0)));
	}

	@Test
	function testSetLengthToZero():Void
	{
		vector.set(1, 1);
		vector.length = 0;

		Assert.isTrue(vector.equals(new FlxVector(0, 0)));
	}

	@Test
	function testUnitVectorSetLength():Void
	{
		vector.set(1, 1);
		vector.length = Math.sqrt(2) * 2;

		var xIsInRange = (vector.x > 1.999 && vector.x < 2.001);
		var yIsInRange = (vector.y > 1.999 && vector.y < 2.001);
		Assert.isTrue(xIsInRange);
		Assert.isTrue(yIsInRange);
	}

	@Test
	function testDegreesBetween():Void
	{
		vector.set(0, 1);
		vector2.set(1, 0);

		Assert.areEqual(90, vector.degreesBetween(vector2));
	}

	@Test
	function testAddNew():Void
	{
		vector.set(1, 2);
		vector2.set(3, 5);

		Assert.isTrue(vector.addNew(vector2).equals(new FlxVector(4, 7)));
		Assert.isTrue(vector.equals(new FlxVector(1, 2)));
	}

	@Test
	function testSubtractNew():Void
	{
		vector.set(1, 2);
		vector2.set(3, 5);

		Assert.isTrue(vector.subtractNew(vector2).equals(new FlxVector(-2, -3)));
		Assert.isTrue(vector.equals(new FlxVector(1, 2)));
	}

	@Test // #1959
	function testNormalizeZero():Void
	{
		vector.set(0, 0);
		var normalized = vector.normalize();
		Assert.isTrue(normalized.equals(new FlxVector(0, 0)));
	}

	@Test
	function testSumVectorsOp()
	{
		vector.set(1, 2);
		vector2.set(3, 5);

		var result = vector + vector2;

		Assert.isTrue(result.equals(FlxVector.weak(4, 7)));
		Assert.isTrue(vector.equals(FlxVector.weak(1, 2)));

		var a = FlxVector.weak(1, 2);
		var b = FlxVector.weak(3, 5);
		result = a + b;

		Assert.isTrue(a._inPool);
		Assert.isTrue(b._inPool);
		Assert.isTrue(result._weak);
	}

	@Test
	function testSubtractVectorsOp():Void
	{
		vector.set(1, 2);
		vector2.set(3, 5);

		var result = vector - vector2;

		Assert.isTrue(result.equals(FlxVector.weak(-2, -3)));
		Assert.isTrue(vector.equals(FlxVector.weak(1, 2)));

		var a = FlxVector.weak(1, 2);
		var b = FlxVector.weak(3, 5);

		result = a - b;

		Assert.isTrue(a._inPool);
		Assert.isTrue(b._inPool);
		Assert.isTrue(result._weak);
	}

	@Test
	function testScaleVectorOp():Void
	{
		vector.set(2, 3);

		var result = vector * 3;

		Assert.isTrue(result.equals(FlxVector.weak(6, 9)));
		Assert.isTrue(vector.equals(FlxVector.weak(2, 3)));
		Assert.isTrue((3 * vector).equals(FlxVector.weak(6, 9)));

		var a = FlxVector.weak(1, 2);
		result = 2 * a;

		Assert.isTrue(a._inPool);
		Assert.isTrue(result._weak);
	}

	@Test
	function testScaleOperatorOverloading():Void
	{
		vector.set(2, 3);

		Assert.isTrue((vector *= 3).equals(FlxVector.weak(6, 9)));
		Assert.isTrue(vector.equals(FlxVector.weak(6, 9)));
	}

	@Test
	function testDotProductOp():Void
	{
		var a = FlxVector.weak(1, 2);
		var b = FlxVector.weak(2, 3);

		var result = a * b;

		Assert.areEqual(8, result);
		Assert.isTrue(a._inPool);
		Assert.isTrue(b._inPool);
	}

	@Test
	function testAddPointOperatorOverloading():Void
	{
		vector.set(1, 2);
		vector2.set(3, 4);

		Assert.isTrue((vector += vector2).equals(FlxVector.weak(4, 6)));
		Assert.isTrue(vector.equals(FlxVector.weak(4, 6)));
	}

	@Test
	function testSubtractPointOperatorOverloading():Void
	{
		vector.set(1, 2);
		vector2.set(3, 4);

		Assert.isTrue((vector -= vector2).equals(FlxVector.weak(-2, -2)));
		Assert.isTrue(vector.equals(FlxVector.weak(-2, -2)));
	}

	@Test
	function testNegateVectorOp()
	{
		vector.set(-1, -2);

		var result = -vector;

		Assert.isTrue(result.equals(FlxVector.weak(1, 2)));
		Assert.isTrue(vector.equals(FlxVector.weak(-1, -2)));

		var a = FlxVector.weak(1, 2);
		result = -a;

		Assert.isTrue(a._inPool);
		Assert.isTrue(result._weak);
	}
}
