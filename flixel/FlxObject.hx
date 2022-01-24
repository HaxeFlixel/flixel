package flixel;

import flash.display.Graphics;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVelocity;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxPath;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;

/**
 * This is the base class for most of the display objects (`FlxSprite`, `FlxText`, etc).
 * It includes some basic attributes about game objects, basic state information,
 * sizes, scrolling, and basic physics and motion.
 */
class FlxObject extends FlxBasic
{
	/**
	 * Default value for `FlxObject`'s `pixelPerfectPosition` var.
	 */
	public static var defaultPixelPerfectPosition:Bool = false;

	/**
	 * This value dictates the maximum number of pixels two objects have to intersect
	 * before collision stops trying to separate them.
	 * Don't modify this unless your objects are passing through each other.
	 */
	public static var SEPARATE_BIAS:Float = 4;

	/**
	 * Generic value for "left". Used by `facing`, `allowCollisions`, and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.LEFT` directly.
	 */
	public static inline var LEFT = FlxDirectionFlags.LEFT;

	/**
	 * Generic value for "right". Used by `facing`, `allowCollisions`, and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.RIGHT` directly.
	 */
	public static inline var RIGHT = FlxDirectionFlags.RIGHT;

	/**
	 * Generic value for "up". Used by `facing`, `allowCollisions`, and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.UP` directly.
	 */
	public static inline var UP = FlxDirectionFlags.UP;

	/**
	 * Generic value for "down". Used by `facing`, `allowCollisions`, and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.DOWN` directly.
	 */
	public static inline var DOWN = FlxDirectionFlags.DOWN;

	/**
	 * Special-case constant meaning no collisions, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.NONE` directly.
	 */
	public static inline var NONE = FlxDirectionFlags.NONE;

	/**
	 * Special-case constant meaning up, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.CEILING` directly.
	 */
	public static inline var CEILING = FlxDirectionFlags.CEILING;

	/**
	 * Special-case constant meaning down, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.FLOOR` directly.
	 */
	public static inline var FLOOR = FlxDirectionFlags.FLOOR;

	/**
	 * Special-case constant meaning only the left and right sides, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.WALL` directly.
	 */
	public static inline var WALL = FlxDirectionFlags.WALL;

	/**
	 * Special-case constant meaning any direction, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.ANY` directly.
	 */
	public static inline var ANY = FlxDirectionFlags.ANY;

	@:noCompletion
	static var _firstSeparateFlxRect:FlxRect = FlxRect.get();
	@:noCompletion
	static var _secondSeparateFlxRect:FlxRect = FlxRect.get();

	/**
	 * The main collision resolution function in Flixel.
	 *
	 * @param   Object1   Any `FlxObject`.
	 * @param   Object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched and were separated.
	 */
	public static function separate(Object1:FlxObject, Object2:FlxObject):Bool
	{
		var separatedX:Bool = separateX(Object1, Object2);
		var separatedY:Bool = separateY(Object1, Object2);
		return separatedX || separatedY;
	}

	/**
	 * Similar to `separate()`, but only checks whether any overlap is found and updates
	 * the `touching` flags of the input objects, but no separation is performed.
	 *
	 * @param   Object1   Any `FlxObject`.
	 * @param   Object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched.
	 */
	public static function updateTouchingFlags(Object1:FlxObject, Object2:FlxObject):Bool
	{
		var touchingX:Bool = updateTouchingFlagsX(Object1, Object2);
		var touchingY:Bool = updateTouchingFlagsY(Object1, Object2);
		return touchingX || touchingY;
	}

