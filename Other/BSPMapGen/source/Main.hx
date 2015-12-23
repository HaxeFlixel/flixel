package;

import flixel.FlxGame;
import generate.GenerateState;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(640, 480, GenerateState));
	}
}