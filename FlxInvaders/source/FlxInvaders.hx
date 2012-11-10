package;
import org.flixel.FlxG;
import org.flixel.FlxGame;

class FlxInvaders extends FlxGame
{
	public function new()
	{
		super(320, 240, PlayState, 2); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState
		#if !neko
		FlxG.bgColor = 0x000000;
		#end
		forceDebugger = true;
		
		//Here we are just displaying the cursor to encourage people to click the game,
		// which will give Flash the browser focus and let the keyboard work.
		//Normally we would do this in say the main menu state or something,
		// but FlxInvaders has no menu :P
		FlxG.mouse.show();
	}
}