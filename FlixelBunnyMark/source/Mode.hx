package;

import nme.Lib;
import org.flixel.FlxGame;
	
class Mode extends FlxGame
{
	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		#if (flash || desktop || neko)
		super(stageWidth, stageHeight, BunnyMarkState, 1, 60, 60);
		#else
		super(stageWidth, stageHeight, BunnyMarkState, 1, 60, 30);
		#end

	}
}
