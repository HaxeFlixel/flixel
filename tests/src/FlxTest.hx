package;

import flixel.FlxG;
import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;

class FlxTest
{
	public function new() {}
	
	@:AfterClass
	private function afterClass():Void
	{
		// make sure we have the same starting conditions for each test
		FlxG.resetGame();
	}
	
	function delay(testCase:Dynamic, factory:AsyncFactory, func:Void->Void, time:Int = 50)
	{
		var resultHandler = factory.createHandler(testCase, func);
		Timer.delay(resultHandler, time);
	}
}