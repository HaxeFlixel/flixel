package flixel.math;

import flixel.util.FlxPool;

/**
 * 2-dimensional vector class
 */
@:forward abstract FlxVector(FlxPoint) from FlxPoint to FlxPoint
{
	public static inline var EPSILON:Float = 0.0000001;
	public static inline var EPSILON_SQUARED:Float = EPSILON * EPSILON;
	
	static var _vector1:FlxVector = new FlxVector();
	static var _vector2:FlxVector = new FlxVector();
	static var _vector3:FlxVector = new FlxVector();
	
	/**
	 * Recycle or create new FlxVector.
	 * Be sure to put() them back into the pool after you're done with them!
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 */
	public static inline function get(X:Float = 0, Y:Float = 0):FlxVector
	{
		return FlxPoint.get();
	}
	
	/**
	 * Recycle or create new FlxVector.
	 * Be sure to put() them back into the pool after you're done with them!
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 */
	public static inline function weak(X:Float = 0, Y:Float = 0):FlxVector
	{
		return FlxPoint.weak();
	}
	
	// Without these delegates we have to say `this.x` everywhere.
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	/**
	 * The horizontal component of the unit vector
	 */
	public var dx(get, never):Float;
	/**
	 * The vertical component of the unit vector
	 */
	public var dy(get, never):Float;
	/**
	 * Length of the vector
	 */
	public var length(get, set):Float;
	/**
	 * length of the vector squared
	 */
	public var lengthSquared(get, never):Float;
	/**
	 * The angle formed by the vector with the horizontal axis (in degrees)
	 */
	public var degrees(get, set):Float;
	/**
	 * The angle formed by the vector with the horizontal axis (in radians)
	 */
	public var radians(get, set):Float;
	/**
	 * The horizontal component of the right normal of the vector
	 */
	public var rx(get, never):Float;
	/**
	 * The vertical component of the right normal of the vector
	 */
	public var ry(get, never):Float;
	/**
	 * The horizontal component of the left normal of the vector
	 */
	public var lx(get, never):Float;
	/**
	 * The vertical component of the left normal of the vector
	 */
	public var ly(get, never):Float;
	
	public inline function new (X:Float = 0, Y:Float = 0)
	{
		this = new FlxPoint(X, Y);
	}
	
	/**
	 * Set the coordinates of this point object.
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 */
	public inline function set(X:Float = 0, Y:Float = 0):FlxVector
	{
		return this.set();
	}
	
	inline function tempUnweaken():Bool
	{
		var wasWeak = this._weak;
		this._weak = false;
		return wasWeak;
	}
	
	inline function putWasWeak(wasWeak:Bool):FlxVector
	{
		this._weak = wasWeak;
		this.putWeak();
		return this;
	}
	
	/**
	 * Scale this vector.
	 * 
	 * @param	k - scale coefficient
	 * @return	scaled vector
	 */
	public inline function scale(k:Float):FlxVector
	{
		return this.scale(k);
	}
	
	/**
	 * Returns scaled copy of this vector.
	 * 
	 * @param	k - scale coefficient
	 * @return	scaled vector
	 */
	public inline function scaleNew(k:Float):FlxVector
	{
		return clone().scale(k);
	}
	
	/**
	 * Return new vector which equals to sum of this vector and passed v vector.
	 * 
	 * @param	v	vector to add
	 * @return	addition result
	 */
	public inline function addNew(v:FlxVector):FlxVector
	{
		return clone().addPoint(v);
	}
	
	/**
	 * Returns new vector which is result of subtraction of v vector from this vector.
	 * 
	 * @param	v	vector to subtract
	 * @return	subtraction result
	 */
	public inline function subtractNew(v:FlxVector):FlxVector
	{
		return clone().subtractPoint(v);
	}
	
	/**
	 * Dot product between two vectors.
	 * 
	 * @param	v	vector to multiply
	 * @return	dot product of two vectors
	 */
	public inline function dotProduct(v:FlxVector):Float
	{
		var dp = x * v.x + y * v.y;
		v.putWeak();
		return dp;
	}
	
	/**
	 * Dot product of vectors with normalization of the second vector.
	 * 
	 * @param	v	vector to multiply
	 * @return	dot product of two vectors
	 */
	public inline function dotProdWithNormalizing(v:FlxVector):Float
	{
		var normalized:FlxVector = v.clone(_vector1).normalize();
		v.putWeak();
		return dotProduct(normalized);
	}
	
	/**
	 * Check the perpendicularity of two vectors.
	 * 
	 * @param	v	vector to check
	 * @return	true - if they are perpendicular
	 */
	public inline function isPerpendicular(v:FlxVector):Bool
	{
		return Math.abs(dotProduct(v)) < EPSILON_SQUARED;
	}
	
	/**
	 * Find the length of cross product between two vectors.
	 * 
	 * @param	v	vector to multiply
	 * @return	the length of cross product of two vectors
	 */
	public inline function crossProductLength(v:FlxVector):Float
	{
		var cp = x * v.y - y * v.x;
		v.putWeak();
		return cp;
	}
	
	/**
	 * Check for parallelism of two vectors.
	 * 
	 * @param	v	vector to check
	 * @return	true - if they are parallel
	 */
	public inline function isParallel(v:FlxVector):Bool
	{
		return Math.abs(crossProductLength(v)) < EPSILON_SQUARED;
	}
	
	/**
	 * Check if this vector has zero length.
	 * 
	 * @return	true - if the vector is zero
	 */
	public inline function isZero():Bool
	{
		return Math.abs(x) < EPSILON && Math.abs(y) < EPSILON;
	}
	
	/**
	 * Vector reset
	 */
	public inline function zero():FlxVector
	{
		x = y = 0;
		return this;
	}
	
	/**
	 * Normalization of the vector (reduction to unit length)
	 */
	public function normalize():FlxVector
	{
		if (isZero()) 
		{
			return this;
		}
		return scale(1 / length);
	}
	
	/**
	 * Check the vector for unit length
	 */
	public inline function isNormalized():Bool
	{
		return Math.abs(lengthSquared - 1) < EPSILON_SQUARED;
	}
	
	/**
	 * Rotate the vector for a given angle.
	 * 
	 * @param	rads	angle to rotate
	 * @return	rotated vector
	 */
	public inline function rotateByRadians(rads:Float):FlxVector
	{
		var s:Float = Math.sin(rads);
		var c:Float = Math.cos(rads);
		var tempX:Float = x;
		
		x = tempX * c - y * s;
		y = tempX * s + y * c;
		
		return this;
	}
	
	/**
	 * Rotate the vector for a given angle.
	 * 
	 * @param	degs	angle to rotate
	 * @return	rotated vector
	 */
	public inline function rotateByDegrees(degs:Float):FlxVector
	{
		return rotateByRadians(degs * FlxAngle.TO_RAD);
	}
	
	/**
	 * Rotate the vector with the values of sine and cosine of the angle of rotation.
	 * 
	 * @param	sin	the value of sine of the angle of rotation
	 * @param	cos	the value of cosine of the angle of rotation
	 * @return	rotated vector
	 */
	public inline function rotateWithTrig(sin:Float, cos:Float):FlxVector
	{
		var tempX:Float = x;
		x = tempX * cos - y * sin;
		y = tempX * sin + y * cos;
		return this;
	}
	
	/**
	 * Right normal of the vector
	 */
	public function rightNormal(?vec:FlxVector):FlxVector
	{ 
		if (vec == null)
		{
			vec = FlxVector.get();
		}
		vec.set( -y, x);
		return vec; 
	}
	
	/**
	 * Left normal of the vector
	 */
	public function leftNormal(?vec:FlxVector):FlxVector
	{ 
		if (vec == null)
		{
			vec = FlxVector.get();
		}
		vec.set(y, -x);
		return vec; 
	}
	
	/**
	 * Change direction of the vector to opposite
	 */
	public inline function negate():FlxVector
	{ 
		x *= -1;
		y *= -1;
		return this;
	}
	
	public inline function negateNew():FlxVector
	{
		return clone().negate();
	}
	
	/**
	 * The projection of this vector to vector that is passed as an argument 
	 * (without modifying the original Vector!).
	 * 
	 * @param	v	vector to project
	 * @param	proj	optional argument - result vector
	 * @return	projection of the vector
	 */
	public function projectTo(v:FlxVector, ?proj:FlxVector):FlxVector
	{
		var vWeak = v.tempUnweaken();
		var dp:Float = dotProduct(v);
		var lenSq:Float = v.lengthSquared;
		
		if (proj == null)
		{
			proj = FlxVector.get();
		}
		
		proj.set(dp * v.x / lenSq, dp * v.y / lenSq);
		v.putWasWeak(vWeak);
		return proj;
	}
		
	/**
	 * Projecting this vector on the normalized vector v.
	 * 
	 * @param	v	this vector has to be normalized, ie have unit length
	 * @param	proj	optional argument - result vector
	 * @return	projection of the vector
	 */
	public function projectToNormalized(v:FlxVector, ?proj:FlxVector):FlxVector
	{
		var vWeak = v.tempUnweaken();
		var dp:Float = dotProduct(v);
		
		if (proj == null)
		{
			proj = FlxVector.get();
		}
		
		proj.set(dp * v.x, dp * v.y);
		v.putWasWeak(vWeak);
		return proj;
	}
		
	/**
	 * Dot product of left the normal vector and vector v
	 */
	public inline function perpProduct(v:FlxVector):Float
	{
		var pp = lx * v.x + ly * v.y;
		v.putWeak();
		return pp;
	}
	
	/**
	 * Find the ratio between the perpProducts of this vector and v vector. This helps to find the intersection point.
	 * 
	 * @param	a	start point of the vector
	 * @param	b	start point of the v vector
	 * @param	v	the second vector
	 * @return	the ratio between the perpProducts of this vector and v vector
	 */
	public function ratio(a:FlxVector, b:FlxVector, v:FlxVector):Float
	{
		var vWeak = v.tempUnweaken();
		if (isParallel(v))
		{
			a.putWeak();
			b.putWeak();
			v.putWasWeak(vWeak);
			return Math.NaN;
		}
		if (lengthSquared < EPSILON_SQUARED || v.lengthSquared < EPSILON_SQUARED)
		{
			a.putWeak();
			b.putWeak();
			v.putWasWeak(vWeak);
			return Math.NaN;
		}
		
		_vector1 = b.clone(_vector1);
		b.putWeak();
		_vector1.subtractPoint(a);
		
		var vWeak = v.tempUnweaken();
		var r = _vector1.perpProduct(v) / perpProduct(v);
		v.putWasWeak(vWeak);
		return r;
	}
		
	/**
	 * Finding the point of intersection of vectors.
	 * 
	 * @param	a	start point of the vector
	 * @param	b	start point of the v vector
	 * @param	v	the second vector
	 * @return the point of intersection of vectors
	 */
	public function findIntersection(a:FlxVector, b:FlxVector, v:FlxVector, ?intersection:FlxVector):FlxVector
	{
		var aWeak = a.tempUnweaken();
		var t:Float = ratio(a, b, v);
		
		if (intersection == null)
		{
			intersection = FlxVector.get();
		}
		
		if (Math.isNaN(t))
		{
			intersection.set(Math.NaN, Math.NaN);
		}
		else
		{
			intersection.set(a.x + t * x, a.y + t * y);
		}
		
		a.putWasWeak(aWeak);
		return intersection;
	}
	
	/**
	 * Finding the point of intersection of vectors if it is in the "bounds" of the vectors.
	 * 
	 * @param	a	start point of the vector
	 * @param	b	start point of the v vector
	 * @param	v	the second vector
	 * @return the point of intersection of vectors if it is in the "bounds" of the vectors
	 */
	public function findIntersectionInBounds(a:FlxVector, b:FlxVector, v:FlxVector, ?intersection:FlxVector):FlxVector
	{
		if (intersection == null)
		{
			intersection = FlxVector.get();
		}
		
		var aWeak = a.tempUnweaken();
		var bWeak = b.tempUnweaken();
		var vWeak = v.tempUnweaken();
		
		var t1:Float = ratio(a, b, v);
		var t2:Float = v.ratio(b, a, this);
		if (!Math.isNaN(t1) && !Math.isNaN(t2) && t1 > 0 && t1 <= 1 && t2 > 0 && t2 <= 1)
		{
			intersection.set(a.x + t1 * x, a.y + t1 * y);
		}
		else
		{
			intersection.set(Math.NaN, Math.NaN);
		}
		
		a.putWasWeak(aWeak);
		b.putWasWeak(bWeak);
		v.putWasWeak(vWeak);
		return intersection;
	}
	
	/**
	 * Limit the length of this vector.
	 * 
	 * @param	max	maximum length of this vector
	 */
	public inline function truncate(max:Float):FlxVector
	{
		length = Math.min(max, length);
		return this;
	}
	
	/**
	 * Get the angle between vectors (in radians).
	 * 
	 * @param	v	second vector, which we find the angle
	 * @return	the angle in radians
	 */
	public inline function radiansBetween(v:FlxVector):Float
	{
		var vWeak = v.tempUnweaken();
		var rads = Math.acos(dotProduct(v) / (length * v.length));
		v.putWasWeak(vWeak);
		return rads;
	}
	
	/**
	 * The angle between vectors (in degrees).
	 * 
	 * @param	v	second vector, which we find the angle
	 * @return	the angle in radians
	 */
	public inline function degreesBetween(v:FlxVector):Float
	{
		return radiansBetween(v) * FlxAngle.TO_DEG;
	}
	
	/**
	 * The sign of half-plane of point with respect to the vector through the a and b points.
	 * 
	 * @param	a	start point of the wall-vector
	 * @param	b	end point of the wall-vector
	 */
	public function sign(a:FlxVector, b:FlxVector):Int
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
	public inline function dist(v:FlxVector):Float
	{
		return Math.sqrt(distSquared(v));
	}
	
	/**
	 * The squared distance between points
	 */
	public inline function distSquared(v:FlxVector):Float
	{
		var dx:Float = v.x - x;
		var dy:Float = v.y - y;
		v.putWeak();
		return dx * dx + dy * dy;
	}
		
	/**
	 * Reflect the vector with respect to the normal of the "wall".
	 * 
	 * @param normal left normal of the "wall". It must be normalized (no checks)
	 * @param bounceCoeff bounce coefficient (0 <= bounceCoeff <= 1)
	 * @return reflected vector (angle of incidence equals to angle of reflection)
	 */
	public inline function bounce(normal:FlxVector, bounceCoeff:Float = 1):FlxVector
	{
		var wasWeak = normal.tempUnweaken();
		var d:Float = (1 + bounceCoeff) * dotProduct(normal);
		x -= d * normal.x;
		y -= d * normal.y;
		normal.putWasWeak(wasWeak);
		return this;
	}
	
	/**
	 * Reflect the vector with respect to the normal. This operation takes "friction" into account.
	 * 
	 * @param normal left normal of the "wall". It must be normalized (no checks)
	 * @param bounceCoeff bounce coefficient (0 <= bounceCoeff <= 1)
	 * @param friction friction coefficient
	 * @return reflected vector
	 */
	public inline function bounceWithFriction(normal:FlxVector, bounceCoeff:Float = 1, friction:Float = 0):FlxVector
	{
		var p1:FlxVector = projectToNormalized(normal.rightNormal(_vector3), _vector1);
		var p2:FlxVector = projectToNormalized(normal, _vector2);
		var bounceX:Float = -p2.x;
		var bounceY:Float = -p2.y;
		var frictionX:Float = p1.x;
		var frictionY:Float = p1.y;
		x = bounceX * bounceCoeff + frictionX * friction;
		y = bounceY * bounceCoeff + frictionY * friction;
		return this;
	}
	
	/**
	 * Checking if this is a valid vector.
	 * 
	 * @return	true - if the vector is valid
	 */
	public inline function isValid():Bool
	{ 
		return !Math.isNaN(x) && !Math.isNaN(y) && Math.isFinite(x) && Math.isFinite(y); 
	}
	
	/**
	 * Copies this vector.
	 * 
	 * @param	vec		optional vector to copy this vector to
	 * @return	copy	of this vector
	 */
	public function clone(?vec:FlxVector):FlxVector
	{
		if (vec == null)
		{
			vec = FlxVector.get();
		}
		
		vec.x = x;
		vec.y = y;
		return vec;
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
		if (isZero()) return 0;
		
		return x / length;
	}
	
	inline function get_dy():Float
	{
		if (isZero()) return 0;
		
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
		if (isZero()) return 0;
		
		return Math.atan2(y, x);
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
	
	static function get_pool():IFlxPool<FlxPoint>
	{
		return FlxPoint.pool;
	}
}
