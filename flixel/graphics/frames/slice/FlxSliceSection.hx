package flixel.graphics.frames.slice;

import flixel.util.FlxBits;

@:build(flixel.system.macros.FlxBitFlagMacro.buildBits())
enum abstract FlxSliceSection(Int)
{
	var TL; var TC; var TR;
	var CL; var CC; var CR;
	var BL; var BC; var BR;
	
	static final LOG2 = Math.log(2);
	static inline var COLUMNS = 3;
	static inline var ROWS = 3;
	
	var index(get, never):Int;
	inline function get_index() return Std.int(Math.log(this) / LOG2);
	
	public var row(get, never):Int;
	inline function get_row() return Std.int(index / 3);
	
	public var column(get, never):Int;
	inline function get_column() return index % 3;
	
}

@:forward
@:forward.new
@:forward.static
abstract FlxSliceSectionFlags(FlxBits<FlxSliceSection>) from FlxBits<FlxSliceSection> to FlxBits<FlxSliceSection>
{
	public function toString()
	{
		final bits = [];
		for (bit in FlxSliceSection.iterator())
		{
			if (this.has(bit))
				bits.push(bit.toString());
		}
		
		return bits.join(" | ");
	}
	
	@:op(A | B) static function or<T>(a:FlxSliceSectionFlags, b:FlxSliceSectionFlags):FlxSliceSectionFlags;
	
	@:commutative
	@:op(A | B) static function orBits<T>(a:FlxSliceSectionFlags, b:FlxSliceSection):FlxSliceSectionFlags;
}

@:access(flixel.graphics.frames.slice.FlxSliceSection)
@:forward(length)
@:forward.variance
abstract FlxSliceSectionList<T>(Array<T>) from Array<T>
{
	public function new(defaultValue:()->T)
	{
		this = [for (i in FlxSliceSection) defaultValue()];
	}
	
	@:arrayAccess
	public inline function get(section:FlxSliceSection)
	{
		return this[intFromBit(section)];
	}
	
	@:arrayAccess
	public inline function set(section:FlxSliceSection, value:T)
	{
		return this[intFromBit(section)] = value;
	}
	
	public inline function iterator()
	{
		return this.iterator();
	}
	
	public inline function keys()
	{
		return FlxSliceSection.iterator();
	}
	
	public inline function keyValueIterator()
	{
		return new SectionListKeyValueIterator(this);
	}
	
	static inline function intFromBit(bit:FlxSliceSection)
	{
		return bit.index;
	}
}

class SectionListKeyValueIterator<T>
{
	final list:FlxSliceSectionList<T>;
	var iter = FlxSliceSection.iterator();

	public inline function new(list)
	{
		this.list = list;
	}

	public inline function hasNext():Bool
	{
		return iter.hasNext();
	}

	public inline function next()
	{
		final key:FlxSliceSection = iter.next();
		final value = list[key];
		return { value: value, key: key };
	}
}