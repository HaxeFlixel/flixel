package flixel;

import flash.display.Graphics;
import flixel.FlxBasic;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxCollisionType;
import flixel.system.layer.frames.FlxSpriteFrames;
import flixel.system.layer.Region;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import flixel.util.FlxVelocity;
import flixel.util.loaders.CachedGraphics;

/**
 * This is the base class for most of the display objects (FlxSprite, FlxText, etc).
 * It includes some basic attributes about game objects, basic state information, sizes, scrolling, and basic physics and motion.
 */

class FlxObject extends FlxBasic
{
	/**
	 * This value dictates the maximum number of pixels two objects have to intersect before collision stops trying to separate them.
	 * Don't modify this unless your objects are passing through eachother.
	 */
	public static var SEPARATE_BIAS:Float = 4;
	/**
	 * Generic value for "left" Used by facing, allowCollisions, and touching.
	 */
	public static inline var LEFT:Int	= 0x0001;
	/**
	 * Generic value for "right" Used by facing, allowCollisions, and touching.
	 */
	public static inline var RIGHT:Int	= 0x0010;
	/**
	 * Generic value for "up" Used by facing, allowCollisions, and touching.
	 */
	public static inline var UP:Int		= 0x0100;
	/**
	 * Generic value for "down" Used by facing, allowCollisions, and touching.
	 */
	public static inline var DOWN:Int	= 0x1000;
	/**
	 * Special-case constant meaning no collisions, used mainly by allowCollisions and touching.
	 */
	public static inline var NONE:Int	= 0;
	/**
	 * Special-case constant meaning up, used mainly by allowCollisions and touching.
	 */
	public static inline var CEILING:Int= UP;
	/**
	 * Special-case constant meaning down, used mainly by allowCollisions and touching.
	 */
	public static inline var FLOOR:Int	= DOWN;
	/**
	 * Special-case constant meaning only the left and right sides, used mainly by allowCollisions and touching.
	 */
	public static inline var WALL:Int	= LEFT | RIGHT;
	/**
	 * Special-case constant meaning any direction, used mainly by allowCollisions and touching.
	 */
	public static inline var ANY:Int	= LEFT | RIGHT | UP | DOWN;
	/**
	 * X position of the upper left corner of this object in world space.
	 */
	public var x(default, set):Float = 0;
	/**
	 * Y position of the upper left corner of this object in world space.
	 */
	public var y(default, set):Float = 0;
	/**
	 * The width of this object's hitbox. For sprites, use offset to control the hitbox position.
	 */
	@:isVar public var width(get, set):Float;
	/**
	 * The height of this object's hitbox. For sprites, use offset to control the hitbox position.
	 */
	@:isVar public var height(get, set):Float;
	/**
	 * Set the angle of a sprite to rotate it. WARNING: rotating sprites decreases rendering
	 * performance for this sprite by a factor of 10x (in Flash target)!
	 */
	public var angle(default, set):Float = 0;
	/**
	 * Set this to false if you want to skip the automatic motion/movement stuff (see updateMotion()).
	 * FlxObject and FlxSprite default to true. FlxText, FlxTileblock and FlxTilemap default to false.
	 */
	public var moves(default, set):Bool = true;
	/**
	 * Whether an object will move/alter position after a collision.
	 */
	public var immovable(default, set):Bool = false;
	/**
	 * Whether the object collides or not.  For more control over what directions the object will collide from, 
	 * use collision constants (like LEFT, FLOOR, etc) to set the value of allowCollisions directly.
	 */
	public var solid(get, set):Bool;
	/**
	 * Whether the object should use complex render on flash target (which uses draw() method) or not.
	 * WARNING: setting forceComplexRender to true decreases rendering performance for this object by a factor of 10x!
	 * @default false
	 */
	public var forceComplexRender(default, set):Bool = false;
	/**
	 * Controls how much this object is affected by camera scrolling. 0 = no movement (e.g. a background layer), 
	 * 1 = same movement speed as the foreground. Default value is (1,1), except for UI elements like FlxButton where it's (0,0).
	 */
	public var scrollFactor(default, null):FlxPoint;
	/**
	 * The basic speed of this object (in pixels per second).
	 */
	public var velocity(default, null):FlxPoint;
	/**
	 * How fast the speed of this object is changing (in pixels per second).
	 * Useful for smooth movement and gravity.
	 */
	public var acceleration(default, null):FlxPoint;
	/**
	 * This isn't drag exactly, more like deceleration that is only applied
	 * when acceleration is not affecting the sprite.
	 */
	public var drag(default, null):FlxPoint;
	/**
	 * If you are using acceleration, you can use maxVelocity with it
	 * to cap the speed automatically (very useful!).
	 */
	public var maxVelocity(default, null):FlxPoint;
	/**
	 * The virtual mass of the object. Default value is 1. Currently only used with elasticity 
	 * during collision resolution. Change at your own risk; effects seem crazy unpredictable so far!
	 */
	public var mass:Float = 1;
	/**
	 * The bounciness of this object. Only affects collisions. Default value is 0, or "not bouncy at all."
	 */
	public var elasticity:Float = 0;
	/**
	 * This is how fast you want this sprite to spin (in degrees per second).
	 */
	public var angularVelocity:Float = 0;
	/**
	 * How fast the spin speed should change (in degrees per second).
	 */
	public var angularAcceleration:Float = 0;
	/**
	 * Like drag but for spinning.
	 */
	public var angularDrag:Float = 0;
	/**
	 * Use in conjunction with angularAcceleration for fluid spin speed control.
	 */
	public var maxAngular:Float = 10000;
	/**
	 * Handy for storing health percentage or armor points or whatever.
	 */
	public var health:Float = 1;
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts. Use bitwise operators to check the values 
	 * stored here, or use isTouching(), justTouched(), etc. You can even use them broadly as boolean values if you're feeling saucy!
	 */
	public var touching:Int = NONE;
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts from the previous game loop step. Use bitwise operators to check the values 
	 * stored here, or use isTouching(), justTouched(), etc. You can even use them broadly as boolean values if you're feeling saucy!
	 */
	public var wasTouching:Int = NONE;
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating collision directions. Use bitwise operators to check the values stored here.
	 * Useful for things like one-way platforms (e.g. allowCollisions = UP;). The accessor "solid" just flips this variable between NONE and ANY.
	 */
	public var allowCollisions:Int = ANY;
	/**
	 * Important variable for collision processing.
	 * By default this value is set automatically during preUpdate().
	 */
	public var last(default, null):FlxPoint;
	/**
	 * Whether this sprite is dragged along with the horizontal movement of objects it collides with 
	 * (makes sense for horizontally-moving platforms in platformers for example).
	 */
	public var collisonXDrag:Bool = true;
	/**
	 * Rendering variables.
	 */
	public var region(default, null):Region;
	public var framesData(default, null):FlxSpriteFrames;
	public var cachedGraphics(default, set):CachedGraphics;
	/**
	 * Internal private static variables, for performance reasons.
	 */
	private var _point:FlxPoint;
	private static var _pZero:FlxPoint = new FlxPoint(); // Should always represent (0,0) - useful for avoiding unnecessary new calls.
	private static var _firstSeparateFlxRect:FlxRect = new FlxRect();
	private static var _secondSeparateFlxRect:FlxRect = new FlxRect();
	
