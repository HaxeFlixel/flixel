package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Explosion extends FlxSprite
{
	private var _delay:Float = 0;
	private var _target:FlxSprite;
	private var _pos:FlxPoint;
	
	public function new() 
	{
		super();
		loadGraphic(AssetPaths.explosion__png, true, 25, 25);
		animation.add("explode", [0, 1, 2], 12, false);
		_pos = FlxPoint.get();
	}
	
	public function explode(Target:FlxSprite, Delay:Float = 0):Void
	{
		_delay = Delay;
		
		_target = Target;
		_pos.x = FlxG.random.float(-20, _target.width-5);
		_pos.y = FlxG.random.float( -20, _target.height-5);
		reset(_target.x + _pos.x, _target.y + _pos.y);
		
		visible = false;
	}
	
	override public function draw():Void 
	{
		x = _target.x + _pos.x;
		y = _target.y + _pos.y;
		super.draw();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (alive && !visible)
		{
			if (_delay <= 0)
			{
				visible = true;
				FlxG.sound.play(AssetPaths.Explosion__wav,.66);
				animation.play("explode");
			}
			else
				_delay -= elapsed * 6;
		}
		else if (alive && visible)
		{
			if (animation.finished)
			{
				animation.pause();
				kill();
			}
		}
	}
}