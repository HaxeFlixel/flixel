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
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxU;
import org.flixel.system.input.FlxTouch;


class FlxVelocity 
{
	
	public function new() { }
	
	/**
	 * Sets the source FlxSprite x/y velocity so it will move directly towards the destination FlxSprite at the speed given (in pixels per second)<br>
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.<br>
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.<br>
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.<br>
	 * If you need the object to accelerate, see accelerateTowardsObject() instead
	 * Note: Doesn't take into account acceleration, maxVelocity or drag (if you set drag or acceleration too high this object may not move at all)
	 * 
	 * @param	source		The FlxSprite on which the velocity will be set
	 * @param	dest		The FlxSprite where the source object will move to
	 * @param	speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	maxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsObject(source:FlxSprite, dest:FlxSprite, speed:Int = 60, maxTime:Int = 0):Void
	{
		var a:Float = angleBetween(source, dest);
		
		if (maxTime > 0)
		{
			var d:Int = distanceBetween(source, dest);
			
			//	We know how many pixels we need to move, but how fast?
			speed = Std.int(d / (maxTime / 1000));
		}
		
		source.velocity.x = Math.cos(a) * speed;
		source.velocity.y = Math.sin(a) * speed;
	}
	
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards the destination FlxSprite at the speed given (in pixels per second)<br>
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.<br>
	 * If you don't need acceleration look at moveTowardsObject() instead.
	 * 
	 * @param	source			The FlxSprite on which the acceleration will be set
	 * @param	dest			The FlxSprite where the source object will move towards
	 * @param	speed			The speed it will accelerate in pixels per second
	 * @param	xSpeedMax		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	ySpeedMax		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	public static function accelerateTowardsObject(source:FlxSprite, dest:FlxSprite, speed:Int, xSpeedMax:Int, ySpeedMax:Int):Void
	{
		var a:Float = angleBetween(source, dest);
		
		source.velocity.x = 0;
		source.velocity.y = 0;
		
		source.acceleration.x = Std.int(Math.cos(a) * speed);
		source.acceleration.y = Std.int(Math.sin(a) * speed);
		
		source.maxVelocity.x = xSpeedMax;
		source.maxVelocity.y = ySpeedMax;
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Move the given FlxSprite towards the mouse pointer coordinates at a steady velocity
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.<br>
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.<br>
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.<br>
	 * 
	 * @param	source		The FlxSprite to move
	 * @param	speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	maxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsMouse(source:FlxSprite, speed:Int = 60, maxTime:Int = 0):Void
	{
		var a:Float = angleBetweenMouse(source);
		
		if (maxTime > 0)
		{
			var d:Int = distanceToMouse(source);
			
			//	We know how many pixels we need to move, but how fast?
			speed = Std.int(d / (maxTime / 1000));
		}
		
		source.velocity.x = Math.cos(a) * speed;
		source.velocity.y = Math.sin(a) * speed;
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
	public static function moveTowardsTouch(source:FlxSprite, touch:FlxTouch, speed:Int = 60, maxTime:Int = 0):Void
	{
		var a:Float = angleBetweenTouch(source, touch);
		
		if (maxTime > 0)
		{
			var d:Int = distanceToTouch(source, touch);
			
			//	We know how many pixels we need to move, but how fast?
			speed = Std.int(d / (maxTime / 1000));
		}
		
		source.velocity.x = Math.cos(a) * speed;
		source.velocity.y = Math.sin(a) * speed;
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards the mouse coordinates at the speed given (in pixels per second)<br>
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.<br>
	 * If you don't need acceleration look at moveTowardsMouse() instead.
	 * 
	 * @param	source			The FlxSprite on which the acceleration will be set
	 * @param	speed			The speed it will accelerate in pixels per second
	 * @param	xSpeedMax		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	ySpeedMax		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	public static function accelerateTowardsMouse(source:FlxSprite, speed:Int, xSpeedMax:Int, ySpeedMax:Int):Void
	{
		var a:Float = angleBetweenMouse(source);
		
		source.velocity.x = 0;
		source.velocity.y = 0;
		
		source.acceleration.x = Std.int(Math.cos(a) * speed);
		source.acceleration.y = Std.int(Math.sin(a) * speed);
		
		source.maxVelocity.x = xSpeedMax;
		source.maxVelocity.y = ySpeedMax;
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards a FlxTouch at the speed given (in pixels per second)<br>
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.<br>
	 * If you don't need acceleration look at moveTowardsMouse() instead.
	 * 
	 * @param	source				The FlxSprite on which the acceleration will be set
	 * @param	touch					The FlxTouch on which to accelerate towards
	 * @param	speed					The speed it will accelerate in pixels per second
	 * @param	xSpeedMax		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	ySpeedMax		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	public static function accelerateTowardsTouch(source:FlxSprite, touch:FlxTouch, speed:Int, xSpeedMax:Int, ySpeedMax:Int):Void
	{
		var a:Float = angleBetweenTouch(source, touch);
		
		source.velocity.x = 0;
		source.velocity.y = 0;
		
		source.acceleration.x = Std.int(Math.cos(a) * speed);
		source.acceleration.y = Std.int(Math.sin(a) * speed);
		
		source.maxVelocity.x = xSpeedMax;
		source.maxVelocity.y = ySpeedMax;
	}
	#end
	
	/**
	 * Sets the x/y velocity on the source FlxSprite so it will move towards the target coordinates at the speed given (in pixels per second)<br>
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.<br>
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.<br>
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.<br>
	 * 
	 * @param	source		The FlxSprite to move
	 * @param	target		The FlxPoint coordinates to move the source FlxSprite towards
	 * @param	speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	maxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsPoint(source:FlxSprite, target:FlxPoint, speed:Int = 60, maxTime:Int = 0):Void
	{
		var a:Float = angleBetweenPoint(source, target);
		
		if (maxTime > 0)
		{
			var d:Int = distanceToPoint(source, target);
			
			//	We know how many pixels we need to move, but how fast?
			speed = Std.int(d / (maxTime / 1000));
		}
		
		source.velocity.x = Math.cos(a) * speed;
		source.velocity.y = Math.sin(a) * speed;
	}
	
	/**
	 * Sets the x/y acceleration on the source FlxSprite so it will move towards the target coordinates at the speed given (in pixels per second)<br>
	 * You must give a maximum speed value, beyond which the FlxSprite won't go any faster.<br>
	 * If you don't need acceleration look at moveTowardsPoint() instead.
	 * 
	 * @param	source			The FlxSprite on which the acceleration will be set
	 * @param	target			The FlxPoint coordinates to move the source FlxSprite towards
	 * @param	speed			The speed it will accelerate in pixels per second
	 * @param	xSpeedMax		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	ySpeedMax		The maximum speed in pixels per second in which the sprite can move vertically
	 */
	public static function accelerateTowardsPoint(source:FlxSprite, target:FlxPoint, speed:Int, xSpeedMax:Int, ySpeedMax:Int):Void
	{
		var a:Float = angleBetweenPoint(source, target);
		
		source.velocity.x = 0;
		source.velocity.y = 0;
		
		source.acceleration.x = Std.int(Math.cos(a) * speed);
		source.acceleration.y = Std.int(Math.sin(a) * speed);
		
		source.maxVelocity.x = xSpeedMax;
		source.maxVelocity.y = ySpeedMax;
	}
	
