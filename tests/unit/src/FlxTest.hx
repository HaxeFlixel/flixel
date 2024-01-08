package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;
import flixel.util.typeLimit.NextState;
import massive.munit.Assert;
import openfl.errors.Error;

class FlxTest
{
	// approx. amount of ticks at 60 fps
	static inline var TICKS_PER_FRAME:UInt = 25;
	static var totalSteps:UInt = 0;

	var destroyable:IFlxDestroyable;

	public function new() {}

	@After
	@:access(flixel)
	function after()
	{
		FlxG.game.getTimer = function()
		{
			return totalSteps * TICKS_PER_FRAME;
		}

		// make sure we have the same starting conditions for each test
		resetGame();
	}

	@:access(flixel)
	function step(steps:UInt = 1, ?callback:Void->Void)
	{
		for (i in 0...steps)
		{
			FlxG.game.step();
			if (callback != null)
				callback();
			totalSteps++;
		}
	}

	function resetGame()
	{
		FlxG.resetGame();
		step();
	}

	function switchState(nextState:NextState)
	{
		FlxG.switchState(nextState);
		step();
	}

	function resetState()
	{
		FlxG.resetState();
		step();
	}

	@Test
	function testDestroy()
	{
		if (destroyable == null)
		{
			return;
		}

		try
		{
			destroyable.destroy();
			destroyable.destroy();
		}
		catch (e:Error)
		{
			Assert.fail(e.message);
		}
	}

	function finishTween(tween:FlxTween)
	{
		while (!tween.finished)
		{
			step();
		}
	}
}
