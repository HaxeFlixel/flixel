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
		var _save:FlxSave = new FlxSave();
		_save.bind("flixel-tutorial");
		#if desktop
		if (_save.data.fullscreen != null)
		{
			startFullscreen = _save.data.fullscreen;
		}
		#end
		
		super();
		addChild(new FlxGame(320, 240, MenuState, 1, 60, 60, false, startFullscreen));
		
		if (_save.data.volume != null)
		{
			FlxG.sound.volume = _save.data.volume;
		}
		_save.close();
	}
}