package;

import org.flixel.FlxGame;
/**
 * ...
 * @author Zaphod
 */
class FlxTeroids extends FlxGame
{
	
	public function new() 
	{
		super(640, 480, MenuState, 1, 50, 50);
		forceDebugger = true;
	}
	
}