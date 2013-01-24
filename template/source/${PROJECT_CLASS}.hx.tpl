package;

import nme.Lib;
import org.flixel.FlxGame;
	
class ${PROJECT_CLASS} extends FlxGame
{	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var ratioX:Float = stageWidth / ${WIDTH};
		var ratioY:Float = stageHeight / ${HEIGHT};
		var ratio:Float = Math.min(ratioX, ratioY);
		super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), MenuState, ratio, 30, 30);
	}
}