	/**
	 * Internal function that computes overlap among two objects on the X axis. It also updates the `touching` variable.
	 * `checkMaxOverlap` is used to determine whether we want to exclude (therefore check) overlaps which are
	 * greater than a certain maximum (linked to `SEPARATE_BIAS`). Default is `true`, handy for `separateX` code.
	 */
	@:noCompletion
	static function computeOverlapX(Object1:FlxObject, Object2:FlxObject, checkMaxOverlap:Bool = true):Float
	{
		var overlap:Float = 0;
		// First, get the two object deltas
		var obj1delta:Float = Object1.x - Object1.last.x;
		var obj2delta:Float = Object2.x - Object2.last.x;

		if (obj1delta != obj2delta)
		{
			// Check if the X hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0) ? obj1delta : -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0) ? obj2delta : -obj2delta;

			var obj1rect:FlxRect = _firstSeparateFlxRect.set(Object1.x - ((obj1delta > 0) ? obj1delta : 0), Object1.last.y, Object1.width + obj1deltaAbs,
				Object1.height);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(Object2.x - ((obj2delta > 0) ? obj2delta : 0), Object2.last.y, Object2.width + obj2deltaAbs,
				Object2.height);

			if ((obj1rect.x + obj1rect.width > obj2rect.x)
				&& (obj1rect.x < obj2rect.x + obj2rect.width)
				&& (obj1rect.y + obj1rect.height > obj2rect.y)
				&& (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = checkMaxOverlap ? (obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS) : 0;

				// If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = Object1.x + Object1.width - Object2.x;
					if ((checkMaxOverlap && (overlap > maxOverlap))
						|| ((Object1.allowCollisions & RIGHT) == 0)
						|| ((Object2.allowCollisions & LEFT) == 0))
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
					if ((checkMaxOverlap && (-overlap > maxOverlap))
						|| ((Object1.allowCollisions & LEFT) == 0)
						|| ((Object2.allowCollisions & RIGHT) == 0))
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
		return overlap;
	}

	/**
	 * The X-axis component of the object separation process.
	 *
	 * @param   Object1   Any `FlxObject`.
	 * @param   Object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched and were separated along the X axis.
	 */
	public static function separateX(Object1:FlxObject, Object2:FlxObject):Bool
	{
		// can't separate two immovable objects
		var obj1immovable:Bool = Object1.immovable;
		var obj2immovable:Bool = Object2.immovable;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}

		// If one of the objects is a tilemap, just pass it off.
		if (Object1.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object1;
			return tilemap.overlapsWithCallback(Object2, separateX);
		}
		if (Object2.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object2;
			return tilemap.overlapsWithCallback(Object1, separateX, true);
		}

		var overlap:Float = computeOverlapX(Object1, Object2);
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var obj1v:Float = Object1.velocity.x;
			var obj2v:Float = Object2.velocity.x;

			if (!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				Object1.x = Object1.x - overlap;
				Object2.x += overlap;

				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass) / Object1.mass) * ((obj2v > 0) ? 1 : -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass) / Object2.mass) * ((obj1v > 0) ? 1 : -1);
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

		return false;
	}

	/**
	 * Checking overlap and updating `touching` variables, X-axis part used by `updateTouchingFlags`.
	 *
	 * @param   Object1   Any `FlxObject`.
	 * @param   Object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched along the X axis.
	 */
	public static function updateTouchingFlagsX(Object1:FlxObject, Object2:FlxObject):Bool
	{
		// If one of the objects is a tilemap, just pass it off.
		if (Object1.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object1;
			return tilemap.overlapsWithCallback(Object2, updateTouchingFlagsX);
		}
		if (Object2.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object2;
			return tilemap.overlapsWithCallback(Object1, updateTouchingFlagsX, true);
		}
		// Since we are not separating, always return any amount of overlap => false as last parameter
		return computeOverlapX(Object1, Object2, false) != 0;
	}

