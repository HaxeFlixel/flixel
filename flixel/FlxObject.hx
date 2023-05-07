package flixel;

import flash.display.Graphics;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVelocity;
import flixel.path.FlxPath;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;

/**
 * At their core `FlxObjects` are just boxes with positions that can move and collide with other
 * objects. Most games utilize `FlxObject's` features through [FlxSprite](https://api.haxeflixel.com/flixel/FlxSprite.html),
 * which extends `FlxObject` directly and adds graphical capabilities.
 * 
 * ## Motion
 * Whenever `update` is called, objects with `move` set to true will update their positions based
 * on the following properties:
 * - `velocity`: The speed of the object in pixels per second.
 * - `acceleration`: The rate at which `velocity` will change in pixels per second.
 * - `drag`: When `acceleration` is 0, `velocity` will slow by this amount, in pixels per second.
 *           When less than or equal to 0, no drag is applied.
 * - `maxVelocity`: The maximum `velocity` (or negative `velocity`) this object can have.
 * - `angle`: The orientation, in degrees, of this `object`. Does not affect collision, mainly
 *            used for `FlxSprite` graphics.
 * - `angularVelocity`: The rotational speed of the object in degrees per second.
 * 
 * ## Overlaps
 * If you're only checking an overlap between two objects you can use `player.overlaps(door)`
 * or `player.overlaps(spikeGroup)`. You can check if two objects or groups of object overlap
 * with [FlxG.overlap](https://api.haxeflixel.com/flixel/FlxG.html#overlap).
 * 
 * Example:
 * ```haxe
 * if (FlxG.overlap(playerGroup, spikeGroup)) trace("overlap!");
 * ```
 * 
 * You can also specify a callback to handle which specific objects collided:
 * ```haxe
 * FlxG.overlap(playerGroup, medKitGroup
 *     function onOverlap(player, medKit)
 *     {
 *         player.health = 100;
 *         medKit.kill();
 *     }
 * );
 * ```
 * 
 * Additional resources:
 * - [Snippets - Simple Overlap](https://snippets.haxeflixel.com/overlap/simple-overlap/)
 * - [Snippets - Overlap Callbacks](https://snippets.haxeflixel.com/overlap/overlap-callbacks/)
 * 
 * ## Collision
 * `FlxG.collide` is similar to `FlxG.overlap` except it resolves the overlap by separating their
 * positions before calling the callback. Typically collide is called on an update loop like so:
 * ```haxe
 * FlxG.collide(playerGroup, crateGroup);
 * ```
 * This takes the player's and crate's momentum and previous and current position in consideration
 * when resolving overlaps between them. Like `overlap` collide will return true if any objects
 * were overlapping, and you can specify a callback.
 * 
 * Additional resources:
 * - [Snippets - 1 to 1 Collision](https://snippets.haxeflixel.com/collision/1-to-1-collision/)
 * - [Demos - FlxCollisions](https://haxeflixel.com/demos/FlxCollisions/)
 * - [Demos - Collision and Grouping](https://haxeflixel.com/demos/CollisionAndGrouping/)
 * @see [Demos - EZPlatformer](https://haxeflixel.com/demos/EZPlatformer/)
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
	@:deprecated("Use LEFT or FlxDirectionFlags.LEFT instead")
	@:noCompletion
	public static inline var LEFT = FlxDirectionFlags.LEFT;

	/**
	 * Generic value for "right". Used by `facing`, `allowCollisions`, and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.RIGHT` directly.
	 */
	@:deprecated("Use RIGHT or FlxDirectionFlags.RIGHT instead")
	@:noCompletion
	public static inline var RIGHT = FlxDirectionFlags.RIGHT;

	/**
	 * Generic value for "up". Used by `facing`, `allowCollisions`, and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.UP` directly.
	 */
	@:deprecated("Use UP or FlxDirectionFlags.UP instead")
	@:noCompletion
	public static inline var UP = FlxDirectionFlags.UP;

	/**
	 * Generic value for "down". Used by `facing`, `allowCollisions`, and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.DOWN` directly.
	 */
	@:deprecated("Use DOWN or FlxDirectionFlags.DOWN instead")
	@:noCompletion
	public static inline var DOWN = FlxDirectionFlags.DOWN;

	/**
	 * Special-case constant meaning no collisions, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.NONE` directly.
	 */
	@:deprecated("Use NONE or FlxDirectionFlags.NONE instead")
	@:noCompletion
	public static inline var NONE = FlxDirectionFlags.NONE;

	/**
	 * Special-case constant meaning up, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.CEILING` directly.
	 */
	@:deprecated("Use CEILING or FlxDirectionFlags.CEILING instead")
	@:noCompletion
	public static inline var CEILING = FlxDirectionFlags.CEILING;

	/**
	 * Special-case constant meaning down, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.FLOOR` directly.
	 */
	@:deprecated("Use FLOOR or FlxDirectionFlags.FLOOR instead")
	@:noCompletion
	public static inline var FLOOR = FlxDirectionFlags.FLOOR;

	/**
	 * Special-case constant meaning only the left and right sides, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.WALL` directly.
	 */
	@:deprecated("Use WALL or FlxDirectionFlags.WALL instead")
	@:noCompletion
	public static inline var WALL = FlxDirectionFlags.WALL;

	/**
	 * Special-case constant meaning any direction, used mainly by `allowCollisions` and `touching`.
	 * Note: This exists for backwards compatibility, prefer using `FlxDirectionFlags.ANY` directly.
	 */
	@:deprecated("Use ANY or FlxDirectionFlags.ANY instead")
	@:noCompletion
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
	public static function separate(object1:FlxObject, object2:FlxObject):Bool
	{
		var separatedX:Bool = separateX(object1, object2);
		var separatedY:Bool = separateY(object1, object2);
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

	static function allowCollisionDrag(type:CollisionDragType, object1:FlxObject, object2:FlxObject):Bool
	{
		return object2.active && object2.moves && switch (type)
		{
			case NEVER: false;
			case ALWAYS: true;
			case IMMOVABLE: object2.immovable;
			case HEAVIER: object2.immovable || object2.mass > object1.mass;
		}
	}

	/**
	 * Internal function that computes overlap among two objects on the X axis. It also updates the `touching` variable.
	 * `checkMaxOverlap` is used to determine whether we want to exclude (therefore check) overlaps which are
	 * greater than a certain maximum (linked to `SEPARATE_BIAS`). Default is `true`, handy for `separateX` code.
	 */
	@:noCompletion
	static function computeOverlapX(object1:FlxObject, object2:FlxObject, checkMaxOverlap:Bool = true):Float
	{
		var overlap:Float = 0;
		// First, get the two object deltas
		var obj1delta:Float = object1.x - object1.last.x;
		var obj2delta:Float = object2.x - object2.last.x;

		if (obj1delta != obj2delta)
		{
			// Check if the X hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0) ? obj1delta : -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0) ? obj2delta : -obj2delta;

			var obj1rect:FlxRect = _firstSeparateFlxRect.set(object1.x - ((obj1delta > 0) ? obj1delta : 0), object1.last.y, object1.width + obj1deltaAbs,
				object1.height);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(object2.x - ((obj2delta > 0) ? obj2delta : 0), object2.last.y, object2.width + obj2deltaAbs,
				object2.height);

			if ((obj1rect.x + obj1rect.width > obj2rect.x)
				&& (obj1rect.x < obj2rect.x + obj2rect.width)
				&& (obj1rect.y + obj1rect.height > obj2rect.y)
				&& (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = checkMaxOverlap ? (obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS) : 0;

				// If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = object1.x + object1.width - object2.x;
					if ((checkMaxOverlap && (overlap > maxOverlap))
						|| ((object1.allowCollisions & FlxDirectionFlags.RIGHT) == 0)
						|| ((object2.allowCollisions & FlxDirectionFlags.LEFT) == 0))
					{
						overlap = 0;
					}
					else
					{
						object1.touching |= FlxDirectionFlags.RIGHT;
						object2.touching |= FlxDirectionFlags.LEFT;
					}
				}
				else if (obj1delta < obj2delta)
				{
					overlap = object1.x - object2.width - object2.x;
					if ((checkMaxOverlap && (-overlap > maxOverlap))
						|| ((object1.allowCollisions & FlxDirectionFlags.LEFT) == 0)
						|| ((object2.allowCollisions & FlxDirectionFlags.RIGHT) == 0))
					{
						overlap = 0;
					}
					else
					{
						object1.touching |= FlxDirectionFlags.LEFT;
						object2.touching |= FlxDirectionFlags.RIGHT;
					}
				}
			}
		}
		return overlap;
	}

	/**
	 * The X-axis component of the object separation process.
	 *
	 * @param   object1   Any `FlxObject`.
	 * @param   object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched and were separated along the X axis.
	 */
	public static function separateX(object1:FlxObject, object2:FlxObject):Bool
	{
		// can't separate two immovable objects
		var immovable1 = object1.immovable;
		var immovable2 = object2.immovable;
		if (immovable1 && immovable2)
		{
			return false;
		}

		// If one of the objects is a tilemap, just pass it off.
		if (object1.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast object1;
			return tilemap.overlapsWithCallback(object2, separateX);
		}
		if (object2.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast object2;
			return tilemap.overlapsWithCallback(object1, separateX, true);
		}

		var overlap:Float = computeOverlapX(object1, object2);
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var delta1 = object1.x - object1.last.x;
			var delta2 = object2.x - object2.last.x;
			var vel1 = object1.velocity.x;
			var vel2 = object2.velocity.x;
			var mass1 = object1.mass;
			var mass2 = object2.mass;
			var massSum = mass1 + mass2;
			var elasticity1 = object1.elasticity;
			var elasticity2 = object2.elasticity;

			if (!immovable1 && !immovable2)
			{
				#if FLX_4_LEGACY_COLLISION
				overlap *= 0.5;
				object1.x = object1.x - overlap;
				object2.x += overlap;

				var newVel1 = Math.sqrt((vel2 * vel2 * mass2) / mass1) * ((vel2 > 0) ? 1 : -1);
				var newVel2 = Math.sqrt((vel1 * vel1 * mass1) / mass2) * ((vel1 > 0) ? 1 : -1);
				var average = (newVel1 + newVel2) * 0.5;
				newVel1 -= average;
				newVel2 -= average;
				object1.velocity.x = average + newVel1 * elasticity1;
				object2.velocity.x = average + newVel2 * elasticity2;
				#else
				object1.x -= overlap / 2;
				object2.x += overlap / 2;
				
				var momentum = mass1 * vel1 + mass2 * vel2;
				var newVel1 = (momentum + elasticity1 * mass2 * (vel2 - vel1)) / massSum;
				var newVel2 = (momentum + elasticity2 * mass1 * (vel1 - vel2)) / massSum;
				object1.velocity.x = newVel1;
				object2.velocity.x = newVel2;
				#end
			}
			else if (!immovable1)
			{
				object1.x -= overlap;
				object1.velocity.x = vel2 - vel1 * elasticity1;
			}
			else if (!immovable2)
			{
				object2.x += overlap;
				object2.velocity.x = vel1 - vel2 * elasticity2;
			}

			// use collisionDrag properties to determine whether one object
			if (allowCollisionDrag(object1.collisionYDrag, object1, object2) && delta1 > delta2)
				object1.y += object2.y - object2.last.y;
			else if (allowCollisionDrag(object2.collisionYDrag, object2, object1) && delta2 > delta1)
				object2.y += object1.y - object1.last.y;

			return true;
		}

		return false;
	}

	/**
	 * Checking overlap and updating `touching` variables, X-axis part used by `updateTouchingFlags`.
	 *
	 * @param   object1   Any `FlxObject`.
	 * @param   object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched along the X axis.
	 */
	public static function updateTouchingFlagsX(object1:FlxObject, object2:FlxObject):Bool
	{
		// If one of the objects is a tilemap, just pass it off.
		if (object1.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast object1;
			return tilemap.overlapsWithCallback(object2, updateTouchingFlagsX);
		}
		if (object2.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast object2;
			return tilemap.overlapsWithCallback(object1, updateTouchingFlagsX, true);
		}
		// Since we are not separating, always return any amount of overlap => false as last parameter
		return computeOverlapX(object1, object2, false) != 0;
	}

	/**
	 * Internal function that computes overlap among two objects on the Y axis. It also updates the `touching` variable.
	 * `checkMaxOverlap` is used to determine whether we want to exclude (therefore check) overlaps which are
	 * greater than a certain maximum (linked to `SEPARATE_BIAS`). Default is `true`, handy for `separateY` code.
	 */
	@:noCompletion
	static function computeOverlapY(object1:FlxObject, object2:FlxObject, checkMaxOverlap:Bool = true):Float
	{
		var overlap:Float = 0;
		// First, get the two object deltas
		var obj1delta:Float = object1.y - object1.last.y;
		var obj2delta:Float = object2.y - object2.last.y;

		if (obj1delta != obj2delta)
		{
			// Check if the Y hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0) ? obj1delta : -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0) ? obj2delta : -obj2delta;

			var obj1rect:FlxRect = _firstSeparateFlxRect.set(object1.x, object1.y - ((obj1delta > 0) ? obj1delta : 0), object1.width,
				object1.height + obj1deltaAbs);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(object2.x, object2.y - ((obj2delta > 0) ? obj2delta : 0), object2.width,
				object2.height + obj2deltaAbs);

			if ((obj1rect.x + obj1rect.width > obj2rect.x)
				&& (obj1rect.x < obj2rect.x + obj2rect.width)
				&& (obj1rect.y + obj1rect.height > obj2rect.y)
				&& (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = checkMaxOverlap ? (obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS) : 0;

				// If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = object1.y + object1.height - object2.y;
					if ((checkMaxOverlap && (overlap > maxOverlap))
						|| ((object1.allowCollisions & FlxDirectionFlags.DOWN) == 0)
						|| ((object2.allowCollisions & FlxDirectionFlags.UP) == 0))
					{
						overlap = 0;
					}
					else
					{
						object1.touching |= FlxDirectionFlags.DOWN;
						object2.touching |= FlxDirectionFlags.UP;
					}
				}
				else if (obj1delta < obj2delta)
				{
					overlap = object1.y - object2.height - object2.y;
					if ((checkMaxOverlap && (-overlap > maxOverlap))
						|| ((object1.allowCollisions & FlxDirectionFlags.UP) == 0)
						|| ((object2.allowCollisions & FlxDirectionFlags.DOWN) == 0))
					{
						overlap = 0;
					}
					else
					{
						object1.touching |= FlxDirectionFlags.UP;
						object2.touching |= FlxDirectionFlags.DOWN;
					}
				}
			}
		}
		return overlap;
	}

	/**
	 * The Y-axis component of the object separation process.
	 *
	 * @param   object1   Any `FlxObject`.
	 * @param   object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched and were separated along the Y axis.
	 */
	public static function separateY(object1:FlxObject, object2:FlxObject):Bool
	{
		// can't separate two immovable objects
		var immovable1:Bool = object1.immovable;
		var immovable2:Bool = object2.immovable;
		if (immovable1 && immovable2)
		{
			return false;
		}

		// If one of the objects is a tilemap, just pass it off.
		if (object1.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast object1;
			return tilemap.overlapsWithCallback(object2, separateY);
		}
		if (object2.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast object2;
			return tilemap.overlapsWithCallback(object1, separateY, true);
		}

		var overlap:Float = computeOverlapY(object1, object2);
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var delta1 = object1.y - object1.last.y;
			var delta2 = object2.y - object2.last.y;
			var vel1 = object1.velocity.y;
			var vel2 = object2.velocity.y;
			var mass1 = object1.mass;
			var mass2 = object2.mass;
			var massSum = mass1 + mass2;
			var elasticity1 = object1.elasticity;
			var elasticity2 = object2.elasticity;

			if (!immovable1 && !immovable2)
			{
				#if FLX_4_LEGACY_COLLISION
				overlap *= 0.5;
				object1.y = object1.y - overlap;
				object2.y += overlap;

				var newVel1 = Math.sqrt((vel2 * vel2 * mass2) / mass1) * ((vel2 > 0) ? 1 : -1);
				var newVel2 = Math.sqrt((vel1 * vel1 * mass1) / mass2) * ((vel1 > 0) ? 1 : -1);
				var average = (newVel1 + newVel2) * 0.5;
				newVel1 -= average;
				newVel2 -= average;
				object1.velocity.y = average + newVel1 * elasticity1;
				object2.velocity.y = average + newVel2 * elasticity2;
				#else
				object1.y -= overlap / 2;
				object2.y += overlap / 2;
				
				var momentum = mass1 * vel1 + mass2 * vel2;
				var newVel1 = (momentum + elasticity1 * mass2 * (vel2 - vel1)) / massSum;
				var newVel2 = (momentum + elasticity2 * mass1 * (vel1 - vel2)) / massSum;
				object1.velocity.y = newVel1;
				object2.velocity.y = newVel2;
				#end
			}
			else if (!immovable1)
			{
				object1.y -= overlap;
				object1.velocity.y = vel2 - vel1 * elasticity1;
			}
			else if (!immovable2)
			{
				object2.y += overlap;
				object2.velocity.y = vel1 - vel2 * elasticity2;
			}

			// use collisionDrag properties to determine whether one object
			if (allowCollisionDrag(object1.collisionXDrag, object1, object2) && delta1 > delta2)
				object1.x += object2.x - object2.last.x;
			else if (allowCollisionDrag(object2.collisionXDrag, object2, object1) && delta2 > delta1)
				object2.x += object1.x - object1.last.x;

			return true;
		}

		return false;
	}

	/**
	 * Checking overlap and updating touching variables, Y-axis part used by `updateTouchingFlags`.
	 *
	 * @param   object1   Any `FlxObject`.
	 * @param   object2   Any other `FlxObject`.
	 * @return  Whether the objects in fact touched along the Y axis.
	 */
	public static function updateTouchingFlagsY(object1:FlxObject, object2:FlxObject):Bool
	{
		// If one of the objects is a tilemap, just pass it off.
		if (object1.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast object1;
			return tilemap.overlapsWithCallback(object2, updateTouchingFlagsY);
		}
		if (object2.flixelType == TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast object2;
			return tilemap.overlapsWithCallback(object1, updateTouchingFlagsY, true);
		}
		// Since we are not separating, always return any amount of overlap => false as last parameter
		return computeOverlapY(object1, object2, false) != 0;
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
	public var touching = FlxDirectionFlags.NONE;

	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts from the previous game loop step. Use bitwise operators to check the values
	 * stored here, or use isTouching(), justTouched(), etc. You can even use them broadly as boolean values if you're feeling saucy!
	 */
	public var wasTouching = FlxDirectionFlags.NONE;

	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating collision directions. Use bitwise operators to check the values stored here.
	 * Useful for things like one-way platforms (e.g. allowCollisions = UP;). The accessor "solid" just flips this variable between NONE and ANY.
	 */
	public var allowCollisions(default, set) = FlxDirectionFlags.ANY;

	/** DEPRECATED
	 * Whether this sprite is dragged along with the horizontal movement of objects it collides with
	 * (makes sense for horizontally-moving platforms in platformers for example).
	 * 
	 * Apart from having a weird typo, this has been deprecated for collisionXDrag, which allows more options.
	 */
	@:deprecated("Use `collisionXDrag`, instead. Note the corrected spelling: `collis(i)onXDrag")
	public var collisonXDrag(get, set):Bool;

	/**
	 * Whether this sprite is dragged along with the horizontal movement of objects it collides with
	 * (makes sense for horizontally-moving platforms in platformers for example). Use values
	 * IMMOVABLE, ALWAYS, HEAVIER or NEVER
	 * @since 4.11.0
	 */
	public var collisionXDrag:CollisionDragType = IMMOVABLE;

	/**
	 * Whether this sprite is dragged along with the vertical movement of objects it collides with
	 * (for sticking to vertically-moving platforms in platformers for example). Use values
	 * IMMOVABLE, ALWAYS, HEAVIER or NEVER
	 * @since 4.11.0
	 */
	public var collisionYDrag:CollisionDragType = NEVER;

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
	 * Setting this to `true` will prevent the object's bounding box from appearing
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
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		super();

		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;

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
		touching = FlxDirectionFlags.NONE;
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
	 * @param   objectOrGroup   The object or group being tested.
	 * @param   inScreenSpace   Whether to take scroll factors into account when checking for overlap.
	 *                          Default is `false`, or "only compare in world space."
	 * @param   camera          Specify which game camera you want.
	 *                          If `null`, it will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup)
	public function overlaps(objectOrGroup:FlxBasic, inScreenSpace:Bool = false, ?camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(objectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(overlapsCallback, group, 0, 0, inScreenSpace, camera);
		}

		if (objectOrGroup.flixelType == TILEMAP)
		{
			// Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			var tilemap:FlxBaseTilemap<Dynamic> = cast objectOrGroup;
			return tilemap.overlaps(this, inScreenSpace, camera);
		}

		var object:FlxObject = cast objectOrGroup;
		if (!inScreenSpace)
		{
			return (object.x + object.width > x) && (object.x < x + width) && (object.y + object.height > y) && (object.y < y + height);
		}

		if (camera == null)
		{
			camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenPosition(null, camera);
		getScreenPosition(_point, camera);
		return (objectScreenPos.x + object.width > _point.x)
			&& (objectScreenPos.x < _point.x + width)
			&& (objectScreenPos.y + object.height > _point.y)
			&& (objectScreenPos.y < _point.y + height);
	}

	@:noCompletion
	inline function overlapsCallback(objectOrGroup:FlxBasic, x:Float, y:Float, inScreenSpace:Bool, camera:FlxCamera):Bool
	{
		return overlaps(objectOrGroup, inScreenSpace, camera);
	}

	/**
	 * Checks to see if this `FlxObject` were located at the given position,
	 * would it overlap the `FlxObject` or `FlxGroup`?
	 * This is distinct from `overlapsPoint()`, which just checks that point,
	 * rather than taking the object's size into account.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 *
	 * @param   x               The X position you want to check.
	 *                          Pretends this object (the caller, not the parameter) is located here.
	 * @param   y               The Y position you want to check.
	 *                          Pretends this object (the caller, not the parameter) is located here.
	 * @param   objectOrGroup   The object or group being tested.
	 * @param   inScreenSpace   Whether to take scroll factors into account when checking for overlap.
	 *                          Default is `false`, or "only compare in world space."
	 * @param   camera          Specify which game camera you want.
	 *                          If `null`, it will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup)
	public function overlapsAt(x:Float, y:Float, objectOrGroup:FlxBasic, inScreenSpace = false, ?camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(objectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(overlapsAtCallback, group, x, y, inScreenSpace, camera);
		}

		if (objectOrGroup.flixelType == TILEMAP)
		{
			// Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			// However, since this is overlapsAt(), we also have to invent the appropriate position for the tilemap.
			// So we calculate the offset between the player and the requested position, and subtract that from the tilemap.
			var tilemap:FlxBaseTilemap<Dynamic> = cast objectOrGroup;
			return tilemap.overlapsAt(tilemap.x - (x - this.x), tilemap.y - (y - this.y), this, inScreenSpace, camera);
		}

		var object:FlxObject = cast objectOrGroup;
		if (!inScreenSpace)
		{
			return (object.x + object.width > x) && (object.x < x + width) && (object.y + object.height > y) && (object.y < y + height);
		}

		if (camera == null)
		{
			camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenPosition(null, camera);
		getScreenPosition(_point, camera);
		return (objectScreenPos.x + object.width > _point.x)
			&& (objectScreenPos.x < _point.x + width)
			&& (objectScreenPos.y + object.height > _point.y)
			&& (objectScreenPos.y < _point.y + height);
	}

	@:noCompletion
	inline function overlapsAtCallback(objectOrGroup:FlxBasic, x:Float, y:Float, inScreenSpace:Bool, camera:FlxCamera):Bool
	{
		return overlapsAt(x, y, objectOrGroup, inScreenSpace, camera);
	}

	/**
	 * Checks to see if a point in 2D world space overlaps this `FlxObject`.
	 *
	 * @param   point           The point in world space you want to check.
	 * @param   inScreenSpace   Whether to take scroll factors into account when checking for overlap.
	 * @param   camera          Specify which game camera you want.
	 *                          If `null`, it will just grab the first global camera.
	 * @return  Whether or not the point overlaps this object.
	 */
	public function overlapsPoint(point:FlxPoint, inScreenSpace = false, ?camera:FlxCamera):Bool
	{
		if (!inScreenSpace)
		{
			return (point.x >= x) && (point.x < x + width) && (point.y >= y) && (point.y < y + height);
		}

		if (camera == null)
		{
			camera = FlxG.camera;
		}
		var xPos:Float = point.x - camera.scroll.x;
		var yPos:Float = point.y - camera.scroll.y;
		getScreenPosition(_point, camera);
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
	 * Returns the screen position of this object.
	 *
	 * @param   result  Optional arg for the returning point
	 * @param   camera  The desired "screen" coordinate space. If `null`, `FlxG.camera` is used.
	 * @return  The screen position of this object.
	 */
	public function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		if (result == null)
			result = FlxPoint.get();

		if (camera == null)
			camera = FlxG.camera;

		result.set(x, y);
		if (pixelPerfectPosition)
			result.floor();

		return result.subtract(camera.scroll.x * scrollFactor.x, camera.scroll.y * scrollFactor.y);
	}

	/**
	 * Returns the world position of this object.
	 * 
	 * @param   result  Optional arg for the returning point.
	 * @return  The world position of this object.
	 */
	public function getPosition(?result:FlxPoint):FlxPoint
	{
		if (result == null)
			result = FlxPoint.get();
		
		return result.set(x, y);
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
	 * @param   x   The new X position of this object.
	 * @param   y   The new Y position of this object.
	 */
	public function reset(x:Float, y:Float):Void
	{
		touching = FlxDirectionFlags.NONE;
		wasTouching = FlxDirectionFlags.NONE;
		setPosition(x, y);
		last.set(this.x, this.y);
		velocity.set();
		revive();
	}

	/**
	 * Check and see if this object is currently on screen.
	 *
	 * @param   camera   Specify which game camera you want.
	 *                   If `null`, it will just grab the first global camera.
	 * @return  Whether the object is on screen or not.
	 */
	public function isOnScreen(?camera:FlxCamera):Bool
	{
		if (camera == null)
			camera = FlxG.camera;

		getScreenPosition(_point, camera);
		return camera.containsPoint(_point, width, height);
	}

	/**
	 * Check if object is rendered pixel perfect on a specific camera.
	 */
	public function isPixelPerfectRender(?camera:FlxCamera):Bool
	{
		if (camera == null)
			camera = FlxG.camera;
		return pixelPerfectRender == null ? camera.pixelPerfectRender : pixelPerfectRender;
	}

	/**
	 * Handy function for checking if this object is touching a particular surface.
	 * Be sure to check it before calling `super.update()`, as that will reset the flags.
	 *
	 * @param   direction   Any of the collision flags (e.g. `LEFT`, `FLOOR`, etc).
	 * @return  Whether the object is touching an object in (any of) the specified direction(s) this frame.
	 */
	public inline function isTouching(direction:FlxDirectionFlags):Bool
	{
		return touching.hasAny(direction);
	}

	/**
	 * Handy function for checking if this object is just landed on a particular surface.
	 * Be sure to check it before calling `super.update()`, as that will reset the flags.
	 *
	 * @param   direction   Any of the collision flags (e.g. `LEFT`, `FLOOR`, etc).
	 * @return  Whether the object just landed on (any of) the specified surface(s) this frame.
	 */
	public inline function justTouched(direction:FlxDirectionFlags):Bool
	{
		return touching.hasAny(direction) && !wasTouching.hasAny(direction);
	}

	/**
	 * Reduces the `health` variable of this object by the amount specified in `Damage`.
	 * Calls `kill()` if health drops to or below zero.
	 *
	 * @param   Damage   How much health to take away (use a negative number to give a health bonus).
	 */
	public function hurt(damage:Float):Void
	{
		health = health - damage;
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
		if (axes.x)
			x = (FlxG.width - width) / 2;

		if (axes.y)
			y = (FlxG.height - height) / 2;

		return this;
	}

	/**
	 * Helper function to set the coordinates of this object.
	 * Handy since it only requires one line of code.
	 *
	 * @param   x   The new x position
	 * @param   y   The new y position
	 */
	public function setPosition(x = 0.0, y = 0.0):Void
	{
		this.x = x;
		this.y = y;
	}

	/**
	 * Shortcut for setting both width and Height.
	 *
	 * @param   width    The new hitbox width.
	 * @param   height   The new hitbox height.
	 */
	public function setSize(width:Float, height:Float)
	{
		this.width = width;
		this.height = height;
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
			if (allowCollisions != FlxDirectionFlags.NONE)
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
	function set_x(value:Float):Float
	{
		return x = value;
	}

	@:noCompletion
	function set_y(value:Float):Float
	{
		return y = value;
	}

	@:noCompletion
	function set_width(value:Float):Float
	{
		#if FLX_DEBUG
		if (value < 0)
		{
			FlxG.log.warn("An object's width cannot be smaller than 0. Use offset for sprites to control the hitbox position!");
			return value;
		}
		#end

		return width = value;
	}

	@:noCompletion
	function set_height(value:Float):Float
	{
		#if FLX_DEBUG
		if (value < 0)
		{
			FlxG.log.warn("An object's height cannot be smaller than 0. Use offset for sprites to control the hitbox position!");
			return value;
		}
		#end

		return height = value;
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
		return (allowCollisions & FlxDirectionFlags.ANY) > FlxDirectionFlags.NONE;
	}

	@:noCompletion
	function set_solid(value:Bool):Bool
	{
		allowCollisions = value ? FlxDirectionFlags.ANY : FlxDirectionFlags.NONE;
		return value;
	}

	@:noCompletion
	function set_angle(value:Float):Float
	{
		return angle = value;
	}

	@:noCompletion
	function set_moves(value:Bool):Bool
	{
		return moves = value;
	}

	@:noCompletion
	function set_immovable(value:Bool):Bool
	{
		return immovable = value;
	}

	@:noCompletion
	function set_pixelPerfectRender(value:Bool):Bool
	{
		return pixelPerfectRender = value;
	}

	@:noCompletion
	function set_allowCollisions(value:FlxDirectionFlags):FlxDirectionFlags
	{
		return allowCollisions = value;
	}

	@:noCompletion
	function get_collisonXDrag():Bool
	{
		return collisionXDrag == IMMOVABLE;
	}

	@:noCompletion
	function set_collisonXDrag(value:Bool):Bool
	{
		collisionXDrag = value ? IMMOVABLE : NEVER;
		return value;
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

/**
 * Determines when to apply collision drag to one object that collided with another.
 */
enum abstract CollisionDragType(Int)
{
	/** Never drags on colliding objects. */
	var NEVER = 0;

	/** Always drags on colliding objects. */
	var ALWAYS = 1;

	/** Drags when colliding with immovable objects. */
	var IMMOVABLE = 2;

	/** Drags when colliding with heavier objects. Immovable objects have infinite mass. */
	var HEAVIER = 3;
}
