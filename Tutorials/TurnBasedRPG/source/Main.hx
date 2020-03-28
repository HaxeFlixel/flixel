package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxSave;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		var startFullscreen:Bool = false;
		var save:FlxSave = new FlxSave();
		save.bind("TurnBasedRPG");
		#if desktop
		if (save.data.fullscreen != null)
		{
			startFullscreen = save.data.fullscreen;
		}
		#end

		super();
		addChild(new FlxGame(320, 240, MenuState, 1, 60, 60, false, startFullscreen));

		if (save.data.volume != null)
		{
			FlxG.sound.volume = save.data.volume;
		}
		save.close();
	}
}
