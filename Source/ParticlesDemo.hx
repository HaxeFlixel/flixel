package ;
import org.flixel.FlxG;
import org.flixel.FlxGame;

/**
 * ...
 * @author Zaphod
 */

class ParticlesDemo extends FlxGame
{

	public function new() 
	{
		FlxG.mobile = false;
		super(400, 300, MenuState, 1, 20, 20);
	}
	
}