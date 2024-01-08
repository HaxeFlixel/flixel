package flixel.math;

import flixel.util.FlxPool;
import flixel.util.FlxStringUtil;
import openfl.geom.Matrix;
import openfl.geom.Point;

/**
 * 2-dimensional point class
 * 
 * ## Pooling
 * To avoid creating new instances, unnecessarily, used points can be
 * for later use. Rather than creating a new instance directly, call
 * `FlxPoint.get(x, y)` and it will retrieve a point from the pool, if
 * one exists, otherwise it will create a new instance. Similarly, when
 * you're done using a point, call `myPoint.put()` to place it back.
 * 
 * You can disable point pooling entirely with `FLX_NO_POINT_POOL`.
 * 
 * ## Weak points
 * Weak points are points meant for a singular use, rather than calling
 * `put` on every point you `get`, you can create a weak point, and have
 * it placed back once used. All `FlxPoint` methods and Flixel utilities
 * automatically call `putWeak()` on every point passed in.
 * 
 * In the following example, a weak point is created, and passed into
 * `p.degreesTo` where `putWeak` is called on it, putting it back in the pool.
 *
 * ```haxe
 * var angle = p.degreesTo(FlxPoint.weak(FlxG.mouse.x, FlxG.mouse.y));
 * ```
 * 
 * ## Overloaded Operators
 * 
 * - `A += B` adds the value of `B` to `A`
 * - `A -= B` subtracts the value of `B` from `A`
 * - `A *= k` scales `A` by float `k` in both x and y components
 * - `A + B` returns a new point that is sum of `A` and `B`
 * - `A - B` returns a new point that is difference of `A` and `B`
 * - `A * k` returns a new point that is `A` scaled with coefficient `k`
 *
 * Note: also accepts `openfl.geom.Point`, but always returns a FlxPoint.
 *
 * Note: that these operators get points from the pool, but do not put
 * points back in the pool, unless they are weak.
 * 
 * Example: 4 total points are created, but only 3 are put into the pool
 * ```haxe
 * var a = FlxPoint.get(1, 1);
 * var b = FlxPoint.get(1, 1);
 * var c = (a * 2.0) + b;
 * a.put();
 * b.put();
 * c.put();
 * ```
 * 
 * To put all 4 back, it should look like this:
 * ```haxe
 * var a = FlxPoint.get(1, 1);
 * var b = FlxPoint.get(1, 1);
 * var c = a * 2.0;
 * var d = c + b;
 * a.put();
 * b.put();
 * c.put();
 * d.put();
 * ```
 * 
 * Otherwise, the remainging points will become garbage, adding to the
 * heap, potentially triggering a garbage collection when you don't want.
 */
