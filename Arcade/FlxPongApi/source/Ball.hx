package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class Ball extends PongSprite
{
	private var _minVelocity:FlxPoint;
	private var _exhaust:Emitter;
	private var _emitter:Emitter;
	
	inline private static function DEFAULT_VELOCITY():FlxPoint
	{
		return FlxPoint.get( -128, -128);
	}
	
	public function new()
	{
		super(Std.int(FlxG.width / 2), Std.int(FlxG.height / 2), 4, 4, Reg.dark);
		velocity = DEFAULT_VELOCITY();
		minVelocity = FlxPoint.get(32, 32);
		maxVelocity = FlxPoint.get(256, 256);
		drag = FlxPoint.get(0, 0);
		elasticity = 1.0;
	}
	
	public function init():Void
	{
		_exhaust = Reg.PS.emitterGroup.recycle(Emitter, function()
		{
			return new Emitter(x, y, 2, Reg.med_lite);
		}, true);
		_exhaust.acceleration.set(0, 0.5);
		_exhaust.velocity.set( -0.1, -0.1, 0.1, 0.1);
		_exhaust.alpha.set(0.7, 0.9, 0, 0);
		
		_emitter = Reg.PS.emitterGroup.add(new Emitter(Std.int(x), Std.int(y), 1));
		_emitter.width = width;
		_emitter.height = height;
	}
	
	override public function update(elapsed:Float):Void
	{
		FlxG.collide(this, Reg.PS.collidables, ballBounce);
		
		_exhaust.x = x;
		_exhaust.y = y;
		
		super.update(elapsed);
	}
	
	private function ballBounce(BallObject:FlxObject, CollidedWith:FlxObject):Void
	{
		FlxG.sound.play("plip");
	}
	
	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);
		velocity = DEFAULT_VELOCITY();
	}
	
	override public function kill():Void
	{
		_emitter.start(true);
		super.kill();
	}
}