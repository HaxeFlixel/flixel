package flixel.plugin.photonstorm;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSound;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.plugin.photonstorm.baseTypes.FlxBullet;
import flixel.system.input.FlxTouch;
import flixel.tile.FlxTilemap;
import flixel.util.FlxMisc;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxVelocity;

/**
 * A Weapon can only fire 1 type of bullet. But it can fire many of them at once (in different directions if needed) via createBulletPattern
 * A Player could fire multiple Weapons at the same time however, if you need to layer them up
 * 
 * @version 1.3 - October 9th 2011
 * @link http://www.photonstorm.com
 * @link http://www.haxeflixel.com
 * @author Richard Davey / Photon Storm
 * @author Touch added by Impaler / Beeblerox
 * 
 * TODO: Angled bullets
 * TODO: Baked Rotation support for angled bullets
 * TODO: Bullet death styles (particle effects)
 * TODO: Bullet trails - blur FX style and Missile Command "draw lines" style? (could be another FX plugin)
 * TODO: Homing Missiles
 * TODO: Bullet uses random sprite from sprite sheet (for rainbow style bullets), or cycles through them in sequence?
 * TODO: Some Weapon base classes like shotgun, lazer, etc?
 */
class FlxWeapon 
{
	// Quick firing direction angle constants
	inline static public var BULLET_UP:Int = -90;
	inline static public var BULLET_DOWN:Int = 90;
	inline static public var BULLET_LEFT:Int = 180;
	inline static public var BULLET_RIGHT:Int = 0;
	inline static public var BULLET_NORTH_EAST:Int = -45;
	inline static public var BULLET_NORTH_WEST:Int = -135;
	inline static public var BULLET_SOUTH_EAST:Int = 45;
	inline static public var BULLET_SOUTH_WEST:Int = 135;
	
	/**
	 * Internal name for this weapon (i.e. "pulse rifle")
	 */
	public var name:String;
	/**
	 * The FlxGroup into which all the bullets for this weapon are drawn. This should be added to your display and collision checked against it.
	 */
	public var group:FlxTypedGroup<FlxBullet>;
	
	// Internal variables, use with caution
	public var nextFire:Int = 0;
	public var fireRate:Int = 0;
	public var bulletSpeed:Int;
	
	// Bullet values
	public var bounds:FlxRect;
	
	public var parent:FlxSprite;
	
	public var multiShot:Int = 0;
	public var bulletLifeSpan:Float = 0;
	public var bulletDamage:Float = 1;
	
	public var bulletElasticity:Float = 0;
	
	public var rndFactorAngle:Int = 0;
	public var rndFactorSpeed:Int = 0;
	public var rndFactorLifeSpan:Float = 0;
	public var rndFactorPosition:FlxPoint;
	
	/**
	 * A reference to the Bullet that was fired
	 */
	public var currentBullet:FlxBullet;
	
	// Callbacks
	public var onPreFireCallback:Void->Void;
	public var onFireCallback:Void->Void;
	public var onPostFireCallback:Void->Void;
	
	// Sounds
	public var onPreFireSound:FlxSound;
	public var onFireSound:FlxSound;
	public var onPostFireSound:FlxSound;
	
	inline static private var FIRE:Int = 0;
	inline static private var FIRE_AT_MOUSE:Int = 1;
	inline static private var FIRE_AT_POSITION:Int = 2;
	inline static private var FIRE_AT_TARGET:Int = 3;
	inline static private var FIRE_FROM_ANGLE:Int = 4;
	inline static private var FIRE_FROM_PARENT_ANGLE:Int = 5;
	inline static private var FIRE_AT_TOUCH:Int = 6;
	
	private var _rotateToAngle:Bool;
	private var _velocity:FlxPoint;
	
	// When firing from a fixed position (i.e. Missile Command)
	private var _fireFromPosition:Bool;
	private var _fireX:Int;
	private var _fireY:Int;
	
