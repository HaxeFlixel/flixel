/**
 * FlxWeapon
 * -- Part of the Flixel Power Tools set
 * 
 * v1.3 Added bullet elasticity and bulletsFired counter
 * v1.2 Added useParentDirection boolean
 * v1.1 Added pre-fire, fire and post-fire callbacks and sound support, rnd factors, boolean returns and currentBullet
 * v1.0 First release
 * 
 * @version 1.3 - October 9th 2011
 * @link http://www.photonstorm.com
 * @link http://www.haxeflixel.com
 * @author Richard Davey / Photon Storm
* @author Touch added by Impaler / Beeblerox
*/

package org.flixel.plugin.photonstorm;

import org.flixel.FlxBasic;
import org.flixel.FlxG;
import org.flixel.FlxTilemap;
import org.flixel.FlxTypedGroup;
import org.flixel.system.input.FlxTouch;
import nme.display.Bitmap;
import nme.display.BitmapInt32;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxRect;
import org.flixel.FlxSound;
import org.flixel.FlxSprite;
import org.flixel.FlxU;
import org.flixel.plugin.photonstorm.baseTypes.Bullet;
import org.flixel.plugin.photonstorm.FlxVelocity;

/**
 * A Weapon can only fire 1 type of bullet. But it can fire many of them at once (in different directions if needed) via createBulletPattern
 * A Player could fire multiple Weapons at the same time however, if you need to layer them up
 * 
 * TODO
 * ----
 * 
 * Angled bullets
 * Baked Rotation support for angled bullets
 * Bullet death styles (particle effects)
 * Bullet trails - blur FX style and Missile Command "draw lines" style? (could be another FX plugin)
 * Homing Missiles
 * Bullet uses random sprite from sprite sheet (for rainbow style bullets), or cycles through them in sequence?
 * Some Weapon base classes like shotgun, lazer, etc?
 */

class FlxWeapon 
{
	/**
	 * Internal name for this weapon (i.e. "pulse rifle")
	 */
	public var name:String;
	
	/**
	 * The FlxGroup into which all the bullets for this weapon are drawn. This should be added to your display and collision checked against it.
	 */
	public var group:FlxTypedGroup<Bullet>;
	
	// Internal variables, use with caution
	public var nextFire:Int;
	public var fireRate:Int;
	public var bulletSpeed:Int;
	
	//	Bullet values
	public var bounds:FlxRect;
	
	private var rotateToAngle:Bool;
	
	//	When firing from a fixed position (i.e. Missile Command)
	private var fireFromPosition:Bool;
	private var fireX:Int;
	private var fireY:Int;
	
	private var lastFired:Int;
	private var touchTarget:FlxTouch;
	
	//	When firing from a parent sprites position (i.e. Space Invaders)
	private var fireFromParent:Bool;
	public var parent:FlxSprite;
	private var positionOffset:FlxPoint;
	private var directionFromParent:Bool;
	private var angleFromParent:Bool;
	
	private var velocity:FlxPoint;
	
	public var multiShot:Int;
	public var bulletLifeSpan:Float;
	public var bulletDamage:Float;
	
	public var bulletElasticity:Float;
	
	public var rndFactorAngle:Int;
	public var rndFactorSpeed:Int;
	public var rndFactorLifeSpan:Float;
	public var rndFactorPosition:FlxPoint;
	
	/**
	 * A reference to the Bullet that was fired
	 */
	public var currentBullet:Bullet;
	
	//	Callbacks
	public var onPreFireCallback:Void->Void;
	public var onFireCallback:Void->Void;
	public var onPostFireCallback:Void->Void;
	
	//	Sounds
	public var onPreFireSound:FlxSound;
	public var onFireSound:FlxSound;
	public var onPostFireSound:FlxSound;
	
	//	Quick firing direction angle constants
	public static inline var BULLET_UP:Int = -90;
	public static inline var BULLET_DOWN:Int = 90;
	public static inline var BULLET_LEFT:Int = 180;
	public static inline var BULLET_RIGHT:Int = 0;
	public static inline var BULLET_NORTH_EAST:Int = -45;
	public static inline var BULLET_NORTH_WEST:Int = -135;
	public static inline var BULLET_SOUTH_EAST:Int = 45;
	public static inline var BULLET_SOUTH_WEST:Int = 135;
	
