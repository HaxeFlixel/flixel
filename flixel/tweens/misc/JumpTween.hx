package flixel.tweens.misc;

import flixel.FlxObject;
import flixel.tweens.FlxTween;

/**
 * Make an object "jump" forom their current position and follow a set path with a constant gravity
 * 
 * **NOTE:** Not meant for collision as the objects velocity and acceleration never change
 */
class JumpTween extends FlxTween
{
	public var object:FlxObject;
	public var velocityX:Float;
	public var velocityY:Float;
	public var gravity:Float;
	public var startX:Float;
	public var startY:Float;
	
	/**
	 * Makes an object "jump" from their current position with the specified velocity and gravity
	 * 
	 * **Note:** The object's velocity and acceleration are not changed
	 * 
	 * @param   object     The jumping object
	 * @param   velocityX  The initial velocity of the object
	 * @param   velocityY  The initial velocity of the object
	 * @param   gravity    How fast the object accelerates downward px/s/s
	 * @param   duration   How long it takes to jump
	 * @since 6.3.0
	 */
	public function jump(object:FlxObject, velocityX:Float, velocityY:Float, gravity:Float, duration:Float)
	{
		this.object = object;
		this.velocityX = velocityX;
		this.velocityY = velocityY;
		this.gravity = gravity;
		this.startX = object.x;
		this.startY = object.y;
		this.duration = duration;
		
		start();
	}
	
	override function destroy():Void
	{
		super.destroy();
		object = null;
	}
	
	/**
	 * Makes an object "jump" from their current position to some apex and,
	 * eventually, the target position as if affected by some constant gravity
	 * 
	 * **Note:** The object's velocity and acceleration are not changed
	 * 
	 * @param   object    The jumping object
	 * @param   endX      The end X position
	 * @param   apexY     The objects highest position during the jump
	 * @param   endY      The end Y position
	 * @param   duration  How long it takes to jump
	 * @since 6.3.0
	 */
	public function jumpTo(object:FlxObject, endX:Float, apexY:Float, endY:Float, duration:Float)
	{
		final vx = getLinearV(object.x, endX, duration);
		
		if (object.y == apexY && endY == apexY)
		{
			final vy = getLinearV(object.y, endY, duration);
			jump(object, vx, vy, 0, duration);
		}
		else if (object.y == apexY && endY != apexY)
			fallToHelper(object, vx, endY, duration);
		else if (object.y != apexY && endY == apexY)
			toComplexHelper(object, vx, apexY, endY, duration);
		else if ((object.y < apexY) != (endY < apexY))
			toComplexHelper(object, vx, Math.min(object.y, endY), endY, duration);
		else
			toComplexHelper(object, vx, apexY, endY, duration);
	}
	
	function toComplexHelper(object:FlxObject, vx:Float, apexY:Float, endY:Float, duration:Float)
	{
		final jumpHeight = apexY - object.y;
		final fallHeight = endY - apexY;
		final t1 = getTimeToApex(jumpHeight, fallHeight, duration);
		// d = (vi + vf) / 2 * t1 | vf = 0 at apex
		// d = vi / 2 * t1
		final vy = getInitialV(jumpHeight, t1);
		// vf = vi + a * t1 | vf = 0 at apex
		// a = -vi / t1
		final a = -vy / t1;
		
		jump(object, vx, vy, a, duration);
	}
	
	/**
	 * Used when jumping to a lower position, when the start is also the apex
	 */
	function fallToHelper(object:FlxObject, vx:Float, endY:Float, duration:Float)
	{
		final fallHeight = endY - object.y;
		final t2 = getTimeToApex(fallHeight, 0, duration);
		final a = getInitialV(fallHeight, t2) / t2;
		
		return jump(object, vx, 0, a, duration);
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		final t = duration * scale;
		object.x = startX + velocityX * t;
		object.y = startY + velocityY * t + .5 * gravity * t * t;
	}
	
	override function isTweenOf(object:Dynamic, ?field:String):Bool
	{
		return this.object == object
			&& (field == null || field == "x" || field == "y");
	}
	
	/**
	 * Calculates the time it will take to get to the apex given the heights and duration
	 * @param jumpHeight  Starting height - apex height
	 * @param fallHeight  Apex height - ending height
	 * @param duration    The time it takes to do the entire jump
	 */
	@:pure static function getTimeToApex(jumpHeight:Float, fallHeight:Float, duration:Float):Float
	{
		// Assume up takes 1 second, calc fall time and use that ratio with the actual duration
		final t1Guess = 1.0; // arbitrary
		// d = (vi + vf)/2 * t1| vf = 0 at apex
		// d/t1 = vi/2 * t1/t1
		final vi = 2 * jumpHeight / t1Guess;
		// vf = vi + a*t | vf = 0 at apex
		// -a*t = vi
		final a = -vi / t1Guess;
		// d = vi * t + 1/2 * a * t^2 | vi = 0 at apex
		// d = 1/2 * a * t^2
		// 2 * d / a = t^2
		final t2Guess = Math.sqrt(2 * fallHeight / a);
		return t1Guess / (t1Guess + t2Guess) * duration;
	}
	
	/**
	 * Calculates the initial verlocity that will bring an obnject to the desired height in the given time
	 */
	@:pure static function getInitialV(apexHeight:Float, duration:Float):Float
	{
		// d = (vi + vf) / 2 * t1 | vf = 0 at apex
		// d = vi / 2 * t1
		// d * 2 = vi * t1
		return apexHeight * 2 / duration;
	}
	
	/**
	 * Calculates the initial verlocity that will bring an obnject to the desired height in the given time
	 */
	@:pure static function getLinearV(start:Float, end:Float, duration:Float)
	{
		return (end - start) / duration;
	}
}