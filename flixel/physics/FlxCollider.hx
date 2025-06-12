package flixel.physics;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxSignal;

typedef ProcessCallback = (IFlxCollider, IFlxCollider)->Bool;
typedef Processer = (a:IFlxCollider, b:IFlxCollider, callback:ProcessCallback)->Bool;
typedef OverlapComputer = (a:IFlxCollider, b:IFlxCollider, result:FlxPoint)->FlxPoint;

enum FlxColliderShape
{
	/** Axis-aligned bounding box, a rectangle that cannot rotate. The default shape */
	AABB;
	
	// CIRCLE; // coming soon
	
	/**
	 * A custom shape that can compute it's own overlap.
	 * 
	 * @param   name            This shape's identifier, useful for resolving two custom shapes
	 * @param   computeOverlap  A function that takes two colliders and determines how much
	 *                          they overlap, and in which direction
	 */
	CUSTOM(name:String, computeOverlap:(collider:IFlxCollider, ?result:FlxPoint)->FlxPoint);
}

enum FlxColliderType
{
	/** Colliders that contain a single shape */
	SHAPE(shape:FlxColliderShape);
	
	/** Special type that processes colliding objects against nearby tiles */
	TILEMAP;
	
	/**
	 * A type consisting of multiple "child" colliders, where, unlike groups, the colliders are not
	 * individually added to the quad tree, but checked against the parent's bounds before using
	 * the given `processer` to check each child
	 * 
	 * @param   processer  A function called on any child colliders whos bounds overlap the given collider
	 */
	MULTI(processer:(collider:IFlxCollider, func:(IFlxCollider)->Bool)->Bool);
}

class FlxCollider
{
	/**  The axis-aligned world bounds of this collider */
	public var bounds(default, null):FlxRect = FlxRect.get();
	
	/**  The world position of this collider prior to this frame's update */
	public var last(default, null):FlxPoint = FlxPoint.get();
	
	public var velocity(default, null):FlxPoint = FlxPoint.get();
	
	public var acceleration(default, null):FlxPoint = FlxPoint.get();
	
	public var dragMode:FlxDragMode = INERTIAL;
	
	public var drag:FlxForceType = NONE;
	
	public var maxVelocity:FlxForceType = NONE;
	
	public var allowCollisions = FlxDirectionFlags.ANY;
	
	public var touching = FlxDirectionFlags.NONE;
	
	public var wasTouching = FlxDirectionFlags.NONE;
	
	/** Whether the collider can be moved by other colliders */
	public var immovable = false;
	
	public var mass = 1.0;
	
	/** The amount of momentum conserved after a collision, defaults to `0` meaning, collisions will stop the collider */
	public var elasticity = 0.0;
	
	public var onBoundsCollide = new FlxTypedSignal<(collider:IFlxCollider)->Void>();
	public var onCollide = new FlxTypedSignal<(collider:IFlxCollider, overlap:FlxPoint)->Void>();
	public var onSeparate = new FlxTypedSignal<(collider:IFlxCollider, overlap:FlxPoint)->Void>();
	
	/**
	 * Whether this sprite is dragged along with the horizontal movement of objects it collides with
	 * (makes sense for horizontally-moving platforms in platformers for example). Use values
	 * IMMOVABLE, ALWAYS, HEAVIER or NEVER
	 */
	public var collisionXDrag:FlxCollisionDragType = IMMOVABLE;

	/**
	 * Whether this sprite is dragged along with the vertical movement of objects it collides with
	 * (for sticking to vertically-moving platforms in platformers for example). Use values
	 * IMMOVABLE, ALWAYS, HEAVIER or NEVER
	 */
	public var collisionYDrag:FlxCollisionDragType = NEVER;
	
	public var x(get, set):Float;
	
	public var y(get, set):Float;
	
	public var width(get, set):Float;
	
	public var height(get, set):Float;
	
	public var centerX(get, never):Float;
	
	public var centerY(get, never):Float;
	
	public var left(get, never):Float;
	
	public var right(get, never):Float;
	
	public var top(get, never):Float;
	
	public var bottom(get, never):Float;
	
	/** The distance this collider has moved this frame */
	public var deltaX(get, never):Float;
	
	/** The distance this collider has moved this frame */
	public var deltaY(get, never):Float;
	
	/** Whether this collider will update its position, velocity and acceleration */
	public var moves:Bool;
	
	public var type:FlxColliderType;
	
