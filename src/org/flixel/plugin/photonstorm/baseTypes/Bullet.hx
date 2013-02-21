/**
 * Bullet
 * -- Part of the Flixel Power Tools set
 * 
 * v1.2 Removed "id" and used the FlxSprite ID value instead
 * v1.1 Updated to support fire callbacks, sounds, random variances and lifespan
 * v1.0 First release
 * 
 * @version 1.2 - October 10th 2011
 * @link http://www.photonstorm.com
* @link http://www.haxeflixel.com
* @author Richard Davey / Photon Storm
* @author Touch added by Impaler / Beeblerox
*/

package org.flixel.plugin.photonstorm.baseTypes;

import org.flixel.system.input.FlxTouch;
import nme.Lib;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.FlxMath;
import org.flixel.plugin.photonstorm.FlxVelocity;
import org.flixel.plugin.photonstorm.FlxWeapon;

class Bullet extends FlxSprite
{
	private var weapon:FlxWeapon;
	
	private var bulletSpeed:Int;
	
	//	Acceleration or Velocity?
	public var accelerates:Bool;
	public var xAcceleration:Int;
	public var yAcceleration:Int;
	
	public var rndFactorAngle:Int;
	public var rndFactorSpeed:Int;
	public var rndFactorLifeSpan:Int;
	public var lifespan:Float;
	
	private var animated:Bool;
	
	public function new(weapon:FlxWeapon, id:Int)
	{
		super(0, 0);
		
		this.weapon = weapon;
		this.ID = id;
		
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
	override public function addAnimation(Name:String, Frames:Array<Int>, FrameRate:Int = 0, Looped:Bool = true):Void
	{
		super.addAnimation(Name, Frames, FrameRate, Looped);
		
		animated = true;
	}
	
	public function fire(fromX:Float, fromY:Float, velX:Float, velY:Float):Void
	{
		x = fromX + FlxMath.rand( -weapon.rndFactorPosition.x, weapon.rndFactorPosition.x);
		y = fromY + FlxMath.rand( -weapon.rndFactorPosition.y, weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			acceleration.x = xAcceleration + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed);
			acceleration.y = yAcceleration + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed);
		}
		else
		{
			velocity.x = velX + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed);
			velocity.y = velY + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed);
		}
		
		postFire();
	}
	
	#if !FLX_NO_MOUSE
	public function fireAtMouse(fromX:Float, fromY:Float, speed:Int, rotateBulletTowards = true):Void
	{
		x = fromX + FlxMath.rand( -weapon.rndFactorPosition.x, weapon.rndFactorPosition.x);
		y = fromY + FlxMath.rand( -weapon.rndFactorPosition.y, weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsMouse(this, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed), Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsMouse(this, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed));
		}
		
		if ( rotateBulletTowards )
		angle = FlxVelocity.angleBetweenMouse(weapon.parent,true);
		
		postFire();
	}
	#end
	
	#if !FLX_NO_TOUCH
	public function fireAtTouch(fromX:Float, fromY:Float, touch:FlxTouch, speed:Int, rotateBulletTowards = true):Void
	{
		x = fromX + FlxMath.rand( -weapon.rndFactorPosition.x, weapon.rndFactorPosition.x);
		y = fromY + FlxMath.rand( -weapon.rndFactorPosition.y, weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsTouch(this, touch, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed), Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsTouch(this, touch, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed));
		}
		
		if ( rotateBulletTowards )
			angle = FlxVelocity.angleBetweenTouch(weapon.parent, touch,true);
		
		postFire();
	}
	#end
	
	public function fireAtPosition(fromX:Float, fromY:Float, toX:Float, toY:Float, speed:Int):Void
	{
		x = fromX + FlxMath.rand( -weapon.rndFactorPosition.x, weapon.rndFactorPosition.x);
		y = fromY + FlxMath.rand( -weapon.rndFactorPosition.y, weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsPoint(this, new FlxPoint(toX, toY), speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed), Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsPoint(this, new FlxPoint(toX, toY), speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed));
		}
		
		postFire();
	}
	
	public function fireAtTarget(fromX:Float, fromY:Float, target:FlxSprite, speed:Int):Void
	{
		x = fromX + FlxMath.rand( -weapon.rndFactorPosition.x, weapon.rndFactorPosition.x);
		y = fromY + FlxMath.rand( -weapon.rndFactorPosition.y, weapon.rndFactorPosition.y);
		
		if (accelerates)
		{
			FlxVelocity.accelerateTowardsObject(this, target, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed), Math.floor(maxVelocity.x), Math.floor(maxVelocity.y));
		}
		else
		{
			FlxVelocity.moveTowardsObject(this, target, speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed));
		}
		
		postFire();
	}
	
	public function fireFromAngle(fromX:Float, fromY:Float, fireAngle:Int, speed:Int):Void
	{
		x = fromX + FlxMath.rand( -weapon.rndFactorPosition.x, weapon.rndFactorPosition.x);
		y = fromY + FlxMath.rand( -weapon.rndFactorPosition.y, weapon.rndFactorPosition.y);
		
		var newVelocity:FlxPoint = FlxVelocity.velocityFromAngle(fireAngle + FlxMath.rand( -weapon.rndFactorAngle, weapon.rndFactorAngle), speed + FlxMath.rand( -weapon.rndFactorSpeed, weapon.rndFactorSpeed));
		
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
		
		postFire();
	}
	
	private function postFire():Void
	{
		if (animated)
		{
			play("fire");
		}
		
		if (weapon.bulletElasticity > 0)
		{
			elasticity = weapon.bulletElasticity;
		}
		
		exists = true;
		
		// Reset last x and y position in case we were recycled.
		last.x = x;
		last.y = y;
		
		if (weapon.bulletLifeSpan > 0)
		{
			lifespan = weapon.bulletLifeSpan + FlxMath.rand( -weapon.rndFactorLifeSpan, weapon.rndFactorLifeSpan);
		}
		
		if (weapon.onFireCallback != null)
		{
			weapon.onFireCallback();
		}
		
		if (weapon.onFireSound != null)
		{
			weapon.onFireSound.play();
		}
	}
	
	public var xGravity(null, set_xGravity):Int;
	
	private function set_xGravity(gx:Int):Int
	{
		acceleration.x = gx;
		return gx;
	}
	
	public var yGravity(null, set_yGravity):Int;
	
	private function set_yGravity(gy:Int):Int
	{
		acceleration.y = gy;
		return gy;
	}
	
	public var maxVelocityX(null, set_maxVelocityX):Int;
	
	private function set_maxVelocityX(mx:Int):Int
	{
		maxVelocity.x = mx;
		return mx;
	}
	
	public var maxVelocityY(null, set_maxVelocityY):Int;
	
	private function set_maxVelocityY(my:Int):Int
	{
		maxVelocity.y = my;
		return my;
	}
	
	override public function update():Void
	{
		if (lifespan > 0)
		{
			lifespan -= FlxG.elapsed;
			if (lifespan <= 0)
			{
				kill();
			}
		}
		
		if (FlxMath.pointInFlxRect(Math.floor(x), Math.floor(y), weapon.bounds) == false)
		{
			kill();
		}
	}
	
}