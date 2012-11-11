package;
import org.flixel.FlxParticle;

class Fire extends FlxParticle
{
	public function new()
	{
		super();
		loadGraphic("assets/fire.png", true);
		addAnimation("burn", [0, 1, 2, 3, 4, 5, 6, 7], 15, false);
		scale.x = scale.y = 2;
		exists = false;
	}
	
	override public function update():Void
	{
		if (finished)
		{
			exists = false;
		}
	}
	
	override public function onEmit():Void
	{
		play("burn", true);
		if(angularVelocity == 0)
		{
			angle = 0;
		}
		
		/*small square
		x = FlxG.width/2 - 25 + FlxG.random()*50;
		y = FlxG.height/2 - 25 + FlxG.random()*50;
		//*/
	}
}