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
		FlxG.mobile = true;
		super(400, 300, MenuState, 2, 20, 20);
	}
	
}