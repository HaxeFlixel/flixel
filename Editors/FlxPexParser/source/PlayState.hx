package;

import flixel.addons.editors.pex.FlxPexParser;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	var emitter:FlxEmitter;

	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		emitter = new FlxEmitter(FlxG.width / 2, FlxG.height / 2);
		initEmitter();
		emitter.start(false, 0.01);
		add(emitter);

		var instructions = new FlxText(0, 10, 0,
			"Drag left mouse to move the fire\nHold right mouse to increase scale");
		instructions.alignment = CENTER;
		instructions.screenCenter(X);
		add(instructions);
	}

	function initEmitter(scale:Int = 1):Void
	{
		FlxPexParser.parse("assets/data/particle.pex", "assets/images/texture.png", emitter, scale);
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.mouse.pressed)
			emitter.setPosition(FlxG.mouse.x, FlxG.mouse.y);

		if (FlxG.mouse.justPressedRight)
			initEmitter(2);
		else if (FlxG.mouse.justReleasedRight)
			initEmitter(1);

		super.update(elapsed);
	}
}