@:forward abstract FlxPoint(FlxBasePoint) to FlxBasePoint from FlxBasePoint 
{
	public static inline var EPSILON:Float = 0.0000001;
	public static inline var EPSILON_SQUARED:Float = EPSILON * EPSILON;

	static var _point1 = new FlxPoint();
	static var _point2 = new FlxPoint();
	static var _point3 = new FlxPoint();

	/**
	 * Recycle or create new FlxPoint.
	 * Be sure to put() them back into the pool after you're done with them!
	 *
	 * @param   x  The X-coordinate of the point in space.
	 * @param   y  The Y-coordinate of the point in space.
	 */
	public static inline function get(x:Float = 0, y:Float = 0):FlxPoint
	{
		return FlxBasePoint.get(x, y);
	}

	/**
	 * Recycle or create a new FlxPoint which will automatically be released
	 * to the pool when passed into a flixel function.
	 *
	 * @param   x  The X-coordinate of the point in space.
	 * @param   y  The Y-coordinate of the point in space.
	 * @since 4.6.0
	 */
	public static inline function weak(x:Float = 0, y:Float = 0):FlxPoint
	{
		return FlxBasePoint.weak(x, y);
	}

	/**
	 * Operator that adds two points, returning a new point.
	 */
	@:noCompletion
	@:op(A + B)
	static inline function plusOp(a:FlxPoint, b:FlxPoint):FlxPoint
	{
		var result = get(a.x + b.x, a.y + b.y);
		a.putWeak();
		b.putWeak();
		return result;
	}

	/**
	 * Operator that subtracts two points, returning a new point.
	 */
	@:noCompletion
	@:op(A - B)
	static inline function minusOp(a:FlxPoint, b:FlxPoint):FlxPoint
	{
		var result = get(a.x - b.x, a.y - b.y);
		a.putWeak();
		b.putWeak();
		return result;
	}

	/**
	 * Operator that scales a point by float, returning a new point.
	 */
	@:noCompletion
	@:op(A * B)
	@:commutative
	static inline function scaleOp(a:FlxPoint, b:Float):FlxPoint
	{
		var result = get(a.x * b, a.y * b);
		a.putWeak();
		return result;
	}

	
	/**
	 * Operator that divides a point by float, returning a new point.
	 */
	@:noCompletion
	@:op(A / B)
	static inline function divideOp(a:FlxPoint, b:Float):FlxPoint
	{
		var result = get(a.x / b, a.y / b);
		a.putWeak();
		return result;
	}

	/**
	 * Operator that adds the right point to the left point, returning the left point instance.
	 */
	@:noCompletion
	@:op(A += B)
	static inline function plusEqualOp(a:FlxPoint, b:FlxPoint):FlxPoint
	{
		return a.addPoint(b);
	}

	/**
	 * Operator that subtracts the right point from the left point, returning the left point instance.
	 */
	@:noCompletion
	@:op(A -= B)
	static inline function minusEqualOp(a:FlxPoint, b:FlxPoint):FlxPoint
	{
		return a.subtractPoint(b);
	}

	/**
	 * Operator that scales a point by float, returning the same point instance.
	 */
	@:noCompletion
	@:op(A *= B)
	static inline function scaleEqualOp(a:FlxPoint, b:Float):FlxPoint
	{
		return a.scale(b);
	}

	
	/**
	 * Operator that adds two points, returning a new point.
	 */
	@:noCompletion
	@:op(A + B)
	@:commutative
	static inline function plusFlashOp(a:FlxPoint, b:Point):FlxPoint
	{
		var result = get(a.x + b.x, a.y + b.y);
		a.putWeak();
		return result;
	}

	/**
	 * Operator that subtracts two points, returning a new point.
	 */
	@:noCompletion
	@:op(A - B)
	static inline function minusFlashOp(a:FlxPoint, b:Point):FlxPoint
	{
		var result = get(a.x - b.x, a.y - b.y);
		a.putWeak();
		return result;
	}

	/**
	 * Operator that subtracts two points, returning a new point.
	 */
	@:noCompletion
	@:op(A - B)
	static inline function minusFlashOp2(a:Point, b:FlxPoint):FlxPoint
	{
		var result = get(a.x - b.x, a.y - b.y);
		b.putWeak();
		return result;
	}

	/**
	 * Operator that adds the right point to the left point, returning the left point instance.
	 */
	@:noCompletion
	@:op(A += B)
	static inline function plusEqualFlashOp(a:FlxPoint, b:Point):FlxPoint
	{
		return a.add(b.x, b.y);
	}

	/**
	 * Operator that subtracts the right point from the left point, returning the left point instance.
	 */
	@:noCompletion
	@:op(A -= B)
	static inline function minusEqualFlashOp(a:FlxPoint, b:Point):FlxPoint
	{
		return a.subtract(b.x, b.y);
	}

	// Without these delegates we have to say `this.x` everywhere.
	public var x(get, set):Float;
	public var y(get, set):Float;

	/**
	 * The horizontal component of the unit point
	 */
	public var dx(get, never):Float;

	/**
	 * The vertical component of the unit point
	 */
	public var dy(get, never):Float;

	/**
	 * Length of the point
	 */
	public var length(get, set):Float;

	/**
	 * length of the point squared
	 */
	public var lengthSquared(get, never):Float;

	/**
	 * The angle formed by the point with the horizontal axis (in degrees)
	 */
	public var degrees(get, set):Float;

	/**
	 * The angle formed by the point with the horizontal axis (in radians)
	 */
	public var radians(get, set):Float;

	/**
	 * The horizontal component of the right normal of the point
	 */
	public var rx(get, never):Float;

	/**
	 * The vertical component of the right normal of the point
	 */
	public var ry(get, never):Float;

	/**
	 * The horizontal component of the left normal of the point
	 */
	public var lx(get, never):Float;

	/**
	 * The vertical component of the left normal of the point
	 */
	public var ly(get, never):Float;

	public inline function new(x:Float = 0, y:Float = 0)
	{
		this = new FlxBasePoint(x, y);
	}

	/**
	 * Set the coordinates of this point object.
	 *
	 * @param   x  The X-coordinate of the point in space.
	 * @param   y  The Y-coordinate of the point in space.
	 */
	public inline function set(x:Float = 0, y:Float = 0):FlxPoint
	{
		this.x = x;
		this.y = y;
		return this;
	}

	/**
	 * Adds to the coordinates of this point.
	 *
	 * @param   x  Amount to add to x
	 * @param   y  Amount to add to y
	 * @return  This point.
	 */
	public inline function add(x:Float = 0, y:Float = 0):FlxPoint
	{
		this.x += x;
		this.y += y;
		return this;
	}

	/**
	 * Adds the coordinates of another point to the coordinates of this point.
	 *
	 * @param   point  The point to add to this point
	 * @return  This point.
	 */
	public inline function addPoint(point:FlxPoint):FlxPoint
	{
		add(point.x, point.y);
		point.putWeak();
		return this;
	}

	/**
	 * Subtracts from the coordinates of this point.
	 *
	 * @param   x  Amount to subtract from x
	 * @param   y  Amount to subtract from y
	 * @return  This point.
	 */
	public inline function subtract(x:Float = 0, y:Float = 0):FlxPoint
	{
		this.x -= x;
		this.y -= y;
		return this;
	}

	/**
	 * Subtracts the coordinates of another point from the coordinates of this point.
	 *
	 * @param   point  The point to subtract from this point
	 * @return  This point.
	 */
	public inline function subtractPoint(point:FlxPoint):FlxPoint
	{
		subtract(point.x, point.y);
		point.putWeak();
		return this;
	}

	/**
	 * Scale this point.
	 *
	 * @param   x - scale x coefficient
	 * @param   y - scale y coefficient, if omitted, x is used
	 * @return  scaled point
	 */
	public inline function scale(x:Float, ?y:Float):FlxPoint
	{
		if (y == null)
			y = x;

		this.x *= x;
		this.y *= y;
		return this;
	}

	/**
	 * Scale this point by another point.
	 *
	 * @param   point - The x and y scale coefficient
	 * @return  scaled point
	 */
	public inline function scalePoint(point:FlxPoint):FlxPoint
	{
		scale(point.x, point.y);
		point.putWeak();
		return this;
	}

	/**
	 * Returns scaled copy of this point.
	 *
	 * @param   k - scale coefficient
	 * @return  scaled point
	 */
	public inline function scaleNew(k:Float):FlxPoint
	{
		return clone().scale(k);
	}

	/**
	 * Return new point which equals to sum of this point and passed p point.
	 *
	 * @param   p  point to add
	 * @return  addition result
	 */
	public inline function addNew(p:FlxPoint):FlxPoint
	{
		return clone().addPoint(p);
	}

	/**
	 * Returns new point which is result of subtraction of p point from this point.
	 *
	 * @param   p  point to subtract
	 * @return  subtraction result
	 */
	public inline function subtractNew(p:FlxPoint):FlxPoint
	{
		return clone().subtractPoint(p);
	}

	/**
	 * Helper function, just copies the values from the specified point.
	 *
	 * @param   p  Any FlxPoint.
	 * @return  A reference to itself.
	 */
	public inline function copyFrom(p:FlxPoint):FlxPoint
	{
		set(p.x, p.y);
		p.putWeak();
		return this;
	}

	/**
	 * Helper function, just copies the values from the specified Flash point.
	 *
	 * @param   p  Any Point.
	 * @return  A reference to itself.
	 */
	public inline function copyFromFlash(p:Point):FlxPoint
	{
		return this.set(p.x, p.y);
	}

	/**
	 * Helper function, just copies the values from this point to the specified point.
	 *
	 * @param   p   optional point to copy this point to
	 * @return  copy of this point
	 */
	public inline function copyTo(?p:FlxPoint):FlxPoint
	{
		if (p == null)
		{
			p = get();
		}
		return p.set(x, y);
	}

	/**
	 * Helper function, just copies the values from this point to the specified Flash point.
	 *
	 * @param   p  Any Point.
	 * @return  A reference to the altered point parameter.
	 */
	public inline function copyToFlash(?p:Point):Point
	{
		if (p == null)
		{
			p = new Point();
		}

		p.x = x;
		p.y = y;
		return p;
	}

	/**
	 * Helper function, just increases the values of the specified Flash point by the values of this point.
	 *
	 * @param   p  Any Point.
	 * @return  A reference to the altered point parameter.
	 */
	public inline function addToFlash(p:Point):Point
	{
		p.x += x;
		p.y += y;

		return p;
	}

	/**
	 * Helper function, just decreases the values of the specified Flash point by the values of this point.
	 *
	 * @param   p  Any Point.
	 * @return  A reference to the altered point parameter.
	 */
	public inline function subtractFromFlash(p:Point):Point
	{
		p.x -= x;
		p.y -= y;

		return p;
	}

	/**
	 * Rounds x and y using Math.floor()
	 */
	public inline function floor():FlxPoint
	{
		x = Math.floor(x);
		y = Math.floor(y);
		return this;
	}

	/**
	 * Rounds x and y using Math.ceil()
	 */
	public inline function ceil():FlxPoint
	{
		x = Math.ceil(x);
		y = Math.ceil(y);
		return this;
	}

	/**
	 * Rounds x and y using Math.round()
	 */
	public inline function round():FlxPoint
	{
		x = Math.round(x);
		y = Math.round(y);
		return this;
	}

	/**
	 * Returns true if this point is within the given rectangular bounds
	 *
	 * @param	x       The X value of the region to test within
	 * @param	y       The Y value of the region to test within
	 * @param	width   The width of the region to test within
	 * @param	height  The height of the region to test within
	 * @return	True if the point is within the region, otherwise false
	 */
	public inline function inCoords(x:Float, y:Float, width:Float, height:Float):Bool
	{
		return FlxMath.pointInCoordinates(this.x, this.y, x, y, width, height);
	}

	/**
	 * Returns true if this point is within the given rectangular block
	 *
	 * @param	rect	The FlxRect to test within
	 * @return	True if pointX/pointY is within the FlxRect, otherwise false
	 */
	public inline function inRect(rect:FlxRect):Bool
	{
		return FlxMath.pointInFlxRect(x, y, rect);
	}

	/**
	 * Rotates this point clockwise in 2D space around another point by the given degrees.
	 *
	 * @param   pivot    The pivot you want to rotate this point around
	 * @param   degrees  Rotate the point by this many degrees clockwise.
	 * @return  A FlxPoint containing the coordinates of the rotated point.
	 */
	@:deprecated("rotate is deprecated, use pivotDegrees")
	public function rotate(pivot:FlxPoint, degrees:Float):FlxPoint
	{
		return pivotDegrees(pivot, degrees);
	}

	/**
	 * Rotates this point clockwise in 2D space around another point by the given radians.
	 * Note: To rotate a point around 0,0 you can use `p.radians += angle`
	 * @since 5.0.0
	 *
	 * @param   pivot    The pivot you want to rotate this point around
	 * @param   radians  Rotate the point by this many radians clockwise.
	 * @return  A FlxPoint containing the coordinates of the rotated point.
	 */
	public function pivotRadians(pivot:FlxPoint, radians:Float):FlxPoint
	{
		_point1.copyFrom(this).subtractPoint(pivot);
		_point1.radians += radians;
		set(_point1.x + pivot.x, _point1.y + pivot.y);
		pivot.putWeak();
		return this;
	}

	/**
	 * Rotates this point clockwise in 2D space around another point by the given degrees.
	 * Note: To rotate a point around 0,0 you can use `p.degrees += angle`
	 * @since 5.0.0
	 *
	 * @param   pivot    The pivot you want to rotate this point around
	 * @param   degrees  Rotate the point by this many degrees clockwise.
	 * @return  A FlxPoint containing the coordinates of the rotated point.
	 */
	public inline function pivotDegrees(pivot:FlxPoint, degrees:Float):FlxPoint
	{
		return pivotRadians(pivot, degrees * FlxAngle.TO_RAD);
	}

	/**
	 * Calculate the distance to another point.
	 *
	 * @param   point  A FlxPoint object to calculate the distance to.
	 * @return  The distance between the two points as a Float.
	 */
	public function distanceTo(point:FlxPoint):Float
	{
		var dx:Float = x - point.x;
		var dy:Float = y - point.y;
		point.putWeak();
		return FlxMath.vectorLength(dx, dy);
	}

	/**
	 * Calculates the angle from this to another point.
	 * If the point is straight right of this, 0 is returned.
	 * @since 5.0.0
	 *
	 * @param   point  The other point.
	 * @return  The angle, in radians, between -PI and PI
	 */
	public inline function radiansTo(point:FlxPoint):Float
	{
		return FlxAngle.radiansFromOrigin(point.x - x, point.y - y);
	}

	/**
	 * Calculates the angle from another point to this.
	 * If this is straight right of the point, 0 is returned.
	 * @since 5.0.0
	 *
	 * @param   point  The other point.
	 * @return  The angle, in radians, between -PI and PI
	 */
	public inline function radiansFrom(point:FlxPoint):Float
	{
		return point.radiansTo(this);
	}

	/**
	 * Calculates the angle from this to another point.
	 * If the point is straight right of this, 0 is returned.
	 * @since 5.0.0
	 *
	 * @param   point  The other point.
	 * @return  The angle, in degrees, between -180 and 180
	 */
	public inline function degreesTo(point:FlxPoint):Float
	{
		return FlxAngle.degreesFromOrigin(point.x - x, point.y - y);
	}

	/**
	 * Calculates the angle from another point to this.
	 * If this is straight right of the point, 0 is returned.
	 * @since 5.0.0
	 *
	 * @param   point  The other point.
	 * @return  The angle, in degrees, between -180 and 180
	 */
	public inline function degreesFrom(point:FlxPoint):Float
	{
		return point.degreesTo(this);
	}

	/** DEPRECATED
	 * 
	 * Calculates the angle between this and another point. 0 degrees points straight up.
	 * 
	 * Note: Every other flixel function treats straight right as 0 degrees.
	 * 
	 * Also Note: The result is very innacurate.
	 *
	 * @param   point   The other point.
	 * @return  The angle in degrees, between -180 and 180.
	 * 
	 * @see [Flixel 5.0.0 Migration guide](https://github.com/HaxeFlixel/flixel/wiki/Flixel-5.0.0-Migration-guide)
	 */
	@:deprecated("angleBetween is deprecated, use degreesTo instead")
	public function angleBetween(point:FlxPoint):Float
	{
		var x:Float = point.x - x;
		var y:Float = point.y - y;
		var angle:Float = 0;

		if ((x != 0) || (y != 0))
		{
			var c1:Float = Math.PI * 0.25;
			var c2:Float = 3 * c1;
			var ay:Float = (y < 0) ? -y : y;

			if (x >= 0)
			{
				angle = c1 - c1 * ((x - ay) / (x + ay));
			}
			else
			{
				angle = c2 - c1 * ((x + ay) / (ay - x));
			}
			angle = ((y < 0) ? -angle : angle) * FlxAngle.TO_DEG;

			if (angle > 90)
			{
				angle = angle - 270;
			}
			else
			{
				angle += 90;
			}
		}

		point.putWeak();
		return angle;
	}

	/**
	 * Applies transformation matrix to this point
	 * @param   matrix  transformation matrix
	 * @return  transformed point
	 */
	public inline function transform(matrix:Matrix):FlxPoint
	{
		var x1 = x * matrix.a + y * matrix.c + matrix.tx;
		var y1 = x * matrix.b + y * matrix.d + matrix.ty;

		return set(x1, y1);
	}

	/**
	 * Short for dot product.
	 *
	 * @param   p  point to multiply
	 * @return  dot product of two points
	 */
	public inline function dot(p:FlxPoint):Float
	{
		return dotProduct(p);
	}

	/**
	 * Dot product between two points.
	 *
	 * @param   p  point to multiply
	 * @return  dot product of two points
	 */
	public inline function dotProduct(p:FlxPoint):Float
	{
		var dp = dotProductWeak(p);
		p.putWeak();
		return dp;
	}

	/**
	 * Dot product between two points.
	 * Meant for internal use, does not call putWeak.
	 *
	 * @param   p  point to multiply
	 * @return  dot product of two points
	 */
	inline function dotProductWeak(p:FlxPoint):Float
	{
		return x * p.x + y * p.y;
	}

	/**
	 * Dot product of points with normalization of the second point.
	 *
	 * @param   p  point to multiply
	 * @return  dot product of two points
	 */
	public inline function dotProdWithNormalizing(p:FlxPoint):Float
	{
		var normalized:FlxPoint = p.clone(_point1).normalize();
		p.putWeak();
		return dotProductWeak(normalized);
	}

	/**
	 * Check the perpendicularity of two points.
	 *
	 * @param   p  point to check
	 * @return  true - if they are perpendicular
	 */
	public inline function isPerpendicular(p:FlxPoint):Bool
	{
		return Math.abs(dotProduct(p)) < EPSILON_SQUARED;
	}

	/**
	 * Find the length of cross product between two points.
	 *
	 * @param   p  point to multiply
	 * @return  the length of cross product of two points
	 */
	public inline function crossProductLength(p:FlxPoint):Float
	{
		var cp = crossProductLengthWeak(p);
		p.putWeak();
		return cp;
	}

	/**
	 * Find the length of cross product between two points.
	 * Meant for internal use, does not call putWeak.
	 *
	 * @param   p  point to multiply
	 * @return  the length of cross product of two points
	 */
	inline function crossProductLengthWeak(p:FlxPoint):Float
	{
		return x * p.y - y * p.x;
	}

	/**
	 * Check for parallelism of two points.
	 *
	 * @param   p  point to check
	 * @return  true - if they are parallel
	 */
	public inline function isParallel(p:FlxPoint):Bool
	{
		var pp = isParallelWeak(p);
		p.putWeak();
		return pp;
	}

	/**
	 * Check for parallelism of two points.
	 * Meant for internal use, does not call putWeak.
	 *
	 * @param   p  point to check
	 * @return  true - if they are parallel
	 */
	inline function isParallelWeak(p:FlxPoint):Bool
	{
		return Math.abs(crossProductLengthWeak(p)) < EPSILON_SQUARED;
	}

	/**
	 * Check if this point has zero length.
	 *
	 * @return  true - if the point is zero
	 */
	public inline function isZero():Bool
	{
		return Math.abs(x) < EPSILON && Math.abs(y) < EPSILON;
	}

	/**
	 * point reset
	 */
	public inline function zero():FlxPoint
	{
		x = y = 0;
		return this;
	}

	/**
	 * Normalization of the point (reduction to unit length)
	 */
	public function normalize():FlxPoint
	{
		if (isZero())
		{
			return this;
		}
		return scale(1 / length);
	}

	/**
	 * Check the point for unit length
	 */
	public inline function isNormalized():Bool
	{
		return Math.abs(lengthSquared - 1) < EPSILON_SQUARED;
	}

	/**
	 * Rotate the point for a given angle.
	 *
	 * @param   rads  angle to rotate
	 * @return  rotated point
	 */
	public inline function rotateByRadians(rads:Float):FlxPoint
	{
		var s:Float = Math.sin(rads);
		var c:Float = Math.cos(rads);
		var tempX:Float = x;

		x = tempX * c - y * s;
		y = tempX * s + y * c;

		return this;
	}

	/**
	 * Rotate the point for a given angle.
	 *
	 * @param   degs  angle to rotate
	 * @return  rotated point
	 */
	public inline function rotateByDegrees(degs:Float):FlxPoint
	{
		return rotateByRadians(degs * FlxAngle.TO_RAD);
	}

	/**
	 * Rotate the point with the values of sine and cosine of the angle of rotation.
	 *
	 * @param   sin  the value of sine of the angle of rotation
	 * @param   cos  the value of cosine of the angle of rotation
	 * @return  rotated point
	 */
	public inline function rotateWithTrig(sin:Float, cos:Float):FlxPoint
	{
		var tempX:Float = x;
		x = tempX * cos - y * sin;
		y = tempX * sin + y * cos;
		return this;
	}

	/**
	 * Sets the polar coordinates of the point
	 *
	 * @param   length   The length to set the point
	 * @param   radians  The angle to set the point, in radians
	 * @return  The rotated point
	 * 
	 * @since 4.10.0
	 */
	public function setPolarRadians(length:Float, radians:Float):FlxPoint
	{
		x = length * Math.cos(radians);
		y = length * Math.sin(radians);
		return this;
	}

	/**
	 * Sets the polar coordinates of the point
	 *
	 * @param   length  The length to set the point
	 * @param   degrees The angle to set the point, in degrees
	 * @return  The rotated point
	 * 
	 * @since 4.10.0
	 */
	public inline function setPolarDegrees(length:Float, degrees:Float):FlxPoint
	{
		return setPolarRadians(length, degrees * FlxAngle.TO_RAD);
	}

	/**
	 * Right normal of the point
	 */
	public function rightNormal(?p:FlxPoint):FlxPoint
	{
		if (p == null)
		{
			p = get();
		}
		p.set(-y, x);
		return p;
	}

	/**
	 * Left normal of the point
	 */
	public function leftNormal(?p:FlxPoint):FlxPoint
	{
		if (p == null)
		{
			p = get();
		}
		p.set(y, -x);
		return p;
	}

	/**
	 * Change direction of the point to opposite
	 */
	public inline function negate():FlxPoint
	{
		x *= -1;
		y *= -1;
		return this;
	}

	public inline function negateNew():FlxPoint
	{
		return clone().negate();
	}

	/**
	 * The projection of this point to point that is passed as an argument
	 * (without modifying the original point!).
	 *
	 * @param   p     point to project
	 * @param   proj  optional argument - result point
	 * @return  projection of the point
	 */
	public function projectTo(p:FlxPoint, ?proj:FlxPoint):FlxPoint
	{
		var dp:Float = dotProductWeak(p);
		var lenSq:Float = p.lengthSquared;

		if (proj == null)
		{
			proj = get();
		}

		proj.set(dp * p.x / lenSq, dp * p.y / lenSq);
		p.putWeak();
		return proj;
	}

	/**
	 * Projecting this point on the normalized point p.
	 *
	 * @param   p     this point has to be normalized, ie have unit length
	 * @param   proj  optional argument - result point
	 * @return  projection of the point
	 */
	public function projectToNormalized(p:FlxPoint, ?proj:FlxPoint):FlxPoint
	{
		proj = projectToNormalizedWeak(p, proj);
		p.putWeak();
		return proj;
	}

	/**
	 * Projecting this point on the normalized point p.
	 * Meant for internal use, does not call putWeak.
	 *
	 * @param   p     this point has to be normalized, ie have unit length
	 * @param   proj  optional argument - result point
	 * @return  projection of the point
	 */
	inline function projectToNormalizedWeak(p:FlxPoint, ?proj:FlxPoint):FlxPoint
	{
		var dp:Float = dotProductWeak(p);

		if (proj == null)
		{
			proj = get();
		}

		return proj.set(dp * p.x, dp * p.y);
	}

	/**
	 * Dot product of left the normal point and point p.
	 */
	public inline function perpProduct(p:FlxPoint):Float
	{
		var pp:Float = perpProductWeak(p);
		p.putWeak();
		return pp;
	}

	/**
	 * Dot product of left the normal point and point p.
	 * Meant for internal use, does not call putWeak.
	 */
	inline function perpProductWeak(p:FlxPoint):Float
	{
		return lx * p.x + ly * p.y;
	}

	/**
	 * Find the ratio between the perpProducts of this point and p point. This helps to find the intersection point.
	 *
	 * @param   a  start point of the point
	 * @param   b  start point of the p point
	 * @param   p  the second point
	 * @return  the ratio between the perpProducts of this point and p point
	 */
	public inline function ratio(a:FlxPoint, b:FlxPoint, p:FlxPoint):Float
	{
		var r = ratioWeak(a, b, p);
		a.putWeak();
		b.putWeak();
		p.putWeak();
		return r;
	}

	/**
	 * Find the ratio between the perpProducts of this point and p point. This helps to find the intersection point.
	 * Meant for internal use, does not call putWeak.
	 *
	 * @param   a  start point of the point
	 * @param   b  start point of the p point
	 * @param   p  the second point
	 * @return  the ratio between the perpProducts of this point and p point
	 */
	inline function ratioWeak(a:FlxPoint, b:FlxPoint, p:FlxPoint):Float
	{
		if (isParallelWeak(p))
			return Math.NaN;
		if (lengthSquared < EPSILON_SQUARED || p.lengthSquared < EPSILON_SQUARED)
			return Math.NaN;

		_point1 = b.clone(_point1);
		_point1.subtract(a.x, a.y);

		return _point1.perpProductWeak(p) / perpProductWeak(p);
	}

	/**
	 * Finding the point of intersection of points.
	 *
	 * @param   a  start point of the point
	 * @param   b  start point of the p point
	 * @param   p  the second point
	 * @return the point of intersection of points
	 */
	public function findIntersection(a:FlxPoint, b:FlxPoint, p:FlxPoint, ?intersection:FlxPoint):FlxPoint
	{
		var t:Float = ratioWeak(a, b, p);

		if (intersection == null)
		{
			intersection = get();
		}

		if (Math.isNaN(t))
		{
			intersection.set(Math.NaN, Math.NaN);
		}
		else
		{
			intersection.set(a.x + t * x, a.y + t * y);
		}

		a.putWeak();
		b.putWeak();
		p.putWeak();
		return intersection;
	}

	/**
	 * Finding the point of intersection of points if it is in the "bounds" of the points.
	 *
	 * @param   a   start point of the point
	 * @param   b   start point of the p point
	 * @param   p   the second point
	 * @return the point of intersection of points if it is in the "bounds" of the points
	 */
	public function findIntersectionInBounds(a:FlxPoint, b:FlxPoint, p:FlxPoint, ?intersection:FlxPoint):FlxPoint
	{
		if (intersection == null)
		{
			intersection = get();
		}

		var t1:Float = ratioWeak(a, b, p);
		var t2:Float = p.ratioWeak(b, a, this);
		if (!Math.isNaN(t1) && !Math.isNaN(t2) && t1 > 0 && t1 <= 1 && t2 > 0 && t2 <= 1)
		{
			intersection.set(a.x + t1 * x, a.y + t1 * y);
		}
		else
		{
			intersection.set(Math.NaN, Math.NaN);
		}

		a.putWeak();
		b.putWeak();
		p.putWeak();
		return intersection;
	}

	/**
	 * Limit the length of this point.
	 *
	 * @param   max  maximum length of this point
	 */
	public inline function truncate(max:Float):FlxPoint
	{
		length = Math.min(max, length);
		return this;
	}

	/**
	 * Get the angle between points (in radians).
	 *
	 * @param   p   second point, which we find the angle
	 * @return  the angle in radians
	 */
	public inline function radiansBetween(p:FlxPoint):Float
	{
		var rads = Math.acos(dotProductWeak(p) / (length * p.length));
		p.putWeak();
		return rads;
	}

	/**
	 * The angle between points (in degrees).
	 *
	 * @param   p   second point, which we find the angle
	 * @return  the angle in degrees
	 */
	public inline function degreesBetween(p:FlxPoint):Float
	{
		return radiansBetween(p) * FlxAngle.TO_DEG;
	}

	/**
	 * The sign of half-plane of point with respect to the point through the a and b points.
	 *
	 * @param   a  start point of the wall-point
	 * @param   b  end point of the wall-point
	 */
	public function sign(a:FlxPoint, b:FlxPoint):Int
	{
		var signFl:Float = (a.x - x) * (b.y - y) - (a.y - y) * (b.x - x);
		a.putWeak();
		b.putWeak();
		if (signFl == 0)
		{
			return 0;
		}
		return Math.round(signFl / Math.abs(signFl));
	}

	/**
	 * The distance between points
	 */
	public inline function dist(p:FlxPoint):Float
	{
		return Math.sqrt(distSquared(p));
	}

	/**
	 * The squared distance between points
	 */
	public inline function distSquared(p:FlxPoint):Float
	{
		var dx:Float = p.x - x;
		var dy:Float = p.y - y;
		p.putWeak();
		return dx * dx + dy * dy;
	}

	/**
	 * Reflect the point with respect to the normal of the "wall".
	 *
	 * @param   normal      left normal of the "wall". It must be normalized (no checks)
	 * @param   bounceCoeff bounce coefficient (0 <= bounceCoeff <= 1)
	 * @return  reflected point (angle of incidence equals to angle of reflection)
	 */
	public inline function bounce(normal:FlxPoint, bounceCoeff:Float = 1):FlxPoint
	{
		var d:Float = (1 + bounceCoeff) * dotProductWeak(normal);
		x -= d * normal.x;
		y -= d * normal.y;
		normal.putWeak();
		return this;
	}

	/**
	 * Reflect the point with respect to the normal. This operation takes "friction" into account.
	 *
	 * @param   normal      left normal of the "wall". It must be normalized (no checks)
	 * @param   bounceCoeff bounce coefficient (0 <= bounceCoeff <= 1)
	 * @param   friction    friction coefficient
	 * @return  reflected point
	 */
	public inline function bounceWithFriction(normal:FlxPoint, bounceCoeff:Float = 1, friction:Float = 0):FlxPoint
	{
		var p1:FlxPoint = projectToNormalizedWeak(normal.rightNormal(_point3), _point1);
		var p2:FlxPoint = projectToNormalizedWeak(normal, _point2);
		var bounceX:Float = -p2.x;
		var bounceY:Float = -p2.y;
		var frictionX:Float = p1.x;
		var frictionY:Float = p1.y;
		x = bounceX * bounceCoeff + frictionX * friction;
		y = bounceY * bounceCoeff + frictionY * friction;
		normal.putWeak();
		return this;
	}

	/**
	 * Checking if this is a valid point.
	 *
	 * @return  true - if the point is valid
	 */
	public inline function isValid():Bool
	{
		return !Math.isNaN(x) && !Math.isNaN(y) && Math.isFinite(x) && Math.isFinite(y);
	}

	/**
	 * Copies this point.
	 *
	 * @param   p   optional point to copy this point to
	 * @return  copy of this point
	 */
	public inline function clone(?p:FlxPoint):FlxPoint
	{
		return copyTo(p);
	}

	inline function get_x():Float
	{
		return this.x;
	}

	inline function set_x(x:Float):Float
	{
		return this.x = x;
	}

	inline function get_y():Float
	{
		return this.y;
	}

	inline function set_y(y:Float):Float
	{
		return this.y = y;
	}

	inline function get_dx():Float
	{
		if (isZero())
			return 0;

		return x / length;
	}

	inline function get_dy():Float
	{
		if (isZero())
			return 0;

		return y / length;
	}

	inline function get_length():Float
	{
		return Math.sqrt(lengthSquared);
	}

	inline function set_length(l:Float):Float
	{
		if (!isZero())
		{
			var a:Float = radians;
			x = l * Math.cos(a);
			y = l * Math.sin(a);
		}
		return l;
	}

	inline function get_lengthSquared():Float
	{
		return x * x + y * y;
	}

	inline function get_degrees():Float
	{
		return radians * FlxAngle.TO_DEG;
	}

	inline function set_degrees(degs:Float):Float
	{
		radians = degs * FlxAngle.TO_RAD;
		return degs;
	}

	function get_radians():Float
	{
		return FlxAngle.radiansFromOrigin(x, y);
	}

	inline function set_radians(rads:Float):Float
	{
		var len:Float = length;

		x = len * Math.cos(rads);
		y = len * Math.sin(rads);
		return rads;
	}

	inline function get_rx():Float
	{
		return -y;
	}

	inline function get_ry():Float
	{
		return x;
	}

	inline function get_lx():Float
	{
		return y;
	}

	inline function get_ly():Float
	{
		return -x;
	}
}

