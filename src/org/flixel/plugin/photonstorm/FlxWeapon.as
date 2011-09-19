/**
 * FlxWeapon
 * -- Part of the Flixel Power Tools set
 * 
 * v1.0 First release
 * 
 * @version 1.0 - June 10th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm 
{
	import org.flixel.*;
	import flash.utils.getTimer;
	import org.flixel.plugin.photonstorm.BaseTypes.Bullet;
	import org.flixel.plugin.photonstorm.FlxVelocity;
	
	/**
	 * A Weapon can only fire 1 type of bullet. But it can fire many of them at once (in different directions if needed) via createBulletPattern
	 * A Player could fire multiple Weapons at the same time however, if you need to layer them up
	 * 
	 * TODO
	 * ----
	 * 
	 * Angled bullets
	 * RND factor
	 * Baked Rotation support for angled bullets
	 * Bullet death styles (particle effects)
	 * Bullet trails - blur FX style and Missile Command "draw lines" style? (could be another FX plugin)
	 * Assigning sound effects
	 * Homing Missiles
	 * Bullet uses random sprite from sprite sheet (for rainbow style bullets), or cycles through them in sequence?
	 * Some Weapon base classes like shotgun, lazer, etc?
	 */
	
	public class FlxWeapon 
	{
		/**
		 * Internal name for this weapon (i.e. "pulse rifle")
		 */
		public var name:String;
		
		/**
		 * The FlxGroup into which all the bullets for this weapon are drawn. This should be added to your display and collision checked against it.
		 */
		public var group:FlxGroup;
		
		//	Bullet values
		public var bounds:FlxRect;
		
		private var bulletSpeed:uint;
		private var rotateToAngle:Boolean;
		
		//	When firing from a fixed position (i.e. Missile Command)
		private var fireFromPosition:Boolean;
		private var fireX:int;
		private var fireY:int;
		
		private var lastFired:uint = 0;
		private var nextFire:uint = 0;
		private var fireRate:uint = 0;
		
		//	When firing from a parent sprites position (i.e. Space Invaders)
		private var fireFromParent:Boolean;
		private var parent:*;
		private var parentXVariable:String;
		private var parentYVariable:String;
		private var positionOffset:FlxPoint;
		
		private var velocity:FlxPoint;
		
		//	Callbacks
		public var onKillCallback:Function;
		public var onFireCallback:Function;
		
		//	Sounds
		public var playSounds:Boolean;
		public var onKillSound:FlxSound;
		public var onFireSound:FlxSound;
		
		//	Quick firing direction angle constants
		public static const BULLET_UP:int = -90;
		public static const BULLET_DOWN:int = 90;
		public static const BULLET_LEFT:int = 180;
		public static const BULLET_RIGHT:int = 0;
		public static const BULLET_NORTH_EAST:int = -45;
		public static const BULLET_NORTH_WEST:int = -135;
		public static const BULLET_SOUTH_EAST:int = 45;
		public static const BULLET_SOUTH_WEST:int = 135;
		
		//	TODO :)
		private var bulletsFired:uint;
		private var currentMagazine:uint;
		private var currentBullet:uint;
		private var magazineCount:uint;
		private var bulletsPerMagazine:uint;
		private var magazineSwapDelay:uint;
		private var magazineSwapCallback:Function;
		private var magazineSwapSound:FlxSound;
		
		private static const FIRE:uint = 0;
		private static const FIRE_AT_MOUSE:uint = 1;
		private static const FIRE_AT_POSITION:uint = 2;
		private static const FIRE_AT_TARGET:uint = 3;
		private static const FIRE_FROM_ANGLE:uint = 4;
		private static const FIRE_FROM_PARENT_ANGLE:uint = 5;
		
		/**
		 * Creates the FlxWeapon class which will fire your bullets.<br>
		 * You should call one of the makeBullet functions to visually create the bullets.<br>
		 * Then either use setDirection with fire() or one of the fireAt functions to launch them.
		 * 
		 * @param	name		The name of your weapon (i.e. "lazer" or "shotgun"). For your internal reference really, but could be displayed in-game.
		 * @param	parentRef	If this weapon belongs to a parent sprite, specify it here (bullets will fire from the sprites x/y vars as defined below).
		 * @param	xVariable	The x axis variable of the parent to use when firing. Typically "x", but could be "screenX" or any public getter that exposes the x coordinate.
		 * @param	yVariable	The y axis variable of the parent to use when firing. Typically "y", but could be "screenY" or any public getter that exposes the y coordinate.
		 */
		public function FlxWeapon(name:String, parentRef:* = null, xVariable:String = "x", yVariable:String = "y")
		{
			this.name = name;
			
			bounds = new FlxRect(0, 0, FlxG.width, FlxG.height);
			
			positionOffset = new FlxPoint;
			
			velocity = new FlxPoint;
			
			if (parentRef)
			{
				setParent(parentRef, xVariable, yVariable);
			}
		}
		
		/**
		 * Makes a pixel bullet sprite (rather than an image). You can set the width/height and color of the bullet.
		 * 
		 * @param	quantity	How many bullets do you need to make? This value should be high enough to cover all bullets you need on-screen *at once* plus probably a few extra spare!
		 * @param	width		The width (in pixels) of the bullets
		 * @param	height		The height (in pixels) of the bullets
		 * @param	color		The color of the bullets. Must be given in 0xAARRGGBB format
		 * @param	offsetX		When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY		When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 */
		public function makePixelBullet(quantity:uint, width:int = 2, height:int = 2, color:uint = 0xffffffff, offsetX:int = 0, offsetY:int = 0):void
		{
			group = new FlxGroup(quantity);
			
			for (var b:uint = 0; b < quantity; b++)
			{
				var tempBullet:Bullet = new Bullet(this, b);
				
				tempBullet.makeGraphic(width, height, color);
				
				group.add(tempBullet);
			}
			
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * Makes a bullet sprite from the given image. It will use the width/height of the image.
		 * 
		 * @param	quantity		How many bullets do you need to make? This value should be high enough to cover all bullets you need on-screen *at once* plus probably a few extra spare!
		 * @param	image			The image used to create the bullet from
		 * @param	offsetX			When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY			When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	autoRotate		When true the bullet sprite will rotate to match the angle of the parent sprite. Call fireFromParentAngle or fromFromAngle to fire it using an angle as the velocity.
		 * @param	frame			If the image has a single row of square animation frames on it, you can specify which of the frames you want to use here. Default is -1, or "use whole graphic"
		 * @param	rotations		The number of rotation frames the final sprite should have.  For small sprites this can be quite a large number (360 even) without any problems.
		 * @param	antiAliasing	Whether to use high quality rotations when creating the graphic. Default is false.
		 * @param	autoBuffer		Whether to automatically increase the image size to accomodate rotated corners. Default is false. Will create frames that are 150% larger on each axis than the original frame or graphic.
		 */
		public function makeImageBullet(quantity:uint, image:Class, offsetX:int = 0, offsetY:int = 0, autoRotate:Boolean = false, rotations:uint = 16, frame:int = -1, antiAliasing:Boolean = false, autoBuffer:Boolean = false):void
		{
			group = new FlxGroup(quantity);
			
			rotateToAngle = autoRotate;
			
			for (var b:uint = 0; b < quantity; b++)
			{
				var tempBullet:Bullet = new Bullet(this, b);
				
				if (autoRotate)
				{
					tempBullet.loadRotatedGraphic(image, rotations, frame, antiAliasing, autoBuffer);
				}
				else
				{
					tempBullet.loadGraphic(image);
				}
				
				group.add(tempBullet);
			}
			
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * Makes an animated bullet from the image and frame data given.
		 * 
		 * @param	quantity		How many bullets do you need to make? This value should be high enough to cover all bullets you need on-screen *at once* plus probably a few extra spare!
		 * @param	imageSequence	The image used to created the animated bullet from
		 * @param	frameWidth		The width of each frame in the animation
		 * @param	frameHeight		The height of each frame in the animation
		 * @param	frames			An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
		 * @param	frameRate		The speed in frames per second that the animation should play at (e.g. 40 fps)
		 * @param	looped			Whether or not the animation is looped or just plays once
		 * @param	offsetX			When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY			When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 */
		public function makeAnimatedBullet(quantity:uint, imageSequence:Class, frameWidth:uint, frameHeight:uint, frames:Array, frameRate:uint, looped:Boolean, offsetX:int = 0, offsetY:int = 0):void
		{
			group = new FlxGroup(quantity);
			
			for (var b:uint = 0; b < quantity; b++)
			{
				var tempBullet:Bullet = new Bullet(this, b);
				
				tempBullet.loadGraphic(imageSequence, true, false, frameWidth, frameHeight);
				
				tempBullet.addAnimation("fire", frames, frameRate, looped);
				
				group.add(tempBullet);
			}
			
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * Internal function that handles the actual firing of the bullets
		 * 
		 * @param	method
		 * @param	x
		 * @param	y
		 * @param	target
		 */
		private function runFire(method:uint, x:int = 0, y:int = 0, target:FlxSprite = null, angle:int = 0):void
		{
			if (fireRate > 0 && (getTimer() < nextFire))
			{
				return;
			}
			
			var bullet:Bullet = getFreeBullet();
			
			if (bullet == null)
			{
				return;
			}

			//	Clear any velocity that may have been previously set from the pool
			bullet.velocity.x = 0;
			bullet.velocity.y = 0;
			
			lastFired = getTimer();
			nextFire = getTimer() + fireRate;
			
			var launchX:int = positionOffset.x;
			var launchY:int = positionOffset.y;
			
			if (fireFromParent)
			{
				launchX += parent[parentXVariable];
				launchY += parent[parentYVariable];
			}
			else if (fireFromPosition)
			{
				launchX += fireX;
				launchY += fireY;
			}
			
			//	Faster (less CPU) to use this small if-else ladder than a switch statement
			if (method == FIRE)
			{
				bullet.fire(launchX, launchY, velocity.x, velocity.y);
			}
			else if (method == FIRE_AT_MOUSE)
			{
				bullet.fireAtMouse(launchX, launchY, bulletSpeed);
			}
			else if (method == FIRE_AT_POSITION)
			{
				bullet.fireAtPosition(launchX, launchY, x, y, bulletSpeed);
			}
			else if (method == FIRE_AT_TARGET)
			{
				bullet.fireAtTarget(launchX, launchY, target, bulletSpeed);
			}
			else if (method == FIRE_FROM_ANGLE)
			{
				bullet.fireFromAngle(launchX, launchY, angle, bulletSpeed);
			}
			else if (method == FIRE_FROM_PARENT_ANGLE)
			{
				bullet.fireFromAngle(launchX, launchY, parent.angle, bulletSpeed);
			}
		}
		
		/**
		 * Fires a bullet (if one is available). The bullet will be given the velocity defined in setBulletDirection and fired at the rate set in setFireRate.
		 */
		public function fire():void
		{
			runFire(FIRE);
		}
		
		/**
		 * Fires a bullet (if one is available) at the mouse coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
		 */
		public function fireAtMouse():void
		{
			runFire(FIRE_AT_MOUSE);
		}
		
		/**
		 * Fires a bullet (if one is available) at the given x/y coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
		 * 
		 * @param	x	The x coordinate (in game world pixels) to fire at
		 * @param	y	The y coordinate (in game world pixels) to fire at
		 */
		public function fireAtPosition(x:int, y:int):void
		{
			runFire(FIRE_AT_POSITION, x, y);
		}
		
		/**
		 * Fires a bullet (if one is available) at the given targets x/y coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
		 * 
		 * @param	target	The FlxSprite you wish to fire the bullet at
		 */
		public function fireAtTarget(target:FlxSprite):void
		{
			runFire(FIRE_AT_TARGET, 0, 0, target);
		}
		
		public function fireFromAngle(angle:int):void
		{
			runFire(FIRE_FROM_ANGLE, 0, 0, null, angle);
		}
		
		public function fireFromParentAngle():void
		{
			runFire(FIRE_FROM_PARENT_ANGLE);
		}
		
		/**
		 * Causes the Weapon to fire from the parents x/y value, as seen in Space Invaders and most shoot-em-ups.
		 * 
		 * @param	parentRef	If this weapon belongs to a parent sprite, specify it here (bullets will fire from the sprites x/y vars as defined below).
		 * @param	xVariable	The x axis variable of the parent to use when firing. Typically "x", but could be "screenX" or any public getter that exposes the x coordinate.
		 * @param	yVariable	The y axis variable of the parent to use when firing. Typically "y", but could be "screenY" or any public getter that exposes the y coordinate.
		 * @param	offsetX		When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY		When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 */
		public function setParent(parentRef:*, xVariable:String, yVariable:String, offsetX:int = 0, offsetY:int = 0):void
		{
			if (parentRef)
			{
				fireFromParent = true;
				
				parent = parentRef;
				
				parentXVariable = xVariable;
				parentYVariable = yVariable;
			
				positionOffset.x = offsetX;
				positionOffset.y = offsetY;
			}
		}
		
		/**
		 * Causes the Weapon to fire from a fixed x/y position on the screen, like in the game Missile Command.<br>
		 * If set this over-rides a call to setParent (which causes the Weapon to fire from the parents x/y position)
		 * 
		 * @param	x	The x coordinate (in game world pixels) to fire from
		 * @param	y	The y coordinate (in game world pixels) to fire from
		 * @param	offsetX		When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 * @param	offsetY		When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
		 */
		public function setFiringPosition(x:int, y:int, offsetX:int = 0, offsetY:int = 0):void
		{
			fireFromPosition = true;
			fireX = x;
			fireY = y;
			
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * The speed in pixels/sec (sq) that the bullet travels at when fired via fireAtMouse, fireAtPosition or fireAtTarget.<br>
		 * You can update this value in real-time, should you need to speed-up or slow-down your bullets (i.e. collecting a power-up)
		 * 
		 * @param	speed		The speed it will move, in pixels per second (sq)
		 */
		public function setBulletSpeed(speed:uint):void
		{
			bulletSpeed = speed;
		}
		
		/**
		 * The speed in pixels/sec (sq) that the bullet travels at when fired via fireAtMouse, fireAtPosition or fireAtTarget.
		 * 
		 * @return	The speed the bullet moves at, in pixels per second (sq)
		 */
		public function getBulletSpeed():uint
		{
			return bulletSpeed;
		}
		
		/**
		 * Sets the firing rate of the Weapon. By default there is no rate, as it can be controlled by FlxControl.setFireButton.<br>
		 * However if you are firing using the mouse you may wish to set a firing rate.
		 * 
		 * @param	rate	The delay in milliseconds (ms) between which each bullet is fired, set to zero to clear
		 */
		public function setFireRate(rate:uint):void
		{
			fireRate = rate;
		}
		
		/**
		 * When a bullet goes outside of this bounds it will be automatically killed, freeing it up for firing again.
		 * TODO - Needs testing with a scrolling map (when not using single screen display)
		 * 
		 * @param	bounds	An FlxRect area. Inside this area the bullet should be considered alive, once outside it will be killed.
		 */
		public function setBulletBounds(bounds:FlxRect):void
		{
			this.bounds = bounds;
		}
		
		/**
		 * Set the direction the bullet will travel when fired.<br>
		 * You can use one of the consts such as BULLET_UP, BULLET_DOWN or BULLET_NORTH_EAST to set the angle easily.<br>
		 * Speed should be given in pixels/sec (sq) and is the speed at which the bullet travels when fired.
		 * 
		 * @param	angle		The angle of the bullet. In clockwise positive direction: Right = 0, Down = 90, Left = 180, Up = -90. You can use one of the consts such as BULLET_UP, etc
		 * @param	speed		The speed it will move, in pixels per second (sq)
		 */
		public function setBulletDirection(angle:int, speed:uint):void
		{
			velocity = FlxVelocity.velocityFromAngle(angle, speed);
		}
		
		/**
		 * Sets gravity on all currently created bullets<br>
		 * This will update ALL bullets, even those currently "in flight", so be careful about when you call this!
		 * 
		 * @param	xForce	A positive value applies gravity dragging the bullet to the right. A negative value drags the bullet to the left. Zero disables horizontal gravity.
		 * @param	yforce	A positive value applies gravity dragging the bullet down. A negative value drags the bullet up. Zero disables vertical gravity.
		 */
		public function setBulletGravity(xForce:int, yForce:int):void
		{
			group.setAll("xGravity", xForce);
			group.setAll("yGravity", yForce);
		}
		
		/**
		 * If you'd like your bullets to accelerate to their top speed rather than be launched already at it, then set the acceleration value here.<br>
		 * If you've previously set the acceleration then setting it to zero will cancel the effect.<br>
		 * This will update ALL bullets, even those currently "in flight", so be careful about when you call this!
		 * 
		 * @param	xAcceleration		Acceleration speed in pixels per second to apply to the sprites horizontal movement, set to zero to cancel. Negative values move left, positive move right.
		 * @param	yAcceleration		Acceleration speed in pixels per second to apply to the sprites vertical movement, set to zero to cancel. Negative values move up, positive move down.
		 * @param	xSpeedMax			The maximum speed in pixels per second in which the sprite can move horizontally
		 * @param	ySpeedMax			The maximum speed in pixels per second in which the sprite can move vertically
		 */
		public function setBulletAcceleration(xAcceleration:int, yAcceleration:int, xSpeedMax:int, ySpeedMax:int):void
		{
			if (xAcceleration == 0 && yAcceleration == 0)
			{
				group.setAll("accelerates", false);
			}
			else
			{
				group.setAll("accelerates", true);
				group.setAll("xAcceleration", xAcceleration);
				group.setAll("yAcceleration", yAcceleration);
				group.setAll("maxVelocityX", xSpeedMax);
				group.setAll("maxVelocityY", ySpeedMax);
			}
		}
		
		/**
		 * When the bullet is fired from a parent (or fixed position) it will do so from their x/y coordinate.<br>
		 * Often you need to align a bullet with the sprite, i.e. to make it look like it came out of the "nose" of a space ship.<br>
		 * Use this offset x/y value to achieve that effect.
		 * 
		 * @param	offsetX		The x coordinate offset to add to the launch location (positive or negative)
		 * @param	offsetY		The y coordinate offset to add to the launch location (positive or negative)
		 */
		public function setBulletOffset(offsetX:int, offsetY:int):void
		{
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
		}
		
		/**
		 * To make the bullet apply a random factor to either its angle, speed, or both when fired, set these values. Can create a nice "scatter gun" effect.
		 * 
		 * @param	randomAngle		The +- value applied to the angle when fired. For example 20 means the bullet can fire up to 20 degrees under or over its angle when fired.
		 * @param	randomSpeed		The +- value applied to the speed when fired. For example 20 means the bullet can fire up to 20 px/sec slower or faster when fired.
		 */
		public function setBulletRandomFactor(randomAngle:uint, randomSpeed:uint):void
		{
		}
		
		/**
		 * If the bullet should have a fixed life span use this function to set it.<br>
		 * The bullet will be killed once it passes this lifespan, if still alive and in bounds.
		 * 
		 * @param	lifespan	The lifespan of the bullet, given in ms (milliseconds) calculated from the moment the bullet is fired
		 */
		public function setBulletLifeSpan(lifespan:int):void
		{
		}
		
		/**
		 * Internal function that returns the next available bullet from the pool (if any)
		 * 
		 * @return	A bullet
		 */
		private function getFreeBullet():Bullet
		{
			var result:Bullet = null;
			
			if (group == null || group.length == 0)
			{
				throw new Error("Weapon.as cannot fire a bullet until one has been created via a call to makePixelBullet or makeImageBullet");
				return null;
			}
			
			for each (var bullet:Bullet in group.members)
			{
				if (bullet.exists == false)
				{
					result = bullet;
					break;
				}
			}
			
			return result;
		}
		
		
		
		// TODO
		public function createBulletPattern(pattern:Array):void
		{
			//	Launches this many bullets
		}
		
		
		public function update():void
		{
			// ???
		}
		
	}

}