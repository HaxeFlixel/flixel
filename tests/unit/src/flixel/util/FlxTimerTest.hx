package flixel.util;

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
		timer.start(0, function(_) calledBack = true);
		step();

		Assert.isTrue(calledBack);
	}

	@Test
	function testCancelNoCallback()
	{
		timer.start(0.01, function(_) Assert.fail("Callback called"));
		timer.cancel();
		step();
	}

	@Test
	function testCompleteAllMultiLoop()
	{
		var loopsCompleted = 0;
		timer.start(1, function(_) loopsCompleted++, 2);
		Assert.areEqual(2, timer.loopsLeft);
		FlxTimer.globalManager.completeAll();
		Assert.areEqual(0, timer.loopsLeft);
		Assert.areEqual(2, loopsCompleted);
		Assert.isTrue(timer.finished);
	}

	@Test
	function testCompleteAllInactive()
	{
		timer.start(1, function(_) {}, 2);
		timer.active = false;
		FlxTimer.globalManager.completeAll();
		Assert.isFalse(timer.finished);
	}

	@Test // #679
	@:access(flixel.util.FlxTimerManager.remove)
	function testManipulateListInCallback()
	{
		var timer2 = new FlxTimer();
		var timer1 = new FlxTimer().start(0.0001, function(_) FlxTimer.globalManager.remove(timer2));
		timer2.start(0.2);
		var timer3 = new FlxTimer().start(0.2);

		step();
		Assert.isTrue(timer1.finished);
		// make sure these timers were updated
		Assert.isTrue(timer2.progress > 0);
		Assert.isTrue(timer3.progress > 0);
	}
}
