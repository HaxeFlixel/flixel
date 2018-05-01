package;

import flixel.FlxG;
import flixel.tweens.FlxTween;

class Enemy extends PongSprite
{
	var _emitter:Emitter;
	
	public function new()
	{
		super(FlxG.width, 0, Reg.level, Reg.level * 4, Reg.dark);
		reset(0, 0);
	}
	
	public function init():Void
	{
		_emitter = Reg.PS.emitterGroup.add(new Emitter(Std.int(x), Std.int(y), 1));
		_emitter.width = width;
		_emitter.height = height;
	}
	
	override public function update(elapsed:Float):Void
	{
		acceleration.x = acceleration.y = 0;
		
		if (Reg.PS.ball.my < my)
			velocity.y = -Reg.level;
		
		if (Reg.PS.ball.my > my)
			velocity.y = Reg.level;
		
		super.update(elapsed);
	}
	
	override public function reset(X:Float, Y:Float):Void
	{
		makeGraphic(Reg.level, Reg.level * 4, Reg.dark);
		super.reset(FlxG.width, Std.int((FlxG.height - height) / 2));
		FlxTween.linearMotion(this, this.x, this.y, this.x - 20, this.y, 1);
	}
	
	override public function kill():Void
	{
		_emitter.start(true);
		FlxG.sound.play("kaboom");
		
		super.kill();
	}
}