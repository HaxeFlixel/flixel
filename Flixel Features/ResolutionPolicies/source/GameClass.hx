package;

import flash.Lib;
import flixel.FlxGame;
	
class GameClass extends FlxGame
{	
	public function new()
	{
		var fps:Int = 60;
		
		super(320, 240, PlayState, 2, fps, fps);
	}
}