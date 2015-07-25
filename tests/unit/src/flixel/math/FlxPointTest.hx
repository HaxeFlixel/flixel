package flixel.math;

import flixel.math.FlxPoint;
import massive.munit.Assert;

class FlxPointTest extends FlxTest
{
	var point1:FlxPoint;
	var point2:FlxPoint;
	
	@Before
	function before()
	{
		point1 = new FlxPoint();
		point2 = new FlxPoint();
	}
	
	@Test
	function testEqualsTrue()
	{
		point1.set(10, 10);
		point2.set(10, 10);
		
		Assert.isTrue(point1.equals(point2));
	}
	
	@Test
	function testEqualsFalse()
	{
		point1.set(10, 10.1);
		point2.set(10, 10);
		
		Assert.isFalse(point1.equals(point2));
	}
}