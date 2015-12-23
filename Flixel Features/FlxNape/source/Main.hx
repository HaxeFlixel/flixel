package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.Piramid;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(640, 480, Piramid));
	}
}