	private var _lastFired:Int = 0;
	private var _touchTarget:FlxTouch;
	
	//	When firing from a parent sprites position (i.e. Space Invaders)
	private var _fireFromParent:Bool;
	private var _positionOffset:FlxPoint;
	private var _directionFromParent:Bool;
	private var _angleFromParent:Bool;
	
	// TODO :)
	/**
	 * Keeps a tally of how many bullets have been fired by this weapon
	 */
	private var _bulletsFired:Int = 0;
	private var _currentMagazine:Int;
	//private var _currentBullet:Int;
	private var _magazineCount:Int;
	private var _bulletsPerMagazine:Int;
	private var _magazineSwapDelay:Int;
	private var _skipParentCollision:Bool;
	
	private var _magazineSwapCallback:Dynamic;
	private var _magazineSwapSound:FlxSound;
	
	/**
	 * Creates the FlxWeapon class which will fire your bullets.
	 * You should call one of the makeBullet functions to visually create the bullets.
	 * Then either use <code>setDirection</code> with <code>fire()</code> or one of the <code>fireAt</code> functions to launch them.
	 * 
	 * @param	Name		The name of your weapon (i.e. "lazer" or "shotgun"). For your internal reference really, but could be displayed in-game.
	 * @param	ParentRef	If this weapon belongs to a parent sprite, specify it here (bullets will fire from the sprites x/y vars as defined below).
	 */
	public function new(Name:String, ?ParentRef:FlxSprite)
	{
		rndFactorPosition = new FlxPoint();
		bounds = new FlxRect(0, 0, FlxG.width, FlxG.height);
		_positionOffset = new FlxPoint();
		_velocity = new FlxPoint();
		
		name = Name;
		
		if (ParentRef != null)
		{
			setParent(ParentRef);
		}
	}
	
	/**
	 * Makes a pixel bullet sprite (rather than an image). You can set the width/height and color of the bullet.
	 * 
	 * @param	Quantity	How many bullets do you need to make? This value should be high enough to cover all bullets you need on-screen *at once* plus probably a few extra spare!
	 * @param	Width		The width (in pixels) of the bullets
	 * @param	Height		The height (in pixels) of the bullets
	 * @param	Color		The color of the bullets. Must be given in 0xAARRGGBB format
	 * @param	OffsetX		When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 * @param	OffsetY		When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 */
	public function makePixelBullet(Quantity:Int, Width:Int = 2, Height:Int = 2, Color:Int = 0xffffffff, OffsetX:Int = 0, OffsetY:Int = 0):Void
	{
		group = new FlxTypedGroup<FlxBullet>(Quantity);
		
		for (b in 0...Quantity)
		{
			var tempBullet:FlxBullet = new FlxBullet(this, b);
			tempBullet.makeGraphic(Width, Height, Color);
			group.add(tempBullet);
		}
		
		_positionOffset.x = OffsetX;
		_positionOffset.y = OffsetY;
	}
	
	/**
	 * Makes a bullet sprite from the given image. It will use the width/height of the image.
	 * 
	 * @param	Quantity		How many bullets do you need to make? This value should be high enough to cover all bullets you need on-screen *at once* plus probably a few extra spare!
	 * @param	Image			The image used to create the bullet from
	 * @param	OffsetX			When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 * @param	OffsetY			When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 * @param	AutoRotate		When true the bullet sprite will rotate to match the angle of the parent sprite. Call fireFromParentAngle or fromFromAngle to fire it using an angle as the velocity.
	 * @param	Frame			If the image has a single row of square animation frames on it, you can specify which of the frames you want to use here. Default is -1, or "use whole graphic"
	 * @param	Rotations		The number of rotation frames the final sprite should have.  For small sprites this can be quite a large number (360 even) without any problems.
	 * @param	AntiAliasing	Whether to use high quality rotations when creating the graphic. Default is false.
	 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners. Default is false. Will create frames that are 150% larger on each axis than the original frame or graphic.
	 */
	public function makeImageBullet(Quantity:Int, Image:Dynamic, OffsetX:Int = 0, OffsetY:Int = 0, AutoRotate:Bool = false, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false):Void
	{
		group = new FlxTypedGroup<FlxBullet>(Quantity);
		
		_rotateToAngle = AutoRotate;
		
		for (b in 0...Quantity)
		{
			var tempBullet:FlxBullet = new FlxBullet(this, b);
			
			#if flash
			if (AutoRotate)
			{
				tempBullet.loadRotatedGraphic(Image, Rotations, Frame, AntiAliasing, AutoBuffer);
			}
			else
			{
				tempBullet.loadGraphic(Image);
			}
			#else
			tempBullet.loadGraphic(Image);
			tempBullet.frame = Frame;
			tempBullet.antialiasing = AntiAliasing;
			#end
			group.add(tempBullet);
		}
		
		_positionOffset.x = OffsetX;
		_positionOffset.y = OffsetY;
	}
	
