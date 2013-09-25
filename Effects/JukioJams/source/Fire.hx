package;

import flixel.util.FlxRandom;
import flixel.effects.particles.FlxParticle;

class Fire extends FlxParticle
{
	public function new()
	{
		super();
		
		loadGraphic("assets/fire.png", true);
		this.animation.add("burn", [0, 1, 2, 3, 4, 5, 6, 7], 15, false);
		scale.set(2, 2);
		exists = false;
	}
	
	override public function update():Void
	{
		if (this.animation.finished)
		{
			exists = false;
		}
	}
	
	override public function onEmit():Void
	{
		this.animation.play("burn", true);
		
		if (angularVelocity == 0)
		{
			angle = 0;
		}
	}
}