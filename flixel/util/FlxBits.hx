package flixel.util;

// @:genericBuild(flixel.system.macros.FlxBitFlagMacro.genericBuildFlags())
// class FlxBits<T> {}// Macro makes this an abstract
abstract FlxBits<T>(Int)
{
	inline public function new ()
	{
		this = 0;
	}
	
	/**
	 * Returns true if this contains **all** of the supplied flags.
	 */
	public inline function has(bits:FlxBits<T>):Bool
	{
		return this & bits.toInt() == bits.toInt();
	}
	
	/**
	 * Returns true if this contains **any** of the supplied flags.
	 */
	public inline function hasAny(bits:FlxBits<T>)
	{
		return this & bits.toInt() > 0;
	}
	
	public inline function with(bits:FlxBits<T>)
	{
		return fromInt(this | bits.toInt());
	}
	
	public inline function without(bits:FlxBits<T>)
	{
		return fromInt(this & ~bits.toInt());
	}
	
	// public function toString()
	// {
	// 	final bits = [];
	// 	for (bit in $p{bitsPath})
	// 	{
	// 		if (has(bit))
	// 			bits.push(bit.toString());
	// 	}
		
	// 	return bits.join(" | ");
	// }
	
	inline function toInt():Int
	{
		return this;
	}
	
	inline static function fromInt<T>(value:Int):FlxBits<T>
	{
		return cast value;
	}
	
	@:from
	inline static function fromBits<T>(value:T)
	{
		return fromInt(intFromBit(value));
	}
	
	inline static function intFromBit<T>(value:T):Int
	{
		return (cast value:Int);
	}
}