	/**
	 * Makes an animated bullet from the image and frame data given.
	 * 
	 * @param	Quantity		How many bullets do you need to make? This value should be high enough to cover all bullets you need on-screen *at once* plus probably a few extra spare!
	 * @param	ImageSequence	The image used to created the animated bullet from
	 * @param	FrameWidth		The width of each frame in the animation
	 * @param	FrameHeight		The height of each frame in the animation
	 * @param	Frames			An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
	 * @param	FrameRate		The speed in frames per second that the animation should play at (e.g. 40 fps)
	 * @param	Looped			Whether or not the animation is looped or just plays once
	 * @param	OffsetX			When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 * @param	OffsetY			When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 */
	public function makeAnimatedBullet(Quantity:Int, ImageSequence:Dynamic, FrameWidth:Int, FrameHeight:Int, Frames:Array<Int>, FrameRate:Int, Looped:Bool, OffsetX:Int = 0, OffsetY:Int = 0):Void
	{
		group = new FlxTypedGroup<FlxBullet>(Quantity);
		
		for (b in 0...Quantity)
		{
			var tempBullet:FlxBullet = new FlxBullet(this, b);
			
			tempBullet.loadGraphic(ImageSequence, true, false, FrameWidth, FrameHeight);
			tempBullet.addAnimation("fire", Frames, FrameRate, Looped);
			
			group.add(tempBullet);
		}
		
		_positionOffset.x = OffsetX;
		_positionOffset.y = OffsetY;
	}
	
	/**
	 * Internal function that handles the actual firing of the bullets
	 * 
	 * @param	Method
	 * @param	X
	 * @param	Y
	 * @param	Target
	 * @return	True if a bullet was fired or false if one wasn't available. The bullet last fired is stored in <code>FlxWeapon.prevBullet</code>
	 */
	private function runFire(Method:Int, X:Int = 0, Y:Int = 0, ?Target:FlxSprite, Angle:Int = 0):Bool
	{
		if (fireRate > 0 && FlxMisc.getTicks() < nextFire)
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

		// Clear any velocity that may have been previously set from the pool
		currentBullet.velocity.x = 0;
		currentBullet.velocity.y = 0;
		
		_lastFired = FlxMisc.getTicks();
		nextFire = FlxMisc.getTicks() + Std.int(fireRate / FlxG.timeScale);
		
		var launchX:Float = _positionOffset.x;
		var launchY:Float = _positionOffset.y;
		
		if (_fireFromParent)
		{
			launchX += parent.x;
			launchY += parent.y;
		}
		else if (_fireFromPosition)
		{
			launchX += _fireX;
			launchY += _fireY;
		}
		
		if (_directionFromParent)
		{
			_velocity = FlxVelocity.velocityFromFacing(parent, bulletSpeed);
		}
		
		// Faster (less CPU) to use this small if-else ladder than a switch statement
		if (Method == FlxWeapon.FIRE)
		{
			currentBullet.fire(launchX, launchY, _velocity.x, _velocity.y);
		}
		else if (Method == FlxWeapon.FIRE_AT_POSITION)
		{
			currentBullet.fireAtPosition(launchX, launchY, X, Y, bulletSpeed);
		}
		else if (Method == FlxWeapon.FIRE_AT_TARGET)
		{
			currentBullet.fireAtTarget(launchX, launchY, Target, bulletSpeed);
		}
		else if (Method == FlxWeapon.FIRE_FROM_ANGLE)
		{
			currentBullet.fireFromAngle(launchX, launchY, Angle, bulletSpeed);
		}
		else if (Method == FlxWeapon.FIRE_FROM_PARENT_ANGLE)
		{
			currentBullet.fireFromAngle(launchX, launchY, Math.floor(parent.angle), bulletSpeed);
		}
		#if !FLX_NO_TOUCH
		else if (Method == FlxWeapon.FIRE_AT_TOUCH)
		{
			if (_touchTarget != null)
			currentBullet.fireAtTouch(launchX, launchY, _touchTarget, bulletSpeed);
		}
		#end
		#if !FLX_NO_MOUSE
		else if (Method == FlxWeapon.FIRE_AT_MOUSE)
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
		
		_bulletsFired++;
		
		return true;
	}
	