/**
 * The base class of FlxPoint, just use FlxPoint instead.
 * 
 * Note to contributors: don't worry about adding functionality to the base class.
 * it's all mostly inlined anyway so there's no runtime definitions for
 * reflection or anything.
 */
@:noCompletion
@:noDoc
@:allow(flixel.math.FlxPoint)
class FlxBasePoint implements IFlxPooled
{
	#if FLX_POINT_POOL
	static var pool:FlxPool<FlxBasePoint> = new FlxPool(FlxBasePoint.new.bind(0, 0));
	#end

	/**
	 * Recycle or create a new FlxBasePoint.
	 * Be sure to put() them back into the pool after you're done with them!
	 *
	 * @param   x  The X-coordinate of the point in space.
	 * @param   y  The Y-coordinate of the point in space.
	 * @return  This point.
	 */
	public static inline function get(x:Float = 0, y:Float = 0):FlxBasePoint
	{
		#if FLX_POINT_POOL
		var point = pool.get().set(x, y);
		point._inPool = false;
		return point;
		#else
		return new FlxBasePoint(x, y);
		#end
	}

	/**
	 * Recycle or create a new FlxBasePoint which will automatically be released
	 * to the pool when passed into a flixel function.
	 *
	 * @param   x  The X-coordinate of the point in space.
	 * @param   y  The Y-coordinate of the point in space.
	 * @return  This point.
	 */
	public static inline function weak(x:Float = 0, y:Float = 0):FlxBasePoint
	{
		var point = get(x, y);
		#if FLX_POINT_POOL
		point._weak = true;
		#end
		return point;
	}

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;

