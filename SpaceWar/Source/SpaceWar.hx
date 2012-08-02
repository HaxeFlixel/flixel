package;

import org.flixel.FlxG;
import org.flixel.FlxGame;

class SpaceWar extends FlxGame
{
	public function new()
	{
		super(640, 480, MenuState, 1, 60, 60);
		#if !neko
		FlxG.bgColor = 0x00808080;
		#else
		FlxG.bgColor = {rgb: 0x808080, a: 0x00};
		#end
	}
}