	//	TODO :)
	/**
	 * Keeps a tally of how many bullets have been fired by this weapon
	 */
	private var bulletsFired:Int;
	private var currentMagazine:Int;
	//private var currentBullet:Int;
	private var magazineCount:Int;
	private var bulletsPerMagazine:Int;
	private var magazineSwapDelay:Int;
	private var skipParentCollision:Bool;
	
	private var magazineSwapCallback:Dynamic;
	private var magazineSwapSound:FlxSound;
	
	private static inline var FIRE:Int = 0;
	private static inline var FIRE_AT_MOUSE:Int = 1;
	private static inline var FIRE_AT_POSITION:Int = 2;
	private static inline var FIRE_AT_TARGET:Int = 3;
	private static inline var FIRE_FROM_ANGLE:Int = 4;
	private static inline var FIRE_FROM_PARENT_ANGLE:Int = 5;
	private static inline var FIRE_AT_TOUCH:Int = 6;
	
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
	public function new(name:String, parentRef:FlxSprite = null)
	{
		bulletsFired = 0;
		
		rndFactorAngle = 0;
		rndFactorLifeSpan = 0;
		rndFactorSpeed = 0;
		rndFactorPosition = new FlxPoint();
		multiShot = 0;
		bulletLifeSpan = 0;
		bulletElasticity = 0;
		bulletDamage = 1;
		
		lastFired = 0;
		nextFire = 0;
		fireRate = 0;
		
		this.name = name;
		
		bounds = new FlxRect(0, 0, FlxG.width, FlxG.height);
		
		positionOffset = new FlxPoint();
		
		velocity = new FlxPoint();
		
		if (parentRef != null)
		{
			setParent(parentRef);
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
	#if flash
	public function makePixelBullet(quantity:UInt, width:Int = 2, height:Int = 2, ?color:UInt = 0xffffffff, offsetX:Int = 0, offsetY:Int = 0):Void
	#else
	public function makePixelBullet(quantity:Int, width:Int = 2, height:Int = 2, ?color:BitmapInt32, offsetX:Int = 0, offsetY:Int = 0):Void
	#end
	{
		#if !flash
		if (color == null)
		{
			color = FlxG.WHITE;
		}
		#end
		
		group = new FlxTypedGroup<Bullet>(quantity);
		
		for (b in 0...(quantity))
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
	public function makeImageBullet(quantity:Int, image:Dynamic, offsetX:Int = 0, offsetY:Int = 0, autoRotate:Bool = false, rotations:Int = 16, frame:Int = -1, antiAliasing:Bool = false, autoBuffer:Bool = false):Void
	{
		group = new FlxTypedGroup<Bullet>(quantity);
		
		rotateToAngle = autoRotate;
		
		for (b in 0...(quantity))
		{
			var tempBullet:Bullet = new Bullet(this, b);
			
			#if flash
			if (autoRotate)
			{
				tempBullet.loadRotatedGraphic(image, rotations, frame, antiAliasing, autoBuffer);
			}
			else
			{
				tempBullet.loadGraphic(image);
			}
			#else
			tempBullet.loadGraphic(image);
			tempBullet.frame = frame;
			tempBullet.antialiasing = antiAliasing;
			#end
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
	public function makeAnimatedBullet(quantity:Int, imageSequence:Dynamic, frameWidth:Int, frameHeight:Int, frames:Array<Int>, frameRate:Int, looped:Bool, offsetX:Int = 0, offsetY:Int = 0):Void
	{
		group = new FlxTypedGroup<Bullet>(quantity);
		
		for (b in 0...(quantity))
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
	 * @return	true if a bullet was fired or false if one wasn't available. The bullet last fired is stored in FlxWeapon.prevBullet
	 */
	private function runFire(method:Int, x:Int = 0, y:Int = 0, target:FlxSprite = null, angle:Int = 0):Bool
	{
		if (fireRate > 0 && FlxU.getTicks() < nextFire)
		{
			return false;
		}
		
		currentBullet = getFreeBullet();
		
		if (currentBullet == null)
		{
			return false;
		}
		
		if (onPreFireCallback != null)
		{
			onPreFireCallback();
		}
		
		if (onPreFireSound != null)
		{
			onPreFireSound.play();
		}

		//	Clear any velocity that may have been previously set from the pool
		currentBullet.velocity.x = 0;
		currentBullet.velocity.y = 0;
		
		lastFired = FlxU.getTicks();
		nextFire = FlxU.getTicks() + Std.int(fireRate / FlxG.timeScale);
		
		var launchX:Float = positionOffset.x;
		var launchY:Float = positionOffset.y;
		
		if (fireFromParent)
		{
			launchX += parent.x;
			launchY += parent.y;
		}
		else if (fireFromPosition)
		{
			launchX += fireX;
			launchY += fireY;
		}
		
		if (directionFromParent)
		{
			velocity = FlxVelocity.velocityFromFacing(parent, bulletSpeed);
		}
		
		//	Faster (less CPU) to use this small if-else ladder than a switch statement
		if (method == FIRE)
		{
			currentBullet.fire(launchX, launchY, velocity.x, velocity.y);
		}
		else if (method == FIRE_AT_POSITION)
		{
			currentBullet.fireAtPosition(launchX, launchY, x, y, bulletSpeed);
		}
		else if (method == FIRE_AT_TARGET)
		{
			currentBullet.fireAtTarget(launchX, launchY, target, bulletSpeed);
		}
		else if (method == FIRE_FROM_ANGLE)
		{
			currentBullet.fireFromAngle(launchX, launchY, angle, bulletSpeed);
		}
		else if (method == FIRE_FROM_PARENT_ANGLE)
		{
			currentBullet.fireFromAngle(launchX, launchY, Math.floor(parent.angle), bulletSpeed);
		}
		#if !FLX_NO_TOUCH
		else if (method == FIRE_AT_TOUCH)
		{
			if ( touchTarget != null)
			currentBullet.fireAtTouch(launchX, launchY, touchTarget, bulletSpeed);
		}
		#end
		#if !FLX_NO_MOUSE
		else if (method == FIRE_AT_MOUSE)
		{
			currentBullet.fireAtMouse(launchX, launchY, bulletSpeed);
		}
		#end
		if (onPostFireCallback != null)
		{
			onPostFireCallback();
		}
		
		if (onPostFireSound != null)
		{
			onPostFireSound.play();
		}
		
		bulletsFired++;
		
		return true;
	}
	
	/**
	 * Fires a bullet (if one is available). The bullet will be given the velocity defined in setBulletDirection and fired at the rate set in setFireRate.
	 * 
	 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	public inline function fire():Bool
	{
		return runFire(FIRE);
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Fires a bullet (if one is available) at the mouse coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
	 * 
	 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	public inline function fireAtMouse():Bool
	{
		return runFire(FIRE_AT_MOUSE);
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Fires a bullet (if one is available) at the FlxTouch coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
	 * 
	 * 	@param	a	The FlxTouch object to fire at, if null use the first available one
	 * @return		true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	public function fireAtTouch(a:FlxTouch = null):Bool
	{
		if ( a == null ) 
		{
			touchTarget = FlxG.touchManager.getFirstTouch();
		} else {
			touchTarget = a;
		}
		var fired = false;
		if ( touchTarget != null) {
			fired = runFire(FIRE_AT_TOUCH);
			touchTarget = null;
		}
		return fired;
	}
	#end
	
	/**
	 * Fires a bullet (if one is available) at the given x/y coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
	 * 
	 * @param	x	The x coordinate (in game world pixels) to fire at
	 * @param	y	The y coordinate (in game world pixels) to fire at
	 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	public inline function fireAtPosition(x:Int, y:Int):Bool
	{
		return runFire(FIRE_AT_POSITION, x, y);
	}
	
	/**
	 * Fires a bullet (if one is available) at the given targets x/y coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
	 * 
	 * @param	target	The FlxSprite you wish to fire the bullet at
	 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	public inline function fireAtTarget(target:FlxSprite):Bool
	{
		return runFire(FIRE_AT_TARGET, 0, 0, target);
	}
	
	/**
	 * Fires a bullet (if one is available) based on the given angle
	 * 
	 * @param	angle	The angle (in degrees) calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	public inline function fireFromAngle(angle:Int):Bool
	{
		return runFire(FIRE_FROM_ANGLE, 0, 0, null, angle);
	}
	
	/**
	 * Fires a bullet (if one is available) based on the angle of the Weapons parent
	 * 
	 * @return	true if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	public inline function fireFromParentAngle():Bool
	{
		return runFire(FIRE_FROM_PARENT_ANGLE);
	}
	
	/**
	 * Causes the Weapon to fire from the parents x/y value, as seen in Space Invaders and most shoot-em-ups.
	 * 
	 * @param	parentRef		If this weapon belongs to a parent sprite, specify it here (bullets will fire from the sprites x/y vars as defined below).
	 * @param	xVariable		The x axis variable of the parent to use when firing. Typically "x", but could be "screenX" or any public getter that exposes the x coordinate.
	 * @param	yVariable		The y axis variable of the parent to use when firing. Typically "y", but could be "screenY" or any public getter that exposes the y coordinate.
	 * @param	offsetX			When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 * @param	offsetY			When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 * @param	useDirection	When fired the bullet direction is based on parent sprites facing value (up/down/left/right)
	 */
	public function setParent(parentRef:FlxSprite, offsetX:Int = 0, offsetY:Int = 0, useDirection:Bool = false):Void
	{
		if (parentRef != null)
		{
			fireFromParent = true;
			
			parent = parentRef;
			
			positionOffset.x = offsetX;
			positionOffset.y = offsetY;
			
			directionFromParent = useDirection;
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
	public function setFiringPosition(x:Int, y:Int, offsetX:Int = 0, offsetY:Int = 0):Void
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
	public function setBulletSpeed(speed:Int):Void
	{
		bulletSpeed = speed;
	}
	
	/**
	 * The speed in pixels/sec (sq) that the bullet travels at when fired via fireAtMouse, fireAtPosition or fireAtTarget.
	 * 
	 * @return	The speed the bullet moves at, in pixels per second (sq)
	 */
	public function getBulletSpeed():Int
	{
		return bulletSpeed;
	}
	
	/**
	 * Sets the firing rate of the Weapon. By default there is no rate, as it can be controlled by FlxControl.setFireButton.<br>
	 * However if you are firing using the mouse you may wish to set a firing rate.
	 * 
	 * @param	rate	The delay in milliseconds (ms) between which each bullet is fired, set to zero to clear
	 */
	public function setFireRate(rate:Int):Void
	{
		fireRate = rate;
	}
	
	/**
	 * When a bullet goes outside of this bounds it will be automatically killed, freeing it up for firing again.
	 * TODO - Needs testing with a scrolling map (when not using single screen display)
	 * 
	 * @param	bounds	An FlxRect area. Inside this area the bullet should be considered alive, once outside it will be killed.
	 */
	public function setBulletBounds(bounds:FlxRect):Void
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
	public function setBulletDirection(angle:Int, speed:Int):Void
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
	public function setBulletGravity(xForce:Int, yForce:Int):Void
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
	public function setBulletAcceleration(xAcceleration:Int, yAcceleration:Int, xSpeedMax:Int, ySpeedMax:Int):Void
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
	public function setBulletOffset(offsetX:Float, offsetY:Float):Void
	{
		positionOffset.x = offsetX;
		positionOffset.y = offsetY;
	}
	
	/**
	 * To make the bullet apply a random factor to either its angle, speed, or both when fired, set these values. Can create a nice "scatter gun" effect.
	 * 
	 * @param	randomAngle		The +- value applied to the angle when fired. For example 20 means the bullet can fire up to 20 degrees under or over its angle when fired.
	 * @param	randomSpeed		The +- value applied to the speed when fired. For example 20 means the bullet can fire up to 20 px/sec slower or faster when fired.
	 * @param  randomPosition  The +- value applied to the firing location when fired (fire spread).
	 * @param  randomLifeSpan  The +- value applied to the <code>bulletLifeSpan</code> when fired. For example passing 2 when <code>bulletLifeSpan</code> is 3, means the bullet can live up to 5 seconds, minimum of 1.
	 */
	public function setBulletRandomFactor(randomAngle:Int = 0, randomSpeed:Int = 0, randomPosition:FlxPoint = null, randomLifeSpan:Float = 0):Void
	{
		rndFactorAngle = randomAngle;
		rndFactorSpeed = randomSpeed;
		
		if (randomPosition != null)
		{
			rndFactorPosition = randomPosition;
		}
		
		rndFactorLifeSpan = (randomLifeSpan < 0) ? -randomLifeSpan : randomLifeSpan;
	}
	
	/**
	 * If the bullet should have a fixed life span use this function to set it.
	 * The bullet will be killed once it passes this lifespan, if still alive and in bounds.
	 * 
	 * @param	lifespan  The lifespan of the bullet, given in seconds.
	 */
	public function setBulletLifeSpan(lifespan:Float):Void
	{
		bulletLifeSpan = lifespan;
	}
	
	/**
	 * The elasticity of the fired bullet controls how much it rebounds off collision surfaces.
	 * 
	 * @param	elasticity	The elasticity of the bullet between 0 and 1 (0 being no rebound, 1 being 100% force rebound). Set to zero to disable.
	 */
	public function setBulletElasticity(elasticity:Float):Void
	{
		bulletElasticity = elasticity;
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
			throw "Weapon.as cannot fire a bullet until one has been created via a call to makePixelBullet or makeImageBullet";
			return null;
		}
		
		var bullet:Bullet;
		for (i in 0...(group.members.length))
		{
			bullet = group.members[i];
			if (bullet.exists == false)
			{
				result = bullet;
				break;
			}
		}
		
		return result;
	}
	
	/**
	 * Sets a pre-fire callback function and sound. These are played immediately before the bullet is fired.
	 * 
	 * @param	callback	The function to call
	 * @param	sound		An FlxSound to play
	 */
	public function setPreFireCallback(callbackFunc:Void->Void = null, sound:FlxSound = null):Void
	{
		onPreFireCallback = callbackFunc;
		onPreFireSound = sound;
	}
	
	/**
	 * Sets a fire callback function and sound. These are played immediately as the bullet is fired.
	 * 
	 * @param	callback	The function to call
	 * @param	sound		An FlxSound to play
	 */
	public function setFireCallback(callbackFunc:Void->Void = null, sound:FlxSound = null):Void
	{
		onFireCallback = callbackFunc;
		onFireSound = sound;
	}
	
	/**
	 * Sets a post-fire callback function and sound. These are played immediately after the bullet is fired.
	 * 
	 * @param	callback	The function to call
	 * @param	sound		An FlxSound to play
	 */
	public function setPostFireCallback(callbackFunc:Void->Void = null, sound:FlxSound = null):Void
	{
		onPostFireCallback = callbackFunc;
		onPostFireSound = sound;
	}
	
	/**
	 * Checks to see if the bullets are overlapping the specified object or group
	 * 
	 * @param  objectOrGroup  The group or object to check if bullets collide
	 * @param  notifyCallBack  A function that will get called if a bullet overlaps an object
	 * @param  skipParent    Don't trigger colision notifies with the parent of this object
	*/
	public inline function bulletsOverlap(objectOrGroup:FlxBasic, notifyCallBack:FlxObject->FlxObject->Void = null, skipParent:Bool = true):Void
	{
		if (group != null && group.length > 0)
		{
			skipParentCollision = skipParent;
			FlxG.overlap(objectOrGroup, group, notifyCallBack != null ? notifyCallBack : onBulletHit, shouldBulletHit);
		}
	}

  	private function shouldBulletHit(o:FlxObject, bullet:FlxObject):Bool
	{
		if (parent == o && skipParentCollision)
			return false;
		
		if (Std.is(o, FlxTilemap))
			return cast(o, FlxTilemap).overlapsWithCallback(bullet);
		else
			return true;
	}

  	private function onBulletHit(o:FlxObject, bullet:FlxObject):Void
	{
		bullet.kill();
	}
	
	// TODO
	public function createBulletPattern(pattern:Array<Dynamic>):Void
	{
		//	Launches this many bullets
	}
	
	
	public function update():Void
	{
		// ???
	}
	
}