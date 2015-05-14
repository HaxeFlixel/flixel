package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;

class Flake extends FlxSprite
{
	private var _level:Int = 0;
	private var _initialized:Bool = false;
	
	
	public function new(Level:Int = 0) 
	{
		
		super();
		_level = Level;
		revive();
		_initialized = true;
	}
	
	override public function revive():Void 
	{
		var size:Int = Std.int(FlxMath.bound(_level / 2, 1, 2));
		makeGraphic(size, size, FlxColor.WHITE.getDarkened(.5 - (_level * .06)));
		super.revive();
		alpha = 1;
		if (_initialized)
		{
			x = FlxG.random.int(0, FlxG.width * 4 * _level);
			y = FlxG.random.int( -5, -10);
		}
		else
		{
			x = FlxG.random.int(0, FlxG.width * 4 * _level);
			y = FlxG.random.int( -10, FlxG.height);
		}
		scrollFactor.set(.7 + (_level * .1), 0);
		velocity.y = FlxG.random.int(20, 40) * ((_level+1) * .2);
		velocity.x = FlxG.random.int( -25, -50) * ((_level+1) * .1);
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		
		if (velocity.y == 0)
			alpha -= elapsed * .5;
		else
		{
			if (x < 0 || y > FlxG.height || alpha <= 0)
			{
				revive();
			}
			else if (y >= FlxG.height - 64 && _level <= 3)
			{
				if (_level == 3)
				{
					scrollFactor.x = 1;
					velocity.set();
					y = FlxG.height - 65;
				}
				else
					revive();
				
			}
		}
		super.update(elapsed);
		
	}
}