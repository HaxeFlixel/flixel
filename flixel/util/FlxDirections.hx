package flixel.util;

/**
 * Uses bit flags to create a list of orthogonal directions. useful for
 * many `FlxObject` features like `allowCollisions` and `touching`.
 * @since 4.10.0
 */
@:enum abstract FlxDirections(Int) from Int to Int
{
	/** Generic value for "left". */
	var LEFT    = 0x0001;
	/** Generic value for "right". */
	var RIGHT   = 0x0010;
	/** Generic value for "up". */
	var UP      = 0x0100;
	/** Generic value for "down". */
	var DOWN    = 0x1000;
	/** Special-case constant meaning no directions. */
	var NONE    = 0x0000;
	
	/**
	 * Directions values can't be constructed from other direction values, due to a bug in haxe.
	 * https://github.com/HaxeFoundation/haxe/issues/10237
	 * We'll just define all these using literal hex values, otherwise they can't be used as
	 * default values for function arguments.
	 */
	
	/** Special-case constant meaning "up". */
	var CEILING = 0x0100;// UP;
	/** Special-case constant meaning "down" */
	var FLOOR   = 0x1000;// DOWN;
	/** Special-case constant meaning "left" and "right". */
	var WALL    = 0x0011;// LEFT | RIGHT;
	/** Special-case constant meaning any, or all directions. */
	var ANY     = 0x1111;// LEFT | RIGHT | UP | DOWN;
	
	/**
	 * Returns true if this contains all of the supplied flags.
	 */
	public inline function hasAll(dir:FlxDirections):Bool
	{
		return this & dir == dir;
	}
	
	/**
	 * Returns true if this contains any one of the supplied flags.
	 */
	public inline function hasAny(dir:FlxDirections):Bool
	{
		return this & dir > NONE;
	}
	
	/**
	 * Adds the supplied flags if this doesn't already have them.
	 * This modifies this instance instead of creating a new one.
	 */
	@:op(A += B)
	public inline function add(dir:FlxDirections):FlxDirections
	{
		return this = this | dir;
	}
	
	/**
	 * Removes the supplied directions if they are present, ignores directions this does not have.
	 * This modifies this instance instead of creating a new one.
	 */
	@:op(A -= B)
	public inline function remove(dir:FlxDirections):FlxDirections
	{
		return this = this & ~dir;
	}
	
	/**
	 * Adds the supplied flags if this doesn't already have them.
	 * this creates a new instance without modifying this instance.
	 */
	@:op(A + B)
	public inline function addNew(dir:FlxDirections):FlxDirections
	{
		return this | dir;
	}
	
	/**
	 * Removes the supplied directions if they are present, ignores directions this does not have.
	 * This creates a new instance without modifying this instance.
	 */
	@:op(A - B)
	public inline function removeNew(dir:FlxDirections):FlxDirections
	{
		return this & ~dir;
	}
	
	public function toString()
	{
		if (this == NONE)
			return "NONE";
		
		var str = "";
		if (hasAny(LEFT )) str += " | L";
		if (hasAny(RIGHT)) str += " | R";
		if (hasAny(UP   )) str += " | U";
		if (hasAny(DOWN )) str += " | D";
		
		// remove the first " | "
		return str.substr(3);
	}
	
	//Expose int operators
	
	@:op(A &  B) static function and(a:FlxDirections, b:FlxDirections):FlxDirections;
	@:op(A |  B) static function or (a:FlxDirections, b:FlxDirections):FlxDirections;
	@:op(A >  B) static function gt (a:FlxDirections, b:FlxDirections):Bool;
	@:op(A <  B) static function lt (a:FlxDirections, b:FlxDirections):Bool;
	@:op(A >= B) static function gte(a:FlxDirections, b:FlxDirections):Bool;
	@:op(A <= B) static function lte(a:FlxDirections, b:FlxDirections):Bool;
}

