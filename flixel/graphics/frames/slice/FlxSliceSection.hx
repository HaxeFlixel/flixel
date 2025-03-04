package flixel.graphics.frames.slice;

enum abstract FlxSliceSection(Int) from Int to Int
{
	static inline var COLUMNS = 3;
	static inline var ROWS = 3;
	
	var TL; var TC; var TR;
	var CL; var CC; var CR;
	var BL; var BC; var BR;
	
	public var column(get, never):Int;
	inline function get_column() return this % ROWS;
	public var row(get, never):Int;
	inline function get_row() return Std.int(this / ROWS);
	
	static public function createAll():Array<FlxSliceSection>
	{
		return [for (i in iterator()) i];
	}
	
	static public inline function iterator()
	{
		return new SectionIterator();
	}
	
	/**
	 * [Description]
	 * @param column 
	 * @param row 
	 * @return FlxSliceSection
	 */
	static public inline function fromXY(column:Int, row:Int):FlxSliceSection
	{
		return column + row * ROWS;
	}
}

class SectionIterator
{
	static inline var LENGTH = 9;
	var iter:IntIterator;
	
	public inline function new() { this.iter = 0...LENGTH; }
	
	public inline function hasNext() { return iter.hasNext(); }
	
	public inline function next():FlxSliceSection { return iter.next(); }
}

@:forward(length)
@:forward.variance
abstract FlxSectionList<T>(Array<T>) from Array<T>
{
	@:arrayAccess
	public inline function get(section:FlxSliceSection)
	{
		return this[section];
	}
	
	@:arrayAccess
	public inline function set(section:FlxSliceSection, value:T)
	{
		return this[section] = value;
	}
	
	public inline function iterator()
	{
		return this.iterator();
	}
	
	public inline function keys()
	{
		return new SectionIterator();
	}
	
	public inline function keyValueIterator()
	{
		return new SectionListKeyValueIterator(this);
	}
}

class SectionListKeyValueIterator<T>
{
	final list:FlxSectionList<T>;
	var current:Int = 0;

	public inline function new(list)
	{
		this.list = list;
	}

	public inline function hasNext():Bool
	{
		return current < list.length;
	}

	public inline function next()
	{
		final key:FlxSliceSection = current++;
		final value = list[key];
		return { value: value, key: key };
	}
}