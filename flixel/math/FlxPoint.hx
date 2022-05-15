package flixel.math;

import flixel.util.FlxPool.IFlxPool;
import openfl.geom.Matrix;
import openfl.geom.Point;

/**
 * 2-dimensional point class
 */
@:forward abstract FlxPoint(FlxBasePoint) to FlxBasePoint from FlxBasePoint 
{
	public static inline var EPSILON:Float = 0.0000001;
	public static inline var EPSILON_SQUARED:Float = EPSILON * EPSILON;

	static var _point1 = new FlxPoint();
	static var _point2 = new FlxPoint();
	static var _point3 = new FlxPoint();

	static var pool(get, never):IFlxPool<FlxPoint>;

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
		return this.set(x, y);
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
		return this.add(x, y);
	}

	/**
	 * Adds the coordinates of another point to the coordinates of this point.
	 *
	 * @param   point  The point to add to this point
	 * @return  This point.
	 */
	public inline function addPoint(point:FlxPoint):FlxPoint
	{
		return this.addPoint(point);
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
		return this.subtract(x, y);
	}

	/**
	 * Subtracts the coordinates of another point from the coordinates of this point.
	 *
	 * @param   point  The point to subtract from this point
	 * @return  This point.
	 */
	public inline function subtractPoint(point:FlxPoint):FlxPoint
	{
		return this.subtractPoint(point);
	}

	/**
	 * Scale this point.
	 *
	 * @param   k - scale coefficient
	 * @return  scaled point
	 */
	public inline function scale(k:Float):FlxPoint
	{
		return this.scale(k);
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
	 * @param   point  Any FlxPoint.
	 * @return  A reference to itself.
	 */
	public inline function copyFrom(point:FlxPoint):FlxPoint
	{
		return this.copyFrom(point);
	}

	/**
	 * Helper function, just copies the values from the specified Flash point.
	 *
	 * @param   Point  Any Point.
	 * @return  A reference to itself.
	 */
	public inline function copyFromFlash(flashPoint:Point):FlxPoint
	{
		return this.copyFromFlash(flashPoint);
	}

	/**
	 * Helper function, just copies the values from this point to the specified point.
	 *
	 * @param   p   optional point to copy this point to
	 * @return  copy of this point
	 */
	public inline function copyTo(?p:FlxPoint):FlxPoint
	{
		return this.copyTo(p);
	}

	/**
	 * Rounds x and y using Math.floor()
	 */
	public inline function floor():FlxPoint
	{
		return this.floor();
	}

	/**
	 * Rounds x and y using Math.ceil()
	 */
	public inline function ceil():FlxPoint
	{
		return this.ceil();
	}

	/**
	 * Rounds x and y using Math.round()
	 */
	public inline function round():FlxPoint
	{
		return this.round();
	}

	/**
	 * Rotates this point clockwise in 2D space around another point by the given angle.
	 *
	 * @param   Pivot   The pivot you want to rotate this point around
	 * @param   Angle   Rotate the point by this many degrees clockwise.
	 * @return  A FlxPoint containing the coordinates of the rotated point.
	 */
	public function rotate(pivot:FlxPoint, angle:Float):FlxPoint
	{
		return this.rotate(pivot, angle);
	}

	/**
	 * Applies transformation matrix to this point
	 * @param   matrix  transformation matrix
	 * @return  transformed point
	 */
	public inline function transform(matrix:Matrix):FlxPoint
	{
		return this.transform(matrix);
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
			p = FlxPoint.get();
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
			p = FlxPoint.get();
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
			proj = FlxPoint.get();
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
			proj = FlxPoint.get();
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
		_point1.subtractPointWeak(a);

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
			intersection = FlxPoint.get();
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
			intersection = FlxPoint.get();
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
	 * @return  the angle in radians
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
		return this.copyTo(p);
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

	static inline function get_pool():IFlxPool<FlxPoint>
	{
		return FlxBasePoint.pool;
	}
}
