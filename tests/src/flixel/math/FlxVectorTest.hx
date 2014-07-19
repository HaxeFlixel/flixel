package flixel.math;

import flixel.math.FlxVector;
import massive.munit.Assert;

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
		
		assertFlxVectorAreEqual(new FlxVector(0, 0), vector);
	}
	
	@Test
	function testSetLengthToZero():Void
	{
		vector.set(1, 1);
		vector.length = 0;

		assertFlxVectorAreEqual(new FlxVector(0, 0), vector);
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

		assertFlxVectorAreEqual(new FlxVector(4, 7), vector.addNew(vector2));
		assertFlxVectorAreEqual(new FlxVector(1, 2), vector);
	}

	@Test
	function testSubtractNew():Void
	{
		vector.set(1, 2);
		vector2.set(3, 5);

		assertFlxVectorAreEqual(new FlxVector(-2, -3), vector.subtractNew(vector2));
		assertFlxVectorAreEqual(new FlxVector(1, 2), vector);
	}

	function assertFlxVectorAreEqual(expected:FlxVector, actual:FlxVector):Void
	{
		Assert.areEqual(expected.x, actual.x);
		Assert.areEqual(expected.y, actual.y);
	}
}