package;

import addonsTests.CaveGeneratorTest;
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
		super(320, 240, MenuState, 2, 30, 30);
		//super(320, 240, CaveGeneratorTest, 2, 50, 50);
		forceDebugger = true;
	}
}
