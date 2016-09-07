package flixel.util;

import massive.munit.Assert;

class FlxTimerTest extends FlxTest
{
	var timer:FlxTimer;
	var loopsCompleted:Int;
	
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
	
	@Test
	function testCompleteAllMultiLoop()
	{
		loopsCompleted = 0;
		timer.start(1, function(_)
		{
			loopsCompleted++;
		}, 2);
		Assert.areEqual(2, timer.loopsLeft);
		FlxTimer.manager.completeAll();
		Assert.areEqual(0, timer.loopsLeft);
		Assert.areEqual(2, loopsCompleted);
		step();
	}
}