	/**
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @param	Width	Desired width of the rectangle.
	 * @param	Height	Desired height of the rectangle.
	 */
	public function new(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0)
	{
		super();
		
		x = X;
		y = Y;
		width = Width;
		height = Height;
		
		initVars();
	}
	
	/**
	 * Internal function for initialization of some object's variables
	 */
	private function initVars():Void
	{
		collisionType = FlxCollisionType.OBJECT;
		last = new FlxPoint(x, y);
		scrollFactor = new FlxPoint(1, 1);
		_point = new FlxPoint();
		
		initMotionVars();
	}
	
	/**
	 * Internal function for initialization of some variables that are used in updateMotion()
	 */
	private inline function initMotionVars():Void
	{
		velocity = new FlxPoint();
		acceleration = new FlxPoint();
		drag = new FlxPoint();
		maxVelocity = new FlxPoint(10000, 10000);
	}
	
	/**
	 * WARNING: This will remove this object entirely. Use kill() if you want to disable it temporarily only and reset() it later to revive it.
	 * Override this function to null out variables manually or call destroy() on class members if necessary. Don't forget to call super.destroy()!
	 */
	override public function destroy():Void
	{
		super.destroy();
		
		velocity = null;
		acceleration = null;
		drag = null;
		maxVelocity = null;
		scrollFactor = null;
		last = null;
		_point = null;
		scrollFactor = null;
		
		framesData = null;
		cachedGraphics = null;
		region = null;
	}
	
