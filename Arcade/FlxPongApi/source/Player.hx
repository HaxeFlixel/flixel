package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

class Player extends PongSprite
{
	var _emitter:Emitter;

	public function new()
	{
		super(16, Std.int((FlxG.height - 16) / 2), 4, 16, Reg.dark);

		moves = false;
		immovable = true;
	}

	public function init():Void
	{
		_emitter = Reg.PS.emitterGroup.add(new Emitter(x, y, 1));
		_emitter.width = width;
		_emitter.height = height;
	}

	override public function update(elapsed:Float):Void
	{
		FlxVelocity.accelerateTowardsPoint(this, FlxPoint.weak(x, 10), 10, 10);
		super.update(elapsed);
	}

	override public function kill():Void
	{
		_emitter.start(true);
		FlxG.sound.play("kaboom");

		super.kill();
	}
}
