package org.flixel.plugin.photonstorm.baseTypes; 

import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.FlxMath;
import org.flixel.plugin.photonstorm.FlxVelocity;
import org.flixel.plugin.photonstorm.FlxWeapon;

class Bullet extends FlxSprite
{
	#if flash
	public var id:UInt;
	#else
	public var id:Int;
	#end
	private var weapon:FlxWeapon;
	
	private var bulletSpeed:Int;
	
	//	Acceleration or Velocity?
	public var accelerates:Bool;
	public var xAcceleration:Int;
	public var yAcceleration:Int;
	
	private var animated:Bool;
	
	#if flash
	public function new(weapon:FlxWeapon, id:UInt)
	#else
	public function new(weapon:FlxWeapon, id:Int)
	#end
	{
		super(0, 0);
		
		this.weapon = weapon;
		this.id = id;
		
		//	Safe defaults
		accelerates = false;
		animated = false;
		bulletSpeed = 0;
		
		exists = false;
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * 
	 * @param	Name		What this animation should be called (e.g. "run").
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped		Whether or not the animation is looped or just plays once.
	 */
	#if flash
	override public function addAnimation(Name:String, Frames:Array<UInt>, ?FrameRate:UInt = 0, ?Looped:Bool = true):Void
	#else
	override public function addAnimation(Name:String, Frames:Array<Int>, ?FrameRate:Int = 0, ?Looped:Bool = true):Void
	#end
	{
		super.addAnimation(Name, Frames, FrameRate, Looped);
		
		animated = true;
	}
	
	public function fire(fromX:Int, fromY:Int, velX:Int, velY:Int):Void
	{
		x = fromX;
		y = fromY;
		
		if (accelerates)
		{
			acceleration.x = xAcceleration;
			acceleration.y = yAcceleration;
		}
		else
		{
			velocity.x = velX;
			velocity.y = velY;
		}
		
		if (animated)
		{
			play("fire");
		}
		
		exists = true;
	}
	
	public function fireAtMouse(fromX:Int, fromY:Int, speed:Int):Void
	{
		x = fromX;
		y = fromY;
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsMouse(this, speed, Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsMouse(this, speed);
		}
		
		if (animated)
		{
			play("fire");
		}
		
		exists = true;
	}
	
	public function fireAtPosition(fromX:Int, fromY:Int, toX:Int, toY:Int, speed:Int):Void
	{
		x = fromX;
		y = fromY;
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsPoint(this, new FlxPoint(toX, toY), speed, Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsPoint(this, new FlxPoint(toX, toY), speed);
		}
		
		if (animated)
		{
			play("fire");
		}
		
		exists = true;
	}
	
	public function fireAtTarget(fromX:Int, fromY:Int, target:FlxSprite, speed:Int):Void
	{
		x = fromX;
		y = fromY;
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsObject(this, target, speed, Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsObject(this, target, speed);
		}
		
		if (animated)
		{
			play("fire");
		}
		
		exists = true;
	}
	
	public function fireFromAngle(fromX:Int, fromY:Int, fireAngle:Int, speed:Int):Void
	{
		x = fromX;
		y = fromY;
		
		var newVelocity:FlxPoint = FlxVelocity.velocityFromAngle(fireAngle, speed);
		
		if (accelerates)
		{
			acceleration.x = newVelocity.x;
			acceleration.y = newVelocity.y;
		}
		else
		{
			velocity.x = newVelocity.x;
			velocity.y = newVelocity.y;
		}
		
		if (animated)
		{
			play("fire");
		}
		
		exists = true;
	}
	
	public var xGravity(null, setxGravity):Int;
	
	public function setxGravity(gx:Int):Int
	{
		acceleration.x = gx;
		return gx;
	}
	
	public var yGravity(null, setyGravity):Int;
	
	public function setyGravity(gy:Int):Int
	{
		acceleration.y = gy;
		return gy;
	}
	
	public var maxVelocityX(null, setMaxVelocityX):Int;
	
	public function setMaxVelocityX(mx:Int):Int
	{
		maxVelocity.x = mx;
		return mx;
	}
	
	public var maxVelocityY(null, setMaxVelocityY):Int;
	
	public function setMaxVelocityY(my:Int):Int
	{
		maxVelocity.y = my;
		return my;
	}
	
	override public function update():Void
	{
		super.update();
		
		if (FlxMath.pointInFlxRect(Math.floor(x), Math.floor(y), weapon.bounds) == false)
		{
			kill();
		}
	}
	
}