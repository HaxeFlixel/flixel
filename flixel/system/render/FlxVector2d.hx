package flixel.system.render;

import openfl.Vector;

/**
 * An `openfl.Vector<T>` disguised as a `openfl.Vector<{ x:T, y:T }>` objects, but without the performance hit
 */
@:multiType(T)
abstract FlxVector2d<T>(Vector<T>) from Vector<T>
{
	// This is needed to get around openfl's complicated Vector class
	@:to static function ofInt(_:Vector<Int>) { return new FlxIntVector2d(0, false, new Array<Int>()); }
	@:to static function ofFloat(_:Vector<Float>) { return new FlxFloatVector2d(0, false, new Array<Float>()); }
	@:to static function ofBool(_:Vector<Bool>) { return new FlxBoolVector2d(0, false, new Array<Bool>()); }
	
	// Note: must be inlined
	@:to inline function toVector():Vector<T> { return this; }
	
	public var length(get, never):Int;
	inline function get_length() return this.length >> 1;
	
	public function new();
	
	public inline function set(index:Int, x:T, y:T)
	{
		this[index << 1 + 0] = x;
		this[index << 1 + 1] = y;
	}
	
	public inline function getX(index:Int) return this[index << 1 + 0];
	public inline function getY(index:Int) return this[index << 1 + 1];
	
	public inline function push(x:T, y:T)
	{
		this.push(x);
		this.push(y);
	}
	
	public inline function clear()
	{ 
		this.slice(0, this.length);
	}
}

@:forward @:forward.new abstract FlxIntVector2d(Vector<Int>) from Vector<Int> to Vector<Int> {}
@:forward @:forward.new abstract FlxFloatVector2d(Vector<Float>) from Vector<Float> to Vector<Float> {}
@:forward @:forward.new abstract FlxBoolVector2d(Vector<Bool>) from Vector<Bool> to Vector<Bool> {}