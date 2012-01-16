package;

import addonsTests.CaveGeneratorTest;
import nme.Lib;
import org.flixel.FlxGame;
	
class Mode extends FlxGame
{
	
	#if flash
	public static var SoundExtension:String = ".mp3";
	#else
	public static var SoundExtension:String = ".wav";
	#end
	
	public static var SoundOn:Bool = true;
	
	public function new()
	{
		#if flash
		super(320, 240, MenuState, 2, 60, 60);
		#else
		// we make it fullscreen
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var ratioX:Float = stageWidth / 320;
		var ratioY:Float = stageHeight / 240;
		var ratio:Float = Math.min(ratioX, ratioY);
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), MenuState, ratio, 60, 30);
		#end
		//super(320, 240, CaveGeneratorTest, 2, 50, 50);
		//forceDebugger = true;
	}
}
