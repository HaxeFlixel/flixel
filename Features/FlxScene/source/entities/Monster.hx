package entities;

import flixel.FlxSprite;
import flixel.FlxG;

class Monster extends FlxSprite
{
	public function new()
	{
		super();
		loadGraphic("assets/monster.png");
		angularVelocity = 100;
	}
}
