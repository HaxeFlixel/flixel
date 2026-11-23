package flixel.math;

/**
 * Simple class for representing 2d rectangles contrained to integers,
 * handy for bitmaps or tile-based coordinates
 */
@:nullSafety(Strict)
@:forward
abstract FlxIntRect(FlxIntRectBase)
{
	public var x(get, set):Int;
	public var y(get, set):Int;
	public var width(get, set):Int;
	public var height(get, set):Int;
	
	inline extern function get_x():Int return this.pos.x;
	inline extern function get_y():Int return this.pos.y;
	inline extern function get_width():Int return this.size.x;
	inline extern function get_height():Int return this.size.y;
	
	inline extern function set_x(value):Int return this.pos.x = value;
	inline extern function set_y(value):Int return this.pos.y = value;
	inline extern function set_width(value):Int return this.size.x = value;
	inline extern function set_height(value):Int return this.size.y = value;
	
	/** The width of the rectangle */
	public var w(get, set):Int;
	
	/** The height of the rectangle */
	public var h(get, set):Int;
	
	inline extern function get_w():Int return this.size.x;
	inline extern function get_h():Int return this.size.y;
	inline extern function set_w(value):Int return this.size.x = value;
	inline extern function set_h(value):Int return this.size.y = value;
	
	overload public inline extern function new (x:Int, y:Int, width:Int, height:Int)
	{
		this = new FlxIntRectBase(new FlxIntPoint(x, y), new FlxIntPoint(width, height));
	}
	
	overload public inline extern function new (pos, width:Int, height:Int)
	{
		this = new FlxIntRectBase(pos, new FlxIntPoint(width, height));
	}
	
	overload public inline extern function new (pos, size)
	{
		this = new FlxIntRectBase(pos, size);
	}
	
	overload public inline extern function new (x:Int, y:Int, size)
	{
		this = new FlxIntRectBase(new FlxIntPoint(x, y), size);
	}
	
	inline public function set(x:Int, y:Int, width:Int, height:Int)
	{
		this.pos.set(x, y);
		this.size.set(width, height);
	}
	
	inline public extern function copy()
	{
		return new FlxIntRect(x, y, width, height);
	}
	
	overload public inline extern function equals(r:FlxIntRect)
	{
		return equals(r.x, r.y, r.width, r.height);
	}
	
	overload public inline extern function equals(pos:FlxIntPoint, size:FlxIntPoint)
	{
		return equals(pos.x, pos.y, size.x, size.y);
	}
	
	overload public inline extern function equals(x:Int, y:Int, size:FlxIntPoint)
	{
		return equals(x, y, size.x, size.y);
	}
	
	overload public inline extern function equals(pos:FlxIntPoint, width:Int, height:Int)
	{
		return equals(pos.x, pos.y, width, height);
	}
	
	overload public inline extern function equals(x:Int, y:Int, width:Int, height:Int)
	{
		return this.pos.equals(x, y) && this.size.equals(width, height);
	}
	
	overload public inline extern function toFloats()
	{
		return FlxRect.get(x, y, width, height);
	}
	
	overload public inline extern function toFloats(r:FlxRect)
	{
		return r.set(x, y, width, height);
	}
	
	@:op(A + B)
	@:commutative
	inline static extern function addOp(r:FlxIntRect, p:FlxIntPoint)
	{
		return new FlxIntRect(r.x + p.x, r.y + p.y, r.width, r.height);
	}
	
	@:op(A - B)
	@:commutative
	inline static extern function subOp(r:FlxIntRect, p:FlxIntPoint)
	{
		return new FlxIntRect(r.x - p.x, r.y - p.y, r.width, r.height);
	}
	
	@:op(A += B)
	inline static extern function addEqOp(r:FlxIntRect, p:FlxIntPoint)
	{
		return new FlxIntRect(r.x + p.x, r.y + p.y, r.width, r.height);
	}
	
	@:op(A -= B)
	inline static extern function subEqOp(r:FlxIntRect, p:FlxIntPoint)
	{
		return new FlxIntRect(r.x - p.x, r.y - p.y, r.width, r.height);
	}
}

class FlxIntRectBase
{
	public var pos:FlxIntPoint;
	public var size:FlxIntPoint;

	public inline extern function new(pos, size)
	{
		this.pos = pos;
		this.size = size;
	}
}
