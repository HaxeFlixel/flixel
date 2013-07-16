package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Zaphod
 */
class Asteroid extends FlxSprite
{
	public function new() 
	{
		super();
		
		// Bouncy!
		elasticity = 1; 
		// Smooth rotations
		antialiasing = true; 
	}
	
	public function init(X:Int = 0, Y:Int = 0, VelocityX:Float = 0, VelocityY:Float = 0, ?Size:String):Asteroid
	{
		exists = true;
		visible = true;
		active = true;
		solid = true;
		
		#if flash
		loadRotatedGraphic((Size == null) ? "assets/large.png" : Size, 100, -1, false, true);
		#else
		loadGraphic((Size == null) ? "assets/large.png" : Size);
		#end
		
		width *= 0.75;
		height *= 0.75;
		centerOffsets();
		
		if (Size == null)
		{
			mass = 9;
		}
		else if (Size == "assets/medium.png")
		{
			mass = 3;
		}
		else
		{
			mass = 1;
		}
		
		angle = FlxRandom.float() * 360;
		
		if ((X != 0) || (Y != 0))
		{
			x = X;
			y = Y;
			velocity.x = VelocityX;
			velocity.y = VelocityY;
			angularVelocity = (Math.abs(velocity.x) + Math.abs(velocity.y));
			
			return this;
		}
		
		var initial_velocity:Int = 100;
		
		if (FlxRandom.float() < 0.5)
		{
			// Appears on the left
			if (FlxRandom.float() < 0.5)	
			{
				x = - 64 + offset.x;
				velocity.x = initial_velocity / 2 + FlxRandom.float() * initial_velocity;
			}
			else
			{
				x = FlxG.width + offset.x;
				velocity.x = -initial_velocity / 2 - FlxRandom.float() * initial_velocity;
			}
			
			y = FlxRandom.float()*(FlxG.height-height);
			velocity.y = FlxRandom.float() * initial_velocity * 2 - initial_velocity;
		}
		else
		{
			if (FlxRandom.float() < 0.5)
			{
				y = - 64 + offset.y;
				velocity.y = initial_velocity / 2 + FlxRandom.float() * initial_velocity;
			}
			else
			{
				y = FlxG.height + offset.y;
				velocity.y = - initial_velocity / 2 + FlxRandom.float() * initial_velocity;
			}
			
			x = FlxRandom.float()*(FlxG.width-width);
			velocity.x = FlxRandom.float() * initial_velocity * 2 - initial_velocity;
		}
		
		angularVelocity = (Math.abs(velocity.x) + Math.abs(velocity.y));
		
		return this;
	}
	
	override public function update():Void 
	{
		if (justTouched(FlxObject.ANY))
		{
			angularVelocity = (Math.abs(velocity.x) + Math.abs(velocity.y));
		}
		
		FlxSpriteUtil.screenWrap(this);
		
		super.update();
	}
	
	override public function kill():Void 
	{
		super.kill();
		
		if (frameWidth <= 32)
		{
			return;
		}
		
		var initial_velocity:Int = 25;
		var slot:Int;
		var size:String;
		
		if (frameWidth >= 64)
		{
			size = "assets/medium.png";
			initial_velocity *= 2;
		}
		else
		{
			size = "assets/small.png";
			initial_velocity *= 3;
		}
		
		var numChunks:Int = Math.floor(2 + FlxRandom.float() * 3);
		
		for (i in 0...numChunks)
		{
			var ax:Float = x + width / 2;
			var ay:Float = y + height / 2;
			var avx:Float = FlxRandom.float() * initial_velocity * 2 - initial_velocity;
			var avy:Float = FlxRandom.float() * initial_velocity * 2 - initial_velocity;
			
			var asteroid:Asteroid = PlayState.asteroids.recycle(Asteroid);
			asteroid.init(Math.floor(ax), Math.floor(ay), avx, avy, size);
		}
	}
}