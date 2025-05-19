package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxDirectionFlags;

using flixel.util.FlxCollision;

@:access(flixel.FlxObject)
class CollisionFrontEnd
{
	public function new () {}
	
	/**
	 * Call this function to see if one `FlxObject` overlaps another within `FlxG.worldBounds`.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a `FlxGroup` (or even bundling groups together!).
	 *
	 * NOTE: does NOT take objects' `scrollFactor` into account, all overlaps are checked in world space.
	 *
	 * NOTE: this takes the entire area of `FlxTilemap`s into account (including "empty" tiles).
	 * Use `FlxTilemap#overlaps()` if you don't want that.
	 *
	 * @param   a        The first object or group you want to check.
	 * @param   b        The second object or group you want to check. Can be the same group as the first.
	 * @param   notify   Called on every object that overlaps another.
	 * @param   process  Called on every object that overlaps another, determines whether to call the `notify`.
	 * @return  Whether any overlaps were detected.
	 */
	overload public inline extern function overlap<TA:FlxObject, TB:FlxObject>(a, ?b, ?notify:(TA, TB)->Void, ?process:(TA, TB)->Bool)
	{
		return overlapHelper(a, b, notify, process);
	}
	
	/**
	 * Call this function to see if one `FlxObject` overlaps another within `FlxG.worldBounds`.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a `FlxGroup` (or even bundling groups together!).
	 *
	 * NOTE: does NOT take objects' `scrollFactor` into account, all overlaps are checked in world space.
	 *
	 * NOTE: this takes the entire area of `FlxTilemap`s into account (including "empty" tiles).
	 * Use `FlxTilemap#overlaps()` if you don't want that.
	 *
	 * @param   a        The first object or group you want to check.
	 * @param   b        The second object or group you want to check. Can be the same group as the first.
	 * @param   notify   Called on every object that overlaps another.
	 * @param   process  Called on every object that overlaps another, determines whether to call the `notify`.
	 * @return  Whether any overlaps were detected.
	 */
	overload public inline extern function overlap<TA:FlxObject, TB:FlxObject>(?notify:(TA, TB)->Void, ?process:(TA, TB)->Bool)
	{
		return overlapHelper(FlxG.state, null, notify, process);
	}
	
	function overlapHelper<TA:FlxObject, TB:FlxObject>(a:FlxBasic, b:Null<FlxBasic>, notify:Null<(TA, TB)->Void>, ?process:Null<(TA, TB)->Bool>)
	{
		if (b == a)
			b = null;

		FlxQuadTree.divisions = FlxG.worldDivisions;// TODO
		final quadTree = FlxQuadTree.recycle(FlxG.worldBounds.x, FlxG.worldBounds.y, FlxG.worldBounds.width, FlxG.worldBounds.height);
		quadTree.load(a, b, cast notify, cast process);
		final result:Bool = quadTree.execute();
		quadTree.destroy();
		return result;
	}
	
	/**
	 * Call this function to see if one `FlxObject` collides with another within `FlxG.worldBounds`.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a FlxGroup (or even bundling groups together!).
	 *
	 * This function just calls `FlxG.overlap` and presets the `ProcessCallback` parameter to `FlxObject.separate`.
	 * To create your own collision logic, write your own `ProcessCallback` and use `FlxG.overlap` to set it up.
	 * NOTE: does NOT take objects' `scrollFactor` into account, all overlaps are checked in world space.
	 *
	 * @param   a        The first object or group you want to check.
	 * @param   b        The second object or group you want to check. Can be the same group as the first.
	 * @param   notify   Called on every object that overlaps another.
	 * 
	 * @return  Whether any objects were successfully collided/separated.
	 */
	public inline function collide<TA:FlxObject, TB:FlxObject>(?a:FlxBasic, ?b:FlxBasic, ?notify:(TA, TB)->Void)
	{
		return overlap(a, b, notify, separate);
	}
	
