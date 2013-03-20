package;

import org.flixel.FlxGame;
import com.chipacabra.jumper.MenuState;
	
class Jumper extends FlxGame
{
	
	#if flash
	public static var SoundExtension:String = ".mp3";
	#else
	public static var SoundExtension:String = ".wav";
	#end
	
	public static var SoundOn:Bool = true;
	
	public function new()
	{
		super(640, 480, MenuState, 1, 40, 40);
	}
}