	/**
	 * Fires a bullet (if one is available). The bullet will be given the velocity defined in setBulletDirection and fired at the rate set in setFireRate.
	 * 
	 * @return	True if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	inline public function fire():Bool
	{
		return runFire(FlxWeapon.FIRE);
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Fires a bullet (if one is available) at the mouse coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
	 * 
	 * @return	True if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	inline public function fireAtMouse():Bool
	{
		return runFire(FlxWeapon.FIRE_AT_MOUSE);
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Fires a bullet (if one is available) at the FlxTouch coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
	 * 
	 * @param	Touch	The FlxTouch object to fire at, if null use the first available one
	 * @return	True if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	public function fireAtTouch(?Touch:FlxTouch):Bool
	{
		if (Touch == null) 
		{
			_touchTarget = FlxG.touchManager.getFirstTouch();
		} 
		else 
		{
			_touchTarget = Touch;
		}
		
		var fired = false;
		
		if (_touchTarget != null) 
		{
			fired = runFire(FlxWeapon.FIRE_AT_TOUCH);
			_touchTarget = null;
		}
		
		return fired;
	}
	#end
	
	/**
	 * Fires a bullet (if one is available) at the given x/y coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
	 * 
	 * @param	X	The x coordinate (in game world pixels) to fire at
	 * @param	Y	The y coordinate (in game world pixels) to fire at
	 * @return	True if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	inline public function fireAtPosition(X:Int, Y:Int):Bool
	{
		return runFire(FlxWeapon.FIRE_AT_POSITION, X, Y);
	}
	
	/**
	 * Fires a bullet (if one is available) at the given targets x/y coordinates, using the speed set in setBulletSpeed and the rate set in setFireRate.
	 * 
	 * @param	Target	The FlxSprite you wish to fire the bullet at
	 * @return	True if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	inline public function fireAtTarget(Target:FlxSprite):Bool
	{
		return runFire(FlxWeapon.FIRE_AT_TARGET, 0, 0, Target);
	}
	
	/**
	 * Fires a bullet (if one is available) based on the given angle
	 * 
	 * @param	Angle	The angle (in degrees) calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * @return	True if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	inline public function fireFromAngle(Angle:Int):Bool
	{
		return runFire(FlxWeapon.FIRE_FROM_ANGLE, 0, 0, null, Angle);
	}
	
	/**
	 * Fires a bullet (if one is available) based on the angle of the Weapons parent
	 * 
	 * @return	True if a bullet was fired or false if one wasn't available. A reference to the bullet fired is stored in FlxWeapon.currentBullet.
	 */
	inline public function fireFromParentAngle():Bool
	{
		return runFire(FlxWeapon.FIRE_FROM_PARENT_ANGLE);
	}
	
