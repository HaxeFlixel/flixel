package;

import nme.Lib;
import org.flixel.FlxGame;
	
class ${PROJECT_CLASS} extends FlxGame
{
	
	#if flash
	public static var SoundExtension:String = ".mp3";
	#elseif neko
	public static var SoundExtension:String = ".ogg";
	#else
	public static var SoundExtension:String = ".wav";
	#end
	
	#if !neko
	public static var SoundOn:Bool = true;
	#else
	public static var SoundOn:Bool = true;
	#end
	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var ratioX:Float = stageWidth / ${WIDTH};
		var ratioY:Float = stageHeight / ${HEIGHT};
		var ratio:Float = Math.min(ratioX, ratioY);
		#if (flash || desktop || neko)
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), MenuState, ratio, 60, 60);
		#else
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), MenuState, ratio, 60, 30);
		#end
		forceDebugger = true;
	}
}
