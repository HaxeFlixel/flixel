package flixel.math;

import flixel.math.FlxVector;
import massive.munit.Assert;

class FlxVectorTest extends FlxTest
{
	var vector:FlxVector;
	
	@Before
	function before():Void
	{
		vector = new FlxVector();
	}
	
	@Test
	function testZeroVectorSetLength():Void
	{
		vector.length = 10;
		
		Assert.areEqual(0, vector.x);
		Assert.areEqual(0, vector.y);
	}
	
	@Test
	function testSetLengthToZero():Void
	{
		vector.set(1, 1);
		vector.length = 0;
		
		Assert.areEqual(0, vector.x);
		Assert.areEqual(0, vector.y);
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
}