package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.physics.FlxCollider;
import flixel.physics.FlxCollisionQuadTree;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxDirectionFlags;

using flixel.physics.FlxCollider.FlxColliderUtil;
using flixel.util.FlxCollision;

@:access(flixel.FlxObject)
class CollisionFrontEnd
{
	/**
	 * Collisions between FlxObjects will not resolve overlaps larger than this values, in pixels
	 */
	public var maxOverlap = 4.0;
	
	/**
	 * How many times the quad tree should divide the world on each axis.
	 * Generally, sparse collisions can have fewer divisons,
	 * while denser collision activity usually profits from more. Default value is `6`.
	 */
	public static var worldDivisions:Int = 6;
	
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
		return FlxCollisionQuadTree.executeOnce(FlxG.worldBounds, FlxG.worldDivisions, a, b, cast notify, cast process);
	}
	
	/**
	 * Call this function to see if one `FlxObject` collides with another within `FlxG.worldBounds`.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a FlxGroup (or even bundling groups together!).
	 *
	 * This function just calls `overlap` and presets the `processer` parameter to `separate`.
	 * To create your own collision logic, write your own `processer` and use `overlap` to set it up.
	 * **NOTE:** does NOT take sprites' `scrollFactor` into account, all overlaps are checked in world space.
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
	public function separate(a:FlxObject, b:FlxObject)
	{
		return FlxColliderUtil.process(a, b, checkAndSeparate);
	}
	
	static final overlapHelperPoint = FlxPoint.get();
	static final overlapInverseHelperPoint = FlxPoint.get();
	function checkAndSeparate(a:IFlxCollider, b:IFlxCollider)
	{
		final colliderA = a.getCollider();
		final colliderB = b.getCollider();
		// if (colliderA.overlapsDelta(colliderB))
		// {
			colliderA.onBoundsCollide.dispatch(b);
			colliderB.onBoundsCollide.dispatch(a);
			
			if (!colliderA.type.match(SHAPE(_)) || !colliderB.type.match(SHAPE(_)))
				return true;
			
			final overlap = a.computeCollisionOverlap(b, maxOverlap);
			
			
			if (overlap.isZero())
				return false;
			
			final negativeOverlap = overlap.copyTo(overlapInverseHelperPoint);
			
			colliderA.onCollide.dispatch(b, overlap);
			colliderB.onCollide.dispatch(a, negativeOverlap);
			
			// seprate x
			if (overlap.x != 0)
			{
				updateTouchingFlagsXHelper(colliderA, colliderB);
				separateXHelper(colliderA, colliderB, overlap.x);
			}
			
			// seprate y
			if (overlap.y != 0)
			{
				updateTouchingFlagsYHelper(colliderA, colliderB);
				separateYHelper(colliderA, colliderB, overlap.y);
			}
			
			updateObjectFields(a, colliderA);
			updateObjectFields(b, colliderB);
			
			colliderA.onSeparate.dispatch(b, overlap);
			colliderB.onSeparate.dispatch(a, negativeOverlap);
			negativeOverlap.put();
			
			return true;
		// }
		
		// return false;
	}
	
	/**
	 * Updates the legacy object's fields so they match the collider's, these vars are to preserve
	 * reflection in existing games
	 */
	function updateObjectFields(obj:IFlxCollider, collider:FlxCollider)
	{
		if (obj is FlxObject)
		{
			final object:FlxObject = cast obj;
			@:bypassAccessor object.x = collider.x;
			@:bypassAccessor object.y = collider.y;
			@:bypassAccessor object.touching = collider.touching;
		}
	}
	
	function separateHelper(a:FlxCollider, b:FlxCollider, overlap:FlxPoint)
	{
		final delta1 = FlxPoint.get(a.x - a.last.x, a.y - a.last.y);
		final delta2 = FlxPoint.get(b.x - b.last.x, b.y - b.last.y);
		final vel1 = a.velocity;
		final vel2 = b.velocity;
		
		if (!a.immovable && !b.immovable)
		{
			a.x -= overlap.x * 0.5;
			a.y -= overlap.y * 0.5;
			b.x += overlap.x * 0.5;
			b.y += overlap.y * 0.5;
			
			final mass1 = a.mass;
			final mass2 = b.mass;
			final momentum = mass1 * vel1.length + mass2 * vel2.length;
			
			// TODO: rebound x/y on overlap normal
			a.velocity.x = (momentum + a.elasticity * mass2 * (vel2.x - vel1.x)) / (mass1 + mass2);
			b.velocity.x = (momentum + b.elasticity * mass1 * (vel1.x - vel2.x)) / (mass1 + mass2);
		}
		else if (!a.immovable)
		{
			a.x -= overlap.x;
			a.y -= overlap.y;
			
			// TODO: rebound x/y on overlap normal
			a.velocity.x = vel2.x - vel1.x * a.elasticity;
		}
		else if (!b.immovable)
		{
			b.x += overlap.x;
			b.y += overlap.y;
			
			// TODO: rebound x/y on overlap normal
			b.velocity.x = vel1.x - vel2.x * b.elasticity;
		}
	}
	
	function separateXHelper(a:FlxCollider, b:FlxCollider, overlap:Float)
	{
		final delta1 = a.x - a.last.x;
		final delta2 = b.x - b.last.x;
		final vel1 = a.velocity.x;
		final vel2 = b.velocity.x;
		
		if (!a.immovable && !b.immovable)
		{
			a.x -= overlap * 0.5;
			b.x += overlap * 0.5;
			
			final mass1 = a.mass;
			final mass2 = b.mass;
			final momentum = mass1 * vel1 + mass2 * vel2;
			a.velocity.x = (momentum + a.elasticity * mass2 * (vel2 - vel1)) / (mass1 + mass2);
			b.velocity.x = (momentum + b.elasticity * mass1 * (vel1 - vel2)) / (mass1 + mass2);
		}
		else if (!a.immovable)
		{
			a.x -= overlap;
			a.velocity.x = vel2 - vel1 * a.elasticity;
		}
		else if (!b.immovable)
		{
			b.x += overlap;
			b.velocity.x = vel1 - vel2 * b.elasticity;
		}
		
		// use collisionDrag properties to determine whether one object
		if (allowCollisionDrag(a.collisionYDrag, a, b) && delta1 > delta2)
			a.y += b.y - b.last.y;
		else if (allowCollisionDrag(b.collisionYDrag, b, a) && delta2 > delta1)
			b.y += a.y - a.last.y;
	}
	
	function separateYHelper(a:FlxCollider, b:FlxCollider, overlap:Float)
	{
		final delta1 = a.y - a.last.y;
		final delta2 = b.y - b.last.y;
		final vel1 = a.velocity.y;
		final vel2 = b.velocity.y;
		
		if (!a.immovable && !b.immovable)
		{
			a.y -= overlap / 2;
			b.y += overlap / 2;
			
			final mass1 = a.mass;
			final mass2 = b.mass;
			final momentum = mass1 * vel1 + mass2 * vel2;
			final newVel1 = (momentum + a.elasticity * mass2 * (vel2 - vel1)) / (mass1 + mass2);
			final newVel2 = (momentum + b.elasticity * mass1 * (vel1 - vel2)) / (mass1 + mass2);
			a.velocity.y = newVel1;
			b.velocity.y = newVel2;
		}
		else if (!a.immovable)
		{
			a.y -= overlap;
			a.velocity.y = vel2 - vel1 * a.elasticity;
		}
		else if (!b.immovable)
		{
			b.y += overlap;
			b.velocity.y = vel1 - vel2 * b.elasticity;
		}
		
		// use collisionDrag properties to determine whether one object
		if (allowCollisionDrag(a.collisionXDrag, a, b) && delta1 > delta2)
			a.x += b.x - b.last.x;
		else if (allowCollisionDrag(b.collisionXDrag, b, a) && delta2 > delta1)
			b.x += a.x - a.last.x;
	}
	
	inline function canCollide(obj:FlxCollider, dir:FlxDirectionFlags)
	{
		return obj.allowCollisions.has(dir);
	}
	
	function updateTouchingFlagsXHelper(a:FlxCollider, b:FlxCollider)
	{
		if ((a.x - a.last.x) > (b.x - b.last.x))
		{
			a.touching |= RIGHT;
			b.touching |= LEFT;
		}
		else
		{
			a.touching |= LEFT;
			b.touching |= RIGHT;
		}
	}
	
	function updateTouchingFlagsYHelper(a:FlxCollider, b:FlxCollider)
	{
		if ((a.y - a.last.y) > (b.y - b.last.y))
		{
			a.touching |= DOWN;
			b.touching |= UP;
		}
		else
		{
			a.touching |= UP;
			b.touching |= DOWN;
		}
	}
	
	function allowCollisionDrag(type:FlxCollisionDragType, a:FlxCollider, b:FlxCollider):Bool
	{
		return b.moves && switch (type)
		{
			case NEVER: false;
			case ALWAYS: true;
			case IMMOVABLE: b.immovable;
			case HEAVIER: b.immovable || b.mass > a.mass;
		}
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