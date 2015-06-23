package flixel.math;

import flixel.util.FlxColor;
import massive.munit.Assert;
import flixel.math.FlxRandom;

class FlxRandomTest extends FlxTest
{
	var random:FlxRandom;
	
	@Before
	function before()
	{
		random = new FlxRandom();
	}
	
	@Test // #1172
	function testIntExcludes()
	{
		for (i in 0...20)
		{
			Assert.areEqual(0, random.int(0, 1, [1]));
		}
	}
	
	@Test // #1536
	function testColorNullException()
	{
		random.color(null, null);
		random.color(FlxColor.GRAY, null);
		random.color(null, FlxColor.GRAY);
		
		random.color(null, null, null);
		random.color(FlxColor.GRAY, null, null);
		random.color(null, FlxColor.GRAY, null);
		random.color(FlxColor.RED, FlxColor.GRAY, null);
	}
}