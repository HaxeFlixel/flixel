package flixel.plugin.photonstorm;

import flash.geom.Rectangle;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.FlxSound;
import flixel.FlxSprite;
import flixel.util.FlxMisc;
import flixel.util.FlxVelocity;

/**
 * 
 * Makes controlling an FlxSprite with the keyboard a LOT easier and quicker to set-up!<br>
 * Sometimes it's hard to know what values to set, especially if you want gravity, jumping, sliding, etc.<br>
 * This class helps sort that - and adds some cool extra functionality too :)
 * 
 * TODO: Hot Keys
 * TODO: Binding of sound effects to keys (seperate from setSounds? as those are event based)
 * TODO: If moving diagonally compensate speed parameter (times x,y velocities by 0.707 or cos/sin(45))
 * TODO: Specify animation frames to play based on velocity
 * TODO: Variable gravity (based on height, the higher the stronger the effect)
 * 
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class FlxControlHandler
{
	/**
	 * The "Instant" Movement Type means the sprite will move at maximum speed instantly, and will not "accelerate" (or speed-up) before reaching that speed.
	 */
	inline static public var MOVEMENT_INSTANT:Int = 0;
	/**
	 * The "Accelerates" Movement Type means the sprite will accelerate until it reaches maximum speed.
	 */
	inline static public var MOVEMENT_ACCELERATES:Int = 1;
	/**
	 * The "Instant" Stopping Type means the sprite will stop immediately when no direction keys are being pressed, there will be no deceleration.
	 */
	inline static public var STOPPING_INSTANT:Int = 0;
	/**
	 * The "Decelerates" Stopping Type means the sprite will start decelerating when no direction keys are being pressed. Deceleration continues until the speed reaches zero.
	 */
	inline static public var STOPPING_DECELERATES:Int = 1;
	/**
	 * The "Never" Stopping Type means the sprite will never decelerate, any speed built up will be carried on and never reduce.
	 */
	inline static public var STOPPING_NEVER:Int = 2;
	
	/**
	 * The "Instant" Movement Type means the sprite will rotate at maximum speed instantly, and will not "accelerate" (or speed-up) before reaching that speed.
	 */
	inline static public var ROTATION_INSTANT:Int = 0;
	/**
	 * The "Accelerates" Rotaton Type means the sprite will accelerate until it reaches maximum rotation speed.
	 */
	inline static public var ROTATION_ACCELERATES:Int = 1;
	/**
	 * The "Instant" Stopping Type means the sprite will stop rotating immediately when no rotation keys are being pressed, there will be no deceleration.
	 */
	inline static public var ROTATION_STOPPING_INSTANT:Int = 0;
	/**
	 * The "Decelerates" Stopping Type means the sprite will start decelerating when no rotation keys are being pressed. Deceleration continues until rotation speed reaches zero.
	 */
	inline static public var ROTATION_STOPPING_DECELERATES:Int = 1;
	/**
	 * The "Never" Stopping Type means the sprite will never decelerate, any speed built up will be carried on and never reduce.
	 */
	inline static public var ROTATION_STOPPING_NEVER:Int = 2;
	
	/**
	 * This keymode fires for as long as the key is held down
	 */
	inline static public var KEYMODE_PRESSED:Int = 0;
	
	/**
	 * This keyboard fires when the key has just been pressed down, and not again until it is released and re-pressed
	 */
	inline static public var KEYMODE_JUST_DOWN:Int = 1;
	
	/**
	 * This keyboard fires only when the key has been pressed and then released again
	 */
	inline static public var KEYMODE_RELEASED:Int = 2;
	
	// Helpers
	public var isPressedUp:Bool = false;
	public var isPressedDown:Bool = false;
	public var isPressedLeft:Bool = false;
	public var isPressedRight:Bool = false;
	
	// Used by the FlxControl plugin
	public var enabled:Bool = false;
	
	private var _entity:FlxSprite;
	
	private var _bounds:Rectangle;
	
	private var _up:Bool = false;
	private var _down:Bool = false;
	private var _left:Bool = false;
	private var _right:Bool = false;

	private var _fire:Bool;
	private var _altFire:Bool;
	private var _jump:Bool;
	private var _altJump:Bool;
	private var _xFacing:Bool;
	private var _yFacing:Bool;
	private var _rotateAntiClockwise:Bool;
	private var _rotateClockwise:Bool;
	
	private var _upMoveSpeed:Int;
	private var _downMoveSpeed:Int;
	private var _leftMoveSpeed:Int;
	private var _rightMoveSpeed:Int;
	private var _thrustSpeed:Int;
	private var _reverseSpeed:Int;
	
	// Rotation
	private var _thrustEnabled:Bool = false;
	private var _reverseEnabled:Bool;
	private var _isRotating:Bool = false;
	private var _antiClockwiseRotationSpeed:Float;
	private var _clockwiseRotationSpeed:Float;
	private var _enforceAngleLimits:Bool = false;
	private var _minAngle:Int;
	private var _maxAngle:Int;
	private var _capAngularVelocity:Bool;
	
	private var _xSpeedAdjust:Float = 0;
	private var _ySpeedAdjust:Float = 0;
	
	private var _gravityX:Int = 0;
	private var _gravityY:Int = 0;
	
	// The ms delay between firing when the key is held down
	private var _fireRate:Int; 			
	// The internal time when they can next fire
	private var _nextFireTime:Int = 0; 		
	// The internal time of when when they last fired
	private var _lastFiredTime:Int; 		
	// The fire key mode
	private var _fireKeyMode:Int;		
	// A function to call every time they fire
	private var _fireCallback:Void->Void;	
	
	// The pixel height amount they jump (drag and gravity also both influence this)
	private var _jumpHeight:Int; 	
	// The ms delay between jumping when the key is held down
	private var _jumpRate:Int; 	
	// The jump key mode
	private var _jumpKeyMode:Int;
	// The internal time when they can next jump
	private var _nextJumpTime:Int; 		
	// The internal time of when when they last jumped
	private var _lastJumpTime:Int; 		
	// A short window of opportunity for them to jump having just fallen off the edge of a surface
	private var _jumpFromFallTime:Int; 	
	// Internal time of when they last collided with a valid jumpSurface
	private var _extraSurfaceTime:Int; 	
	// The surfaces from FlxObject they can jump from (i.e. FlxObject.FLOOR)
	private var _jumpSurface:Int; 		
	// A function to call every time they jump
	private var _jumpCallback:Void->Void;	
	
	private var _movement:Int;
	private var _stopping:Int;
	private var _rotation:Int;
	private var _rotationStopping:Int;
	private var _capVelocity:Bool;
	// TODO
	private var _hotkeys:Array<String>;			
	
	private var _upKey:String;
	private var _downKey:String;
	private var _leftKey:String;
	private var _rightKey:String;
	private var _fireKey:String;
	// TODO
	private var _altFireKey:String;		
	private var _jumpKey:String;
	// TODO
	private var _altJumpKey:String;		
	private var _antiClockwiseKey:String;
	private var _clockwiseKey:String;
	private var _thrustKey:String;
	private var _reverseKey:String;
	
	// Sounds
	private var _jumpSound:FlxSound;
	private var _fireSound:FlxSound;
	private var _walkSound:FlxSound;
	private var _thrustSound:FlxSound;
	
	/**
	 * Sets the FlxSprite to be controlled by this class, and defines the initial movement and stopping types.<br>
	 * After creating an instance of this class you should call setMovementSpeed, and one of the enableXControl functions if you need more than basic cursors.
	 * 
	 * @param	Sprite			The FlxSprite you want this class to control. It can only control one FlxSprite at once.
	 * @param	MovementType	Set to either MOVEMENT_INSTANT or MOVEMENT_ACCELERATES
	 * @param	StoppingType	Set to STOPPING_INSTANT, STOPPING_DECELERATES or STOPPING_NEVER
	 * @param	UpdateFacing	If true it sets the FlxSprite.facing value to the direction pressed (default false)
	 * @param	EnableArrowKeys	If true it will enable all arrow keys (default) - see setCursorControl for more fine-grained control
	 */
	public function new(Sprite:FlxSprite, MovementType:Int, StoppingType:Int, UpdateFacing:Bool = false, EnableArrowKeys:Bool = true)
	{
		_entity = Sprite;
		
		_movement = MovementType;
		_stopping = StoppingType;
		
		_xFacing = UpdateFacing;
		_yFacing = UpdateFacing;
		
		_rotation = ROTATION_INSTANT;
		_rotationStopping = ROTATION_STOPPING_INSTANT;
		
		if (EnableArrowKeys)
		{
			setCursorControl();
		}
		
		enabled = true;
	}
	
	/**
	 * Set the speed at which the sprite will move when a direction key is pressed.<br>
	 * All values are given in pixels per second. So an xSpeed of 100 would move the sprite 100 pixels in 1 second (1000ms)
	 * Due to the nature of the internal Flash timer this amount is not 100% accurate and will vary above/below the desired distance by a few pixels.
	 * 
	 * If you need different speed values for left/right or up/down then use setAdvancedMovementSpeed
	 * 
	 * @param	SpeedX			The speed in pixels per second in which the sprite will move/accelerate horizontally
	 * @param	SpeedY			The speed in pixels per second in which the sprite will move/accelerate vertically
	 * @param	SpeedMaxX		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	SpeedMaxY		The maximum speed in pixels per second in which the sprite can move vertically
	 * @param	DecelerationX	A deceleration speed in pixels per second to apply to the sprites horizontal movement (default 0)
	 * @param	DecelerationY	A deceleration speed in pixels per second to apply to the sprites vertical movement (default 0)
	 */
	public function setMovementSpeed(SpeedX:Int, SpeedY:Int, SpeedMaxX:Int, SpeedMaxY:Int, DecelerationX:Int = 0, DecelerationY:Int = 0):Void
	{
		_leftMoveSpeed = - SpeedX;
		_rightMoveSpeed = SpeedX;
		_upMoveSpeed = - SpeedY;
		_downMoveSpeed = SpeedY;
		
		setMaximumSpeed(SpeedMaxX, SpeedMaxY);
		setDeceleration(DecelerationX, DecelerationY);
	}
	
	/**
	 * If you know you need the same value for the acceleration, maximum speeds and (optionally) deceleration then this is a quick way to set them.
	 * 
	 * @param	Speed			The speed in pixels per second in which the sprite will move/accelerate/decelerate
	 * @param	Acceleration	If true it will set the speed value as the deceleration value (default) false will leave deceleration disabled
	 */
	public function setStandardSpeed(Speed:Int, Acceleration:Bool = true):Void
	{
		if (Acceleration)
		{
			setMovementSpeed(Speed, Speed, Speed, Speed, Speed, Speed);
		}
		else
		{
			setMovementSpeed(Speed, Speed, Speed, Speed);
		}
	}
	
	/**
	 * Set the speed at which the sprite will move when a direction key is pressed.<br>
	 * All values are given in pixels per second. So an xSpeed of 100 would move the sprite 100 pixels in 1 second (1000ms)<br>
	 * Due to the nature of the internal Flash timer this amount is not 100% accurate and will vary above/below the desired distance by a few pixels.<br>
	 * 
	 * If you don't need different speed values for every direction on its own then use setMovementSpeed
	 * 
	 * @param	LeftSpeed		The speed in pixels per second in which the sprite will move/accelerate to the left
	 * @param	RightSpeed		The speed in pixels per second in which the sprite will move/accelerate to the right
	 * @param	UpSpeed			The speed in pixels per second in which the sprite will move/accelerate up
	 * @param	DownSpeed		The speed in pixels per second in which the sprite will move/accelerate down
	 * @param	SpeedMaxX		The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	SpeedMaxY		The maximum speed in pixels per second in which the sprite can move vertically
	 * @param	DecelerationX	Deceleration speed in pixels per second to apply to the sprites horizontal movement (default 0)
	 * @param	DecelerationY	Deceleration speed in pixels per second to apply to the sprites vertical movement (default 0)
	 */
	public function setAdvancedMovementSpeed(LeftSpeed:Int, RightSpeed:Int, UpSpeed:Int, DownSpeed:Int, SpeedMaxX:Int, SpeedMaxY:Int, DecelerationX:Int = 0, DecelerationY:Int = 0):Void
	{
		_leftMoveSpeed = - LeftSpeed;
		_rightMoveSpeed = RightSpeed;
		_upMoveSpeed = - UpSpeed;
		_downMoveSpeed = DownSpeed;
		
		setMaximumSpeed(SpeedMaxX, SpeedMaxY);
		setDeceleration(DecelerationX, DecelerationY);
	}
	
	/**
	 * Set the speed at which the sprite will rotate when a direction key is pressed.<br>
	 * Use this in combination with setMovementSpeed to create a Thrust like movement system.<br>
	 * All values are given in pixels per second. So an xSpeed of 100 would rotate the sprite 100 pixels in 1 second (1000ms)<br>
	 * Due to the nature of the internal Flash timer this amount is not 100% accurate and will vary above/below the desired distance by a few pixels.<br>
	 */
	public function setRotationSpeed(AntiClockwiseSpeed:Float, ClockwiseSpeed:Float, SpeedMax:Float, Deceleration:Float):Void
	{
		_antiClockwiseRotationSpeed = -AntiClockwiseSpeed;
		_clockwiseRotationSpeed = ClockwiseSpeed;
		
		setRotationKeys();
		setMaximumRotationSpeed(SpeedMax);
		setRotationDeceleration(Deceleration);
	}
	
	/**
	 * @param	RotationType
	 * @param	StoppingType
	 */
	public function setRotationType(RotationType:Int, StoppingType:Int):Void
	{
		_rotation = RotationType;
		_rotationStopping = StoppingType;
	}
	
	/**
	 * Sets the maximum speed (in pixels per second) that the FlxSprite can rotate.<br>
	 * When the FlxSprite is accelerating (movement type MOVEMENT_ACCELERATES) its speed won't increase above this value.<br>
	 * However Flixel allows the velocity of an FlxSprite to be set to anything. So if you'd like to check the value and restrain it, then enable "limitVelocity".
	 * 
	 * @param	Speed			The maximum speed in pixels per second in which the sprite can rotate
	 * @param	LimitVelocity	If true the angular velocity of the FlxSprite will be checked and kept within the limit. If false it can be set to anything.
	 */
	public function setMaximumRotationSpeed(Speed:Float, LimitVelocity:Bool = true):Void
	{
		_entity.maxAngular = Speed;
		
		_capAngularVelocity = LimitVelocity;
	}
	
	/**
	 * Deceleration is a speed (in pixels per second) that is applied to the sprite if stopping type is "DECELERATES" and if no rotation is taking place.<br>
	 * The velocity of the sprite will be reduced until it reaches zero.
	 * 
	 * @param	Speed	The speed in pixels per second at which the sprite will have its angular rotation speed decreased
	 */
	public function setRotationDeceleration(Speed:Float):Void
	{
		_entity.angularDrag = Speed;
	}
	
	/**
	 * Set minimum and maximum angle limits that the Sprite won't be able to rotate beyond.<br>
	 * Values must be between -180 and +180. 0 is pointing right, 90 down, 180 left, -90 up.
	 * 
	 * @param	MinimumAngle	Minimum angle below which the sprite cannot rotate (must be -180 or above)
	 * @param	MaximumAngle	Maximum angle above which the sprite cannot rotate (must be 180 or below)
	 */
	public function setRotationLimits(MinimumAngle:Int, MaximumAngle:Int):Void
	{
		if (MinimumAngle > MaximumAngle || MinimumAngle < -180 || MaximumAngle > 180)
		{
			throw "FlxControlHandler setRotationLimits: Invalid Minimum / Maximum angle";
		}
		else
		{
			_enforceAngleLimits = true;
			_minAngle = MinimumAngle;
			_maxAngle = MaximumAngle;
		}
	}
	
	/**
	 * Disables rotation limits set in place by setRotationLimits()
	 */
	public function disableRotationLimits():Void
	{
		_enforceAngleLimits = false;
	}
	
	/**
	 * Set which keys will rotate the sprite. The speed of rotation is set in setRotationSpeed.
	 * 
	 * @param	LeftRight				Use the LEFT and RIGHT arrow keys for anti-clockwise and clockwise rotation respectively.
	 * @param	UpDown					Use the UP and DOWN arrow keys for anti-clockwise and clockwise rotation respectively.
	 * @param	CustomAntiClockwise		The String value of your own key to use for anti-clockwise rotation (as taken from flixel.system.input.Keyboard)
	 * @param	CustomClockwise			The String value of your own key to use for clockwise rotation (as taken from flixel.system.input.Keyboard)
	 */
	public function setRotationKeys(LeftRight:Bool = true, UpDown:Bool = false, CustomAntiClockwise:String = "", CustomClockwise:String = ""):Void
	{
		_isRotating = true;
		_rotateAntiClockwise = true;
		_rotateClockwise = true;
		_antiClockwiseKey = "LEFT";
		_clockwiseKey = "RIGHT";

		if (UpDown)
		{
			_antiClockwiseKey = "UP";
			_clockwiseKey = "DOWN";
		}
		
		if (CustomAntiClockwise != "" && CustomClockwise != "")
		{
			_antiClockwiseKey = CustomAntiClockwise;
			_clockwiseKey = CustomClockwise;
		}
	}
	
	/**
	 * If you want to enable a Thrust like motion for your sprite use this to set the speed and keys.<br>
	 * This is usually used in conjunction with Rotation and it will over-ride anything already defined in setMovementSpeed.
	 * 
	 * @param	ThrustKey		Specify the key String (as taken from flixel.system.input.Keyboard) to use for the Thrust action
	 * @param	ThrustSpeed		The speed in pixels per second which the sprite will move. Acceleration or Instant movement is determined by the Movement Type.
	 * @param	ReverseKey		If you want to be able to reverse, set the key string as taken from flixel.system.input.Keyboard (defaults to null).
	 * @param	ReverseSpeed	The speed in pixels per second which the sprite will reverse. Acceleration or Instant movement is determined by the Movement Type.
	 */
	public function setThrust(ThrustKey:String, ThrustSpeed:Float, ?ReverseKey:String, ReverseSpeed:Float = 0):Void
	{
		_thrustEnabled = false;
		_reverseEnabled = false;
		
		if (ThrustKey != "")
		{
			_thrustKey = ThrustKey;
			_thrustSpeed = Math.floor(ThrustSpeed);
			_thrustEnabled = true;
		}
		
		if (ReverseKey != null)
		{
			_reverseKey = ReverseKey;
			_reverseSpeed = Math.floor(ReverseSpeed);
			_reverseEnabled = true;
		}
	}
	
	/**
	 * Sets the maximum speed (in pixels per second) that the FlxSprite can move. You can set the horizontal and vertical speeds independantly.<br>
	 * When the FlxSprite is accelerating (movement type MOVEMENT_ACCELERATES) its speed won't increase above this value.<br>
	 * However Flixel allows the velocity of an FlxSprite to be set to anything. So if you'd like to check the value and restrain it, then enable "limitVelocity".
	 * 
	 * @param	SpeedX			The maximum speed in pixels per second in which the sprite can move horizontally
	 * @param	SpeedY			The maximum speed in pixels per second in which the sprite can move vertically
	 * @param	LimitVelocity	If true the velocity of the FlxSprite will be checked and kept within the limit. If false it can be set to anything.
	 */
	public function setMaximumSpeed(SpeedX:Int, SpeedY:Int, LimitVelocity:Bool = true):Void
	{
		_entity.maxVelocity.x = SpeedX;
		_entity.maxVelocity.y = SpeedY;
		
		_capVelocity = LimitVelocity;
	}
	
	/**
	 * Deceleration is a speed (in pixels per second) that is applied to the sprite if stopping type is "DECELERATES" and if no acceleration is taking place.<br>
	 * The velocity of the sprite will be reduced until it reaches zero, and can be configured separately per axis.
	 * 
	 * @param	SpeedX		The speed in pixels per second at which the sprite will have its horizontal speed decreased
	 * @param	SpeedY		The speed in pixels per second at which the sprite will have its vertical speed decreased
	 */
	public function setDeceleration(SpeedX:Int, SpeedY:Int):Void
	{
		_entity.drag.x = SpeedX;
		_entity.drag.y = SpeedY;
	}
	
	/**
	 * Gravity can be applied to the sprite, pulling it in any direction.<br>
	 * Gravity is given in pixels per second and is applied as acceleration. The speed the sprite reaches under gravity will never exceed the Maximum Movement Speeds set.<br>
	 * If you don't want gravity for a specific direction pass a value of zero.
	 * 
	 * @param	ForceX	A positive value applies gravity dragging the sprite to the right. A negative value drags the sprite to the left. Zero disables horizontal gravity.
	 * @param	ForceY	A positive value applies gravity dragging the sprite down. A negative value drags the sprite up. Zero disables vertical gravity.
	 */
	public function setGravity(ForceX:Int, ForceY:Int):Void
	{
		_gravityX = ForceX;
		_gravityY = ForceY;
		
		_entity.acceleration.x = _gravityX;
		_entity.acceleration.y = _gravityY;
	}
	
	/**
	 * Switches the gravity applied to the sprite. If gravity was +400 Y (pulling them down) this will swap it to -400 Y (pulling them up)<br>
	 * To reset call flipGravity again
	 */
	public function flipGravity():Void
	{
		if (!Math.isNaN(_gravityX) && _gravityX != 0)
		{
			_gravityX = - _gravityX;
			_entity.acceleration.x = _gravityX;
		}
		
		if (!Math.isNaN(_gravityY) && _gravityY != 0)
		{
			_gravityY = - _gravityY;
			_entity.acceleration.y = _gravityY;
		}
	}
	
	/**
	 * TODO
	 * 
	 * @param	FactorX
	 * @param	FactorY
	 */
	public function speedUp(FactorX:Float, FactorY:Float):Void
	{
	}
	
	/**
	 * TODO
	 * 
	 * @param	FactorX
	 * @param	FactorY
	 */
	public function slowDown(FactorX:Float, FactorY:Float):Void
	{
	}
	
	/**
	 * TODO
	 * 
	 * @param	ResetX
	 * @param	ResetY
	 */
	public function resetSpeeds(ResetX:Bool = true, ResetY:Bool = true):Void
	{
		if (ResetX)
		{
			_xSpeedAdjust = 0;
		}
		
		if (ResetY)
		{
			_ySpeedAdjust = 0;
		}
	}
	
	/**
	 * Creates a new Hot Key, which can be bound to any function you specify (such as "swap weapon", "quit", etc)
	 * 
	 * @param	Key			The key to use as the hot key (String from flixel.system.input.Keyboard, i.e. "SPACE", "CONTROL", "Q", etc)
	 * @param	Callback	The function to call when the key is pressed
	 * @param	Keymode		The keymode that will trigger the callback, either KEYMODE_PRESSED, KEYMODE_JUST_DOWN or KEYMODE_RELEASED
	 */
	public function addHotKey(Key:String, Callback:Dynamic, Keymode:Int):Void
	{
		// TODO
	}
	
	/**
	 * Removes a previously defined hot key
	 * 
	 * @param	Key		The key to use as the hot key (String from flixel.system.input.Keyboard, i.e. "SPACE", "CONTROL", "Q", etc)
	 * @return	True if the key was found and removed, false if the key couldn't be found
	 */
	public function removeHotKey(Key:String):Bool
	{
		return true;
	}
	
	/**
	 * Set sound effects for the movement events jumping, firing, walking and thrust.
	 * 
	 * @param	Jump	The FlxSound to play when the user jumps
	 * @param	Fire	The FlxSound to play when the user fires
	 * @param	Walk	The FlxSound to play when the user walks
	 * @param	Thrust	The FlxSound to play when the user thrusts
	 */
	public function setSounds(?Jump:FlxSound, ?Fire:FlxSound, ?Walk:FlxSound, ?Thrust:FlxSound):Void
	{
		if (Jump != null)
		{
			_jumpSound = Jump;
		}
		
		if (Fire != null)
		{
			_fireSound = Fire;
		}
		
		if (Walk != null)
		{
			_walkSound = Walk;
		}
		
		if (Thrust != null)
		{
			_thrustSound = Thrust;
		}
	}
	
	/**
	 * Enable a fire button
	 * 
	 * @param	Key				The key to use as the fire button (String from flixel.system.input.Keyboard, i.e. "SPACE", "CONTROL")
	 * @param	Keymode			The FlxControlHandler KEYMODE value (KEYMODE_PRESSED, KEYMODE_JUST_DOWN, KEYMODE_RELEASED)
	 * @param	RepeatDelay		Time delay in ms between which the fire action can repeat (0 means instant, 250 would allow it to fire approx. 4 times per second)
	 * @param	Callback		A user defined function to call when it fires
	 * @param	AltKey			Specify an alternative fire key that works AS WELL AS the primary fire key (TODO)
	 */
	public function setFireButton(Key:String, Keymode:Int, RepeatDelay:Int, Callback:Void->Void, AltKey:String = ""):Void
	{
		_fireKey = Key;
		_fireKeyMode = Keymode;
		_fireRate = RepeatDelay;
		_fireCallback = Callback;
		
		if (AltKey != "")
		{
			_altFireKey = AltKey;
		}
		
		_fire = true;
	}
	
	/**
	 * Enable a jump button
	 * 
	 * @param	Key				The key to use as the jump button (String from flixel.system.input.Keyboard, i.e. "SPACE", "CONTROL")
	 * @param	Keymode			The FlxControlHandler KEYMODE value (KEYMODE_PRESSED, KEYMODE_JUST_DOWN, KEYMODE_RELEASED)
	 * @param	Height			The height in pixels/sec that the Sprite will attempt to jump (gravity and acceleration can influence this actual height obtained)
	 * @param	Surface			A bitwise combination of all valid surfaces the Sprite can jump off (from FlxObject, such as FlxObject.FLOOR)
	 * @param	RepeatDelay		Time delay in ms between which the jumping can repeat (250 would be 4 times per second)
	 * @param	JumpFromFall	A time in ms that allows the Sprite to still jump even if it's just fallen off a platform, if still within ths time limit
	 * @param	Callback		A user defined function to call when the Sprite jumps
	 * @param	AltKey			Specify an alternative jump key that works AS WELL AS the primary jump key (TODO)
	 */
	public function setJumpButton(Key:String, Keymode:Int, Height:Int, Surface:Int, RepeatDelay:Int = 250, JumpFromFall:Int = 0, ?Callback:Void->Void, AltKey:String = ""):Void
	{
		_jumpKey = Key;
		_jumpKeyMode = Keymode;
		_jumpHeight = Height;
		_jumpSurface = Surface;
		_jumpRate = RepeatDelay;
		_jumpFromFallTime = JumpFromFall;
		_jumpCallback = Callback;
		
		if (AltKey != "")
		{
			_altJumpKey = AltKey;
		}
		
		_jump = true;
	}
	
	/**
	 * Limits the sprite to only be allowed within this rectangle. If its x/y coordinates go outside it will be repositioned back inside.
	 * Coordinates should be given in GAME WORLD pixel values (not screen value, although often they are the two same things)
	 * 
	 * @param	X		The x coordinate of the top left corner of the area (in game world pixels)
	 * @param	Y		The y coordinate of the top left corner of the area (in game world pixels)
	 * @param	Width	The width of the area (in pixels)
	 * @param	Height	The height of the area (in pixels)
	 */
	public function setBounds(X:Int, Y:Int, Width:Int, Height:Int):Void
	{
		_bounds = new Rectangle(X, Y, Width, Height);
	}
	
	/**
	 * Clears any previously set sprite bounds
	 */
	public function removeBounds():Void
	{
		_bounds = null;
	}
	
	private function moveUp():Bool
	{
		var move:Bool = false;
		
		if (FlxG.keys.pressed(_upKey))
		{
			move = true;
			isPressedUp = true;
			
			if (_yFacing)
			{
				_entity.facing = FlxObject.UP;
			}
			
			if (_movement == MOVEMENT_INSTANT)
			{
				_entity.velocity.y = _upMoveSpeed;
			}
			else if (_movement == MOVEMENT_ACCELERATES)
			{
				_entity.acceleration.y = _upMoveSpeed;
			}
			
			if (_bounds != null && _entity.y < _bounds.top)
			{
				_entity.y = _bounds.top;
			}
		}
		
		return move;
	}
	
	private function moveDown():Bool
	{
		var move:Bool = false;
		
		if (FlxG.keys.pressed(_downKey))
		{
			move = true;
			isPressedDown = true;
			
			if (_yFacing)
			{
				_entity.facing = FlxObject.DOWN;
			}
			
			if (_movement == MOVEMENT_INSTANT)
			{
				_entity.velocity.y = _downMoveSpeed;
			}
			else if (_movement == MOVEMENT_ACCELERATES)
			{
				_entity.acceleration.y = _downMoveSpeed;
			}
			
			if (_bounds != null && _entity.y > _bounds.bottom)
			{
				_entity.y = _bounds.bottom;
			}
			
		}
		
		return move;
	}
	
	private function moveLeft():Bool
	{
		var move:Bool = false;
		
		if (FlxG.keys.pressed(_leftKey))
		{
			move = true;
			isPressedLeft = true;
			
			if (_xFacing)
			{
				_entity.facing = FlxObject.LEFT;
			}
			
			if (_movement == MOVEMENT_INSTANT)
			{
				_entity.velocity.x = _leftMoveSpeed;
			}
			else if (_movement == MOVEMENT_ACCELERATES)
			{
				_entity.acceleration.x = _leftMoveSpeed;
			}
			
			if (_bounds != null && _entity.x < _bounds.x)
			{
				_entity.x = _bounds.x;
			}
		}
		
		return move;
	}
	
	private function moveRight():Bool
	{
		var move:Bool = false;
		
		if (FlxG.keys.pressed(_rightKey))
		{
			move = true;
			isPressedRight = true;
			
			if (_xFacing)
			{
				_entity.facing = FlxObject.RIGHT;
			}
			
			if (_movement == MOVEMENT_INSTANT)
			{
				_entity.velocity.x = _rightMoveSpeed;
			}
			else if (_movement == MOVEMENT_ACCELERATES)
			{
				_entity.acceleration.x = _rightMoveSpeed;
			}
			
			if (_bounds != null && _entity.x > _bounds.right)
			{
				_entity.x = _bounds.right;
			}
		}
		
		return move;
	}
	
	private function moveAntiClockwise():Bool
	{
		var move:Bool = false;
		
		if (FlxG.keys.pressed(_antiClockwiseKey))
		{
			move = true;
			
			if (_rotation == ROTATION_INSTANT)
			{
				_entity.angularVelocity = _antiClockwiseRotationSpeed;
			}
			else if (_rotation == ROTATION_ACCELERATES)
			{
				_entity.angularAcceleration = _antiClockwiseRotationSpeed;
			}
			
			// TODO - Not quite there yet given the way Flixel can rotate to any valid int angle!
			if (_enforceAngleLimits)
			{
				//entity.angle = FlxAngle.angleLimit(entity.angle, minAngle, maxAngle);
			}
		}
		
		return move;
	}
	
	private function moveClockwise():Bool
	{
		var move:Bool = false;
		
		if (FlxG.keys.pressed(_clockwiseKey))
		{
			move = true;
			
			if (_rotation == ROTATION_INSTANT)
			{
				_entity.angularVelocity = _clockwiseRotationSpeed;
			}
			else if (_rotation == ROTATION_ACCELERATES)
			{
				_entity.angularAcceleration = _clockwiseRotationSpeed;
			}
			
			// TODO - Not quite there yet given the way Flixel can rotate to any valid int angle!
			if (_enforceAngleLimits)
			{
				//entity.angle = FlxAngle.angleLimit(entity.angle, minAngle, maxAngle);
			}
		}
		
		return move;
	}
	
	private function moveThrust():Bool
	{
		var move:Bool = false;
		
		if (FlxG.keys.pressed(_thrustKey))
		{
			move = true;
			
			var motion:FlxPoint = FlxVelocity.velocityFromAngle(Math.floor(_entity.angle), _thrustSpeed);
			
			if (_movement == MOVEMENT_INSTANT)
			{
				_entity.velocity.x = motion.x;
				_entity.velocity.y = motion.y;
			}
			else if (_movement == MOVEMENT_ACCELERATES)
			{
				_entity.acceleration.x = motion.x;
				_entity.acceleration.y = motion.y;
			}
			
			if (_bounds != null && _entity.x < _bounds.x)
			{
				_entity.x = _bounds.x;
			}
		}
		
		if (move && _thrustSound != null)
		{
			_thrustSound.play(false);
		}
		
		return move;
	}
	
	private function moveReverse():Bool
	{
		var move:Bool = false;
		
		if (FlxG.keys.pressed(_reverseKey))
		{
			move = true;
			
			var motion:FlxPoint = FlxVelocity.velocityFromAngle(Math.floor(_entity.angle), _reverseSpeed);
			
			if (_movement == MOVEMENT_INSTANT)
			{
				_entity.velocity.x = -motion.x;
				_entity.velocity.y = -motion.y;
			}
			else if (_movement == MOVEMENT_ACCELERATES)
			{
				_entity.acceleration.x = -motion.x;
				_entity.acceleration.y = -motion.y;
			}
			
			if (_bounds != null && _entity.x < _bounds.x)
			{
				_entity.x = _bounds.x;
			}
		}
		
		return move;
	}
	
	private function runFire():Bool
	{
		var fired:Bool = false;
		
		// 0 = Pressed
		// 1 = Just Down
		// 2 = Just Released
		if ((_fireKeyMode == 0 && FlxG.keys.pressed(_fireKey)) || (_fireKeyMode == 1 && FlxG.keys.justPressed(_fireKey)) || (_fireKeyMode == 2 && FlxG.keys.justReleased(_fireKey)))
		{
			if (_fireRate > 0)
			{
				if (FlxMisc.getTicks() > _nextFireTime)
				{
					_lastFiredTime = FlxMisc.getTicks();
					_fireCallback();
					fired = true;
					_nextFireTime = _lastFiredTime + Std.int(_fireRate / FlxG.timeScale);
				}
			}
			else
			{
				_lastFiredTime = FlxMisc.getTicks();
				_fireCallback();
				fired = true;
			}
		}
		
		if (fired && _fireSound != null)
		{
			_fireSound.play(true);
		}
		
		return fired;
	}
	
	private function runJump():Bool
	{
		var jumped:Bool = false;
		
		// This should be called regardless if they've pressed jump or not
		if (_entity.isTouching(_jumpSurface))
		{
			_extraSurfaceTime = FlxMisc.getTicks() + _jumpFromFallTime;
		}
		
		if ((_jumpKeyMode == KEYMODE_PRESSED && FlxG.keys.pressed(_jumpKey)) || (_jumpKeyMode == KEYMODE_JUST_DOWN && FlxG.keys.justPressed(_jumpKey)) || (_jumpKeyMode == KEYMODE_RELEASED && FlxG.keys.justReleased(_jumpKey)))
		{
			// Sprite not touching a valid jump surface
			if (_entity.isTouching(_jumpSurface) == false)
			{
				// They've run out of time to jump
				if (FlxMisc.getTicks() > _extraSurfaceTime)
				{
					return jumped;
				}
				else
				{
					// Still within the fall-jump window of time, but have jumped recently
					if (_lastJumpTime > (_extraSurfaceTime - _jumpFromFallTime))
					{
						return jumped;
					}
				}
				
				// If there is a jump repeat rate set and we're still less than it then return
				if (FlxMisc.getTicks() < _nextJumpTime)
				{
					return jumped;
				}
			}
			else
			{
				// If there is a jump repeat rate set and we're still less than it then return
				if (FlxMisc.getTicks() < _nextJumpTime)
				{
					return jumped;
				}
			}
			
			if (_gravityY > 0)
			{
				// Gravity is pulling them down to earth, so they are jumping up (negative)
				_entity.velocity.y = -_jumpHeight;
			}
			else
			{
				// Gravity is pulling them up, so they are jumping down (positive)
				_entity.velocity.y = _jumpHeight;
			}
			
			if (_jumpCallback != null)
			{
				_jumpCallback();
			}
			
			_lastJumpTime = FlxMisc.getTicks();
			_nextJumpTime = _lastJumpTime + Std.int(_jumpRate / FlxG.timeScale);
			
			jumped = true;
		}
		
		if (jumped && _jumpSound != null)
		{
			_jumpSound.play(true);
		}
		
		return jumped;
	}
	
	/**
	 * Called by the FlxControl plugin
	 */
	public function update():Void
	{
		if (_entity == null)
		{
			return;
		}
		
		// Reset the helper booleans
		isPressedUp = false;
		isPressedDown = false;
		isPressedLeft = false;
		isPressedRight = false;
		
		if (_stopping == STOPPING_INSTANT)
		{
			if (_movement == MOVEMENT_INSTANT)
			{
				_entity.velocity.x = 0;
				_entity.velocity.y = 0;
			}
			else if (_movement == MOVEMENT_ACCELERATES)
			{
				_entity.acceleration.x = 0;
				_entity.acceleration.y = 0;
			}
		}
		else if (_stopping == STOPPING_DECELERATES)
		{
			if (_movement == MOVEMENT_INSTANT)
			{
				_entity.velocity.x = 0;
				_entity.velocity.y = 0;
			}
			else if (_movement == MOVEMENT_ACCELERATES)
			{
				// By default these are zero anyway, so it's safe to set like this
				_entity.acceleration.x = _gravityX;
				_entity.acceleration.y = _gravityY;
			}
		}
		
		// Rotation
		if (_isRotating)
		{
			if (_rotationStopping == ROTATION_STOPPING_INSTANT)
			{
				if (_rotation == ROTATION_INSTANT)
				{
					_entity.angularVelocity = 0;
				}
				else if (_rotation == ROTATION_ACCELERATES)
				{
					_entity.angularAcceleration = 0;
				}
			}
			else if (_rotationStopping == ROTATION_STOPPING_DECELERATES)
			{
				if (_rotation == ROTATION_INSTANT)
				{
					_entity.angularVelocity = 0;
				}
			}
			
			var hasRotatedAntiClockwise:Bool = false;
			var hasRotatedClockwise:Bool = false;
			
			hasRotatedAntiClockwise = moveAntiClockwise();
			
			if (hasRotatedAntiClockwise == false)
			{
				hasRotatedClockwise = moveClockwise();
			}
			
			if (_rotationStopping == ROTATION_STOPPING_DECELERATES)
			{
				if (_rotation == ROTATION_ACCELERATES && hasRotatedAntiClockwise == false && hasRotatedClockwise == false)
				{
					_entity.angularAcceleration = 0;
				}
			}
			
			// If they have got instant stopping with acceleration and are NOT pressing a key, then stop the rotation. Otherwise we let it carry on
			if (_rotationStopping == ROTATION_STOPPING_INSTANT && _rotation == ROTATION_ACCELERATES && hasRotatedAntiClockwise == false && hasRotatedClockwise == false)
			{
				_entity.angularVelocity = 0;
				_entity.angularAcceleration = 0;
			}
		}
		
		// Thrust
		if (_thrustEnabled || _reverseEnabled)
		{
			var moved:Bool = false;
			
			if (_thrustEnabled)
			{
				moved = moveThrust();
			}
			
			if (moved == false && _reverseEnabled)
			{
				moved = moveReverse();
			}
		}
		else
		{
			var movedX:Bool = false;
			var movedY:Bool = false;
			
			if (_up)
			{
				movedY = moveUp();
			}
			
			if (_down && movedY == false)
			{
				movedY = moveDown();
			}
			
			if (_left)
			{
				movedX = moveLeft();
			}
			
			if (_right && movedX == false)
			{
				movedX = moveRight();
			}
		}
		
		if (_fire)
		{
			runFire();
		}
		
		if (_jump)
		{
			runJump();
		}
		
		if (_capVelocity)
		{
			if (_entity.velocity.x > _entity.maxVelocity.x)
			{
				_entity.velocity.x = _entity.maxVelocity.x;
			}
			
			if (_entity.velocity.y > _entity.maxVelocity.y)
			{
				_entity.velocity.y = _entity.maxVelocity.y;
			}
		}
		
		if (_walkSound != null)
		{
			if ((_movement == MOVEMENT_INSTANT && _entity.velocity.x != 0) || (_movement == MOVEMENT_ACCELERATES && _entity.acceleration.x != 0))
			{
				_walkSound.play(false);
			}
			else
			{
				_walkSound.stop();
			}
		}
	}
	
	/**
	 * Sets Custom Key controls. Useful if none of the pre-defined sets work. All String values should be taken from flixel.system.input.Keyboard
	 * Pass a blank (empty) String to disable that key from being checked.
	 * 
	 * @param	CustomUpKey		The String to use for the Up key.
	 * @param	CustomDownKey	The String to use for the Down key.
	 * @param	CustomLeftKey	The String to use for the Left key.
	 * @param	CustomRightKey	The String to use for the Right key.
	 */
	public function setCustomKeys(CustomUpKey:String, CustomDownKey:String, CustomLeftKey:String, CustomRightKey:String):Void
	{
		if (CustomUpKey != "")
		{
			_up = true;
			_upKey = CustomUpKey;
		}
		
		if (CustomDownKey != "")
		{
			_down = true;
			_downKey = CustomDownKey;
		}
		
		if (CustomLeftKey != "")
		{
			_left = true;
			_leftKey = CustomLeftKey;
		}
		
		if (CustomRightKey != "")
		{
			_right = true;
			_rightKey = CustomRightKey;
		}
	}
	
	/**
	 * Enables Cursor/Arrow Key controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
	 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
	 * 
	 * @param	AllowUp		Enable the UP key
	 * @param	AllowDown	Enable the DOWN key
	 * @param	AllowLeft	Enable the LEFT key
	 * @param	AllowRight	Enable the RIGHT key
	 */
	public function setCursorControl(AllowUp:Bool = true, AllowDown:Bool = true, AllowLeft:Bool = true, AllowRight:Bool = true):Void
	{
		_up = AllowUp;
		_down = AllowDown;
		_left = AllowLeft;
		_right = AllowRight;
		
		_upKey = "UP";
		_downKey = "DOWN";
		_leftKey = "LEFT";
		_rightKey = "RIGHT";
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
	public function setWASDControl(AllowUp:Bool = true, AllowDown:Bool = true, AllowLeft:Bool = true, AllowRight:Bool = true):Void
	{
		_up = AllowUp;
		_down = AllowDown;
		_left = AllowLeft;
		_right = AllowRight;
		
		_upKey = "W";
		_downKey = "S";
		_leftKey = "A";
		_rightKey = "D";
	}
	
	/**
	 * Enables ESDF (home row) controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
	 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
	 * 
	 * @param	AllowUp		Enable the up (E) key
	 * @param	AllowDown	Enable the down (D) key
	 * @param	AllowLeft	Enable the left (S) key
	 * @param	AllowRight	Enable the right (F) key
	 */
	public function setESDFControl(AllowUp:Bool = true, AllowDown:Bool = true, AllowLeft:Bool = true, AllowRight:Bool = true):Void
	{
		_up = AllowUp;
		_down = AllowDown;
		_left = AllowLeft;
		_right = AllowRight;
		
		_upKey = "E";
		_downKey = "D";
		_leftKey = "S";
		_rightKey = "F";
	}
	
	/**
	 * Enables IJKL (right-sided or secondary player) controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
	 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
	 * 
	 * @param	AllowUp		Enable the up (I) key
	 * @param	AllowDown	Enable the down (K) key
	 * @param	AllowLeft	Enable the left (J) key
	 * @param	AllowRight	Enable the right (L) key
	 */
	public function setIJKLControl(AllowUp:Bool = true, AllowDown:Bool = true, AllowLeft:Bool = true, AllowRight:Bool = true):Void
	{
		_up = AllowUp;
		_down = AllowDown;
		_left = AllowLeft;
		_right = AllowRight;
		
		_upKey = "I";
		_downKey = "K";
		_leftKey = "J";
		_rightKey = "L";
	}
	
	/**
	 * Enables HJKL (Rogue / Net-Hack) controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
	 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
	 * 
	 * @param	AllowUp		Enable the up (K) key
	 * @param	AllowDown	Enable the down (J) key
	 * @param	AllowLeft	Enable the left (H) key
	 * @param	AllowRight	Enable the right (L) key
	 */
	public function setHJKLControl(AllowUp:Bool = true, AllowDown:Bool = true, AllowLeft:Bool = true, AllowRight:Bool = true):Void
	{
		_up = AllowUp;
		_down = AllowDown;
		_left = AllowLeft;
		_right = AllowRight;
		
		_upKey = "K";
		_downKey = "J";
		_leftKey = "H";
		_rightKey = "L";
	}
	
	/**
	 * Enables ZQSD (Azerty keyboard) controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
	 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
	 * 
	 * @param	AllowUp		Enable the up (Z) key
	 * @param	AllowDown	Enable the down (Q) key
	 * @param	AllowLeft	Enable the left (S) key
	 * @param	AllowRight	Enable the right (D) key
	 */
	public function setZQSDControl(AllowUp:Bool = true, AllowDown:Bool = true, AllowLeft:Bool = true, AllowRight:Bool = true):Void
	{
		_up = AllowUp;
		_down = AllowDown;
		_left = AllowLeft;
		_right = AllowRight;
		
		_upKey = "Z";
		_downKey = "S";
		_leftKey = "Q";
		_rightKey = "D";
	}
	
	/**
	 * Enables Dvoark Simplified Controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.<br>
	 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
	 * 
	 * @param	AllowUp		Enable the up (COMMA) key
	 * @param	AllowDown	Enable the down (A) key
	 * @param	AllowLeft	Enable the left (O) key
	 * @param	AllowRight	Enable the right (E) key
	 */
	public function setDvorakSimplifiedControl(AllowUp:Bool = true, AllowDown:Bool = true, AllowLeft:Bool = true, AllowRight:Bool = true):Void
	{
		_up = AllowUp;
		_down = AllowDown;
		_left = AllowLeft;
		_right = AllowRight;
		
		_upKey = "COMMA";
		_downKey = "O";
		_leftKey = "A";
		_rightKey = "E";
	}
	
	/**
	 * Enables Numpad (left-handed) Controls. Can be set on a per-key basis. Useful if you only want to allow a few keys.
	 * For example in a Space Invaders game you'd only enable LEFT and RIGHT.
	 * 
	 * @param	AllowUp		Enable the up (NUMPADEIGHT) key
	 * @param	AllowDown	Enable the down (NUMPADTWO) key
	 * @param	AllowLeft	Enable the left (NUMPADFOUR) key
	 * @param	AllowRight	Enable the right (NUMPADSIX) key
	 */
	public function setNumpadControl(AllowUp:Bool = true, AllowDown:Bool = true, AllowLeft:Bool = true, AllowRight:Bool = true):Void
	{
		_up = AllowUp;
		_down = AllowDown;
		_left = AllowLeft;
		_right = AllowRight;
		
		_upKey = "NUMPADEIGHT";
		_downKey = "NUMPADTWO";
		_leftKey = "NUMPADFOUR";
		_rightKey = "NUMPADSIX";
	}
}