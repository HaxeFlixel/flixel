package;

import flixel.FlxG;
import haxe.Timer;

class FlxTest
{
	public function new() {}
	
	@:AfterClass
	private function afterClass():Void
	{
		// make sure we have the same starting conditions for each test
		FlxG.resetGame();
	}
	
	function delay(f:Void->Void)
	{
		Timer.delay(f, 1000);
	}
}