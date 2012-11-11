package;
import org.flixel.FlxGame;

class FlxBloom extends FlxGame
{
	public function new()
	{
		super(640, 480, PlayState, 1, 60, 60);
		forceDebugger = true;
	}
}