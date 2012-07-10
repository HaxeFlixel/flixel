package;

import org.flixel.FlxGame;

class Demo extends FlxGame
{
	public function new()
	{
		super(400, 300, CaveGenerationState, 1, 20, 20);
	}
}