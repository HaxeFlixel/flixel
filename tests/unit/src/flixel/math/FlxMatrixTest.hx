package flixel.math;

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
}