	/**
	 * Internal function that computes overlap among two objects on the Y axis. It also updates the `touching` variable.
	 * `checkMaxOverlap` is used to determine whether we want to exclude (therefore check) overlaps which are
	 * greater than a certain maximum (linked to `SEPARATE_BIAS`). Default is `true`, handy for `separateY` code.
	 */
	@:noCompletion
	static function computeOverlapY(Object1:FlxObject, Object2:FlxObject, checkMaxOverlap:Bool = true):Float
	{
		var overlap:Float = 0;
		// First, get the two object deltas
		var obj1delta:Float = Object1.y - Object1.last.y;
		var obj2delta:Float = Object2.y - Object2.last.y;

		if (obj1delta != obj2delta)
		{
			// Check if the Y hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0) ? obj1delta : -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0) ? obj2delta : -obj2delta;

			var obj1rect:FlxRect = _firstSeparateFlxRect.set(Object1.x, Object1.y - ((obj1delta > 0) ? obj1delta : 0), Object1.width,
				Object1.height + obj1deltaAbs);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(Object2.x, Object2.y - ((obj2delta > 0) ? obj2delta : 0), Object2.width,
				Object2.height + obj2deltaAbs);

			if ((obj1rect.x + obj1rect.width > obj2rect.x)
				&& (obj1rect.x < obj2rect.x + obj2rect.width)
				&& (obj1rect.y + obj1rect.height > obj2rect.y)
				&& (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = checkMaxOverlap ? (obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS) : 0;

				// If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = Object1.y + Object1.height - Object2.y;
					if ((checkMaxOverlap && (overlap > maxOverlap))
						|| ((Object1.allowCollisions & DOWN) == 0)
						|| ((Object2.allowCollisions & UP) == 0))
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
					if ((checkMaxOverlap && (-overlap > maxOverlap))
						|| ((Object1.allowCollisions & UP) == 0)
						|| ((Object2.allowCollisions & DOWN) == 0))
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
		return overlap;
	}

	/**
	 * The Y-axis component of the object separation process.
	 *
	 * @param   Object1   Any `FlxObject`.
	 * @param   Object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched and were separated along the Y axis.
	 */
	public static function separateY(Object1:FlxObject, Object2:FlxObject):Bool
	{
		// can't separate two immovable objects
		var obj1immovable:Bool = Object1.immovable;
		var obj2immovable:Bool = Object2.immovable;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}

		// If one of the objects is a tilemap, just pass it off.
		if (Object1.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object1;
			return tilemap.overlapsWithCallback(Object2, separateY);
		}
		if (Object2.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object2;
			return tilemap.overlapsWithCallback(Object1, separateY, true);
		}

		var overlap:Float = computeOverlapY(Object1, Object2);
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var obj1delta:Float = Object1.y - Object1.last.y;
			var obj2delta:Float = Object2.y - Object2.last.y;
			var obj1v:Float = Object1.velocity.y;
			var obj2v:Float = Object2.velocity.y;

			if (!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				Object1.y = Object1.y - overlap;
				Object2.y += overlap;

				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass) / Object1.mass) * ((obj2v > 0) ? 1 : -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass) / Object2.mass) * ((obj1v > 0) ? 1 : -1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				Object1.velocity.y = average + obj1velocity * Object1.elasticity;
				Object2.velocity.y = average + obj2velocity * Object2.elasticity;
			}
			else if (!obj1immovable)
			{
				Object1.y = Object1.y - overlap;
				Object1.velocity.y = obj2v - obj1v * Object1.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object1.collisonXDrag && Object2.active && Object2.moves && (obj1delta > obj2delta))
				{
					Object1.x += Object2.x - Object2.last.x;
				}
			}
			else if (!obj2immovable)
			{
				Object2.y += overlap;
				Object2.velocity.y = obj1v - obj2v * Object2.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object2.collisonXDrag && Object1.active && Object1.moves && (obj1delta < obj2delta))
				{
					Object2.x += Object1.x - Object1.last.x;
				}
			}
			return true;
		}

		return false;
	}

	/**
	 * Checking overlap and updating touching variables, Y-axis part used by `updateTouchingFlags`.
	 *
	 * @param   Object1   Any `FlxObject`.
	 * @param   Object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched along the Y axis.
	 */
	public static function updateTouchingFlagsY(Object1:FlxObject, Object2:FlxObject):Bool
	{
		// If one of the objects is a tilemap, just pass it off.
		if (Object1.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object1;
			return tilemap.overlapsWithCallback(Object2, updateTouchingFlagsY);
		}
		if (Object2.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast Object2;
			return tilemap.overlapsWithCallback(Object1, updateTouchingFlagsY, true);
		}
		// Since we are not separating, always return any amount of overlap => false as last parameter
		return computeOverlapY(Object1, Object2, false) != 0;
	}

	/**
	 * X position of the upper left corner of this object in world space.
	 */
	public var x(default, set):Float = 0;

	/**
	 * Y position of the upper left corner of this object in world space.
	 */
	public var y(default, set):Float = 0;

	/**
	 * The width of this object's hitbox. For sprites, use `offset` to control the hitbox position.
	 */
	@:isVar
	public var width(get, set):Float;

	/**
	 * The height of this object's hitbox. For sprites, use `offset` to control the hitbox position.
	 */
	@:isVar
	public var height(get, set):Float;

	/**
	 * Whether or not the coordinates should be rounded during rendering.
	 * Does not affect `copyPixels()`, which can only render on whole pixels.
	 * Defaults to the camera's global `pixelPerfectRender` value,
	 * but overrides that value if not equal to `null`.
	 */
	public var pixelPerfectRender(default, set):Null<Bool>;

	/**
	 * Whether or not the position of this object should be rounded before any `draw()` or collision checking.
	 */
	public var pixelPerfectPosition:Bool = true;

	/**
	 * Set the angle (in degrees) of a sprite to rotate it. WARNING: rotating sprites
	 * decreases their rendering performance by a factor of ~10x when using blitting!
	 */
	public var angle(default, set):Float = 0;

	/**
	 * Set this to `false` if you want to skip the automatic motion/movement stuff (see `updateMotion()`).
	 * `FlxObject` and `FlxSprite` default to `true`. `FlxText`, `FlxTileblock` and `FlxTilemap` default to `false`.
	 */
	public var moves(default, set):Bool = true;

	/**
	 * Whether an object will move/alter position after a collision.
	 */
	public var immovable(default, set):Bool = false;

	/**
	 * Whether the object collides or not. For more control over what directions the object will collide from,
	 * use collision constants (like `LEFT`, `FLOOR`, etc) to set the value of `allowCollisions` directly.
	 */
	public var solid(get, set):Bool;

	/**
	 * Controls how much this object is affected by camera scrolling. `0` = no movement (e.g. a background layer),
	 * `1` = same movement speed as the foreground. Default value is `(1,1)`,
	 * except for UI elements like `FlxButton` where it's `(0,0)`.
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
	 * when `acceleration` is not affecting the sprite.
	 */
	public var drag(default, null):FlxPoint;

	/**
	 * If you are using `acceleration`, you can use `maxVelocity` with it
	 * to cap the speed automatically (very useful!).
	 */
	public var maxVelocity(default, null):FlxPoint;

	/**
	 * Important variable for collision processing.
	 * By default this value is set automatically during at the start of `update()`.
	 */
	public var last(default, null):FlxPoint;

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
	public var touching:FlxDirectionFlags = NONE;

	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts from the previous game loop step. Use bitwise operators to check the values
	 * stored here, or use isTouching(), justTouched(), etc. You can even use them broadly as boolean values if you're feeling saucy!
	 */
	public var wasTouching:FlxDirectionFlags = NONE;

	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating collision directions. Use bitwise operators to check the values stored here.
	 * Useful for things like one-way platforms (e.g. allowCollisions = UP;). The accessor "solid" just flips this variable between NONE and ANY.
	 */
	public var allowCollisions(default, set):FlxDirectionFlags = ANY;

	/**
	 * Whether this sprite is dragged along with the horizontal movement of objects it collides with
	 * (makes sense for horizontally-moving platforms in platformers for example).
	 */
	public var collisonXDrag:Bool = true;

	#if FLX_DEBUG
	/**
	 * Overriding this will force a specific color to be used for debug rect
	 * (ignoring any of the other debug bounding box colors specified).
	 */
	public var debugBoundingBoxColor:Null<FlxColor> = null;

	/**
	 * Color used for the debug rect if `allowCollisions == ANY`.
	 * @since 4.2.0
	 */
	public var debugBoundingBoxColorSolid(default, set):FlxColor = FlxColor.RED;

	/**
	 * Color used for the debug rect if `allowCollisions == NONE`.
	 * @since 4.2.0
	 */
	public var debugBoundingBoxColorNotSolid(default, set):FlxColor = FlxColor.BLUE;

	/**
	 * Color used for the debug rect if this object collides partially
	 * (`immovable` in the case of `FlxObject`, or `allowCollisions` not equal to
	 * `ANY` or `NONE` in the case of tiles in `FlxTilemap`).
	 * @since 4.2.0
	 */
	public var debugBoundingBoxColorPartial(default, set):FlxColor = FlxColor.GREEN;

	/**
	 * Setting this to `true` will prevent the object from appearing
	 * when `FlxG.debugger.drawDebug` is `true`.
	 */
	public var ignoreDrawDebug:Bool = false;
	#end

	/**
	 * The path this object follows. Not initialized by default.
	 * Assign a `new FlxPath()` object and `start()` it if you want to this object to follow a path.
	 * Set `path` to `null` again to stop following the path.
	 * See `flixel.util.FlxPath` for more info and usage examples.
	 */
	public var path(default, set):FlxPath = null;

	@:noCompletion
	var _point:FlxPoint = FlxPoint.get();
	@:noCompletion
	var _rect:FlxRect = FlxRect.get();

	/**
	 * @param   X        The X-coordinate of the point in space.
	 * @param   Y        The Y-coordinate of the point in space.
	 * @param   Width    Desired width of the rectangle.
	 * @param   Height   Desired height of the rectangle.
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
	 * Internal function for initialization of some object's variables.
	 */
	@:noCompletion
	function initVars():Void
	{
		flixelType = OBJECT;
		last = FlxPoint.get(x, y);
		scrollFactor = FlxPoint.get(1, 1);
		pixelPerfectPosition = FlxObject.defaultPixelPerfectPosition;

		initMotionVars();
	}

	/**
	 * Internal function for initialization of some variables that are used in `updateMotion()`.
	 */
	@:noCompletion
	inline function initMotionVars():Void
	{
		velocity = FlxPoint.get();
		acceleration = FlxPoint.get();
		drag = FlxPoint.get();
		maxVelocity = FlxPoint.get(10000, 10000);
	}

	/**
	 * **WARNING:** A destroyed `FlxBasic` can't be used anymore.
	 * It may even cause crashes if it is still part of a group or state.
	 * You may want to use `kill()` instead if you want to disable the object temporarily only and `revive()` it later.
	 *
	 * This function is usually not called manually (Flixel calls it automatically during state switches for all `add()`ed objects).
	 *
	 * Override this function to `null` out variables manually or call `destroy()` on class members if necessary.
	 * Don't forget to call `super.destroy()`!
	 */
	override public function destroy():Void
	{
		super.destroy();

		velocity = FlxDestroyUtil.put(velocity);
		acceleration = FlxDestroyUtil.put(acceleration);
		drag = FlxDestroyUtil.put(drag);
		maxVelocity = FlxDestroyUtil.put(maxVelocity);
		scrollFactor = FlxDestroyUtil.put(scrollFactor);
		last = FlxDestroyUtil.put(last);
		_point = FlxDestroyUtil.put(_point);
		_rect = FlxDestroyUtil.put(_rect);
	}

	/**
	 * Override this function to update your class's position and appearance.
	 * This is where most of your game rules and behavioral code will go.
	 */
	override public function update(elapsed:Float):Void
	{
		#if FLX_DEBUG
		// this just increments FlxBasic.activeCount, no need to waste a function call on release
		super.update(elapsed);
		#end

		last.set(x, y);

		if (path != null && path.active)
			path.update(elapsed);

		if (moves)
			updateMotion(elapsed);

		wasTouching = touching;
		touching = NONE;
	}

	/**
	 * Internal function for updating the position and speed of this object.
	 * Useful for cases when you need to update this but are buried down in too many supers.
	 * Does a slightly fancier-than-normal integration to help with higher fidelity framerate-independent motion.
	 */
	@:noCompletion
	function updateMotion(elapsed:Float):Void
	{
		var velocityDelta = 0.5 * (FlxVelocity.computeVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngular, elapsed) - angularVelocity);
		angularVelocity += velocityDelta;
		angle += angularVelocity * elapsed;
		angularVelocity += velocityDelta;

		velocityDelta = 0.5 * (FlxVelocity.computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x, elapsed) - velocity.x);
		velocity.x += velocityDelta;
		var delta = velocity.x * elapsed;
		velocity.x += velocityDelta;
		x += delta;

		velocityDelta = 0.5 * (FlxVelocity.computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y, elapsed) - velocity.y);
		velocity.y += velocityDelta;
		delta = velocity.y * elapsed;
		velocity.y += velocityDelta;
		y += delta;
	}

	/**
	 * Rarely called, and in this case just increments the visible objects count and calls `drawDebug()` if necessary.
	 */
	override public function draw():Void
	{
		#if FLX_DEBUG
		super.draw();
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	/**
	 * Checks to see if some `FlxObject` overlaps this `FlxObject` or `FlxGroup`.
	 * If the group has a LOT of things in it, it might be faster to use `FlxG.overlap()`.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 *
	 * @param   ObjectOrGroup   The object or group being tested.
	 * @param   InScreenSpace   Whether to take scroll factors into account when checking for overlap.
	 *                          Default is `false`, or "only compare in world space."
	 * @param   Camera          Specify which game camera you want.
	 *                          If `null`, it will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup)
	public function overlaps(ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(overlapsCallback, group, 0, 0, InScreenSpace, Camera);
		}

		if (ObjectOrGroup.flixelType == TILEMAP)
		{
			// Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			var tilemap:FlxBaseTilemap<Dynamic> = cast ObjectOrGroup;
			return tilemap.overlaps(this, InScreenSpace, Camera);
		}

		var object:FlxObject = cast ObjectOrGroup;
		if (!InScreenSpace)
		{
			return (object.x + object.width > x) && (object.x < x + width) && (object.y + object.height > y) && (object.y < y + height);
		}

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenPosition(null, Camera);
		getScreenPosition(_point, Camera);
		return (objectScreenPos.x + object.width > _point.x)
			&& (objectScreenPos.x < _point.x + width)
			&& (objectScreenPos.y + object.height > _point.y)
			&& (objectScreenPos.y < _point.y + height);
	}

	@:noCompletion
	inline function overlapsCallback(ObjectOrGroup:FlxBasic, X:Float, Y:Float, InScreenSpace:Bool, Camera:FlxCamera):Bool
	{
		return overlaps(ObjectOrGroup, InScreenSpace, Camera);
	}

	/**
	 * Checks to see if this `FlxObject` were located at the given position,
	 * would it overlap the `FlxObject` or `FlxGroup`?
	 * This is distinct from `overlapsPoint()`, which just checks that point,
	 * rather than taking the object's size into account.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 *
	 * @param   X               The X position you want to check.
	 *                          Pretends this object (the caller, not the parameter) is located here.
	 * @param   Y               The Y position you want to check.
	 *                          Pretends this object (the caller, not the parameter) is located here.
	 * @param   ObjectOrGroup   The object or group being tested.
	 * @param   InScreenSpace   Whether to take scroll factors into account when checking for overlap.
	 *                          Default is `false`, or "only compare in world space."
	 * @param   Camera          Specify which game camera you want.
	 *                          If `null`, it will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup)
	public function overlapsAt(X:Float, Y:Float, ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(overlapsAtCallback, group, X, Y, InScreenSpace, Camera);
		}

		if (ObjectOrGroup.flixelType == TILEMAP)
		{
			// Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			// However, since this is overlapsAt(), we also have to invent the appropriate position for the tilemap.
			// So we calculate the offset between the player and the requested position, and subtract that from the tilemap.
			var tilemap:FlxBaseTilemap<Dynamic> = cast ObjectOrGroup;
			return tilemap.overlapsAt(tilemap.x - (X - x), tilemap.y - (Y - y), this, InScreenSpace, Camera);
		}

		var object:FlxObject = cast ObjectOrGroup;
		if (!InScreenSpace)
		{
			return (object.x + object.width > X) && (object.x < X + width) && (object.y + object.height > Y) && (object.y < Y + height);
		}

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenPosition(null, Camera);
		getScreenPosition(_point, Camera);
		return (objectScreenPos.x + object.width > _point.x)
			&& (objectScreenPos.x < _point.x + width)
			&& (objectScreenPos.y + object.height > _point.y)
			&& (objectScreenPos.y < _point.y + height);
	}

	@:noCompletion
	inline function overlapsAtCallback(ObjectOrGroup:FlxBasic, X:Float, Y:Float, InScreenSpace:Bool, Camera:FlxCamera):Bool
	{
		return overlapsAt(X, Y, ObjectOrGroup, InScreenSpace, Camera);
	}

	/**
	 * Checks to see if a point in 2D world space overlaps this `FlxObject`.
	 *
	 * @param   Point           The point in world space you want to check.
	 * @param   InScreenSpace   Whether to take scroll factors into account when checking for overlap.
	 * @param   Camera          Specify which game camera you want.
	 *                          If `null`, it will just grab the first global camera.
	 * @return  Whether or not the point overlaps this object.
	 */
	public function overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (!InScreenSpace)
		{
			return (point.x >= x) && (point.x < x + width) && (point.y >= y) && (point.y < y + height);
		}

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var xPos:Float = point.x - Camera.scroll.x;
		var yPos:Float = point.y - Camera.scroll.y;
		getScreenPosition(_point, Camera);
		point.putWeak();
		return (xPos >= _point.x) && (xPos < _point.x + width) && (yPos >= _point.y) && (yPos < _point.y + height);
	}

	/**
	 * Check and see if this object is currently within the world bounds -
	 * useful for killing objects that get too far away.
	 *
	 * @return   Whether the object is within the world bounds or not.
	 */
	public inline function inWorldBounds():Bool
	{
		return (x + width > FlxG.worldBounds.x) && (x < FlxG.worldBounds.right) && (y + height > FlxG.worldBounds.y) && (y < FlxG.worldBounds.bottom);
	}

	/**
	 * Call this function to figure out the on-screen position of the object.
	 *
	 * @param   Point    Takes a `FlxPoint` object and assigns the post-scrolled X and Y values of this object to it.
	 * @param   Camera   Specify which game camera you want.
	 *                   If `null`, it will just grab the first global camera.
	 * @return  The Point you passed in, or a new Point if you didn't pass one,
	 *          containing the screen X and Y position of this object.
	 */
	public function getScreenPosition(?point:FlxPoint, ?Camera:FlxCamera):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();

		if (Camera == null)
			Camera = FlxG.camera;

		point.set(x, y);
		if (pixelPerfectPosition)
			point.floor();

		return point.subtract(Camera.scroll.x * scrollFactor.x, Camera.scroll.y * scrollFactor.y);
	}

	public function getPosition(?point:FlxPoint):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();
		return point.set(x, y);
	}

	/**
	 * Retrieve the midpoint of this object in world coordinates.
	 *
	 * @param   point   Allows you to pass in an existing `FlxPoint` object if you're so inclined.
	 *                  Otherwise a new one is created.
	 * @return  A `FlxPoint` object containing the midpoint of this object in world coordinates.
	 */
	public function getMidpoint(?point:FlxPoint):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();
		return point.set(x + width * 0.5, y + height * 0.5);
	}

	public function getHitbox(?rect:FlxRect):FlxRect
	{
		if (rect == null)
			rect = FlxRect.get();
		return rect.set(x, y, width, height);
	}

	/**
	 * Handy function for reviving game objects.
	 * Resets their existence flags and position.
	 *
	 * @param   X   The new X position of this object.
	 * @param   Y   The new Y position of this object.
	 */
	public function reset(X:Float, Y:Float):Void
	{
		touching = NONE;
		wasTouching = NONE;
		setPosition(X, Y);
		last.set(x, y);
		velocity.set();
		revive();
	}

	/**
	 * Check and see if this object is currently on screen.
	 *
	 * @param   Camera   Specify which game camera you want.
	 *                   If `null`, it will just grab the first global camera.
	 * @return  Whether the object is on screen or not.
	 */
	public function isOnScreen(?Camera:FlxCamera):Bool
	{
		if (Camera == null)
			Camera = FlxG.camera;

		getScreenPosition(_point, Camera);
		return Camera.containsPoint(_point, width, height);
	}

	/**
	 * Check if object is rendered pixel perfect on a specific camera.
	 */
	public function isPixelPerfectRender(?Camera:FlxCamera):Bool
	{
		if (Camera == null)
			Camera = FlxG.camera;
		return pixelPerfectRender == null ? Camera.pixelPerfectRender : pixelPerfectRender;
	}

	/**
	 * Handy function for checking if this object is touching a particular surface.
	 * Be sure to check it before calling `super.update()`, as that will reset the flags.
	 *
	 * @param   Direction   Any of the collision flags (e.g. `LEFT`, `FLOOR`, etc).
	 * @return  Whether the object is touching an object in (any of) the specified direction(s) this frame.
	 */
	public inline function isTouching(Direction:FlxDirectionFlags):Bool
	{
		return (touching & Direction) > NONE;
	}

	/**
	 * Handy function for checking if this object is just landed on a particular surface.
	 * Be sure to check it before calling `super.update()`, as that will reset the flags.
	 *
	 * @param   Direction   Any of the collision flags (e.g. `LEFT`, `FLOOR`, etc).
	 * @return  Whether the object just landed on (any of) the specified surface(s) this frame.
	 */
	public inline function justTouched(Direction:FlxDirectionFlags):Bool
	{
		return ((touching & Direction) > NONE) && ((wasTouching & Direction) <= NONE);
	}

	/**
	 * Reduces the `health` variable of this object by the amount specified in `Damage`.
	 * Calls `kill()` if health drops to or below zero.
	 *
	 * @param   Damage   How much health to take away (use a negative number to give a health bonus).
	 */
	public function hurt(Damage:Float):Void
	{
		health = health - Damage;
		if (health <= 0)
			kill();
	}

	/**
	 * Centers this `FlxObject` on the screen, either by the x axis, y axis, or both.
	 *
	 * @param   axes   On what axes to center the object (e.g. `X`, `Y`, `XY`) - default is both. 
	 * @return  This FlxObject for chaining
	 */
	public inline function screenCenter(axes:FlxAxes = XY):FlxObject
	{
		if (axes.match(X | XY))
			x = (FlxG.width - width) / 2;

		if (axes.match(Y | XY))
			y = (FlxG.height - height) / 2;

		return this;
	}

	/**
	 * Helper function to set the coordinates of this object.
	 * Handy since it only requires one line of code.
	 *
	 * @param   X   The new x position
	 * @param   Y   The new y position
	 */
	public function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		x = X;
		y = Y;
	}

	/**
	 * Shortcut for setting both width and Height.
	 *
	 * @param   Width    The new hitbox width.
	 * @param   Height   The new hitbox height.
	 */
	public function setSize(Width:Float, Height:Float)
	{
		width = Width;
		height = Height;
	}

	#if FLX_DEBUG
	public function drawDebug():Void
	{
		if (ignoreDrawDebug)
			return;

		for (camera in cameras)
		{
			drawDebugOnCamera(camera);

			if (path != null && !path.ignoreDrawDebug)
				path.drawDebug();
		}
	}

	/**
	 * Override this function to draw custom "debug mode" graphics to the
	 * specified camera while the debugger's `drawDebug` mode is toggled on.
	 *
	 * @param   Camera   Which camera to draw the debug visuals to.
	 */
	public function drawDebugOnCamera(camera:FlxCamera):Void
	{
		if (!camera.visible || !camera.exists || !isOnScreen(camera))
			return;

		var rect = getBoundingBox(camera);
		var gfx:Graphics = beginDrawDebug(camera);
		drawDebugBoundingBox(gfx, rect, allowCollisions, immovable);
		endDrawDebug(camera);
	}

	function drawDebugBoundingBox(gfx:Graphics, rect:FlxRect, allowCollisions:Int, partial:Bool)
	{
		// Find the color to use
		var color:Null<Int> = debugBoundingBoxColor;
		if (color == null)
		{
			if (allowCollisions != NONE)
			{
				color = partial ? debugBoundingBoxColorPartial : debugBoundingBoxColorSolid;
			}
			else
			{
				color = debugBoundingBoxColorNotSolid;
			}
		}

		// fill static graphics object with square shape
		gfx.lineStyle(1, color, 0.5);
		gfx.drawRect(rect.x, rect.y, rect.width, rect.height);
	}

	inline function beginDrawDebug(camera:FlxCamera):Graphics
	{
		if (FlxG.renderBlit)
		{
			FlxSpriteUtil.flashGfx.clear();
			return FlxSpriteUtil.flashGfx;
		}
		else
		{
			return camera.debugLayer.graphics;
		}
	}

	inline function endDrawDebug(camera:FlxCamera)
	{
		if (FlxG.renderBlit)
			camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
	#end

	@:access(flixel.FlxCamera)
	function getBoundingBox(camera:FlxCamera):FlxRect
	{
		getScreenPosition(_point, camera);

		_rect.set(_point.x, _point.y, width, height);
		_rect = camera.transformRect(_rect);

		if (isPixelPerfectRender(camera))
		{
			_rect.floor();
		}

		return _rect;
	}
	
	/**
	 * Calculates the smallest globally aligned bounding box that encompasses this
	 * object's width and height, at its current rotation.
	 * Note, if called on a `FlxSprite`, the origin is used, but scale and offset are ignored.
	 * Use `getScreenBounds` to use these properties.
	 * @param newRect The optional output `FlxRect` to be returned, if `null`, a new one is created.
	 * @return A globally aligned `FlxRect` that fully contains the input object's width and height.
	 * @since 4.11.0
	 */
	public function getRotatedBounds(?newRect:FlxRect)
	{
		if (newRect == null)
			newRect = FlxRect.get();
		
		newRect.set(x, y, width, height);
		return newRect.getRotatedBounds(angle, null, newRect);
	}

	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	override public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("x", x),
			LabelValuePair.weak("y", y),
			LabelValuePair.weak("w", width),
			LabelValuePair.weak("h", height),
			LabelValuePair.weak("visible", visible),
			LabelValuePair.weak("velocity", velocity)
		]);
	}

	@:noCompletion
	function set_x(NewX:Float):Float
	{
		return x = NewX;
	}

	@:noCompletion
	function set_y(NewY:Float):Float
	{
		return y = NewY;
	}

	@:noCompletion
	function set_width(Width:Float):Float
	{
		#if FLX_DEBUG
		if (Width < 0)
		{
			FlxG.log.warn("An object's width cannot be smaller than 0. Use offset for sprites to control the hitbox position!");
			return Width;
		}
		#end

		return width = Width;
	}

	@:noCompletion
	function set_height(Height:Float):Float
	{
		#if FLX_DEBUG
		if (Height < 0)
		{
			FlxG.log.warn("An object's height cannot be smaller than 0. Use offset for sprites to control the hitbox position!");
			return Height;
		}
		#end

		return height = Height;
	}

	@:noCompletion
	function get_width():Float
	{
		return width;
	}

	@:noCompletion
	function get_height():Float
	{
		return height;
	}

	@:noCompletion
	inline function get_solid():Bool
	{
		return (allowCollisions & ANY) > NONE;
	}

	@:noCompletion
	function set_solid(Solid:Bool):Bool
	{
		allowCollisions = Solid ? ANY : NONE;
		return Solid;
	}

	@:noCompletion
	function set_angle(Value:Float):Float
	{
		return angle = Value;
	}

	@:noCompletion
	function set_moves(Value:Bool):Bool
	{
		return moves = Value;
	}

	@:noCompletion
	function set_immovable(Value:Bool):Bool
	{
		return immovable = Value;
	}

	@:noCompletion
	function set_pixelPerfectRender(Value:Bool):Bool
	{
		return pixelPerfectRender = Value;
	}

	@:noCompletion
	function set_allowCollisions(Value:FlxDirectionFlags):FlxDirectionFlags
	{
		return allowCollisions = Value;
	}

	#if FLX_DEBUG
	@:noCompletion
	function set_debugBoundingBoxColorSolid(color:FlxColor)
	{
		return debugBoundingBoxColorSolid = color;
	}

	@:noCompletion
	function set_debugBoundingBoxColorNotSolid(color:FlxColor)
	{
		return debugBoundingBoxColorNotSolid = color;
	}

	@:noCompletion
	function set_debugBoundingBoxColorPartial(color:FlxColor)
	{
		return debugBoundingBoxColorPartial = color;
	}
	#end

	@:noCompletion
	function set_path(path:FlxPath):FlxPath
	{
		if (this.path == path)
			return path;

		if (this.path != null)
			this.path.object = null;

		if (path != null)
			path.object = this;
		return this.path = path;
	}
}
