package flixel.util;
#if !FLX_NO_TOUCH
import flixel.input.touch.FlxTouch;
#end
class FlxVelocity 
{	
	/**
	 * Sets the source FlxSprite x/y velocity so it will move directly towards the destination FlxSprite at the speed given (in pixels per second)
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.
	 * If you need the object to accelerate, see accelerateTowardsObject() instead
	 * Note: Doesn't take into account acceleration, maxVelocity or drag (if you set drag or acceleration too high this object may not move at all)
	 * 
	 * @param	Source		The FlxSprite on which the velocity will be set
	 * @param	Dest		The FlxSprite where the source object will move to
	 * @param	Speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	MaxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsObject(Source:FlxSprite, Dest:FlxSprite, Speed:Int = 60, MaxTime:Int = 0):Void
	{
		var a:Float = FlxAngle.angleBetween(Source, Dest);
		
		if (MaxTime > 0)
		{
			var d:Int = FlxMath.distanceBetween(Source, Dest);
			
			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}
		
		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}
	
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards the destination FlxSprite at the speed given (in pixels per second)
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.
	 * If you don't need acceleration look at moveTowardsObject() instead.
	 * 
	 * @param	Source			The FlxSprite on which the acceleration will be set
	 * @param	Dest			The FlxSprite where the source object will move towards
	 * @param	Speed			The speed it will accelerate in pixels per second
	 * @param	MaxXSpeed		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	MaxYSpeed		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	public static function accelerateTowardsObject(Source:FlxSprite, Dest:FlxSprite, Speed:Int, MaxXSpeed:Int, MaxYSpeed:Int):Void
	{
		var a:Float = FlxAngle.angleBetween(Source, Dest);
		
		Source.velocity.x = 0;
		Source.velocity.y = 0;
		
		Source.acceleration.x = Std.int(Math.cos(a) * Speed);
		Source.acceleration.y = Std.int(Math.sin(a) * Speed);
		
		Source.maxVelocity.x = MaxXSpeed;
		Source.maxVelocity.y = MaxYSpeed;
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Move the given FlxSprite towards the mouse pointer coordinates at a steady velocity
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.
	 * 
	 * @param	Source		The FlxSprite to move
	 * @param	Speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	MaxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsMouse(Source:FlxSprite, Speed:Int = 60, MaxTime:Int = 0):Void
	{
		var a:Float = FlxAngle.angleBetweenMouse(Source);
		
		if (MaxTime > 0)
		{
			var d:Int = FlxMath.distanceToMouse(Source);
			
			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}
		
		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Move the given FlxSprite towards a FlxTouch point at a steady velocity
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.
	 * 
	 * @param	source			The FlxSprite to move
	 * @param	speed				The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	maxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsTouch(Source:FlxSprite, Touch:FlxTouch, Speed:Int = 60, MaxTime:Int = 0):Void
	{
		var a:Float = FlxAngle.angleBetweenTouch(Source, Touch);
		
		if (MaxTime > 0)
		{
			var d:Int = FlxMath.distanceToTouch(Source, Touch);
			
			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}
		
		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards the mouse coordinates at the speed given (in pixels per second)
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.
	 * If you don't need acceleration look at moveTowardsMouse() instead.
	 * 
	 * @param	Source			The FlxSprite on which the acceleration will be set
	 * @param	Speed			The speed it will accelerate in pixels per second
	 * @param	MaxXSpeed		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	MaxYSpeed		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	public static function accelerateTowardsMouse(Source:FlxSprite, Speed:Int, MaxXSpeed:Int, MaxYSpeed:Int):Void
	{
		var a:Float = FlxAngle.angleBetweenMouse(Source);
		
		Source.velocity.x = 0;
		Source.velocity.y = 0;
		
		Source.acceleration.x = Std.int(Math.cos(a) * Speed);
		Source.acceleration.y = Std.int(Math.sin(a) * Speed);
		
		Source.maxVelocity.x = MaxXSpeed;
		Source.maxVelocity.y = MaxYSpeed;
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards a FlxTouch at the speed given (in pixels per second)
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.
	 * If you don't need acceleration look at moveTowardsMouse() instead.
	 * 
	 * @param	Source			The FlxSprite on which the acceleration will be set
	 * @param	Touch			The FlxTouch on which to accelerate towards
	 * @param	Speed			The speed it will accelerate in pixels per second
	 * @param	MaxXSpeed		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	MaxYSpeed		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	public static function accelerateTowardsTouch(Source:FlxSprite, Touch:FlxTouch, Speed:Int, MaxXSpeed:Int, MaxYSpeed:Int):Void
	{
		var a:Float = FlxAngle.angleBetweenTouch(Source, Touch);
		
		Source.velocity.x = 0;
		Source.velocity.y = 0;
		
		Source.acceleration.x = Std.int(Math.cos(a) * Speed);
		Source.acceleration.y = Std.int(Math.sin(a) * Speed);
		
		Source.maxVelocity.x = MaxXSpeed;
		Source.maxVelocity.y = MaxYSpeed;
	}
	#end
	
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
	public static function moveTowardsPoint(Source:FlxSprite, Target:FlxPoint, Speed:Int = 60, MaxTime:Int = 0):Void
	{
		var a:Float = FlxAngle.angleBetweenPoint(Source, Target);
		
		if (MaxTime > 0)
		{
			var d:Int = FlxMath.distanceToPoint(Source, Target);
			
			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}
		
		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
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
	public static function accelerateTowardsPoint(Source:FlxSprite, Target:FlxPoint, Speed:Int, MaxXSpeed:Int, MaxYSpeed:Int):Void
	{
		var a:Float = FlxAngle.angleBetweenPoint(Source, Target);
		
		Source.velocity.x = 0;
		Source.velocity.y = 0;
		
		Source.acceleration.x = Std.int(Math.cos(a) * Speed);
		Source.acceleration.y = Std.int(Math.sin(a) * Speed);
		
		Source.maxVelocity.x = MaxXSpeed;
		Source.maxVelocity.y = MaxYSpeed;
	}
	
	/**
	 * Given the angle and speed calculate the velocity and return it as an FlxPoint
	 * 
	 * @param	Angle	The angle (in degrees) calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * @param	Speed	The speed it will move, in pixels per second sq
	 * @return	A FlxPoint where FlxPoint.x contains the velocity x value and FlxPoint.y contains the velocity y value
	 */
	inline public static function velocityFromAngle(Angle:Int, Speed:Int):FlxPoint
	{
		var a:Float = FlxAngle.asRadians(Angle);
		
		var result:FlxPoint = new FlxPoint();
		
		result.x = Std.int(Math.cos(a) * Speed);
		result.y = Std.int(Math.sin(a) * Speed);
		
		return result;
	}
	
	/**
	 * Given the FlxSprite and speed calculate the velocity and return it as an FlxPoint based on the direction the sprite is facing
	 * 
	 * @param	Parent	The FlxSprite to get the facing value from
	 * @param	Speed	The speed it will move, in pixels per second
	 * @return	An FlxPoint where FlxPoint.x contains the velocity x value and FlxPoint.y contains the velocity y value
	 */
	public static function velocityFromFacing(Parent:FlxSprite, Speed:Int):FlxPoint
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
		
		var result:FlxPoint = new FlxPoint();
		
		result.x = Std.int(Math.cos(a) * Speed);
		result.y = Std.int(Math.sin(a) * Speed);
		
		return result;
	}
}