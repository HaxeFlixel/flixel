/**
 * FlxControlHandler
 * -- Part of the Flixel Power Tools set
 * 
 * v1.6 Thrust and Reverse complete, final few rotation bugs solved. Sounds hooked in for fire, jump, walk and thrust
 * v1.5 Full support for rotation with min/max angle limits
 * v1.4 Fixed bug in runFire causing fireRate to be ignored
 * v1.3 Major refactoring and lots of new enhancements
 * v1.2 First real version deployed to dev
 * v1.1 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.6 - June 15th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm 
{
	import flash.geom.Rectangle;
	import org.flixel.*;
	import flash.utils.getTimer;
	
	/**
	 * Makes controlling an FlxSprite with the keyboard a LOT easier and quicker to set-up!<br>
	 * Sometimes it's hard to know what values to set, especially if you want gravity, jumping, sliding, etc.<br>
	 * This class helps sort that - and adds some cool extra functionality too :)
	 * 
	 * TODO
	 * ----
	 * Hot Keys
	 * Binding of sound effects to keys (seperate from setSounds? as those are event based)
	 * If moving diagonally compensate speed parameter (times x,y velocities by 0.707 or cos/sin(45))
	 * Specify animation frames to play based on velocity
	 * Variable gravity (based on height, the higher the stronger the effect)
	 */
	public class FlxControlHandler
	{
		//	Used by the FlxControl plugin
		public var enabled:Boolean = false;
		
		private var entity:FlxSprite = null;
		
		private var bounds:Rectangle;
		
		private var up:Boolean;
		private var down:Boolean;
		private var left:Boolean;
		private var right:Boolean;
		private var fire:Boolean;
		private var altFire:Boolean;
		private var jump:Boolean;
		private var altJump:Boolean;
		private var xFacing:Boolean;
		private var yFacing:Boolean;
		private var rotateAntiClockwise:Boolean;
		private var rotateClockwise:Boolean;
		
		private var upMoveSpeed:int;
		private var downMoveSpeed:int;
		private var leftMoveSpeed:int;
		private var rightMoveSpeed:int;
		private var thrustSpeed:int;
		private var reverseSpeed:int;
		
		//	Rotation
		private var thrustEnabled:Boolean;
		private var reverseEnabled:Boolean;
		private var isRotating:Boolean;
		private var antiClockwiseRotationSpeed:Number;
		private var clockwiseRotationSpeed:Number;
		private var enforceAngleLimits:Boolean;
		private var minAngle:int;
		private var maxAngle:int;
		private var capAngularVelocity:Boolean;
		
		private var xSpeedAdjust:Number = 0;
		private var ySpeedAdjust:Number = 0;
		
		private var gravityX:int;
		private var gravityY:int;
		
		private var fireRate:int; 			// The ms delay between firing when the key is held down
		private var nextFireTime:int; 		// The internal time when they can next fire
		private var lastFiredTime:int; 		// The internal time of when when they last fired
		private var fireKeyMode:uint;		// The fire key mode
		private var fireCallback:Function;	// A function to call every time they fire
		
		private var jumpHeight:int; 		// The pixel height amount they jump (drag and gravity also both influence this)
		private var jumpRate:int; 			// The ms delay between jumping when the key is held down
		private var jumpKeyMode:uint;		// The jump key mode
		private var nextJumpTime:int; 		// The internal time when they can next jump
		private var lastJumpTime:int; 		// The internal time of when when they last jumped
		private var jumpFromFallTime:int; 	// A short window of opportunity for them to jump having just fallen off the edge of a surface
		private var extraSurfaceTime:int; 	// Internal time of when they last collided with a valid jumpSurface
		private var jumpSurface:uint; 		// The surfaces from FlxObject they can jump from (i.e. FlxObject.FLOOR)
		private var jumpCallback:Function;	// A function to call every time they jump
		
		private var movement:int;
		private var stopping:int;
		private var rotation:int;
		private var rotationStopping:int;
		private var capVelocity:Boolean;
		
		private var hotkeys:Array;			// TODO
		
		private var upKey:String;
		private var downKey:String;
		private var leftKey:String;
		private var rightKey:String;
		private var fireKey:String;
		private var altFireKey:String;		// TODO
		private var jumpKey:String;
		private var altJumpKey:String;		// TODO
		private var antiClockwiseKey:String;
		private var clockwiseKey:String;
		private var thrustKey:String;
		private var reverseKey:String;
		
		//	Sounds
		private var jumpSound:FlxSound = null;
		private var fireSound:FlxSound = null;
		private var walkSound:FlxSound = null;
		private var thrustSound:FlxSound = null;
		
		/**
		 * The "Instant" Movement Type means the sprite will move at maximum speed instantly, and will not "accelerate" (or speed-up) before reaching that speed.
		 */
		public static const MOVEMENT_INSTANT:int = 0;
		/**
		 * The "Accelerates" Movement Type means the sprite will accelerate until it reaches maximum speed.
		 */
		public static const MOVEMENT_ACCELERATES:int = 1;
		/**
		 * The "Instant" Stopping Type means the sprite will stop immediately when no direction keys are being pressed, there will be no deceleration.
		 */
		public static const STOPPING_INSTANT:int = 0;
		/**
		 * The "Decelerates" Stopping Type means the sprite will start decelerating when no direction keys are being pressed. Deceleration continues until the speed reaches zero.
		 */
		public static const STOPPING_DECELERATES:int = 1;
		/**
		 * The "Never" Stopping Type means the sprite will never decelerate, any speed built up will be carried on and never reduce.
		 */
		public static const STOPPING_NEVER:int = 2;
		
		/**
		 * The "Instant" Movement Type means the sprite will rotate at maximum speed instantly, and will not "accelerate" (or speed-up) before reaching that speed.
		 */
		public static const ROTATION_INSTANT:int = 0;
		/**
		 * The "Accelerates" Rotaton Type means the sprite will accelerate until it reaches maximum rotation speed.
		 */
		public static const ROTATION_ACCELERATES:int = 1;
		/**
		 * The "Instant" Stopping Type means the sprite will stop rotating immediately when no rotation keys are being pressed, there will be no deceleration.
		 */
		public static const ROTATION_STOPPING_INSTANT:int = 0;
		/**
		 * The "Decelerates" Stopping Type means the sprite will start decelerating when no rotation keys are being pressed. Deceleration continues until rotation speed reaches zero.
		 */
		public static const ROTATION_STOPPING_DECELERATES:int = 1;
		/**
		 * The "Never" Stopping Type means the sprite will never decelerate, any speed built up will be carried on and never reduce.
		 */
		public static const ROTATION_STOPPING_NEVER:int = 2;
		
		/**
		 * This keymode fires for as long as the key is held down
		 */
		public static const KEYMODE_PRESSED:int = 0;
		
		/**
		 * This keyboard fires when the key has just been pressed down, and not again until it is released and re-pressed
		 */
		public static const KEYMODE_JUST_DOWN:int = 1;
		
		/**
		 * This keyboard fires only when the key has been pressed and then released again
		 */
		public static const KEYMODE_RELEASED:int = 2;
		
		/**
		 * Sets the FlxSprite to be controlled by this class, and defines the initial movement and stopping types.<br>
		 * After creating an instance of this class you should call setMovementSpeed, and one of the enableXControl functions if you need more than basic cursors.
		 * 
		 * @param	source			The FlxSprite you want this class to control. It can only control one FlxSprite at once.
		 * @param	movementType	Set to either MOVEMENT_INSTANT or MOVEMENT_ACCELERATES
		 * @param	stoppingType	Set to STOPPING_INSTANT, STOPPING_DECELERATES or STOPPING_NEVER
		 * @param	updateFacing	If true it sets the FlxSprite.facing value to the direction pressed (default false)
		 * @param	enableArrowKeys	If true it will enable all arrow keys (default) - see setCursorControl for more fine-grained control
		 * 
		 * @see		setMovementSpeed
		 */
		public function FlxControlHandler(source:FlxSprite, movementType:int, stoppingType:int, updateFacing:Boolean = false, enableArrowKeys:Boolean = true)
		{
			entity = source;
			
			movement = movementType;
			stopping = stoppingType;
			
			xFacing = updateFacing;
			yFacing = updateFacing;
			
			up = false;
			down = false;
			left = false;
			right = false;
			
			thrustEnabled = false;
			isRotating = false;
			enforceAngleLimits = false;
			rotation = ROTATION_INSTANT;
			rotationStopping = ROTATION_STOPPING_INSTANT;
			
			if (enableArrowKeys)
			{
				setCursorControl();
			}
			
			enabled = true;
		}
		
		/**
		 * Set the speed at which the sprite will move when a direction key is pressed.<br>
		 * All values are given in pixels per second. So an xSpeed of 100 would move the sprite 100 pixels in 1 second (1000ms)<br>
		 * Due to the nature of the internal Flash timer this amount is not 100% accurate and will vary above/below the desired distance by a few pixels.<br>
		 * 
		 * If you need different speed values for left/right or up/down then use setAdvancedMovementSpeed
		 * 
		 * @param	xSpeed			The speed in pixels per second in which the sprite will move/accelerate horizontally
		 * @param	ySpeed			The speed in pixels per second in which the sprite will move/accelerate vertically
		 * @param	xSpeedMax		The maximum speed in pixels per second in which the sprite can move horizontally
		 * @param	ySpeedMax		The maximum speed in pixels per second in which the sprite can move vertically
		 * @param	xDeceleration	A deceleration speed in pixels per second to apply to the sprites horizontal movement (default 0)
		 * @param	yDeceleration	A deceleration speed in pixels per second to apply to the sprites vertical movement (default 0)
		 */
		public function setMovementSpeed(xSpeed:uint, ySpeed:uint, xSpeedMax:uint, ySpeedMax:uint, xDeceleration:uint = 0, yDeceleration:uint = 0):void
		{
			leftMoveSpeed = -xSpeed;
			rightMoveSpeed = xSpeed;
			upMoveSpeed = -ySpeed;
			downMoveSpeed = ySpeed;
			
			setMaximumSpeed(xSpeedMax, ySpeedMax);
			setDeceleration(xDeceleration, yDeceleration);
		}
		
		/**
		 * If you know you need the same value for the acceleration, maximum speeds and (optionally) deceleration then this is a quick way to set them.
		 * 
		 * @param	speed			The speed in pixels per second in which the sprite will move/accelerate/decelerate
		 * @param	acceleration	If true it will set the speed value as the deceleration value (default) false will leave deceleration disabled
		 */
		public function setStandardSpeed(speed:uint, acceleration:Boolean = true):void
		{
			if (acceleration)
			{
				setMovementSpeed(speed, speed, speed, speed, speed, speed);
			}
			else
			{
				setMovementSpeed(speed, speed, speed, speed);
			}
		}
		
		/**
		 * Set the speed at which the sprite will move when a direction key is pressed.<br>
		 * All values are given in pixels per second. So an xSpeed of 100 would move the sprite 100 pixels in 1 second (1000ms)<br>
		 * Due to the nature of the internal Flash timer this amount is not 100% accurate and will vary above/below the desired distance by a few pixels.<br>
		 * 
		 * If you don't need different speed values for every direction on its own then use setMovementSpeed
		 * 
		 * @param	leftSpeed		The speed in pixels per second in which the sprite will move/accelerate to the left
		 * @param	rightSpeed		The speed in pixels per second in which the sprite will move/accelerate to the right
		 * @param	upSpeed			The speed in pixels per second in which the sprite will move/accelerate up
		 * @param	downSpeed		The speed in pixels per second in which the sprite will move/accelerate down
		 * @param	xSpeedMax		The maximum speed in pixels per second in which the sprite can move horizontally
		 * @param	ySpeedMax		The maximum speed in pixels per second in which the sprite can move vertically
		 * @param	xDeceleration	Deceleration speed in pixels per second to apply to the sprites horizontal movement (default 0)
		 * @param	yDeceleration	Deceleration speed in pixels per second to apply to the sprites vertical movement (default 0)
		 */
		public function setAdvancedMovementSpeed(leftSpeed:uint, rightSpeed:uint, upSpeed:uint, downSpeed:uint, xSpeedMax:uint, ySpeedMax:uint, xDeceleration:uint = 0, yDeceleration:uint = 0):void
		{
			leftMoveSpeed = -leftSpeed;
			rightMoveSpeed = rightSpeed;
			upMoveSpeed = -upSpeed;
			downMoveSpeed = downSpeed;
			
			setMaximumSpeed(xSpeedMax, ySpeedMax);
			setDeceleration(xDeceleration, yDeceleration);
		}
		
		/**
		 * Set the speed at which the sprite will rotate when a direction key is pressed.<br>
		 * Use this in combination with setMovementSpeed to create a Thrust like movement system.<br>
		 * All values are given in pixels per second. So an xSpeed of 100 would rotate the sprite 100 pixels in 1 second (1000ms)<br>
		 * Due to the nature of the internal Flash timer this amount is not 100% accurate and will vary above/below the desired distance by a few pixels.<br>
		 */
		public function setRotationSpeed(antiClockwiseSpeed:Number, clockwiseSpeed:Number, speedMax:Number, deceleration:Number):void
		{
			antiClockwiseRotationSpeed = -antiClockwiseSpeed;
			clockwiseRotationSpeed = clockwiseSpeed;
			
			setRotationKeys();
			setMaximumRotationSpeed(speedMax);
			setRotationDeceleration(deceleration);
		}
		
		/**
		 * 
		 * 
		 * @param	rotationType
		 * @param	stoppingType
		 */
		public function setRotationType(rotationType:int, stoppingType:int):void
		{
			rotation = rotationType;
			rotationStopping = stoppingType;
		}
		
		/**
		 * Sets the maximum speed (in pixels per second) that the FlxSprite can rotate.<br>
		 * When the FlxSprite is accelerating (movement type MOVEMENT_ACCELERATES) its speed won't increase above this value.<br>
		 * However Flixel allows the velocity of an FlxSprite to be set to anything. So if you'd like to check the value and restrain it, then enable "limitVelocity".
		 * 
		 * @param	speed			The maximum speed in pixels per second in which the sprite can rotate
		 * @param	limitVelocity	If true the angular velocity of the FlxSprite will be checked and kept within the limit. If false it can be set to anything.
		 */
		public function setMaximumRotationSpeed(speed:Number, limitVelocity:Boolean = true):void
		{
			entity.maxAngular = speed;
			
			capAngularVelocity = limitVelocity;
		}
		
		/**
		 * Deceleration is a speed (in pixels per second) that is applied to the sprite if stopping type is "DECELERATES" and if no rotation is taking place.<br>
		 * The velocity of the sprite will be reduced until it reaches zero.
		 * 
		 * @param	speed		The speed in pixels per second at which the sprite will have its angular rotation speed decreased
		 */
		public function setRotationDeceleration(speed:Number):void
		{
			entity.angularDrag = speed;
		}
		
		/**
		 * Set minimum and maximum angle limits that the Sprite won't be able to rotate beyond.<br>
		 * Values must be between -180 and +180. 0 is pointing right, 90 down, 180 left, -90 up.
		 * 
		 * @param	minimumAngle	Minimum angle below which the sprite cannot rotate (must be -180 or above)
		 * @param	maximumAngle	Maximum angle above which the sprite cannot rotate (must be 180 or below)
		 */
		public function setRotationLimits(minimumAngle:int, maximumAngle:int):void
		{
			if (minimumAngle > maximumAngle || minimumAngle < -180 || maximumAngle > 180)
			{
				throw new Error("FlxControlHandler setRotationLimits: Invalid Minimum / Maximum angle");
			}
			else
			{
				enforceAngleLimits = true;
				minAngle = minimumAngle;
				maxAngle = maximumAngle;
			}
		}
		
		/**
		 * Disables rotation limits set in place by setRotationLimits()
		 */
		public function disableRotationLimits():void
		{
			enforceAngleLimits = false;
		}
		
		/**
		 * Set which keys will rotate the sprite. The speed of rotation is set in setRotationSpeed.
		 * 
		 * @param	leftRight				Use the LEFT and RIGHT arrow keys for anti-clockwise and clockwise rotation respectively.
		 * @param	upDown					Use the UP and DOWN arrow keys for anti-clockwise and clockwise rotation respectively.
		 * @param	customAntiClockwise		The String value of your own key to use for anti-clockwise rotation (as taken from org.flixel.system.input.Keyboard)
		 * @param	customClockwise			The String value of your own key to use for clockwise rotation (as taken from org.flixel.system.input.Keyboard)
		 */
		public function setRotationKeys(leftRight:Boolean = true, upDown:Boolean = false, customAntiClockwise:String = "", customClockwise:String = ""):void
		{
			isRotating = true;
			rotateAntiClockwise = true;
			rotateClockwise = true;
			antiClockwiseKey = "LEFT";
			clockwiseKey = "RIGHT";

			if (upDown == true)
			{
				antiClockwiseKey = "UP";
				clockwiseKey = "DOWN";
			}
			
			if (customAntiClockwise != "" && customClockwise != "")
			{
				antiClockwiseKey = customAntiClockwise;
				clockwiseKey = customClockwise;
			}
		}
		
		/**
		 * If you want to enable a Thrust like motion for your sprite use this to set the speed and keys.<br>
		 * This is usually used in conjunction with Rotation and it will over-ride anything already defined in setMovementSpeed.
		 * 
		 * @param	thrustKey		Specify the key String (as taken from org.flixel.system.input.Keyboard) to use for the Thrust action
		 * @param	thrustSpeed		The speed in pixels per second which the sprite will move. Acceleration or Instant movement is determined by the Movement Type.
		 * @param	reverseKey		If you want to be able to reverse, set the key string as taken from org.flixel.system.input.Keyboard (defaults to null).
		 * @param	reverseSpeed	The speed in pixels per second which the sprite will reverse. Acceleration or Instant movement is determined by the Movement Type.
		 */
		public function setThrust(thrustKey:String, thrustSpeed:Number, reverseKey:String = null, reverseSpeed:Number = 0):void
		{
			thrustEnabled = false;
			reverseEnabled = false;
			
			if (thrustKey)
			{
				this.thrustKey = thrustKey;
				this.thrustSpeed = thrustSpeed;
				thrustEnabled = true;
			}
			
			if (reverseKey)
			{
				this.reverseKey = reverseKey;
				this.reverseSpeed = reverseSpeed;
				reverseEnabled = true;
			}
		}
		
		/**
		 * Sets the maximum speed (in pixels per second) that the FlxSprite can move. You can set the horizontal and vertical speeds independantly.<br>
		 * When the FlxSprite is accelerating (movement type MOVEMENT_ACCELERATES) its speed won't increase above this value.<br>
		 * However Flixel allows the velocity of an FlxSprite to be set to anything. So if you'd like to check the value and restrain it, then enable "limitVelocity".
		 * 
		 * @param	xSpeed			The maximum speed in pixels per second in which the sprite can move horizontally
		 * @param	ySpeed			The maximum speed in pixels per second in which the sprite can move vertically
		 * @param	limitVelocity	If true the velocity of the FlxSprite will be checked and kept within the limit. If false it can be set to anything.
		 */
		public function setMaximumSpeed(xSpeed:uint, ySpeed:uint, limitVelocity:Boolean = true):void
		{
			entity.maxVelocity.x = xSpeed;
			entity.maxVelocity.y = ySpeed;
			
			capVelocity = limitVelocity;
		}
		
		/**
		 * Deceleration is a speed (in pixels per second) that is applied to the sprite if stopping type is "DECELERATES" and if no acceleration is taking place.<br>
		 * The velocity of the sprite will be reduced until it reaches zero, and can be configured separately per axis.
		 * 
		 * @param	xSpeed		The speed in pixels per second at which the sprite will have its horizontal speed decreased
		 * @param	ySpeed		The speed in pixels per second at which the sprite will have its vertical speed decreased
		 */
		public function setDeceleration(xSpeed:uint, ySpeed:uint):void
		{
			entity.drag.x = xSpeed;
			entity.drag.y = ySpeed;
		}
		
		/**
		 * Gravity can be applied to the sprite, pulling it in any direction.<br>
		 * Gravity is given in pixels per second and is applied as acceleration. The speed the sprite reaches under gravity will never exceed the Maximum Movement Speeds set.<br>
		 * If you don't want gravity for a specific direction pass a value of zero.
		 * 
		 * @param	xForce	A positive value applies gravity dragging the sprite to the right. A negative value drags the sprite to the left. Zero disables horizontal gravity.
		 * @param	yForce	A positive value applies gravity dragging the sprite down. A negative value drags the sprite up. Zero disables vertical gravity.
		 */
		public function setGravity(xForce:int, yForce:int):void
		{
			gravityX = xForce;
			gravityY = yForce;
			
			entity.acceleration.x = gravityX;
			entity.acceleration.y = gravityY;
		}
		
		/**
		 * Switches the gravity applied to the sprite. If gravity was +400 Y (pulling them down) this will swap it to -400 Y (pulling them up)<br>
		 * To reset call flipGravity again
		 */
		public function flipGravity():void
		{
			if (gravityX && gravityX != 0)
			{
				gravityX = -gravityX;
				entity.acceleration.x = gravityX;
			}
			
			if (gravityY && gravityY != 0)
			{
				gravityY = -gravityY;
				entity.acceleration.y = gravityY;
			}
		}
		
		/**
		 * TODO
		 * 
		 * @param	xFactor
		 * @param	yFactor
		 */
		public function speedUp(xFactor:Number, yFactor:Number):void
		{
		}
		
		/**
		 * TODO
		 * 
		 * @param	xFactor
		 * @param	yFactor
		 */
		public function slowDown(xFactor:Number, yFactor:Number):void
		{
		}
		
		/**
		 * TODO
		 * 
		 * @param	xFactor
		 * @param	yFactor
		 */
		public function resetSpeeds(resetX:Boolean = true, resetY:Boolean = true):void
		{
			if (resetX)
			{
				xSpeedAdjust = 0;
			}
			
			if (resetY)
			{
				ySpeedAdjust = 0;
			}
		}
		
		/**
		 * Creates a new Hot Key, which can be bound to any function you specify (such as "swap weapon", "quit", etc)
		 * 
		 * @param	key			The key to use as the hot key (String from org.flixel.system.input.Keyboard, i.e. "SPACE", "CONTROL", "Q", etc)
		 * @param	callback	The function to call when the key is pressed
		 * @param	keymode		The keymode that will trigger the callback, either KEYMODE_PRESSED, KEYMODE_JUST_DOWN or KEYMODE_RELEASED
		 */
		public function addHotKey(key:String, callback:Function, keymode:int):void
		{
			
		}
		
		/**
		 * Removes a previously defined hot key
		 * 
		 * @param	key		The key to use as the hot key (String from org.flixel.system.input.Keyboard, i.e. "SPACE", "CONTROL", "Q", etc)
		 * @return	true if the key was found and removed, false if the key couldn't be found
		 */
		public function removeHotKey(key:String):Boolean
		{
			return true;
		}
		
		/**
		 * Set sound effects for the movement events jumping, firing, walking and thrust.
		 * 
		 * @param	jump	The FlxSound to play when the user jumps
		 * @param	fire	The FlxSound to play when the user fires
		 * @param	walk	The FlxSound to play when the user walks
		 * @param	thrust	The FlxSound to play when the user thrusts
		 */
		public function setSounds(jump:FlxSound = null, fire:FlxSound = null, walk:FlxSound = null, thrust:FlxSound = null):void
		{
			if (jump)
			{
				jumpSound = jump;
			}
			
			if (fire)
			{
				fireSound = fire;
			}
			
			if (walk)
			{
				walkSound = walk;
			}
			
			if (thrust)
			{
				thrustSound = thrust;
			}
		}
		
		/**
		 * Enable a fire button
		 * 
		 * @param	key				The key to use as the fire button (String from org.flixel.system.input.Keyboard, i.e. "SPACE", "CONTROL")
		 * @param	keymode			The FlxControlHandler KEYMODE value (KEYMODE_PRESSED, KEYMODE_JUST_DOWN, KEYMODE_RELEASED)
		 * @param	repeatDelay		Time delay in ms between which the fire action can repeat (0 means instant, 250 would allow it to fire approx. 4 times per second)
		 * @param	callback		A user defined function to call when it fires
		 * @param	altKey			Specify an alternative fire key that works AS WELL AS the primary fire key (TODO)
		 */
		public function setFireButton(key:String, keymode:uint, repeatDelay:uint, callback:Function, altKey:String = ""):void
		{
			fireKey = key;
			fireKeyMode = keymode;
			fireRate = repeatDelay;
			fireCallback = callback;
			
			if (altKey != "")
			{
				altFireKey = altKey;
			}
			
			fire = true;
		}
		
		/**
		 * Enable a jump button
		 * 
		 * @param	key				The key to use as the jump button (String from org.flixel.system.input.Keyboard, i.e. "SPACE", "CONTROL")
		 * @param	keymode			The FlxControlHandler KEYMODE value (KEYMODE_PRESSED, KEYMODE_JUST_DOWN, KEYMODE_RELEASED)
		 * @param	height			The height in pixels/sec that the Sprite will attempt to jump (gravity and acceleration can influence this actual height obtained)
		 * @param	surface			A bitwise combination of all valid surfaces the Sprite can jump off (from FlxObject, such as FlxObject.FLOOR)
		 * @param	repeatDelay		Time delay in ms between which the jumping can repeat (250 would be 4 times per second)
		 * @param	jumpFromFall	A time in ms that allows the Sprite to still jump even if it's just fallen off a platform, if still within ths time limit
		 * @param	callback		A user defined function to call when the Sprite jumps
		 * @param	altKey			Specify an alternative jump key that works AS WELL AS the primary jump key (TODO)
		 */
		public function setJumpButton(key:String, keymode:uint, height:int, surface:int, repeatDelay:uint = 250, jumpFromFall:int = 0, callback:Function = null, altKey:String = ""):void
		{
			jumpKey = key;
			jumpKeyMode = keymode;
			jumpHeight = height;
			jumpSurface = surface;
			jumpRate = repeatDelay;
			jumpFromFallTime = jumpFromFall;
			jumpCallback = callback;
			
			if (altKey != "")
			{
				altJumpKey = altKey;
			}
			
			jump = true;
		}
		
		/**
		 * Limits the sprite to only be allowed within this rectangle. If its x/y coordinates go outside it will be repositioned back inside.<br>
		 * Coordinates should be given in GAME WORLD pixel values (not screen value, although often they are the two same things)
		 * 
		 * @param	x		The x coordinate of the top left corner of the area (in game world pixels)
		 * @param	y		The y coordinate of the top left corner of the area (in game world pixels)
		 * @param	width	The width of the area (in pixels)
		 * @param	height	The height of the area (in pixels)
		 */
		public function setBounds(x:int, y:int, width:uint, height:uint):void
		{
			bounds = new Rectangle(x, y, width, height);
		}
		
		/**
		 * Clears any previously set sprite bounds
		 */
		public function removeBounds():void
		{
			bounds = null;
		}
		
		private function moveUp():Boolean
		{
			var move:Boolean = false;
			
			if (FlxG.keys.pressed(upKey))
			{
				move = true;
				
				if (yFacing)
				{
					entity.facing = FlxObject.UP;
				}
				
				if (movement == MOVEMENT_INSTANT)
				{
					entity.velocity.y = upMoveSpeed;
				}
				else if (movement == MOVEMENT_ACCELERATES)
				{
					entity.acceleration.y = upMoveSpeed;
				}
				
				if (bounds && entity.y < bounds.top)
				{
					entity.y = bounds.top;
				}
			}
			
			return move;
		}
		
		private function moveDown():Boolean
		{
			var move:Boolean = false;
			
			if (FlxG.keys.pressed(downKey))
			{
				move = true;
				
				if (yFacing)
				{
					entity.facing = FlxObject.DOWN;
				}
				
				if (movement == MOVEMENT_INSTANT)
				{
					entity.velocity.y = downMoveSpeed;
				}
				else if (movement == MOVEMENT_ACCELERATES)
				{
					entity.acceleration.y = downMoveSpeed;
				}
				
				if (bounds && entity.y > bounds.bottom)
				{
					entity.y = bounds.bottom;
				}
				
			}
			
			return move;
		}
		
		private function moveLeft():Boolean
		{
			var move:Boolean = false;
			
			if (FlxG.keys.pressed(leftKey))
			{
				move = true;
				
				if (xFacing)
				{
					entity.facing = FlxObject.LEFT;
				}
				
				if (movement == MOVEMENT_INSTANT)
				{
					entity.velocity.x = leftMoveSpeed;
				}
				else if (movement == MOVEMENT_ACCELERATES)
				{
					entity.acceleration.x = leftMoveSpeed;
				}
				
				if (bounds && entity.x < bounds.x)
				{
					entity.x = bounds.x;
				}
			}
			
			return move;
		}
		
		private function moveRight():Boolean
		{
			var move:Boolean = false;
			
			if (FlxG.keys.pressed(rightKey))
			{
				move = true;
				
				if (xFacing)
				{
					entity.facing = FlxObject.RIGHT;
				}
				
				if (movement == MOVEMENT_INSTANT)
				{
					entity.velocity.x = rightMoveSpeed;
				}
				else if (movement == MOVEMENT_ACCELERATES)
				{
					entity.acceleration.x = rightMoveSpeed;
				}
				
				if (bounds && entity.x > bounds.right)
				{
					entity.x = bounds.right;
				}
			}
			
			return move;
		}
		
		private function moveAntiClockwise():Boolean
		{
			var move:Boolean = false;
			
			if (FlxG.keys.pressed(antiClockwiseKey))
			{
				move = true;
				
				if (rotation == ROTATION_INSTANT)
				{
					entity.angularVelocity = antiClockwiseRotationSpeed;
				}
				else if (rotation == ROTATION_ACCELERATES)
				{
					entity.angularAcceleration = antiClockwiseRotationSpeed;
				}
				
				// TODO - Not quite there yet given the way Flixel can rotate to any valid int angle!
				if (enforceAngleLimits)
				{
					//entity.angle = FlxMath.angleLimit(entity.angle, minAngle, maxAngle);
				}
			}
			
			return move;
		}
		
		private function moveClockwise():Boolean
		{
			var move:Boolean = false;
			
			if (FlxG.keys.pressed(clockwiseKey))
			{
				move = true;
				
				if (rotation == ROTATION_INSTANT)
				{
					entity.angularVelocity = clockwiseRotationSpeed;
				}
				else if (rotation == ROTATION_ACCELERATES)
				{
					entity.angularAcceleration = clockwiseRotationSpeed;
				}
				
				// TODO - Not quite there yet given the way Flixel can rotate to any valid int angle!
				if (enforceAngleLimits)
				{
					//entity.angle = FlxMath.angleLimit(entity.angle, minAngle, maxAngle);
				}
			}
			
			return move;
		}
		
		private function moveThrust():Boolean
		{
			var move:Boolean = false;
			
			if (FlxG.keys.pressed(thrustKey))
			{
				move = true;
				
				var motion:FlxPoint = FlxVelocity.velocityFromAngle(entity.angle, thrustSpeed);
				
				if (movement == MOVEMENT_INSTANT)
				{
					entity.velocity.x = motion.x;
					entity.velocity.y = motion.y;
				}
				else if (movement == MOVEMENT_ACCELERATES)
				{
					entity.acceleration.x = motion.x;
					entity.acceleration.y = motion.y;
				}
				
				if (bounds && entity.x < bounds.x)
				{
					entity.x = bounds.x;
				}
			}
			
			if (move && thrustSound)
			{
				thrustSound.play(false);
			}
			
			return move;
		}
		
		private function moveReverse():Boolean
		{
			var move:Boolean = false;
			
			if (FlxG.keys.pressed(reverseKey))
			{
				move = true;
				
				var motion:FlxPoint = FlxVelocity.velocityFromAngle(entity.angle, reverseSpeed);
				
				if (movement == MOVEMENT_INSTANT)
				{
					entity.velocity.x = -motion.x;
					entity.velocity.y = -motion.y;
				}
				else if (movement == MOVEMENT_ACCELERATES)
				{
					entity.acceleration.x = -motion.x;
					entity.acceleration.y = -motion.y;
				}
				
				if (bounds && entity.x < bounds.x)
				{
					entity.x = bounds.x;
				}
			}
			
			return move;
		}
		
		private function runFire():Boolean
		{
			var fired:Boolean = false;
			
			//	0 = Pressed
			//	1 = Just Down
			//	2 = Just Released
			if ((fireKeyMode == 0 && FlxG.keys.pressed(fireKey)) || (fireKeyMode == 1 && FlxG.keys.justPressed(fireKey)) || (fireKeyMode == 2 && FlxG.keys.justReleased(fireKey)))
			{
				if (fireRate > 0)
				{
					if (getTimer() > nextFireTime)
					{
						lastFiredTime = getTimer();
						
						fireCallback.call();
						
						fired = true;
						
						nextFireTime = lastFiredTime + fireRate;
					}
				}
				else
				{
					lastFiredTime = getTimer();
					
					fireCallback.call();
					
					fired = true;
				}
			}
			
			if (fired && fireSound)
			{
				fireSound.play(true);
			}
			
			return fired;
		}
		
		private function runJump():Boolean
		{
			var jumped:Boolean = false;
			
			//	This should be called regardless if they've pressed jump or not
			if (entity.isTouching(jumpSurface))
			{
				extraSurfaceTime = getTimer() + jumpFromFallTime;
			}
			
			if ((jumpKeyMode == KEYMODE_PRESSED && FlxG.keys.pressed(jumpKey)) || (jumpKeyMode == KEYMODE_JUST_DOWN && FlxG.keys.justPressed(jumpKey)) || (jumpKeyMode == KEYMODE_RELEASED && FlxG.keys.justReleased(jumpKey)))
			{
				//	Sprite not touching a valid jump surface
				if (entity.isTouching(jumpSurface) == false)
				{
					//	They've run out of time to jump
					if (getTimer() > extraSurfaceTime)
					{
						return jumped;
					}
					else
					{
						//	Still within the fall-jump window of time, but have jumped recently
						if (lastJumpTime > (extraSurfaceTime - jumpFromFallTime))
						{
							return jumped;
						}
					}
					
					//	If there is a jump repeat rate set and we're still less than it then return
					if (getTimer() < nextJumpTime)
					{
						return jumped;
					}
				}
				else
				{
					//	If there is a jump repeat rate set and we're still less than it then return
					if (getTimer() < nextJumpTime)
					{
						return jumped;
					}
				}
				
				if (gravityY > 0)
				{
					//	Gravity is pulling them down to earth, so they are jumping up (negative)
					entity.velocity.y = -jumpHeight;
				}
				else
				{
					//	Gravity is pulling them up, so they are jumping down (positive)
					entity.velocity.y = jumpHeight;
				}
				
				if (jumpCallback is Function)
				{
					jumpCallback.call();
				}
				
				lastJumpTime = getTimer();
				nextJumpTime = lastJumpTime + jumpRate;
					
				jumped = true;
			}
			
			if (jumped && jumpSound)
			{
				jumpSound.play(true);
			}
			
			return jumped;
		}
		
		/**
		 * Called by the FlxControl plugin
		 */
		public function update():void
		{
			if (entity == null)
			{
				return;
			}
			
			if (stopping == STOPPING_INSTANT)
			{
				if (movement == MOVEMENT_INSTANT)
				{
					entity.velocity.x = 0;
					entity.velocity.y = 0;
				}
				else if (movement == MOVEMENT_ACCELERATES)
				{
					entity.acceleration.x = 0;
					entity.acceleration.y = 0;
				}
			}
			else if (stopping == STOPPING_DECELERATES)
			{
				if (movement == MOVEMENT_INSTANT)
				{
					entity.velocity.x = 0;
					entity.velocity.y = 0;
				}
				else if (movement == MOVEMENT_ACCELERATES)
				{
					if (gravityX == 0)
					{
						entity.acceleration.x = 0;
					}
					
					if (gravityY == 0)
					{
						entity.acceleration.y = 0;
					}
				}
			}
			
			//	Rotation
			if (isRotating)
			{
				if (rotationStopping == ROTATION_STOPPING_INSTANT)
				{
					if (rotation == ROTATION_INSTANT)
					{
						entity.angularVelocity = 0;
					}
					else if (rotation == ROTATION_ACCELERATES)
					{
						entity.angularAcceleration = 0;
					}
				}
				else if (rotationStopping == ROTATION_STOPPING_DECELERATES)
				{
					if (rotation == ROTATION_INSTANT)
					{
						entity.angularVelocity = 0;
					}
				}
				
				var hasRotatedAntiClockwise:Boolean = false;
				var hasRotatedClockwise:Boolean = false;
				
				hasRotatedAntiClockwise = moveAntiClockwise();
				
				if (hasRotatedAntiClockwise == false)
				{
					hasRotatedClockwise = moveClockwise();
				}
				
				if (rotationStopping == ROTATION_STOPPING_DECELERATES)
				{
					if (rotation == ROTATION_ACCELERATES && hasRotatedAntiClockwise == false && hasRotatedClockwise == false)
					{
						entity.angularAcceleration = 0;
					}
				}
				
				//	If they have got instant stopping with acceleration and are NOT pressing a key, then stop the rotation. Otherwise we let it carry on
				if (rotationStopping == ROTATION_STOPPING_INSTANT && rotation == ROTATION_ACCELERATES && hasRotatedAntiClockwise == false && hasRotatedClockwise == false)
				{
					entity.angularVelocity = 0;
					entity.angularAcceleration = 0;
				}
			}
			
			//	Thrust
			if (thrustEnabled || reverseEnabled)
			{
				var moved:Boolean = false;
				
				if (thrustEnabled)
				{
					moved = moveThrust();
				}
				
				if (moved == false && reverseEnabled)
				{
					moved = moveReverse();
				}
			}
			else
			{
				var movedX:Boolean = false;
				var movedY:Boolean = false;
				
				if (up)
				{
					movedY = moveUp();
				}
				
				if (down && movedY == false)
				{
					movedY = moveDown();
				}
				
				if (left)
				{
					movedX = moveLeft();
				}
				
				if (right && movedX == false)
				{
					movedX = moveRight();
				}
			}
			
			if (fire)
			{
				runFire();
			}
			
			if (jump)
			{
				runJump();
			}
			
			if (capVelocity)
			{
				if (entity.velocity.x > entity.maxVelocity.x)
				{
					entity.velocity.x = entity.maxVelocity.x;
				}
				
				if (entity.velocity.y > entity.maxVelocity.y)
				{
					entity.velocity.y = entity.maxVelocity.y;
				}
			}
			
			if (walkSound)
			{
				if ((movement == MOVEMENT_INSTANT && entity.velocity.x != 0) || (movement == MOVEMENT_ACCELERATES && entity.acceleration.x != 0))
				{
					walkSound.play(false);
				}
				else
				{
					walkSound.stop();
				}
			}
		}
		
		/**
		 * Sets Custom Key controls. Useful if none of the pre-defined sets work. All String values should be taken from org.flixel.system.input.Keyboard
		 * Pass a blank (empty) String to disable that key from being checked.
		 * 
		 * @param	customUpKey		The String to use for the Up key.
		 * @param	customDownKey	The String to use for the Down key.
		 * @param	customLeftKey	The String to use for the Left key.
		 * @param	customRightKey	The String to use for the Right key.
		 */
		public function setCustomKeys(customUpKey:String, customDownKey:String, customLeftKey:String, customRightKey:String):void
		{
			if (customUpKey != "")
			{
				up = true;
				upKey = customUpKey;
			}
			
			if (customDownKey != "")
			{
				down = true;
				downKey = customDownKey;
			}
			
			if (customLeftKey != "")
			{
				left = true;
				leftKey = customLeftKey;
			}
			
			if (customRightKey != "")
			{
				right = true;
				rightKey = customRightKey;
			}
		}
		
		/**
		 * Enables Cursor/Arrow Key controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
		 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
		 * 
		 * @param	allowUp		Enable the UP key
		 * @param	allowDown	Enable the DOWN key
		 * @param	allowLeft	Enable the LEFT key
		 * @param	allowRight	Enable the RIGHT key
		 */
		public function setCursorControl(allowUp:Boolean = true, allowDown:Boolean = true, allowLeft:Boolean = true, allowRight:Boolean = true):void
		{
			up = allowUp;
			down = allowDown;
			left = allowLeft;
			right = allowRight;
			
			upKey = "UP";
			downKey = "DOWN";
			leftKey = "LEFT";
			rightKey = "RIGHT";
		}
		
		/**
		 * Enables WASD controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
		 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
		 * 
		 * @param	allowUp		Enable the up (W) key
		 * @param	allowDown	Enable the down (S) key
		 * @param	allowLeft	Enable the left (A) key
		 * @param	allowRight	Enable the right (D) key
		 */
		public function setWASDControl(allowUp:Boolean = true, allowDown:Boolean = true, allowLeft:Boolean = true, allowRight:Boolean = true):void
		{
			up = allowUp;
			down = allowDown;
			left = allowLeft;
			right = allowRight;
			
			upKey = "W";
			downKey = "S";
			leftKey = "A";
			rightKey = "D";
		}
		
		/**
		 * Enables ESDF (home row) controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
		 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
		 * 
		 * @param	allowUp		Enable the up (E) key
		 * @param	allowDown	Enable the down (D) key
		 * @param	allowLeft	Enable the left (S) key
		 * @param	allowRight	Enable the right (F) key
		 */
		public function setESDFControl(allowUp:Boolean = true, allowDown:Boolean = true, allowLeft:Boolean = true, allowRight:Boolean = true):void
		{
			up = allowUp;
			down = allowDown;
			left = allowLeft;
			right = allowRight;
			
			upKey = "E";
			downKey = "D";
			leftKey = "S";
			rightKey = "F";
		}
		
		/**
		 * Enables IJKL (right-sided or secondary player) controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
		 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
		 * 
		 * @param	allowUp		Enable the up (I) key
		 * @param	allowDown	Enable the down (K) key
		 * @param	allowLeft	Enable the left (J) key
		 * @param	allowRight	Enable the right (L) key
		 */
		public function setIJKLControl(allowUp:Boolean = true, allowDown:Boolean = true, allowLeft:Boolean = true, allowRight:Boolean = true):void
		{
			up = allowUp;
			down = allowDown;
			left = allowLeft;
			right = allowRight;
			
			upKey = "I";
			downKey = "K";
			leftKey = "J";
			rightKey = "L";
		}
		
		/**
		 * Enables HJKL (Rogue / Net-Hack) controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
		 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
		 * 
		 * @param	allowUp		Enable the up (K) key
		 * @param	allowDown	Enable the down (J) key
		 * @param	allowLeft	Enable the left (H) key
		 * @param	allowRight	Enable the right (L) key
		 */
		public function setHJKLControl(allowUp:Boolean = true, allowDown:Boolean = true, allowLeft:Boolean = true, allowRight:Boolean = true):void
		{
			up = allowUp;
			down = allowDown;
			left = allowLeft;
			right = allowRight;
			
			upKey = "K";
			downKey = "J";
			leftKey = "H";
			rightKey = "L";
		}
		
		/**
		 * Enables ZQSD (Azerty keyboard) controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
		 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
		 * 
		 * @param	allowUp		Enable the up (Z) key
		 * @param	allowDown	Enable the down (Q) key
		 * @param	allowLeft	Enable the left (S) key
		 * @param	allowRight	Enable the right (D) key
		 */
		public function setZQSDControl(allowUp:Boolean = true, allowDown:Boolean = true, allowLeft:Boolean = true, allowRight:Boolean = true):void
		{
			up = allowUp;
			down = allowDown;
			left = allowLeft;
			right = allowRight;
			
			upKey = "Z";
			downKey = "S";
			leftKey = "Q";
			rightKey = "D";
		}
		
		/**
		 * Enables Dvoark Simplified Controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
		 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
		 * 
		 * @param	allowUp		Enable the up (COMMA) key
		 * @param	allowDown	Enable the down (A) key
		 * @param	allowLeft	Enable the left (O) key
		 * @param	allowRight	Enable the right (E) key
		 */
		public function setDvorakSimplifiedControl(allowUp:Boolean = true, allowDown:Boolean = true, allowLeft:Boolean = true, allowRight:Boolean = true):void
		{
			up = allowUp;
			down = allowDown;
			left = allowLeft;
			right = allowRight;
			
			upKey = "COMMA";
			downKey = "O";
			leftKey = "A";
			rightKey = "E";
		}
		
		/**
		 * Enables Numpad (left-handed) Controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
		 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
		 * 
		 * @param	allowUp		Enable the up (NUMPADEIGHT) key
		 * @param	allowDown	Enable the down (NUMPADTWO) key
		 * @param	allowLeft	Enable the left (NUMPADFOUR) key
		 * @param	allowRight	Enable the right (NUMPADSIX) key
		 */
		public function setNumpadControl(allowUp:Boolean = true, allowDown:Boolean = true, allowLeft:Boolean = true, allowRight:Boolean = true):void
		{
			up = allowUp;
			down = allowDown;
			left = allowLeft;
			right = allowRight;
			
			upKey = "NUMPADEIGHT";
			downKey = "NUMPADTWO";
			leftKey = "NUMPADFOUR";
			rightKey = "NUMPADSIX";
		}
		
		
	}

}