	/**
	 * Creates a new collider
	 * 
	 * @param   type  Defaults to `SHAPE(AABB)`
	 */
	public function new (?type:FlxColliderType)
	{
		if (type == null)
			type = SHAPE(AABB);
		this.type = type;
	}
	
	public function destroy()
	{
		bounds = FlxDestroyUtil.destroy(bounds);
		last = FlxDestroyUtil.destroy(last);
		velocity = FlxDestroyUtil.destroy(velocity);
		acceleration = FlxDestroyUtil.destroy(acceleration);
		onCollide.removeAll();
		onSeparate.removeAll();
	}
	
	public function update(elapsed:Float)
	{
		last.set(x, y);
		if (moves)
		{
			final lastVelocityX = velocity.x;
			final lastVelocityY = velocity.y;
			velocity.x += acceleration.x * elapsed;
			velocity.y += acceleration.y * elapsed;
			
			applyDrag(elapsed);
			constrainVelocity();
			
			x += (lastVelocityX + 0.5 * (velocity.x - lastVelocityX)) * elapsed;
			y += (lastVelocityY + 0.5 * (velocity.y - lastVelocityY)) * elapsed;
		}
	}
	
	function applyDrag(elapsed:Float)
	{
		switch drag
		{
			case NONE:
			case ORTHO(dragX, dragY):
				
				if (dragX > 0)
					velocity.x = FlxColliderUtil.applyDrag1D(velocity.x, acceleration.x, dragX * elapsed, dragMode);
				
				if (dragY > 0)
					velocity.y = FlxColliderUtil.applyDrag1D(velocity.y, acceleration.y, dragY * elapsed, dragMode);
				
			case LINEAR(drag):
				
				final apply = switch dragMode
				{
					case ALWAYS: true;
					case INERTIAL: acceleration.isZero();
					case SKID: velocity.dot(acceleration) < 0;
				}
				
				if (apply)
				{
					final speed = velocity.length;
					final frameDrag = FlxColliderUtil.getDrag1D(speed, drag) * elapsed;
					velocity.length = speed + drag;
				}
		}
	}
	
	function constrainVelocity()
	{
		switch maxVelocity
		{
			case NONE:
			case ORTHO(maxX, maxY):
				if (maxX > 0)
				{
					if (velocity.x > maxX)
						velocity.x = maxX;
					else if (velocity.x < -maxX)
						velocity.x = -maxX;
				}
				
				if (maxY > 0)
				{
					if (velocity.y > maxY)
						velocity.y = maxY;
					else if (velocity.y < -maxY)
						velocity.y = -maxY;
				}
			case LINEAR(max):
				
				final speed = velocity.length;
				if (speed > max)
					velocity.scale(max / speed, max / speed);
		}
	}
	
	/**
	 * The smallest rect that contains the object in it's current and last position
	 * 
	 * @param   rect  Optional point to store the result, if `null` one is created
	 * @since 6.2.0
	 */
	public function getDeltaRect(?rect:FlxRect)
	{
		if (rect == null)
			rect = FlxRect.get();
		
		rect.x = bounds.x > last.x ? last.x : bounds.x;
		rect.right = (bounds.x > last.x ? bounds.x : last.x) + bounds.width;
		rect.y = bounds.y > last.y ? last.y : bounds.y;
		rect.bottom = (bounds.y > last.y ? bounds.y : last.y) + bounds.height;
		
		return rect;
	}
	
	inline function get_x():Float { return bounds.x; }
	inline function get_y():Float { return bounds.y; }
	inline function get_width():Float { return bounds.width; }
	inline function get_height():Float { return bounds.height; }
	
	inline function set_x(value:Float):Float { return bounds.x = value; }
	inline function set_y(value:Float):Float { return bounds.y = value; }
	inline function set_width(value:Float):Float { return bounds.width = value; }
	inline function set_height(value:Float):Float { return bounds.height = value; }
	
	inline function get_centerX():Float { return bounds.x + bounds.width * 0.5; }
	inline function get_centerY():Float { return bounds.y + bounds.height * 0.5; }
	inline function get_left():Float { return bounds.left; }
	inline function get_right():Float { return bounds.right; }
	inline function get_top():Float { return bounds.top; }
	inline function get_bottom():Float { return bounds.bottom; }
	
	inline function get_deltaX():Float { return x - last.x; }
	inline function get_deltaY():Float { return y - last.y; }
}