	/**
	 * Find the distance (in pixels, rounded) between two FlxSprites, taking their origin into account
	 * 
	 * @param	a	The first FlxSprite
	 * @param	b	The second FlxSprite
	 * @return	int	Distance (in pixels)
	 */
	public static function distanceBetween(a:FlxSprite, b:FlxSprite):Int
	{
		var dx:Float = (a.x + a.origin.x) - (b.x + b.origin.x);
		var dy:Float = (a.y + a.origin.y) - (b.y + b.origin.y);
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	/**
	 * Find the distance (in pixels, rounded) from an FlxSprite to the given FlxPoint, taking the source origin into account
	 * 
	 * @param	a		The first FlxSprite
	 * @param	target	The FlxPoint
	 * @return	int		Distance (in pixels)
	 */
	public static function distanceToPoint(a:FlxSprite, target:FlxPoint):Int
	{
		var dx:Float = (a.x + a.origin.x) - (target.x);
		var dy:Float = (a.y + a.origin.y) - (target.y);
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Find the distance (in pixels, rounded) from the object x/y and the mouse x/y
	 * 
	 * @param	a	The FlxSprite to test against
	 * @return	int	The distance between the given sprite and the mouse coordinates
	 */
	public static function distanceToMouse(a:FlxSprite):Int
	{
		var dx:Float = (a.x + a.origin.x) - FlxG.mouse.screenX;
		var dy:Float = (a.y + a.origin.y) - FlxG.mouse.screenY;
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Find the distance (in pixels, rounded) from the object x/y and the FlxPoint screen x/y
	 * 
	 * @param	a	The FlxSprite to test against
	 * @param	b	The FlxTouch to test against
	 * @return	int	The distance between the given sprite and the mouse coordinates
	 */
	public static function distanceToTouch(a:FlxSprite, b:FlxTouch):Int
	{
		var dx:Float = (a.x + a.origin.x) - b.screenX;
		var dy:Float = (a.y + a.origin.y) - b.screenY;
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	#end
	
	/**
	 * Find the angle (in radians) between an FlxSprite and an FlxPoint. The source sprite takes its x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	a			The FlxSprite to test from
	 * @param	target		The FlxPoint to angle the FlxSprite towards
	 * @param	asDegrees	If you need the value in degrees instead of radians, set to true
	 * 
	 * @return	Number The angle (in radians unless asDegrees is true)
	 */
	public static function angleBetweenPoint(a:FlxSprite, target:FlxPoint, asDegrees:Bool = false):Float
	{
		var dx:Float = (target.x) - (a.x + a.origin.x);
		var dy:Float = (target.y) - (a.y + a.origin.y);
		
		if (asDegrees)
		{
			return FlxMath.asDegrees(Math.atan2(dy, dx));
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
	 * @param	a			The FlxSprite to test from
	 * @param	b			The FlxSprite to test to
	 * @param	asDegrees	If you need the value in degrees instead of radians, set to true
	 * 
	 * @return	Number The angle (in radians unless asDegrees is true)
	 */
	public static function angleBetween(a:FlxSprite, b:FlxSprite, asDegrees:Bool = false):Float
	{
		var dx:Float = (b.x + b.origin.x) - (a.x + a.origin.x);
		var dy:Float = (b.y + b.origin.y) - (a.y + a.origin.y);
		
		if (asDegrees)
		{
			return FlxMath.asDegrees(Math.atan2(dy, dx));
		}
		else
		{
			return Math.atan2(dy, dx);
		}
	}
	
	/**
	 * Given the angle and speed calculate the velocity and return it as an FlxPoint
	 * 
	 * @param	angle	The angle (in degrees) calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * @param	speed	The speed it will move, in pixels per second sq
	 * 
	 * @return	An FlxPoint where FlxPoint.x contains the velocity x value and FlxPoint.y contains the velocity y value
	 */
	public static function velocityFromAngle(angle:Int, speed:Int):FlxPoint
	{
		var a:Float = FlxMath.asRadians(angle);
		
		var result:FlxPoint = new FlxPoint();
		
		result.x = Std.int(Math.cos(a) * speed);
		result.y = Std.int(Math.sin(a) * speed);
		
		return result;
	}
	
	/**
	 * Given the FlxSprite and speed calculate the velocity and return it as an FlxPoint based on the direction the sprite is facing
	 * 
	 * @param	parent	The FlxSprite to get the facing value from
	 * @param	speed	The speed it will move, in pixels per second sq
	 * 
	 * @return	An FlxPoint where FlxPoint.x contains the velocity x value and FlxPoint.y contains the velocity y value
	 */
	public static function velocityFromFacing(parent:FlxSprite, speed:Int):FlxPoint
	{
		var a:Float = 0;
		
		if (parent.facing == FlxObject.LEFT)
		{
			a = FlxMath.asRadians(180);
		}
		else if (parent.facing == FlxObject.RIGHT)
		{
			a = FlxMath.asRadians(0);
		}
		else if (parent.facing == FlxObject.UP)
		{
			a = FlxMath.asRadians( -90);
		}
		else if (parent.facing == FlxObject.DOWN)
		{
			a = FlxMath.asRadians(90);
		}
		
		var result:FlxPoint = new FlxPoint();
		
		result.x = Std.int(Math.cos(a) * speed);
		result.y = Std.int(Math.sin(a) * speed);
		
		return result;
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Find the angle (in radians) between an FlxSprite and the mouse, taking their x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	a			The FlxObject to test from
	 * @param	b			The FlxObject to test to
	 * @param	asDegrees	If you need the value in degrees instead of radians, set to true
	 * 
	 * @return	Number The angle (in radians unless asDegrees is true)
	 */
	public static function angleBetweenMouse(a:FlxObject, asDegrees:Bool = false):Float
	{
		//	In order to get the angle between the object and mouse, we need the objects screen coordinates (rather than world coordinates)
		var p:FlxPoint = a.getScreenXY();
		
		var dx:Float = FlxG.mouse.screenX - p.x;
		var dy:Float = FlxG.mouse.screenY - p.y;
		
		if (asDegrees)
		{
			return FlxMath.asDegrees(Math.atan2(dy, dx));
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
	 * @param	a						The FlxObject to test from
	 * @param	b						The FlxTouch to test to
	 * @param	asDegrees		If you need the value in degrees instead of radians, set to true
	 * 
	 * @return	Number The angle (in radians unless asDegrees is true)
	 */
	public static function angleBetweenTouch(a:FlxObject, b:FlxTouch, asDegrees:Bool = false):Float
	{
		//	In order to get the angle between the object and mouse, we need the objects screen coordinates (rather than world coordinates)
		var p:FlxPoint = a.getScreenXY();
		
		var dx:Float = b.screenX - p.x;
		var dy:Float = b.screenY - p.y;
		
		if (asDegrees)
		{
			return FlxMath.asDegrees(Math.atan2(dy, dx));
		}
		else
		{
			return Math.atan2(dy, dx);
		}
	}
	#end

}