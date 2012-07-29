package;

import org.flixel.FlxGame;

class BreakoutGame extends FlxGame
{
	public function new()
	{
		super(320, 240, Breakout, 2, 60, 60);
		forceDebugger = true;
	}
}