class FlxColliderUtil
{
	/**
	 * A tween-like function that takes a starting velocity and some other factors and returns an altered velocity.
	 *
	 * @param   velocity      The x or y component of the starting speed
	 * @param   acceleration  The rate at which the velocity is changing.
	 * @param   drag          The deceleration of the object
	 * @param   max           An absolute value cap for the velocity (0 for no cap).
	 * @param   elapsed       The amount of time passed in to the latest update cycle
	 * @return  The altered velocity value.
	 */
	public static function applyDrag1D(velocity:Float, acceleration:Float, drag:Float, mode:FlxDragMode):Float
	{
		final apply = velocity != 0 && switch mode
		{
			case ALWAYS: true;
			case INERTIAL: acceleration == 0;
			case SKID: (acceleration == 0 || ((acceleration > 0) != (velocity > 0)));
		}
		
		return apply ? getDrag1D(velocity, drag) : velocity;
	}
	
	public static function getDrag1D(velocity:Float, drag:Float):Float
	{
		return if (velocity > 0 && velocity - drag > 0)
			velocity - drag;
		else if (velocity < 0 && velocity + drag < 0)
			velocity + drag;
		else
			0;
	}
	
	/**
	 * Checks whether the two objects' delta rects overlap
	 * @see FlxCollision.getDeltaRect
	 * @since 6.2.0
	 */
	overload public static inline extern function overlapsDelta(a:IFlxCollider, b:IFlxCollider)
	{
		return overlapsDeltaHelper(a.getCollider(), b.getCollider());
	}
	
	/**
	 * Checks whether the two colliders' delta rects overlap
	 * 
	 * @see FlxCollider.getDeltaRect
	 * @since 6.2.0
	 */
	overload public static inline extern function overlapsDelta(a:FlxCollider, b:FlxCollider)
	{
		return overlapsDeltaHelper(a, b);
	}
	
	static function overlapsDeltaHelper(a:FlxCollider, b:FlxCollider)
	{
		final rect1 = a.getDeltaRect();
		final rect2 = b.getDeltaRect();
		
		final result = rect1.overlaps(rect2);
		
		rect1.put();
		rect2.put();
		return result;
	}
	
	public static function process(a:IFlxCollider, b:IFlxCollider, func:(IFlxCollider, IFlxCollider)->Bool):Bool
	{
		final colliderA = a.getCollider();
		final colliderB = b.getCollider();
		return func(a, b) && processSub(a, b, colliderA, colliderB, func);
	}
	
	static function processSub(a:IFlxCollider, b:IFlxCollider, colliderA:FlxCollider, colliderB:FlxCollider, func:(IFlxCollider, IFlxCollider)->Bool):Bool
	{
		return switch colliderA.type
		{
			case TILEMAP:
				final tilemap:FlxBaseTilemap<FlxObject> = cast a;
				return tilemap.forEachCollidingTile(b, (tile)->processSub(tile, b, tile.getCollider(), colliderB, func), false);
			case MULTI(processer):
				return processer(b, (childA)->processSub(childA, b, childA.getCollider(), colliderB, func));
			case SHAPE(shape):
				return switch colliderB.type
				{
					case TILEMAP:
						final tilemap:FlxBaseTilemap<FlxObject> = cast b;
						return tilemap.forEachCollidingTile(a, (tile)->processSub(a, tile, colliderA, tile.getCollider(), func), false);
					case MULTI(processer):
						return processer(a, (childB)->processSub(a, childB, colliderA, childB.getCollider(), func));
					case SHAPE(shape):
						return func(a, b);
				}
		}
	}
	
	public static function computeCollisionOverlap(a:IFlxCollider, b:IFlxCollider, maxOverlap:Float, ?result:FlxPoint):FlxPoint
	{
		final colliderA = a.getCollider();
		final colliderB = b.getCollider();
		return switch [colliderA.type, colliderB.type]
		{
			case [SHAPE(shapeA), SHAPE(shapeB)]:
				switch [shapeA, shapeB]
				{
					case [CUSTOM(_, func), _]: func(b, result);
					case [_, CUSTOM(_, func)]: func(a, result).negate();
					case [AABB, AABB]: computeCollisionOverlapAabb(colliderA, colliderB, maxOverlap, result);
					case [shapeA, shapeB]: throw 'Unexpected types: [$shapeA, $shapeB]';
				}
			default:
				throw "Cannot compute overlap with a MULTI or TILEMAP collider";
		}
	}
	
	//{ region    --- TILEMAP ---
	
