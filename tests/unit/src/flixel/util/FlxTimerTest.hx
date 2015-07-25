package flixel.util;

import flixel.util.FlxTimer;
import massive.munit.Assert;

class FlxTimerTest extends FlxTest
{
	var timer:FlxTimer;
	
	@Before
	function before()
	{
		timer = new FlxTimer();
		destroyable = timer;
	}
	
	@Test
	function testZeroTimer()
	{
		var calledBack:Bool = false;
		timer.start(0, function(_)
		{
			calledBack = true;
		});
		step();
		
		Assert.isTrue(calledBack);
	}
	
	@Test
	function testCancelNoCallback()
	{
		timer.start(0.01, function(_)
		{
			Assert.fail("Callback called");
		});
		timer.cancel();
		step();
	}
}