	#if FLX_POINT_POOL
	var _weak:Bool = false;
	var _inPool:Bool = false;
	#end

	@:keep
	public inline function new(x:Float = 0, y:Float = 0)
	{
		set(x, y);
	}

	/**
	 * Set the coordinates of this point object.
	 *
	 * @param   x  The X-coordinate of the point in space.
	 * @param   y  The Y-coordinate of the point in space.
	 */
	public function set(x:Float = 0, y:Float = 0):FlxBasePoint
	{
		this.x = x;
		this.y = y;
		return this;
	}

	/**
	 * Add this FlxBasePoint to the recycling pool.
	 */
	public function put():Void
	{
		#if FLX_POINT_POOL
		if (!_inPool)
		{
			_inPool = true;
			_weak = false;
			pool.putUnsafe(this);
		}
		#end
	}

	/**
	 * Add this FlxBasePoint to the recycling pool if it's a weak reference (allocated via weak()).
	 */
	public inline function putWeak():Void
	{
		#if FLX_POINT_POOL
		if (_weak)
		{
			put();
		}
		#end
	}

	/**
	 * Function to compare this FlxBasePoint to another.
	 *
	 * @param   point  The other FlxBasePoint to compare to this one.
	 * @return  True if the FlxBasePoints have the same x and y value, false otherwise.
	 */
	public inline function equals(point:FlxBasePoint):Bool
	{
		var result = FlxMath.equal(x, point.x) && FlxMath.equal(y, point.y);
		point.putWeak();
		return result;
	}