	// /**
	//  * Helper to compute the overlap of two objects, this is used when
	//  * `objectA.computeCollisionOverlap(objectB)` is called on two objects
	//  */
	// public static function computeCollisionOverlapTilemap(tilemap:FlxBaseTilemap<FlxObject>, b:FlxObject, ?result:FlxPoint)
	// {
	// 	if (result == null)
	// 		result = FlxPoint.get();
	// 	else
	// 		result.set();
		
	// 	final overlap = FlxPoint.get();
	// 	function each (tile:FlxObject)
	// 	{
	// 		FlxColliderUtil.computeCollisionOverlap(tile, b, overlap);
	// 		// if (result.isZero() && (overlap.x != 0 || overlap.y != 0))
	// 		if (result.lengthSquared < overlap.lengthSquared)
	// 		{
	// 			result.copyFrom(overlap);
	// 			return true;
	// 		}
	// 		return false;
	// 	}
	// 	tilemap.forEachCollidingTile(b, each, false);
	// 	overlap.put();
	// 	return result;
	// }
	
	//{ endregion --- TILEMAP ---
	
	
	//{ region    --- AABB ---
	
	/**
	 * Helper to compute the overlap of two objects, this is used when
	 * `a.computeCollisionOverlap(b)` is called on two objects
	 */
	public static function computeCollisionOverlapAabb(a:FlxCollider, b:FlxCollider, maxOverlap:Float, ?result:FlxPoint)
	{
		if (result == null)
			result = FlxPoint.get();
		
		if (!checkForPenetration(a, b))
			return result.set(0, 0);
		
		final allowX = checkCollisionEdgesX(a, b);
		final allowY = checkCollisionEdgesY(a, b);
		if (!allowX && !allowY)
			return result.set(0, 0);
		
		function abs(n:Float) return n < 0 ? -n : n;
		
		// only X
		if (checkForFullPenetrationX(a, b) || allowX && !allowY)
		{
			final overlap = computeCollisionOverlapXAabb(a, b);
			if (abs(overlap) > maxOverlap)
				return result;
			
			return result.set(overlap, 0);
		}
		
		// only Y
		if (checkForFullPenetrationY(a, b) || !allowX && allowY)
		{
			final overlap = computeCollisionOverlapYAabb(a, b);
			if (abs(overlap) > maxOverlap)
				return result;
			
			return result.set(0, overlap);
		}
		
		result.set(computeCollisionOverlapXAabb(a, b), computeCollisionOverlapYAabb(a, b));
		
		final absX = abs(result.x);
		final absY = abs(result.y);
		
		// separate on the smaller axis
		if (absX > absY)
		{
			result.x = 0;
			if (absY > maxOverlap)
				result.y = 0;
		}
		else
		{
			result.y = 0;
			if (absX > maxOverlap)
				result.x = 0;
		}
		
		return result;
	}
	
	/**
	 * Checks whether the colliders overlap, or if they did overlap this frame
	 */
	public static function checkForPenetration(a:FlxCollider, b:FlxCollider)
	{
		return a.bounds.overlaps(b.bounds)
			|| (checkForFullPenetrationX(a, b))
			|| (checkForFullPenetrationY(a, b));
		
	}
	
	/**
	 * Checks whether one collider fully passed the other, this frame, in the X axis
	 */
	public static function checkForFullPenetrationX(a:FlxCollider, b:FlxCollider)
	{
		return a.bounds.overlapsY(b.bounds) && (a.deltaX > b.deltaX
			? a.left > b.right && a.last.x + a.width < b.last.x
			: a.right < b.left && a.last.x > b.last.x + b.width);
	}
	
	/**
	 * Checks whether one collider fully passed the other, this frame, in the Y axis
	 */
	public static function checkForFullPenetrationY(a:FlxCollider, b:FlxCollider)
	{
		return a.bounds.overlapsX(b.bounds) && (a.deltaY > b.deltaY
			? a.top > b.bottom && a.last.y + a.height < b.last.y
			: a.bottom < b.top && a.last.y > b.last.y + b.height);
	}
	
	/**
	 * Helper to compute the X overlap of two objects, this is used when
	 * `a.computeCollisionOverlapX(b)` is called on two objects
	 */
	public static function computeCollisionOverlapXAabb(a:FlxCollider, b:FlxCollider):Float
	{
		if (a.deltaX > b.deltaX)
			return a.x + a.width - b.x;
		
		return a.x - b.width - b.x;
	}
	
	/**
	 * Helper to compute the Y overlap of two objects, this is used when
	 * `a.computeCollisionOverlapY(b)` is called on two objects
	 */
	public static function computeCollisionOverlapYAabb(a:FlxCollider, b:FlxCollider):Float
	{
		if (a.deltaY > b.deltaY)
			return a.y + a.height - b.y;
		
		return a.y - b.height - b.y;
	}
	