	/**
	 * Causes the Weapon to fire from the parents x/y value, as seen in Space Invaders and most shoot-em-ups.
	 * 
	 * @param	ParentRef		If this weapon belongs to a parent sprite, specify it here (bullets will fire from the sprites x/y vars as defined below).
	 * @param	VariableX		The x axis variable of the parent to use when firing. Typically "x", but could be "screenX" or any public getter that exposes the x coordinate.
	 * @param	VariableY		The y axis variable of the parent to use when firing. Typically "y", but could be "screenY" or any public getter that exposes the y coordinate.
	 * @param	OffsetX			When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 * @param	OffsetY			When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 * @param	UseDirection	When fired the bullet direction is based on parent sprites facing value (up/down/left/right)
	 */
	public function setParent(ParentRef:FlxSprite, OffsetX:Int = 0, OffsetY:Int = 0, UseDirection:Bool = false):Void
	{
		if (ParentRef != null)
		{
			_fireFromParent = true;
			
			parent = ParentRef;
			
			_positionOffset.x = OffsetX;
			_positionOffset.y = OffsetY;
			
			_directionFromParent = UseDirection;
		}
	}
	
	/**
	 * Causes the Weapon to fire from a fixed x/y position on the screen, like in the game Missile Command.<br>
	 * If set this over-rides a call to setParent (which causes the Weapon to fire from the parents x/y position)
	 * 
	 * @param	X			The x coordinate (in game world pixels) to fire from
	 * @param	Y			The y coordinate (in game world pixels) to fire from
	 * @param	OffsetX		When the bullet is fired if you need to offset it on the x axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 * @param	OffsetY		When the bullet is fired if you need to offset it on the y axis, for example to line it up with the "nose" of a space ship, set the amount here (positive or negative)
	 */
	public function setFiringPosition(X:Int, Y:Int, OffsetX:Int = 0, OffsetY:Int = 0):Void
	{
		_fireFromPosition = true;
		_fireX = X;
		_fireY = Y;
		
		_positionOffset.x = OffsetX;
		_positionOffset.y = OffsetY;
	}
	
