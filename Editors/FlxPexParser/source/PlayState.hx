package;

import flixel.addons.editors.pex.FlxPexParser;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState
{
	var emitter:FlxEmitter;
	var emitterScale:Float = 1;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		emitter = new FlxEmitter(FlxG.width / 2, FlxG.height / 2);
		initEmitter();
		emitter.start(false, 0.01);
		add(emitter);
	}

	function initEmitter():Void
	{
		FlxPexParser.parse("assets/data/particle.pex", "assets/images/texture.png", emitter, emitterScale);
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.mouse.pressed)
		{
			emitter.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		}
		else if (FlxG.mouse.pressedRight)
		{
			emitterScale = emitterScale == 1 ? 2 : 1;
			initEmitter();
		}
		super.update(elapsed);
	}	
}