	/**
	 * Separates 2 overlapping objects. If an object is a tilemap,
	 * it will separate it from any tiles that overlap it.
	 * 
	 * @return  Whether the objects were overlapping and were separated
	 */
	public function separate(object1:FlxObject, object2:FlxObject)
	{
		return processCheckTilemap(object1, object2, checkAndSeparate);
		
		// final separatedX = separateX(object1, object2);
		// final separatedY = separateY(object1, object2);
		// return separatedX || separatedY;
	}
	
	/**
	 * Internal elper that determines whether either object is a tilemap, determines
	 * which tiles are overlapping and calls the appropriate separator
	 * 
	 * @param   func         The process you wish to call with both objects, or between tiles,
	 *                       
	 * @param   isCollision  Does nothing, if both objects are immovable
	 * @return  The result of whichever separator was used
	 */
	function processCheckTilemap(object1:FlxObject, object2:FlxObject, func:(FlxObject, FlxObject)->Bool):Bool
	{
		// two immovable objects cannot collide
		if (object1.immovable && object2.immovable)
			return false;
		
		// If one of the objects is a tilemap, just pass it off.
		if (object1.flixelType == TILEMAP)
		{
			final tilemap:FlxBaseTilemap<FlxObject> = cast object1;
			// If object1 is a tilemap, check it's tiles against object2, which may also be a tilemap
			function recurseProcess(tile)
			{
				// Keep tile as first arg
				return processCheckTilemap(tile, object2, func);
			}
			return tilemap.forEachCollidingTile(object2, recurseProcess);
		}
		else if (object2.flixelType == TILEMAP)
		{
			final tilemap:FlxBaseTilemap<FlxObject> = cast object2;
			// If object1 is a tilemap, check it's tiles against object2, which may also be a tilemap
			function recurseProcess(tile)
			{
				// Keep tile as second arg
				return processCheckTilemap(object1, tile, func);
			}
			return tilemap.forEachCollidingTile(object1, recurseProcess);
		}
		
		return func(object1, object2);
	}
	
	static final overlapHelperPoint = FlxPoint.get();
	function checkAndSeparate(object1:FlxObject, object2:FlxObject)
	{
		if (checkDeltaOverlaps(object1, object2))
		{
			// check if any collisions are allowed
			final allowX = checkCollisionXHelper(object1, object2);
			final allowY = checkCollisionYHelper(object1, object2);
			if (!allowX && !allowY)
				return false;
			
			// determine the amount of overlap
			final overlap = object1.computeCollisionOverlap(object2, overlapHelperPoint);
			
			// seprate x
			if (allowX && overlap.x != 0)
			{
				updateTouchingFlagsXHelper(object1, object2);
				separateXHelper(object1, object2, overlap.x);
			}
			
			// seprate y
			if (allowY && overlap.y != 0)
			{
				updateTouchingFlagsYHelper(object1, object2);
				separateYHelper(object1, object2, overlap.y);
			}
			
			return true;
		}
		
		return false;
	}
	
	public function checkCollision(object1:FlxObject, object2:FlxObject)
	{
		return checkDeltaOverlaps(object1, object2)
			&& (checkCollisionXHelper(object1, object2) || checkCollisionYHelper(object1, object2));
	}
	
	/**
	 * Internal function use to determine if two objects may cross path,
	 * by comparing the bounds they occupy this frame
	 */
	function checkDeltaOverlaps(object1:FlxObject, object2:FlxObject)
	{
		return object1.overlapsDelta(object2);
	}
	
	function separateXHelper(object1:FlxObject, object2:FlxObject, overlap:Float)
	{
		final delta1 = object1.x - object1.last.x;
		final delta2 = object2.x - object2.last.x;
		final vel1 = object1.velocity.x;
		final vel2 = object2.velocity.x;
		
		if (!object1.immovable && !object2.immovable)
		{
			#if FLX_4_LEGACY_COLLISION
			legacySeparateX(object1, object2, overlap);
			#else
			object1.x -= overlap * 0.5;
			object2.x += overlap * 0.5;
			
			final mass1 = object1.mass;
			final mass2 = object2.mass;
			final momentum = mass1 * vel1 + mass2 * vel2;
			object1.velocity.x = (momentum + object1.elasticity * mass2 * (vel2 - vel1)) / (mass1 + mass2);
			object2.velocity.x = (momentum + object2.elasticity * mass1 * (vel1 - vel2)) / (mass1 + mass2);
			#end
		}
		else if (!object1.immovable)
		{
			object1.x -= overlap;
			object1.velocity.x = vel2 - vel1 * object1.elasticity;
		}
		else if (!object2.immovable)
		{
			object2.x += overlap;
			object2.velocity.x = vel1 - vel2 * object2.elasticity;
		}
		
		// use collisionDrag properties to determine whether one object
		if (allowCollisionDrag(object1.collisionYDrag, object1, object2) && delta1 > delta2)
			object1.y += object2.y - object2.last.y;
		else if (allowCollisionDrag(object2.collisionYDrag, object2, object1) && delta2 > delta1)
			object2.y += object1.y - object1.last.y;
	}
	
