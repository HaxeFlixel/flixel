package;

import flixel.util.FlxColorUtil;
import flixel.FlxG;
import flixel.util.FlxPoint;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

class SinThing extends FlxSprite
{
	public var s:FlxPoint;
	public var flippedFlag:Bool;
	public var half:Bool;
	
	private var _timer:Float;
	
	public function new(Toggled:Bool)
	{
		super();
		
		var base:Int = 0;
		var fr:Float = 10 + FlxRandom.float() * 10;
		
		switch (Std.int(FlxRandom.float() * 3))
		{
			case 0:
				loadGraphic("assets/particle_square.png", true, false, 18, 18);
				if(Toggled)
				{
					base = 5;
				}
				animation.add("idle", [base + 0, base + 1, base + 2, base + 3, base + 4, base + 3, base + 2, base + 1], 20);
			case 1:
				loadGraphic("assets/particle_circloid.png", true, false, 18, 18);
				if(Toggled)
				{
					base = 5;
				}
				animation.add("idle", [base + 0, base + 1, base + 2, base + 3, base + 4, base + 3, base + 2, base + 1], 20);
			case 2:
				loadGraphic("assets/particle_diamond_big.png", true, false, 31, 31);
				if(Toggled)
				{
					base = 8;
				}
				animation.add("idle", [base + 0, base + 1, base + 2, base + 3, base + 4, base + 5, base + 6, base + 7, base + 6, base + 5, base + 4, base + 3, base + 2, base + 1], 20);
		}

		animation.play("idle");
		
		s = new FlxPoint(FlxG.width * FlxRandom.float(), FlxG.height * FlxRandom.float());
		
		if (FlxRandom.float() < 0.5)
		{
			flippedFlag = true;
		}
		
		if (FlxRandom.float() < 0.3)
		{
			half = true;
		}
		
		_timer = 0;
	}
	
	override public function update():Void
	{
		var amount:Float = FlxG.elapsed * (60 / TempoController.timing) * 0.0075;
		
		if (flippedFlag)
		{
			amount = -amount;
		}
		
		s.x += amount;
		s.y += amount;
		x = FlxG.width * 0.5 + Math.sin(s.x) * FlxG.width * 0.5 * (half?0.5:1);
		y = FlxG.height * 0.5 + Math.sin(s.y) * FlxG.height * 0.5 * (half?0.5:1);
		
		_timer += FlxG.elapsed;

		if (_timer > TempoController.timing)
		{
			_timer = 0;
			color = FlxColorUtil.getRandomColor();
		}
	}
}