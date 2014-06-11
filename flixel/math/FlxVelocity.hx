package flixel.math;

import flixel.FlxG;
import flixel.FlxSprite;
#if !FLX_NO_TOUCH
import flixel.input.touch.FlxTouch;
#end

class FlxVelocity 
{	
	/**
	 * Sets the x/y velocity on the source FlxSprite so it will move towards the target coordinates at the speed given (in pixels per second)
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.
	 * 
	 * @param	Source		The FlxSprite to move
	 * @param	Target		The FlxPoint coordinates to move the source FlxSprite towards
	 * @param	Speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	MaxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsPoint(Source:FlxSprite, Target:FlxPoint, Speed:Float = 60, MaxTime:Int = 0):Void
	{
		var sourcePoint = Source.toPoint();
		var angle:Float = sourcePoint.getAngle(Target) - 90;
		
		if (MaxTime > 0)
		{
			var distance:Float = sourcePoint.getDistance(Target);
			
			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(distance / (MaxTime / 1000));
		}
		
		Source.velocity.set(Speed, Speed);
		Source.velocity.angle = angle;
		
		sourcePoint.put();
		Target.putWeak();
	}
	
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards the target coordinates at the speed given (in pixels per second)
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.
	 * If you don't need acceleration look at moveTowardsPoint() instead.
	 * 
	 * @param	Source			The FlxSprite on which the acceleration will be set
	 * @param	Target			The FlxPoint coordinates to move the source FlxSprite towards
	 * @param	Speed			The speed it will accelerate in pixels per second
	 * @param	MaxXSpeed		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	MaxYSpeed		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	public static function accelerateTowardsPoint(Source:FlxSprite, Target:FlxPoint, Acceleration:Float, MaxXSpeed:Float, MaxYSpeed:Float):Void
	{
		var sourcePoint = Source.toPoint();
		var angle:Float = sourcePoint.getAngle(Target) - 90;
		
		Source.velocity.set();
		
		Source.acceleration.set(Acceleration, Acceleration);
		Source.acceleration.angle = angle;
		
		Source.maxVelocity.set(MaxXSpeed, MaxYSpeed);
		
		sourcePoint.put();
		Target.putWeak();
	}
	
	/**
	 * Given the angle and speed calculate the velocity and return it as an FlxPoint
	 * 
	 * @param	Angle	The angle (in degrees) calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * @param	Speed	The speed it will move, in pixels per second sq
	 * @return	A FlxPoint where FlxPoint.x contains the velocity x value and FlxPoint.y contains the velocity y value
	 */
	public static inline function velocityFromAngle(Angle:Float, Speed:Float):FlxPoint
	{
		var a:Float = FlxAngle.asRadians(Angle);
		
		var result = FlxPoint.get();
		
		result.x = Math.cos(a) * Speed;
		result.y = Math.sin(a) * Speed;
		
		return result;
	}
	
	/**
	 * Given the FlxSprite and speed calculate the velocity and return it as an FlxPoint based on the direction the sprite is facing
	 * 
	 * @param	Parent	The FlxSprite to get the facing value from
	 * @param	Speed	The speed it will move, in pixels per second
	 * @return	An FlxPoint where FlxPoint.x contains the velocity x value and FlxPoint.y contains the velocity y value
	 */
	public static function velocityFromFacing(Parent:FlxSprite, Speed:Float):FlxPoint
	{
		var a:Float = 0;
		
		if (Parent.facing == FlxObject.LEFT)
		{
			a = FlxAngle.asRadians(180);
		}
		else if (Parent.facing == FlxObject.RIGHT)
		{
			a = FlxAngle.asRadians(0);
		}
		else if (Parent.facing == FlxObject.UP)
		{
			a = FlxAngle.asRadians( -90);
		}
		else if (Parent.facing == FlxObject.DOWN)
		{
			a = FlxAngle.asRadians(90);
		}
		
		var result:FlxPoint = FlxPoint.get();
		
		result.x = Math.cos(a) * Speed;
		result.y = Math.sin(a) * Speed;
		
		return result;
	}
	
	/**
	 * A tween-like function that takes a starting velocity and some other factors and returns an altered velocity.
	 * 
	 * @param	Velocity		Any component of velocity (e.g. 20).
	 * @param	Acceleration		Rate at which the velocity is changing.
	 * @param	Drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
	 * @param	Max				An absolute value cap for the velocity (0 for no cap).
	 * @return	The altered Velocity value.
	 */
	public static function computeVelocity(Velocity:Float, Acceleration:Float, Drag:Float, Max:Float):Float
	{
		if (Acceleration != 0)
		{
			Velocity += Acceleration * FlxG.elapsed;
		}
		else if (Drag != 0)
		{
			var drag:Float = Drag * FlxG.elapsed;
			if (Velocity - drag > 0)
			{
				Velocity = Velocity - drag;
			}
			else if (Velocity + drag < 0)
			{
				Velocity += drag;
			}
			else
			{
				Velocity = 0;
			}
		}
		if ((Velocity != 0) && (Max != 0))
		{
			if (Velocity > Max)
			{
				Velocity = Max;
			}
			else if (Velocity < -Max)
			{
				Velocity = -Max;
			}
		}
		return Velocity;
	}
}
