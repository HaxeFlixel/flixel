package;

import flash.Lib;
import flixel.FlxGame;
import flixel.system.FlxSplash;

class ProjectClass extends FlxGame
{
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		var ratioX:Float = stageWidth / 640;
		var ratioY:Float = stageHeight / 480;
		var ratio:Float = Math.min(ratioX, ratioY);

		var fps:Int = 60;

		// we're in debug mode because we need the debug drawing, but let's play the splash anyway!
		FlxSplash.nextState = MenuState;
		super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), FlxSplash, ratio, fps, fps);
	}
}
