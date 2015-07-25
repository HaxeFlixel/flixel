package;

import flash.errors.Error;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;
import massive.munit.Assert;

class FlxTest
{
	// approx. amount of ticks at 60 fps
	static inline var TICKS_PER_FRAME:UInt = 25;
	static var totalSteps:UInt = 0;
	
	var destroyable:IFlxDestroyable;
	
	public function new() {}
	
	@:access(flixel)
	@AfterClass
	function afterClass()
	{
		FlxG.game.getTimer = function()
		{
			return totalSteps * TICKS_PER_FRAME;
		}
		
		// make sure we have the same starting conditions for each test
		FlxG.resetGame();
		step();
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
}