package;

import flixel.addons.editors.pex.FlxPexParser;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState
{
	var emitter:FlxEmitter;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		emitter = FlxPexParser.parse("assets/data/particle.pex", "assets/images/texture.png");
		emitter.x = FlxG.width / 2;
		emitter.y = FlxG.height / 2;
		emitter.start(false, 0.01);
		add(emitter);
	}

	override public function update():Void
	{
		if (FlxG.mouse.pressed)
		{
			emitter.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		}
		super.update();
	}	
}
