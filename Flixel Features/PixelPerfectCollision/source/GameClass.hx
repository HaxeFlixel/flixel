package;

import flash.Lib;
import flixel.FlxGame;
import openfl.display.FPS;


/**
 * @author azrafe7
 */
class GameClass extends FlxGame
{	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var scale:Float = 2;
		var fps:Int = 60;
		
		super(Math.ceil(stageWidth / scale), Math.ceil(stageHeight / scale), PlayState, scale, fps, fps);
	}
}