	/**
	 * The speed in pixels/sec (sq) that the bullet travels at when fired via fireAtMouse, fireAtPosition or fireAtTarget.<br>
	 * You can update this value in real-time, should you need to speed-up or slow-down your bullets (i.e. collecting a power-up)
	 * 
	 * @param	Speed	The speed it will move, in pixels per second (sq)
	 */
	public function setBulletSpeed(Speed:Int):Void
	{
		bulletSpeed = Speed;
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
	 * @param	Rate	The delay in milliseconds (ms) between which each bullet is fired, set to zero to clear
	 */
	public function setFireRate(Rate:Int):Void
	{
		fireRate = Rate;
	}
	
	/**
	 * When a bullet goes outside of this bounds it will be automatically killed, freeing it up for firing again.
	 * TODO - Needs testing with a scrolling map (when not using single screen display)
	 * 
	 * @param	Bounds	An FlxRect area. Inside this area the bullet should be considered alive, once outside it will be killed.
	 */
	public function setBulletBounds(Bounds:FlxRect):Void
	{
		bounds = Bounds;
	}
	
	/**
	 * Set the direction the bullet will travel when fired.<br>
	 * You can use one of the consts such as BULLET_UP, BULLET_DOWN or BULLET_NORTH_EAST to set the angle easily.<br>
	 * Speed should be given in pixels/sec (sq) and is the speed at which the bullet travels when fired.
	 * 
	 * @param	angle		The angle of the bullet. In clockwise positive direction: Right = 0, Down = 90, Left = 180, Up = -90. You can use one of the consts such as BULLET_UP, etc
	 * @param	speed		The speed it will move, in pixels per second (sq)
	 */
	public function setBulletDirection(Angle:Int, Speed:Int):Void
	{
		_velocity = FlxVelocity.velocityFromAngle(Angle, Speed);
	}
	
	/**
	 * Sets gravity on all currently created bullets<br>
	 * This will update ALL bullets, even those currently "in flight", so be careful about when you call this!
	 * 
	 * @param	ForceX	A positive value applies gravity dragging the bullet to the right. A negative value drags the bullet to the left. Zero disables horizontal gravity.
	 * @param	ForceY	A positive value applies gravity dragging the bullet down. A negative value drags the bullet up. Zero disables vertical gravity.
	 */
	public function setBulletGravity(ForceX:Int, ForceY:Int):Void
	{
		group.setAll("xGravity", ForceX);
		group.setAll("yGravity", ForceY);
	}
	
	/**
	 * If you'd like your bullets to accelerate to their top speed rather than be launched already at it, then set the acceleration value here.<br>
	 * If you've previously set the acceleration then setting it to zero will cancel the effect.<br>
	 * This will update ALL bullets, even those currently "in flight", so be careful about when you call this!
	 * 
	 * @param	AccelerationX		Acceleration speed in pixels per second to apply to the sprites horizontal movement, set to zero to cancel. Negative values move left, positive move right.
	 * @param	AccelerationY		Acceleration speed in pixels per second to apply to the sprites vertical movement, set to zero to cancel. Negative values move up, positive move down.
	 * @param	SpeedMaxX			The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	SpeedMaxY			The maximum speed in pixels per second in which the sprite can move vertically
	 */
	public function setBulletAcceleration(AccelerationX:Int, AccelerationY:Int, SpeedMaxX:Int, SpeedMaxY:Int):Void
	{
		if (AccelerationX == 0 && AccelerationY == 0)
		{
			group.setAll("accelerates", false);
		}
		else
		{
			group.setAll("accelerates", true);
			group.setAll("xAcceleration", AccelerationX);
			group.setAll("yAcceleration", AccelerationY);
			group.setAll("maxVelocityX", SpeedMaxX);
			group.setAll("maxVelocityY", SpeedMaxY);
		}
	}
	
	/**
	 * When the bullet is fired from a parent (or fixed position) it will do so from their x/y coordinate.<br>
	 * Often you need to align a bullet with the sprite, i.e. to make it look like it came out of the "nose" of a space ship.<br>
	 * Use this offset x/y value to achieve that effect.
	 * 
	 * @param	OffsetX		The x coordinate offset to add to the launch location (positive or negative)
	 * @param	OffsetY		The y coordinate offset to add to the launch location (positive or negative)
	 */
	public function setBulletOffset(OffsetX:Float, OffsetY:Float):Void
	{
		_positionOffset.x = OffsetX;
		_positionOffset.y = OffsetY;
	}
	
	/**
	 * To make the bullet apply a random factor to either its angle, speed, or both when fired, set these values. Can create a nice "scatter gun" effect.
	 * 
	 * @param 	RandomAngle		The +- value applied to the angle when fired. For example 20 means the bullet can fire up to 20 degrees under or over its angle when fired.
	 * @param	RandomSpeed		The +- value applied to the speed when fired. For example 20 means the bullet can fire up to 20 px/sec slower or faster when fired.
	 * @param 	RandomPosition  The +- value applied to the firing location when fired (fire spread).
	 * @param 	RandomLifeSpan  The +- value applied to the <code>bulletLifeSpan</code> when fired. For example passing 2 when <code>bulletLifeSpan</code> is 3, means the bullet can live up to 5 seconds, minimum of 1.
	 */
	public function setBulletRandomFactor(RandomAngle:Int = 0, RandomSpeed:Int = 0, ?RandomPosition:FlxPoint, RandomLifeSpan:Float = 0):Void
	{
		rndFactorAngle = RandomAngle;
		rndFactorSpeed = RandomSpeed;
		
		if (RandomPosition != null)
		{
			rndFactorPosition = RandomPosition;
		}
		
		rndFactorLifeSpan = (RandomLifeSpan < 0) ? -RandomLifeSpan : RandomLifeSpan;
	}
	
	/**
	 * If the bullet should have a fixed life span use this function to set it.
	 * The bullet will be killed once it passes this lifespan, if still alive and in bounds.
	 * 
	 * @param	Lifespan  The lifespan of the bullet, given in seconds.
	 */
	public function setBulletLifeSpan(Lifespan:Float):Void
	{
		bulletLifeSpan = Lifespan;
	}
	
	/**
	 * The elasticity of the fired bullet controls how much it rebounds off collision surfaces.
	 * 
	 * @param	Elasticity	The elasticity of the bullet between 0 and 1 (0 being no rebound, 1 being 100% force rebound). Set to zero to disable.
	 */
	public function setBulletElasticity(Elasticity:Float):Void
	{
		bulletElasticity = Elasticity;
	}
	
	/**
	 * Internal function that returns the next available bullet from the pool (if any)
	 * 
	 * @return	A <code>FlxBullet</code>
	 */
	private function getFreeBullet():FlxBullet
	{
		var result:FlxBullet = null;
		
		if (group == null || group.length == 0)
		{
			throw "Weapon.as cannot fire a bullet until one has been created via a call to makePixelBullet or makeImageBullet";
			return null;
		}
		
		var bullet:FlxBullet;
		
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
	 * @param	Callback	The function to call
	 * @param	Sound		A FlxSound to play
	 */
	public function setPreFireCallback(?Callback:Void->Void, ?Sound:FlxSound):Void
	{
		onPreFireCallback = Callback;
		onPreFireSound = Sound;
	}
	
	/**
	 * Sets a fire callback function and sound. These are played immediately as the bullet is fired.
	 * 
	 * @param	Callback	The function to call
	 * @param	Sound		A FlxSound to play
	 */
	public function setFireCallback(?Callback:Void->Void, ?Sound:FlxSound):Void
	{
		onFireCallback = Callback;
		onFireSound = Sound;
	}
	
	/**
	 * Sets a post-fire callback function and sound. These are played immediately after the bullet is fired.
	 * 
	 * @param	Callback	The function to call
	 * @param	Sound		An FlxSound to play
	 */
	public function setPostFireCallback(?Callback:Void->Void, ?Sound:FlxSound):Void
	{
		onPostFireCallback = Callback;
		onPostFireSound = Sound;
	}
	
	/**
	 * Checks to see if the bullets are overlapping the specified object or group
	 * 
	 * @param  ObjectOrGroup  	The group or object to check if bullets collide
	 * @param  NotifyCallBack  	A function that will get called if a bullet overlaps an object
	 * @param  SkipParent    	Don't trigger colision notifies with the parent of this object
	*/
	inline public function bulletsOverlap(ObjectOrGroup:FlxBasic, ?NotifyCallBack:FlxObject->FlxObject->Void, SkipParent:Bool = true):Void
	{
		if (group != null && group.length > 0)
		{
			_skipParentCollision = SkipParent;
			FlxG.overlap(ObjectOrGroup, group, NotifyCallBack != null ? NotifyCallBack : onBulletHit, shouldBulletHit);
		}
	}

  	private function shouldBulletHit(Object:FlxObject, Bullet:FlxObject):Bool
	{
		if (parent == Object && _skipParentCollision)
		{
			return false;
		}
		
		if (Std.is(Object, FlxTilemap))
		{
			return cast(Object, FlxTilemap).overlapsWithCallback(Bullet);
		}
		else
		{
			return true;
		}
	}

  	private function onBulletHit(Object:FlxObject, Bullet:FlxObject):Void
	{
		Bullet.kill();
	}
	
	// TODO
	public function createBulletPattern(Pattern:Array<Dynamic>):Void
	{
		//	Launches this many bullets
	}
	
	public function update():Void
	{
		// ???
	}
}