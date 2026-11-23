package flixel.math;

/**
 * Simple class for representing 2d points contrained to integers,
 * handy for bitmaps or tile-based coordinates
 */
@:nullSafety(Strict)
@:forward
abstract FlxIntPoint(FlxIntPointBase)
{
	/**
	 * The sum of x squared and y sqaured. Since Math.sqrt is a heavier operation than multiplying,
	 * this method allows `n*n < p.lengthSquared` rather than `n < Math.sqrt(p.length)`
	 */
	public var lengthSquared(get, never):Int;
	inline public extern function get_lengthSquared() return this.x * this.x + this.y * this.y;
	
	/** The length of the hypotenuse formed by the x and y sides */
	public var length(get, never):Float;
	inline public extern function get_length()
	{
		return Math.sqrt(lengthSquared);
	}
	
	overload public inline extern function new (x:Int, y:Int)
	{
		this = new FlxIntPointBase(x, y);
	}
	
	overload public inline extern function new (n)
	{
		this = new FlxIntPointBase(n, n);
	}
	
	overload public inline extern function set(x:Int, y:Int)
	{
		this.x = x;
		this.y = y;
	}
	
	overload public inline extern function set(n:Int)
	{
		this.x = this.y = n;
	}
	
	inline public extern function copy()
	{
		return new FlxIntPoint(this.x, this.y);
	}
	
	overload public inline extern function equals(p:FlxIntPoint)
	{
		return this.x == p.x && this.y == p.y;
	}
	
	overload public inline extern function equals(x:Int, y:Int)
	{
		return this.x == x && this.y == y;
	}
	
	overload public inline extern function toFloats()
	{
		return FlxPoint.get(this.x, this.y);
	}
	
	overload public inline extern function toFloats(p:FlxPoint)
	{
		return p.set(this.x, this.y);
	}
	
	@:op(A + B)
	inline static extern function addOp(a:FlxIntPoint, b:FlxIntPoint)
	{
		return new FlxIntPoint(a.x + b.x, a.y + b.y);
	}
	
	@:op(A - B)
	inline static extern function subOp(a:FlxIntPoint, b:FlxIntPoint)
	{
		return new FlxIntPoint(a.x - b.x, a.y - b.y);
	}
	
	@:op(A * B)
	inline static extern function scaleOp(p:FlxIntPoint, n:Int)
	{
		return new FlxIntPoint(p.x * n, p.y * n);
	}
	
	@:op(A += B)
	inline static extern function addEqOp(a:FlxIntPoint, b:FlxIntPoint)
	{
		a.x += b.x;
		a.y += b.y;
		return a;
	}
	
	@:op(A -= B)
	inline static extern function subEqOp(a:FlxIntPoint, b:FlxIntPoint)
	{
		a.x -= b.x;
		a.y -= b.y;
		return a;
	}
	
	@:op(A *= B)
	inline static extern function scaleEqOp(p:FlxIntPoint, n:Int)
	{
		p.x *= n;
		p.y *= n;
		return p;
	}
}

class FlxIntPointBase
{
	public var x:Int;
	public var y:Int;

	public inline function new(x, y)
	{
		this.x = x;
		this.y = y;
	}
}
