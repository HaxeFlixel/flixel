package;

import addonsTests.CaveGeneratorTest;
import org.flixel.FlxGame;
	
class Mode extends FlxGame
{
	public function new()
	{
		super(320, 240, MenuState, 2, 50, 50);
		//super(320, 240, CaveGeneratorTest, 2, 50, 50);
		forceDebugger = true;
	}
}
