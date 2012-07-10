package ;
import org.flixel.FlxGame;

/**
 * ...
 * @author Zaphod
 */

class SaveDemo extends FlxGame
{

	public function new() 
	{
		super(400, 300, MenuState, 1, 20, 20);
		forceDebugger = true;
	}
	
}