	function separateYHelper(object1:FlxObject, object2:FlxObject, overlap:Float)
	{
		final delta1 = object1.y - object1.last.y;
		final delta2 = object2.y - object2.last.y;
		final vel1 = object1.velocity.y;
		final vel2 = object2.velocity.y;
		
		if (!object1.immovable && !object2.immovable)
		{
			#if FLX_4_LEGACY_COLLISION
			legacySeparateY(object1, object2, overlap);
			#else
			object1.y -= overlap / 2;
			object2.y += overlap / 2;
			
			final mass1 = object1.mass;
			final mass2 = object2.mass;
			final momentum = mass1 * vel1 + mass2 * vel2;
			final newVel1 = (momentum + object1.elasticity * mass2 * (vel2 - vel1)) / (mass1 + mass2);
			final newVel2 = (momentum + object2.elasticity * mass1 * (vel1 - vel2)) / (mass1 + mass2);
			object1.velocity.y = newVel1;
			object2.velocity.y = newVel2;
			#end
		}
		else if (!object1.immovable)
		{
			object1.y -= overlap;
			object1.velocity.y = vel2 - vel1 * object1.elasticity;
		}
		else if (!object2.immovable)
		{
			object2.y += overlap;
			object2.velocity.y = vel1 - vel2 * object2.elasticity;
		}
		
		// use collisionDrag properties to determine whether one object
		if (allowCollisionDrag(object1.collisionXDrag, object1, object2) && delta1 > delta2)
			object1.x += object2.x - object2.last.x;
		else if (allowCollisionDrag(object2.collisionXDrag, object2, object1) && delta2 > delta1)
			object2.x += object1.x - object1.last.x;
	}
	
	/**
	 * Helper to determine which edges of `object1`, if any, will strike the opposing edge of `object2`
	 * based solely on their delta positions
	 */
	public function getCollisionEdge(object1:FlxObject, object2:FlxObject)
	{
		return getCollisionEdgeX(object1, object2) | getCollisionEdgeY(object1, object2);
	}
	
	
	/**
	 * Helper to determine which horizontal edge of `object1`, if any, will strike the opposing edge of `object2`
	 * based solely on their delta positions
	 */
	public function getCollisionEdgeX(object1:FlxObject, object2:FlxObject)
	{
		final deltaDiff = (object1.x - object1.last.x) - (object2.x - object2.last.x);
		return deltaDiff == 0 ? NONE : deltaDiff > 0 ? RIGHT : LEFT;
	}
	
	/**
	 * Helper to determine which vertical edge of `object1`, if any, will strike the opposing edge of `object2`
	 * based solely on their delta positions
	 */
	public function getCollisionEdgeY(object1:FlxObject, object2:FlxObject)
	{
		final deltaDiff = (object1.y - object1.last.y) - (object2.y - object2.last.y);
		return abs(deltaDiff) < 0.0001 ? NONE : deltaDiff > 0 ? DOWN : UP;
	}
	
	inline function canObjectCollide(obj:FlxObject, dir:FlxDirectionFlags)
	{
		return obj.allowCollisions.has(dir);
	}
	
