package;

import flixel.FlxSprite;
import flixel.FlxG;

/**
 * ...
 * @author Zaphod
 */
class Bunny extends FlxSprite
{
	public function new() 
	{
		super();
		
		#if flash
		loadRotatedGraphic("assets/wabbit_alpha.png", 16, -1, false, true);
		#else
		loadGraphic("assets/wabbit_alpha.png");
		#end
	}
	
	public function init(Offscreen:Bool = false):Bunny
	{
		var speedMultiplier:Int = 50;
		
		if (Offscreen)
		{
			speedMultiplier = 5000;
		}
		
		velocity.x = speedMultiplier * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1);
		velocity.y = speedMultiplier * ((Math.random() * 5) - 2.5) * (Math.random() < 0.5 ? 1 : -1);
		acceleration.y = 5;
		angle = 15 - Math.random() * 30;
		angularVelocity = 30 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1);
		complex = PlayState.complex;
		elasticity = 1;
		
		return this;
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (complex)
		{
			alpha = 0.3 + 0.7 * y / FlxG.height;
		}
		
		if (!PlayState.offScreen)
		{
			setBounds();
		}
	}
	
	private function setBounds():Void
	{
		if (x > FlxG.width)
		{
			velocity.x *= -1;
			x = FlxG.width;
		}
		else if (x < 0)
		{
			velocity.x *= -1;
			x = 0;
		}
		
		if (y > FlxG.height)
		{
			velocity.y *= -0.8;
			y = FlxG.height;
			
			if (Math.random() > 0.5) 
			{
				velocity.y -= 3 + Math.random() * 4;
			}
		}
		else if (y < 0)
		{
			velocity.y *= -0.8;
			y = 0;
		}
	}
	
	public var complex(default, set):Bool = false;
	
	private function set_complex(Value:Bool):Bool
	{
		if (Value)
		{
			scale.x = scale.y = 0.3 + Math.random();
		}
		else 
		{
			scale.set(1, 1);
			alpha = 1;
		}
		
		return complex = Value;
	}
}