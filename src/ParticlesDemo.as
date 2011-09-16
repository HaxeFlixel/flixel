package
{
	import org.flixel.*;
	[SWF(width="400", height="300", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class ParticlesDemo extends FlxGame
	{
		public function ParticlesDemo()
		{
			super(400,300,MenuState,1,20,20);
		}
	}
}