	function checkCollisionXHelper(object1:FlxObject, object2:FlxObject)
	{
		final dir = getCollisionEdgeX(object1, object2);
		return (dir == RIGHT && canObjectCollide(object1, RIGHT) && canObjectCollide(object2, LEFT))
			|| (dir == LEFT && canObjectCollide(object1, LEFT) && canObjectCollide(object2, RIGHT));
	}
	
	function checkCollisionYHelper(object1:FlxObject, object2:FlxObject)
	{
		final dir = getCollisionEdgeY(object1, object2);
		return (dir == DOWN && canObjectCollide(object1, DOWN) && canObjectCollide(object2, UP))
			|| (dir == UP && canObjectCollide(object1, UP) && canObjectCollide(object2, DOWN));
	}
	
	/** Determines if the two objects crossed pathed this frame and computes their overlap, otherwise returns (0, 0) **/
	public function computeCollisionOverlap(object1:FlxObject, object2:FlxObject, ?result:FlxPoint)
	{
		if (checkCollision(object1, object2))
			object1.computeCollisionOverlap(object2, result);
		
		return result;
	}
	
	function updateTouchingFlagsXHelper(object1:FlxObject, object2:FlxObject)
	{
		if ((object1.x - object1.last.x) > (object2.x - object2.last.x))
		{
			object1.touching |= RIGHT;
			object2.touching |= LEFT;
		}
		else
		{
			object1.touching |= LEFT;
			object2.touching |= RIGHT;
		}
	}
	
	function updateTouchingFlagsYHelper(object1:FlxObject, object2:FlxObject)
	{
		if ((object1.y - object1.last.y) > (object2.y - object2.last.y))
		{
			object1.touching |= DOWN;
			object2.touching |= UP;
		}
		else
		{
			object1.touching |= UP;
			object2.touching |= DOWN;
		}
	}
	
	function allowCollisionDrag(type:CollisionDragType, object1:FlxObject, object2:FlxObject):Bool
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
	 * The separateX that existed before HaxeFlixel 5.0, preserved for anyone who
	 * needs to use it in an old project. Does not preserve momentum, avoid if possible
	 */
	static inline function legacySeparateX(object1:FlxObject, object2:FlxObject, overlap:Float)
	{
		final vel1 = object1.velocity.x;
		final vel2 = object2.velocity.x;
		final mass1 = object1.mass;
		final mass2 = object2.mass;
		object1.x = object1.x - (overlap * 0.5);
		object2.x += overlap * 0.5;
		
		var newVel1 = Math.sqrt((vel2 * vel2 * mass2) / mass1) * ((vel2 > 0) ? 1 : -1);
		var newVel2 = Math.sqrt((vel1 * vel1 * mass1) / mass2) * ((vel1 > 0) ? 1 : -1);
		final average = (newVel1 + newVel2) * 0.5;
		newVel1 -= average;
		newVel2 -= average;
		object1.velocity.x = average + (newVel1 * object1.elasticity);
		object2.velocity.x = average + (newVel2 * object2.elasticity);
	}
	
	/**
	 * The separateY that existed before HaxeFlixel 5.0, preserved for anyone who
	 * needs to use it in an old project. Does not preserve momentum, avoid if possible
	 */
	static inline function legacySeparateY(object1:FlxObject, object2:FlxObject, overlap:Float)
	{
		final vel1 = object1.velocity.y;
		final vel2 = object2.velocity.y;
		final mass1 = object1.mass;
		final mass2 = object2.mass;
		object1.y = object1.y - (overlap * 0.5);
		object2.y += overlap * 0.5;
		
		var newVel1 = Math.sqrt((vel2 * vel2 * mass2) / mass1) * ((vel2 > 0) ? 1 : -1);
		var newVel2 = Math.sqrt((vel1 * vel1 * mass1) / mass2) * ((vel1 > 0) ? 1 : -1);
		final average = (newVel1 + newVel2) * 0.5;
		newVel1 -= average;
		newVel2 -= average;
		object1.velocity.y = average + (newVel1 * object1.elasticity);
		object2.velocity.y = average + (newVel2 * object2.elasticity);
	}
}

private inline function abs(n:Float)
{
	return n > 0 ? n : -n;
}

private inline function min(a:Float, b:Float)
{
	return a < b ? a : b;
}