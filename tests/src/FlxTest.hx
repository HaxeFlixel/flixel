package;

import flixel.FlxG;

class FlxTest
{
	public function new() {}
	
	@:AfterClass
	private function afterClass():Void
	{
		// make sure we have the same starting conditions for each test
		FlxG.resetGame();
	}
}