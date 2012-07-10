package;
import org.flixel.FlxGame;


class ParticleTest extends FlxGame
{
	public function new()
	{
		super(320, 240, TestState, 2, 60, 60);
		forceDebugger = true;
	}
}