	//} endregion --- AABB ---
	
	/**
	 * Helper to determine which edges of `a`, if any, will strike the opposing edge of `b`
	 * based solely on their delta positions
	 * 
	 * @param   elseBoth  Whether to return `NONE` or "both" directions, when the objects are
	 *                    not moving relative to one another
	 */
	public static function getCollisionEdges(a:FlxCollider, b:FlxCollider, elseBoth = false)
	{
		return getCollisionEdgesX(a, b, elseBoth) | getCollisionEdgesY(a, b, elseBoth);
	}
	
	/**
	 * Helper to determine which horizontal edge of `a`, if any, will strike the opposing edge of `b`
	 * based solely on their delta positions
	 * 
	 * @param   elseBoth  Whether to return `NONE` or "both" directions, when the objects are
	 *                    not moving relative to one another
	 */
	public static function getCollisionEdgesX(a:FlxCollider, b:FlxCollider, elseBoth = false):FlxDirectionFlags
	{
		final deltaDiff = a.deltaX - b.deltaX;
		return abs(deltaDiff) < 0.0001 ? (elseBoth ? RIGHT | LEFT : NONE) : deltaDiff > 0 ? RIGHT : LEFT;
	}
	
	
	/**
	 * Helper to determine which vertical edge of `a`, if any, will strike the opposing edge of `b`
	 * based solely on their delta positions
	 * 
	 * @param   elseBoth  Whether to return `NONE` or "both" directions, when the objects are
	 *                    not moving relative to one another
	 */
	public static function getCollisionEdgesY(a:FlxCollider, b:FlxCollider, elseBoth = false):FlxDirectionFlags
	{
		final deltaDiff = a.deltaY - b.deltaY;
		return abs(deltaDiff) < 0.0001 ? (elseBoth ? DOWN | UP : NONE) : deltaDiff > 0 ? DOWN : UP;
	}
	
	static inline function canObjectCollide(obj:FlxCollider, dir:FlxDirectionFlags)
	{
		return obj.allowCollisions.has(dir);
	}
	
	/**
	 * Returns whether thetwo objects can collide in the X direction they are traveling.
	 * Checks `allowCollisions`.
	 * 
	 * @param   elseBoth  Whether to return `NONE` or "both" directions, when the objects are
	 *                    not moving relative to one another
	 */
	public static function checkCollisionEdgesX(a:FlxCollider, b:FlxCollider, elseBoth = false)
	{
		final dir = getCollisionEdgesX(a, b, elseBoth);
		return (dir.has(RIGHT) && canObjectCollide(a, RIGHT) && canObjectCollide(b, LEFT))
			|| (dir.has(LEFT) && canObjectCollide(a, LEFT) && canObjectCollide(b, RIGHT));
	}
	
	/**
	 * Returns whether thetwo objects can collide in the Y direction they are traveling.
	 * Checks `allowCollisions`.
	 * 
	 * @param   elseBoth  Whether to return `NONE` or "both" directions, when the objects are
	 *                    not moving relative to one another
	 */
	public static function checkCollisionEdgesY(a:FlxCollider, b:FlxCollider, elseBoth = false)
	{
		final dir = getCollisionEdgesY(a, b, elseBoth);
		return (dir.has(DOWN) && canObjectCollide(a, DOWN) && canObjectCollide(b, UP))
			|| (dir.has(UP) && canObjectCollide(a, UP) && canObjectCollide(b, DOWN));
	}
}

interface IFlxCollider
{
	/**
	 * The collider of this object
	 * **Note:** For FlxObjects calling this will copy the objects collision properties into the collider
	 */
	function getCollider():FlxCollider;
}

/**
 * Determines when to apply collision drag to one object that collided with another.
 */
enum abstract FlxCollisionDragType(Int)
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

enum FlxForceType
{
	NONE;
	ORTHO(x:Float, y:Float);
	LINEAR(amount:Float);
}

enum FlxDragMode
{
	/** Drag is applied every frame */
	ALWAYS;
	
	/** Drag is applied every frame that the object is not accelerating */
	INERTIAL;
	
	/** Drag is applied every frame that the object is not accelerating in the current direction of motion */
	SKID;
}

private inline function abs(n:Float)
{
	return n > 0 ? n : -n;
}

private inline function min(a:Float, b:Float)
{
	return a < b ? a : b;
}