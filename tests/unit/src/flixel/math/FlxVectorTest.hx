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
}