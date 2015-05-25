package flixel.math;

import flixel.math.FlxRect;
import massive.munit.Assert;

class FlxRectTest extends FlxTest
{
	var rect1:FlxRect;
	var rect2:FlxRect;
	
	@Before
	function before()
	{
		rect1 = new FlxRect();
		rect2 = new FlxRect();
	}
	
	@Test
	function testEqualsTrue()
	{
		rect1.set(0, 0, 10, 10);
		rect2.set(0, 0, 10, 10);
		
		Assert.isTrue(rect1.equals(rect2));
	}
	
	@Test
	function testEqualsFalse()
	{
		rect1.set(0, 0, 10, 10.1);
		rect2.set(0, 0, 10, 10);
		
		Assert.isFalse(rect1.equals(rect2));
	}
}