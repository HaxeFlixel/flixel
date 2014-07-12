package;

import flash.errors.Error;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;

class FlxTest
{
	var destroyable:IFlxDestroyable;
	
	public function new() {}
	
	@:AfterClass
	function afterClass():Void
	{
		// make sure we have the same starting conditions for each test
		FlxG.resetGame();
	}
	
	function delay(testCase:Dynamic, factory:AsyncFactory, func:Void->Void, time:Int = 50)
	{
		var resultHandler = factory.createHandler(testCase, func);
		Timer.delay(resultHandler, time);
	}
	
	@:access(flixel)
	function step()
	{
		FlxG.game.step();
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