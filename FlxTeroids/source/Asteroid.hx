package;

import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Zaphod
 */
class Asteroid extends WrapSprite
{
	
	public function new() 
	{
		super();
		elasticity = 1; //bouncy!
		antialiasing = true; //Smooth rotations
	}
	
	public function create(?X:Int = 0, ?Y:Int = 0, ?VelocityX:Float = 0, ?VelocityY:Float = 0, ?Size:String = null):Asteroid
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
		alterBoundingBox();
		
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
		
		angle = FlxG.random() * 360;
		
		if((X != 0) || (Y != 0))
		{
			x = X;
			y = Y;
			velocity.x = VelocityX;
			velocity.y = VelocityY;
			angularVelocity = (Math.abs(velocity.x) + Math.abs(velocity.y));
			return this;
		}
		
		var initial_velocity:Int = 20;
		if(FlxG.random() < 0.5)
		{
			if(FlxG.random() < 0.5)	//Appears on the left
			{
				x = -64 + offset.x;
				velocity.x = initial_velocity / 2 + FlxG.random() * initial_velocity;
			}
			else
			{
				x = FlxG.width + offset.x;
				velocity.x = -initial_velocity / 2 - FlxG.random() * initial_velocity;
			}
			y = FlxG.random()*(FlxG.height-height);
			velocity.y = FlxG.random() * initial_velocity * 2 - initial_velocity;
		}
		else
		{
			if(FlxG.random() < 0.5)
			{
				y = -64 + offset.y;
				velocity.y = initial_velocity / 2 + FlxG.random() * initial_velocity;
			}
			else
			{
				y = FlxG.height + offset.y;
				velocity.y = -initial_velocity / 2 + FlxG.random() * initial_velocity;
			}
			x = FlxG.random()*(FlxG.width-width);
			velocity.x = FlxG.random() * initial_velocity * 2 - initial_velocity;
		}
		
		angularVelocity = (Math.abs(velocity.x) + Math.abs(velocity.y));
		return this;
	}
	
	override public function update():Void 
	{
		wrap();
		
		if (justTouched(FlxObject.ANY))
		{
			angularVelocity = (Math.abs(velocity.x) + Math.abs(velocity.y));
		}
		
		super.update();
	}
	
	override public function kill():Void 
	{
		super.kill();
		
		if(frameWidth <= 32)
		{
			return;
		}
		
		var initial_velocity:Int = 20;
		var slot:Int;
		var size:String;
		
		if(frameWidth >= 64)
		{
			size = "assets/medium.png";
			initial_velocity *= 2;
		}
		else
		{
			size = "assets/small.png";
			initial_velocity *= 3;
		}
		
		var numChunks:Int = Math.floor(2 + FlxG.random() * 3);
		for (i in 0...(numChunks))
		{
			var ax:Float = x + width / 2;
			var ay:Float = y + height / 2;
			var avx:Float = FlxG.random() * initial_velocity * 2 - initial_velocity;
			var avy:Float = FlxG.random() * initial_velocity * 2 - initial_velocity;
			
			var asteroid:Asteroid = cast(cast(FlxG.state, PlayState).asteroids.recycle(Asteroid), Asteroid);
			asteroid.create(Math.floor(ax), Math.floor(ay), avx, avy, size);
		}
	}
	
}