	/**
	 * Override this function to update your class's position and appearance.
	 * This is where most of your game rules and behavioral code will go.
	 */
	override public function update():Void 
	{
		#if !FLX_NO_DEBUG
		FlxBasic._ACTIVECOUNT++;
		#end
		
		last.x = x;
		last.y = y;
		
		if (moves)
		{
			updateMotion();
		}
		
		wasTouching = touching;
		touching = NONE;
	}
	
	/**
	 * Internal function for updating the position and speed of this object. Useful for cases when you need to update this but are buried down in too many supers.
	 * Does a slightly fancier-than-normal integration to help with higher fidelity framerate-independenct motion.
	 */
	private inline function updateMotion():Void
	{
		var delta:Float;
		var velocityDelta:Float;
		
		var dt:Float = FlxG.elapsed;
		
		velocityDelta = 0.5 * (FlxVelocity.computeVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngular) - angularVelocity);
		angularVelocity += velocityDelta; 
		angle += angularVelocity * dt;
		angularVelocity += velocityDelta;
		
		velocityDelta = 0.5 * (FlxVelocity.computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x) - velocity.x);
		velocity.x += velocityDelta;
		delta = velocity.x * dt;
		velocity.x += velocityDelta;
		x += delta;
		
		velocityDelta = 0.5 * (FlxVelocity.computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y) - velocity.y);
		velocity.y += velocityDelta;
		delta = velocity.y * dt;
		velocity.y += velocityDelta;
		y += delta;
	}
	
	/**
	 * Rarely called, and in this case just increments the visible objects count and calls drawDebug() if necessary.
	 */
	override public function draw():Void
	{
		for (camera in cameras)
		{
			if (camera.visible && camera.exists && isOnScreen(camera))
			{
				#if !FLX_NO_DEBUG
				FlxBasic._VISIBLECOUNT++;
				#end
			}
		}
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Override this function to draw custom "debug mode" graphics to the
	 * specified camera while the debugger's visual mode is toggled on.
	 * 
	 * @param	Camera	Which camera to draw the debug visuals to.
	 */
	override public function drawDebugOnCamera(?Camera:FlxCamera):Void
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		if (!Camera.visible || !Camera.exists || !isOnScreen(Camera))
		{
			return;
		}

		//get bounding box coordinates
		var boundingBoxX:Float = x - (Camera.scroll.x * scrollFactor.x); //copied from getScreenXY()
		var boundingBoxY:Float = y - (Camera.scroll.y * scrollFactor.y);
		#if flash
		var boundingBoxWidth:Int = Std.int(width);
		var boundingBoxHeight:Int = Std.int(height);
		#end
		
		if (allowCollisions != FlxObject.NONE && !_boundingBoxColorOverritten)
		{
			if (allowCollisions != ANY)
			{
				debugBoundingBoxColor = FlxColor.PINK;
			}
			if (immovable)
			{
				debugBoundingBoxColor = FlxColor.GREEN;
			}
			else
			{
				debugBoundingBoxColor = FlxColor.RED;
			}
		}
		else if (!_boundingBoxColorOverritten)
		{
			debugBoundingBoxColor = FlxColor.BLUE;
		}
		
		//fill static graphics object with square shape
		#if flash
		var gfx:Graphics = FlxSpriteUtil.flashGfx;
		gfx.clear();
		gfx.moveTo(boundingBoxX, boundingBoxY);
		gfx.lineStyle(1, debugBoundingBoxColor, 0.5);
		gfx.lineTo(boundingBoxX + boundingBoxWidth, boundingBoxY);
		gfx.lineTo(boundingBoxX + boundingBoxWidth, boundingBoxY + boundingBoxHeight);
		gfx.lineTo(boundingBoxX, boundingBoxY + boundingBoxHeight);
		gfx.lineTo(boundingBoxX, boundingBoxY);
		//draw graphics shape to camera buffer
		Camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		#else
		var gfx:Graphics = Camera.debugLayer.graphics;
		gfx.lineStyle(1, debugBoundingBoxColor, 0.5);
		gfx.drawRect(boundingBoxX, boundingBoxY, width, height);
		#end
	}
	#end
	
	/**
	 * Checks to see if some FlxObject overlaps this FlxObject or FlxGroup. If the group has a LOT of things in it, 
	 * it might be faster to use FlxG.overlaps(). WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * @param	ObjectOrGroup	The object or group being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.  Default is false, or "only compare in world space."
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	public function overlaps(ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (ObjectOrGroup.collisionType == FlxCollisionType.SPRITEGROUP)
		{
			ObjectOrGroup = Reflect.field(ObjectOrGroup, "group");
		}
		
		if (ObjectOrGroup.collisionType == FlxCollisionType.GROUP)
		{
			var results:Bool = false;
			var i:Int = 0;
			var basic:FlxBasic;
			var grp:FlxTypedGroup<FlxBasic> = cast ObjectOrGroup;
			var members:Array<FlxBasic> = grp.members;
			while (i < grp.length)
			{
				basic = members[i++];
				if (basic != null && basic.exists && overlaps(basic, InScreenSpace, Camera))
				{
					results = true;
					break;
				}
			}
			return results;
		}
		
		if (ObjectOrGroup.collisionType == FlxCollisionType.TILEMAP)
		{
			//Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			return cast(ObjectOrGroup, FlxTilemap).overlaps(this, InScreenSpace, Camera);
		}
		
		var object:FlxObject = cast(ObjectOrGroup, FlxObject);
		if (!InScreenSpace)
		{
			return	(object.x + object.width > x) && (object.x < x + width) &&
					(object.y + object.height > y) && (object.y < y + height);
		}

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenXY(null, Camera);
		getScreenXY(_point, Camera);
		return	(objectScreenPos.x + object.width > _point.x) && (objectScreenPos.x < _point.x + width) &&
				(objectScreenPos.y + object.height > _point.y) && (objectScreenPos.y < _point.y + height);
	}
	
	/**
	 * Checks to see if this FlxObject were located at the given position, would it overlap the FlxObject or FlxGroup?
	 * This is distinct from overlapsPoint(), which just checks that point, rather than taking the object's size into account. WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * @param	X				The X position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	Y				The Y position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	ObjectOrGroup	The object or group being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.  Default is false, or "only compare in world space."
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	public function overlapsAt(X:Float, Y:Float, ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (ObjectOrGroup.collisionType == FlxCollisionType.SPRITEGROUP)
		{
			ObjectOrGroup = Reflect.field(ObjectOrGroup, "group");
		}
		
		if (ObjectOrGroup.collisionType == FlxCollisionType.GROUP)
		{
			var results:Bool = false;
			var basic:FlxBasic;
			var i:Int = 0;
			var grp:FlxTypedGroup<FlxBasic> = cast ObjectOrGroup;
			var members:Array<FlxBasic> = grp.members;
			while (i < Std.int(grp.length))
			{
				basic = members[i++];
				if (basic != null && basic.exists && overlapsAt(X, Y, basic, InScreenSpace, Camera))
				{
					results = true;
					break;
				}
			}
			return results;
		}
		
		if (ObjectOrGroup.collisionType == FlxCollisionType.TILEMAP)
		{
			//Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			//However, since this is overlapsAt(), we also have to invent the appropriate position for the tilemap.
			//So we calculate the offset between the player and the requested position, and subtract that from the tilemap.
			var tilemap:FlxTilemap = cast(ObjectOrGroup, FlxTilemap);
			return tilemap.overlapsAt(tilemap.x - (X - x), tilemap.y - (Y - y), this, InScreenSpace, Camera);
		}
		
		var object:FlxObject = cast(ObjectOrGroup, FlxObject);
		if (!InScreenSpace)
		{
			return	(object.x + object.width > X) && (object.x < X + width) &&
					(object.y + object.height > Y) && (object.y < Y + height);
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenXY(null, Camera);
		getScreenXY(_point, Camera);
		return	(objectScreenPos.x + object.width > _point.x) && (objectScreenPos.x < _point.x + width) &&
			(objectScreenPos.y + object.height > _point.y) && (objectScreenPos.y < _point.y + height);
	}
	
	/**
	 * Checks to see if a point in 2D world space overlaps this FlxObject object.
	 * @param	Point			The point in world space you want to check.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	public function overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (!InScreenSpace)
		{
			return (point.x > x) && (point.x < x + width) && (point.y > y) && (point.y < y + height);
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var X:Float = point.x - Camera.scroll.x;
		var Y:Float = point.y - Camera.scroll.y;
		getScreenXY(_point, Camera);
		return (X > _point.x) && (X < _point.x + width) && (Y > _point.y) && (Y < _point.y + height);
	}
	
	/**
	 * Check and see if this object is currently within the Worldbounds - useful for killing objects that get too far away.
	 * @return	Whether the object is within the Worldbounds or not.
	 */
	public inline function inWorldBounds():Bool
	{
		return (x + width > FlxG.worldBounds.x) && (x < FlxG.worldBounds.right) && (y + height > FlxG.worldBounds.y) && (y < FlxG.worldBounds.bottom);
	}
	
	/**
	 * Call this function to figure out the on-screen position of the object.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @param	Point		Takes a FlxPoint object and assigns the post-scrolled X and Y values of this object to it.
	 * @return	The Point you passed in, or a new Point if you didn't pass one, containing the screen X and Y position of this object.
	 */
	public function getScreenXY(?point:FlxPoint, ?Camera:FlxCamera):FlxPoint
	{
		if (point == null)
		{
			point = new FlxPoint();
		}
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		return point.set(x - (Camera.scroll.x * scrollFactor.x), y - (Camera.scroll.y * scrollFactor.y));
	}
	
	/**
	 * Retrieve the midpoint of this object in world coordinates.
	 * @param	point	Allows you to pass in an existing FlxPoint object if you're so inclined.  Otherwise a new one is created.
	 * @return	A FlxPoint object containing the midpoint of this object in world coordinates.
	 */
	public function getMidpoint(?point:FlxPoint):FlxPoint
	{
		if (point == null)
		{
			point = new FlxPoint();
		}
		return point.set(x + width * 0.5, y + height * 0.5);
	}
	
	/**
	 * Handy function for reviving game objects.
	 * Resets their existence flags and position.
	 * @param	X	The new X position of this object.
	 * @param	Y	The new Y position of this object.
	 */
	public function reset(X:Float, Y:Float):Void
	{
		revive();
		touching = NONE;
		wasTouching = NONE;
		setPosition(X, Y);
		last.set(x, y);
		velocity.set();
	}
	
	/**
	 * Check and see if this object is currently on screen.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * 
	 * @return	Whether the object is on screen or not.
	 */
	public function isOnScreen(?Camera:FlxCamera):Bool
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		getScreenXY(_point, Camera);
		return (_point.x + width > 0) && (_point.x < Camera.width) && (_point.y + height > 0) && (_point.y < Camera.height);
	}
	
	/**
	 * Handy function for checking if this object is touching a particular surface.
	 * @param	Direction	Any of the collision flags (e.g. LEFT, FLOOR, etc).
	 * @return	Whether the object is touching an object in (any of) the specified direction(s) this frame.
	 */
	public inline function isTouching(Direction:Int):Bool
	{
		return (touching & Direction) > NONE;
	}
	
	/**
	 * Handy function for checking if this object is just landed on a particular surface.
	 * @param	Direction	Any of the collision flags (e.g. LEFT, FLOOR, etc).
	 * @return	Whether the object just landed on (any of) the specified surface(s) this frame.
	 */
	public inline function justTouched(Direction:Int):Bool
	{
		return ((touching & Direction) > NONE) && ((wasTouching & Direction) <= NONE);
	}
	
	/**
	 * Reduces the "health" variable of this sprite by the amount specified in Damage.
	 * Calls kill() if health drops to or below zero.
	 * @param	Damage		How much health to take away (use a negative number to give a health bonus).
	 */
	public function hurt(Damage:Float):Void
	{
		health = health - Damage;
		if (health <= 0)
		{
			kill();
		}
	}
	
	/**
	 * The main collision resolution function in flixel.
	 * @param	Object1 	Any FlxObject.
	 * @param	Object2		Any other FlxObject.
	 * @return	Whether the objects in fact touched and were separated.
	 */
	public static function separate(Object1:FlxObject, Object2:FlxObject):Bool
	{
		var separatedX:Bool = separateX(Object1, Object2);
		var separatedY:Bool = separateY(Object1, Object2);
		return separatedX || separatedY;
	}
	
	/**
	 * The X-axis component of the object separation process.
	 * @param	Object1 	Any FlxObject.
	 * @param	Object2		Any other FlxObject.
	 * @return	Whether the objects in fact touched and were separated along the X axis.
	 */
	public static function separateX(Object1:FlxObject, Object2:FlxObject):Bool
	{
		//can't separate two immovable objects
		var obj1immovable:Bool = Object1.immovable;
		var obj2immovable:Bool = Object2.immovable;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}
		
		//If one of the objects is a tilemap, just pass it off.
		if (Object1.collisionType == FlxCollisionType.TILEMAP)
		{
			return cast(Object1, FlxTilemap).overlapsWithCallback(Object2, separateX);
		}
		if (Object2.collisionType == FlxCollisionType.TILEMAP)
		{
			return cast(Object2, FlxTilemap).overlapsWithCallback(Object1, separateX, true);
		}
		
		//First, get the two object deltas
		var overlap:Float = 0;
		var obj1delta:Float = Object1.x - Object1.last.x;
		var obj2delta:Float = Object2.x - Object2.last.x;
		
		if (obj1delta != obj2delta)
		{
			//Check if the X hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0)?obj1delta: -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0)?obj2delta: -obj2delta;
			
			var obj1rect:FlxRect = _firstSeparateFlxRect.set(Object1.x - ((obj1delta > 0)?obj1delta:0), Object1.last.y, Object1.width + ((obj1delta > 0)?obj1delta: -obj1delta), Object1.height);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(Object2.x - ((obj2delta > 0)?obj2delta:0), Object2.last.y, Object2.width + ((obj2delta > 0)?obj2delta: -obj2delta), Object2.height);
			
			if ((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS;
				
				//If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = Object1.x + Object1.width - Object2.x;
					if ((overlap > maxOverlap) || ((Object1.allowCollisions & RIGHT) == 0) || ((Object2.allowCollisions & LEFT) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= RIGHT;
						Object2.touching |= LEFT;
					}
				}
				else if (obj1delta < obj2delta)
				{
					overlap = Object1.x - Object2.width - Object2.x;
					if ((-overlap > maxOverlap) || ((Object1.allowCollisions & LEFT) == 0) || ((Object2.allowCollisions & RIGHT) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= LEFT;
						Object2.touching |= RIGHT;
					}
				}
			}
		}
		
		//Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var obj1v:Float = Object1.velocity.x;
			var obj2v:Float = Object2.velocity.x;
			
			if (!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				Object1.x = Object1.x - overlap;
				Object2.x += overlap;
				
				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass) / Object1.mass) * ((obj2v > 0)?1: -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass) / Object2.mass) * ((obj1v > 0)?1: -1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				Object1.velocity.x = average + obj1velocity * Object1.elasticity;
				Object2.velocity.x = average + obj2velocity * Object2.elasticity;
			}
			else if (!obj1immovable)
			{
				Object1.x = Object1.x - overlap;
				Object1.velocity.x = obj2v - obj1v * Object1.elasticity;
			}
			else if (!obj2immovable)
			{
				Object2.x += overlap;
				Object2.velocity.x = obj1v - obj2v * Object2.elasticity;
			}
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/**
	 * The Y-axis component of the object separation process.
	 * @param	Object1 	Any FlxObject.
	 * @param	Object2		Any other FlxObject.
	 * @return	Whether the objects in fact touched and were separated along the Y axis.
	 */
	public static function separateY(Object1:FlxObject, Object2:FlxObject):Bool
	{
		//can't separate two immovable objects
		var obj1immovable:Bool = Object1.immovable;
		var obj2immovable:Bool = Object2.immovable;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}
		
		//If one of the objects is a tilemap, just pass it off.
		if (Object1.collisionType == FlxCollisionType.TILEMAP)
		{
			return cast(Object1, FlxTilemap).overlapsWithCallback(Object2, separateY);
		}
		if (Object2.collisionType == FlxCollisionType.TILEMAP)
		{
			return cast(Object2, FlxTilemap).overlapsWithCallback(Object1, separateY, true);
		}

		//First, get the two object deltas
		var overlap:Float = 0;
		var obj1delta:Float = Object1.y - Object1.last.y;
		var obj2delta:Float = Object2.y - Object2.last.y;
		
		if (obj1delta != obj2delta)
		{
			//Check if the Y hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0)?obj1delta: -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0)?obj2delta: -obj2delta;
			
			var obj1rect:FlxRect = _firstSeparateFlxRect.set(Object1.x, Object1.y - ((obj1delta > 0)?obj1delta:0), Object1.width, Object1.height + obj1deltaAbs);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(Object2.x, Object2.y - ((obj2delta > 0)?obj2delta:0), Object2.width, Object2.height + obj2deltaAbs);
			
			if ((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS;
				
				//If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = Object1.y + Object1.height - Object2.y;
					if ((overlap > maxOverlap) || ((Object1.allowCollisions & DOWN) == 0) || ((Object2.allowCollisions & UP) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= DOWN;
						Object2.touching |= UP;
					}
				}
				else if (obj1delta < obj2delta)
				{
					overlap = Object1.y - Object2.height - Object2.y;
					if ((-overlap > maxOverlap) || ((Object1.allowCollisions & UP) == 0) || ((Object2.allowCollisions & DOWN) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= UP;
						Object2.touching |= DOWN;
					}
				}
			}
		}
		
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var obj1v:Float = Object1.velocity.y;
			var obj2v:Float = Object2.velocity.y;
			
			if (!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				Object1.y = Object1.y - overlap;
				Object2.y += overlap;
				
				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass)/Object1.mass) * ((obj2v > 0)?1:-1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass)/Object2.mass) * ((obj1v > 0)?1:-1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				Object1.velocity.y = average + obj1velocity * Object1.elasticity;
				Object2.velocity.y = average + obj2velocity * Object2.elasticity;
			}
			else if (!obj1immovable)
			{
				Object1.y = Object1.y - overlap;
				Object1.velocity.y = obj2v - obj1v*Object1.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object1.collisonXDrag && Object2.active && Object2.moves && (obj1delta > obj2delta))
				{
					Object1.x += Object2.x - Object2.last.x;
				}
			}
			else if (!obj2immovable)
			{
				Object2.y += overlap;
				Object2.velocity.y = obj1v - obj2v*Object2.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object2.collisonXDrag && Object1.active && Object1.moves && (obj1delta < obj2delta))
				{
					Object2.x += Object1.x - Object1.last.x;
				}
			}
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/**
	 * Helper function to set the coordinates of this object.
	 * Handy since it only requires one line of code.
	 * @param	X	The new x position
	 * @param	Y	The new y position
	 */
	public function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		x = X;
		y = Y;
	}
	
	/**
	 * Shortcut for setting both width and Height.
	 * @param	Width	The new sprite width.
	 * @param	Height	The new sprite height.
	 */
	public function setSize(Width:Float, Height:Float)
	{
		width = Width;
		height = Height;
	}
	
	/**
	 * Internal function for setting cachedGraphics property for this object. 
	 * It changes cachedGraphics' useCount also for better memory tracking.
	 * @param	value
	 */
	private function set_cachedGraphics(Value:CachedGraphics):CachedGraphics
	{
		var oldCached:CachedGraphics = cachedGraphics;
		
		if (cachedGraphics != Value && Value != null)
		{
			Value.useCount++;
		}
		
		if (oldCached != null && oldCached != Value)
		{
			oldCached.useCount--;
		}
		
		return cachedGraphics = Value;
	}
	
	/**
	 * Internal
	 */
	private function set_x(NewX:Float):Float
	{
		return x = NewX;
	}
	
	private function set_y(NewY:Float):Float
	{
		return y = NewY;
	}
	
	private function set_width(Width:Float):Float
	{
		#if !FLX_NO_DEBUG
		if (Width < 0) 
		{
			FlxG.log.warn("An object's width cannot be smaller than 0. Use offset for sprites to control the hitbox position!");
		}
		else
		{
		#end
			width = Width;
		#if !FLX_NO_DEBUG
		}
		#end
		
		return Width;
	}
	
	private function set_height(Height:Float):Float
	{
		#if !FLX_NO_DEBUG
		if (Height < 0) 
		{
			FlxG.log.warn("An object's height cannot be smaller than 0. Use offset for sprites to control the hitbox position!");
		}
		else
		{
		#end
			height = Height;
		#if !FLX_NO_DEBUG
		}
		#end
		
		return Height;
	}
	
	private function get_width():Float
	{
		return width;
	}
	
	private function get_height():Float
	{
		return height;
	}
	
	private inline function get_solid():Bool
	{
		return (allowCollisions & ANY) > NONE;
	}
	
	private function set_solid(Solid:Bool):Bool
	{
		if (Solid)
		{
			allowCollisions = ANY;
		}
		else
		{
			allowCollisions = NONE;
		}
		return Solid;
	}
	
	private function set_angle(Value:Float):Float
	{
		return angle = Value;
	}
	
	private function set_moves(Value:Bool):Bool
	{
		return moves = Value;
	}
	
	private function set_immovable(Value:Bool):Bool
	{
		return immovable = Value;
	}
	
	private function set_forceComplexRender(Value:Bool):Bool 
	{
		return forceComplexRender = Value;
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Overriding this will force a specific color to be used for debug rect.
	 */
	public var debugBoundingBoxColor(default, set):Int;
	
	private function set_debugBoundingBoxColor(Value:Int):Int 
	{
		_boundingBoxColorOverritten = true;
		return debugBoundingBoxColor = Value; 
	}
	
	private var _boundingBoxColorOverritten:Bool = false;
	#end
	
	/**
	 * Convert object to readable string name.  Useful for debugging, save games, etc.
	 */
	override public function toString():String
	{
		return FlxStringUtil.getDebugString([ { label: "x", value: x }, 
		                                      { label: "y", value: y },
		                                      { label: "w", value: width },
		                                      { label: "h", value: height },
		                                      { label: "visible", value: visible },
		                                      { label: "velocity", value: velocity }]);
	}
}
