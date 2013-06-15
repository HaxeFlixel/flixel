/**
* FlxVelocity
* -- Part of the Flixel Power Tools set
* 
* v1.5 New methods: velocityFromAngle, accelerateTowardsObject, accelerateTowardsMouse, accelerateTowardsPoint
* v1.4 New methods: moveTowardsPoint, distanceToPoint, angleBetweenPoint
* v1.3 Updated for the Flixel 2.5 Plugin system
* 
* @version 1.5 - June 10th 2011
* @link http://www.photonstorm.com
* @link http://www.haxeflixel.com
* @author Richard Davey / Photon Storm
* @author Touch added by Impaler / Beeblerox
* @see Depends on FlxMath
*/

package org.flixel.plugin.photonstorm;

import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.util.FlxAngle;
import org.flixel.util.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.system.input.FlxTouch;
import org.flixel.util.FlxMath;

class FlxVelocity 
{	
	/**
	 * Sets the source FlxSprite x/y velocity so it will move directly towards the destination FlxSprite at the speed given (in pixels per second)<br>
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.<br>
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.<br>
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.<br>
	 * If you need the object to accelerate, see accelerateTowardsObject() instead
	 * Note: Doesn't take into account acceleration, maxVelocity or drag (if you set drag or acceleration too high this object may not move at all)
	 * 
	 * @param	Source		The FlxSprite on which the velocity will be set
	 * @param	Dest		The FlxSprite where the source object will move to
	 * @param	Speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	MaxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	static public function moveTowardsObject(Source:FlxSprite, Dest:FlxSprite, Speed:Int = 60, MaxTime:Int = 0):Void
	{
		var a:Float = angleBetween(Source, Dest);
		
		if (MaxTime > 0)
		{
			var d:Int = distanceBetween(Source, Dest);
			
			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}
		
		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}
	
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards the destination FlxSprite at the speed given (in pixels per second)<br>
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.<br>
	 * If you don't need acceleration look at moveTowardsObject() instead.
	 * 
	 * @param	Source			The FlxSprite on which the acceleration will be set
	 * @param	Dest			The FlxSprite where the source object will move towards
	 * @param	Speed			The speed it will accelerate in pixels per second
	 * @param	MaxXSpeed		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	MaxYSpeed		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	static public function accelerateTowardsObject(Source:FlxSprite, Dest:FlxSprite, Speed:Int, MaxXSpeed:Int, MaxYSpeed:Int):Void
	{
		var a:Float = angleBetween(Source, Dest);
		
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
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.<br>
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.<br>
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.<br>
	 * 
	 * @param	Source		The FlxSprite to move
	 * @param	Speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	MaxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	static public function moveTowardsMouse(Source:FlxSprite, Speed:Int = 60, MaxTime:Int = 0):Void
	{
		var a:Float = angleBetweenMouse(Source);
		
		if (MaxTime > 0)
		{
			var d:Int = distanceToMouse(Source);
			
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
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.<br>
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.<br>
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.<br>
	 * 
	 * @param	source			The FlxSprite to move
	 * @param	speed				The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	maxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsTouch(Source:FlxSprite, Touch:FlxTouch, Speed:Int = 60, MaxTime:Int = 0):Void
	{
		var a:Float = angleBetweenTouch(Source, Touch);
		
		if (MaxTime > 0)
		{
			var d:Int = distanceToTouch(Source, Touch);
			
			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}
		
		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards the mouse coordinates at the speed given (in pixels per second)<br>
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.<br>
	 * If you don't need acceleration look at moveTowardsMouse() instead.
	 * 
	 * @param	Source			The FlxSprite on which the acceleration will be set
	 * @param	Speed			The speed it will accelerate in pixels per second
	 * @param	MaxXSpeed		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	MaxYSpeed		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	static public function accelerateTowardsMouse(Source:FlxSprite, Speed:Int, MaxXSpeed:Int, MaxYSpeed:Int):Void
	{
		var a:Float = angleBetweenMouse(Source);
		
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
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards a FlxTouch at the speed given (in pixels per second)<br>
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.<br>
	 * If you don't need acceleration look at moveTowardsMouse() instead.
	 * 
	 * @param	Source			The FlxSprite on which the acceleration will be set
	 * @param	Touch			The FlxTouch on which to accelerate towards
	 * @param	Speed			The speed it will accelerate in pixels per second
	 * @param	MaxXSpeed		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	MaxYSpeed		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	static public function accelerateTowardsTouch(Source:FlxSprite, Touch:FlxTouch, Speed:Int, MaxXSpeed:Int, MaxYSpeed:Int):Void
	{
		var a:Float = angleBetweenTouch(Source, Touch);
		
		Source.velocity.x = 0;
		Source.velocity.y = 0;
		
		Source.acceleration.x = Std.int(Math.cos(a) * Speed);
		Source.acceleration.y = Std.int(Math.sin(a) * Speed);
		
		Source.maxVelocity.x = MaxXSpeed;
		Source.maxVelocity.y = MaxYSpeed;
	}
	#end
	
	/**
	 * Sets the x/y velocity on the source FlxSprite so it will move towards the target coordinates at the speed given (in pixels per second)<br>
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.<br>
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.<br>
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.<br>
	 * 
	 * @param	Source		The FlxSprite to move
	 * @param	Target		The FlxPoint coordinates to move the source FlxSprite towards
	 * @param	Speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	MaxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	static public function moveTowardsPoint(Source:FlxSprite, Target:FlxPoint, Speed:Int = 60, MaxTime:Int = 0):Void
	{
		var a:Float = angleBetweenPoint(Source, Target);
		
		if (MaxTime > 0)
		{
			var d:Int = distanceToPoint(Source, Target);
			
			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}
		
		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}
	
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards the target coordinates at the speed given (in pixels per second)<br>
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.<br>
	 * If you don't need acceleration look at moveTowardsPoint() instead.
	 * 
	 * @param	Source			The FlxSprite on which the acceleration will be set
	 * @param	Target			The FlxPoint coordinates to move the source FlxSprite towards
	 * @param	Speed			The speed it will accelerate in pixels per second
	 * @param	MaxXSpeed		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	MaxYSpeed		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	static public function accelerateTowardsPoint(Source:FlxSprite, Target:FlxPoint, Speed:Int, MaxXSpeed:Int, MaxYSpeed:Int):Void
	{
		var a:Float = angleBetweenPoint(Source, Target);
		
		Source.velocity.x = 0;
		Source.velocity.y = 0;
		
		Source.acceleration.x = Std.int(Math.cos(a) * Speed);
		Source.acceleration.y = Std.int(Math.sin(a) * Speed);
		
		Source.maxVelocity.x = MaxXSpeed;
		Source.maxVelocity.y = MaxYSpeed;
	}
	
	/**
	 * Find the distance (in pixels, rounded) between two FlxSprites, taking their origin into account
	 * 
	 * @param	SpriteA		The first FlxSprite
	 * @param	SpriteB		The second FlxSprite
	 * @return	Distance between the sprites in pixels
	 */
	inline static public function distanceBetween(SpriteA:FlxSprite, SpriteB:FlxSprite):Int
	{
		var dx:Float = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x);
		var dy:Float = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y);
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	/**
	 * Find the distance (in pixels, rounded) from an <code>FlxSprite</code>
	 * to the given <code>FlxPoint</code>, taking the source origin into account.
	 * 
	 * @param	Sprite	The FlxSprite
	 * @param	Target	The FlxPoint
	 * @return	Distance in pixels
	 */
	inline static public function distanceToPoint(Sprite:FlxSprite, Target:FlxPoint):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - (Target.x);
		var dy:Float = (Sprite.y + Sprite.origin.y) - (Target.y);
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Find the distance (in pixels, rounded) from the object x/y and the mouse x/y
	 * 
	 * @param	Sprite	The FlxSprite to test against
	 * @return	The distance between the given sprite and the mouse coordinates
	 */
	inline static public function distanceToMouse(Sprite:FlxSprite):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - FlxG.mouse.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - FlxG.mouse.screenY;
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Find the distance (in pixels, rounded) from the object x/y and the FlxPoint screen x/y
	 * 
	 * @param	Sprite	The FlxSprite to test against
	 * @param	Touch	The FlxTouch to test against
	 * @return	The distance between the given sprite and the mouse coordinates
	 */
	inline static public function distanceToTouch(Sprite:FlxSprite, Touch:FlxTouch):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Touch.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Touch.screenY;
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	#end
	
	/**
	 * Find the angle (in radians) between an FlxSprite and an FlxPoint. The source sprite takes its x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	Sprite		The FlxSprite to test from
	 * @param	Target		The FlxPoint to angle the FlxSprite towards
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless AsDegrees is true)
	 */
	static public function angleBetweenPoint(Sprite:FlxSprite, Target:FlxPoint, AsDegrees:Bool = false):Float
	{
		var dx:Float = (Target.x) - (Sprite.x + Sprite.origin.x);
		var dy:Float = (Target.y) - (Sprite.y + Sprite.origin.y);
		
		if (AsDegrees)
		{
			return FlxAngle.asDegrees(Math.atan2(dy, dx));
		}
		else
		{
			return Math.atan2(dy, dx);
		}
	}
	
	/**
	 * Find the angle (in radians) between the two FlxSprite, taking their x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	SpriteA		The FlxSprite to test from
	 * @param	SpriteB		The FlxSprite to test to
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless asDegrees is true)
	 */
	inline static public function angleBetween(SpriteA:FlxSprite, SpriteB:FlxSprite, AsDegrees:Bool = false):Float
	{
		var dx:Float = (SpriteB.x + SpriteB.origin.x) - (SpriteA.x + SpriteA.origin.x);
		var dy:Float = (SpriteB.y + SpriteB.origin.y) - (SpriteA.y + SpriteA.origin.y);
		
		if (AsDegrees)
		{
			return FlxAngle.asDegrees(Math.atan2(dy, dx));
		}
		else
		{
			return Math.atan2(dy, dx);
		}
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
	static public function velocityFromFacing(Parent:FlxSprite, Speed:Int):FlxPoint
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
	
	#if !FLX_NO_MOUSE
	/**
	 * Find the angle (in radians) between an FlxSprite and the mouse, taking their x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	Object		The FlxObject to test from
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless AsDegrees is true)
	 */
	inline static public function angleBetweenMouse(Object:FlxObject, AsDegrees:Bool = false):Float
	{
		//	In order to get the angle between the object and mouse, we need the objects screen coordinates (rather than world coordinates)
		if (Object == null)
			return 0;
		
		var p:FlxPoint = Object.getScreenXY();
		
		var dx:Float = FlxG.mouse.screenX - p.x;
		var dy:Float = FlxG.mouse.screenY - p.y;
		
		if (AsDegrees)
		{
			return FlxAngle.asDegrees(Math.atan2(dy, dx));
		}
		else
		{
			return Math.atan2(dy, dx);
		}
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Find the angle (in radians) between an FlxSprite and a FlxTouch, taking their x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	Object		The FlxObject to test from
	 * @param	Touch		The FlxTouch to test to
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless AsDegrees is true)
	 */
	inline static public function angleBetweenTouch(Object:FlxObject, Touch:FlxTouch, AsDegrees:Bool = false):Float
	{
		//	In order to get the angle between the object and mouse, we need the objects screen coordinates (rather than world coordinates)
		var p:FlxPoint = Object.getScreenXY();
		
		var dx:Float = Touch.screenX - p.x;
		var dy:Float = Touch.screenY - p.y;
		
		if (AsDegrees)
		{
			return FlxAngle.asDegrees(Math.atan2(dy, dx));
		}
		else
		{
			return Math.atan2(dy, dx);
		}
	}
	#end
}