	/**
	 * Necessary for IFlxDestroyable.
	 */
	public function destroy() {}

	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	public inline function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("x", x), LabelValuePair.weak("y", y)]);
	}

	/**
	 * Necessary for FlxCallbackPoint.
	 */
	function set_x(Value:Float):Float
	{
		return x = Value;
	}

	/**
	 * Necessary for FlxCallbackPoint.
	 */
	function set_y(Value:Float):Float
	{
		return y = Value;
	}
}


/**
 * A FlxPoint that calls a function when set_x(), set_y() or set() is called. Used in FlxSpriteGroup.
 * IMPORTANT: Calling set(x, y); is MUCH FASTER than setting x and y separately. Needs to be destroyed unlike simple FlxPoints!
 */
class FlxCallbackPoint extends FlxBasePoint
{
	var _setXCallback:FlxPoint->Void;
	var _setYCallback:FlxPoint->Void;
	var _setXYCallback:FlxPoint->Void;

	/**
	 * If you only specify one callback function, then the remaining two will use the same.
	 *
	 * @param	setXCallback	Callback for set_x()
	 * @param	setYCallback	Callback for set_y()
	 * @param	setXYCallback	Callback for set()
	 */
	public function new(setXCallback:FlxPoint->Void, ?setYCallback:FlxPoint->Void, ?setXYCallback:FlxPoint->Void)
	{
		super();

		_setXCallback = setXCallback;
		_setYCallback = setXYCallback;
		_setXYCallback = setXYCallback;

		if (_setXCallback != null)
		{
			if (_setYCallback == null)
				_setYCallback = setXCallback;
			if (_setXYCallback == null)
				_setXYCallback = setXCallback;
		}
	}

	override public function set(x:Float = 0, y:Float = 0):FlxCallbackPoint
	{
		super.set(x, y);
		if (_setXYCallback != null)
			_setXYCallback(this);
		return this;
	}

	override function set_x(value:Float):Float
	{
		super.set_x(value);
		if (_setXCallback != null)
			_setXCallback(this);
		return value;
	}

	override function set_y(value:Float):Float
	{
		super.set_y(value);
		if (_setYCallback != null)
			_setYCallback(this);
		return value;
	}

	override public function destroy():Void
	{
		super.destroy();
		_setXCallback = null;
		_setYCallback = null;
		_setXYCallback = null;
	}

	override public function put():Void {} // don't pool FlxCallbackPoints
}
