package flixel.util;

/**
 * Uses bit flags to create a list of orthogonal directions. useful for
 * many `FlxObject` features like `allowCollisions` and `touching`.
 * @since 4.10.0
 */
@:enum abstract FlxDirectionFlags(Int) from Int from FlxDirection to Int
{
	var LEFT = 0x0001; // FlxDirection.LEFT;
	var RIGHT = 0x0010; // FlxDirection.RIGHT;
	var UP = 0x0100; // FlxDirection.UP;
	var DOWN = 0x1000; // FlxDirection.DOWN;
	// Directions values can't be constructed from other direction values, due to a bug in haxe.
	// https://github.com/HaxeFoundation/haxe/issues/10237
	// We'll just define all these using literal hex values, otherwise they can't be used as
	// default values for function arguments.

	/** Special-case constant meaning no directions. */
	var NONE = 0x0000;

	/** Special-case constant meaning "up". */
	var CEILING = 0x0100; // UP;

	/** Special-case constant meaning "down" */
	var FLOOR = 0x1000; // DOWN;

	/** Special-case constant meaning "left" and "right". */
	var WALL = 0x0011; // LEFT | RIGHT;

	/** Special-case constant meaning any, or all directions. */
	var ANY = 0x1111; // LEFT | RIGHT | UP | DOWN;

	/**
	 * Returns true if this contains all of the supplied flags.
	 */
	public inline function has(dir:FlxDirectionFlags):Bool
	{
		return this & dir == dir;
	}

	/**
	 * Creates a new `FlxDirections` that includes the supplied directions.
	 */
	public inline function with(dir:FlxDirectionFlags):FlxDirectionFlags
	{
		return this | dir;
	}

	/**
	 * Creates a new `FlxDirections` that excludes the supplied directions.
	 */
	public inline function without(dir:FlxDirectionFlags):FlxDirectionFlags
	{
		return this & ~dir;
	}

	public function toString()
	{
		if (this == NONE)
			return "NONE";

		var str = "";
		if (has(LEFT))
			str += " | L";
		if (has(RIGHT))
			str += " | R";
		if (has(UP))
			str += " | U";
		if (has(DOWN))
			str += " | D";

		// remove the first " | "
		return str.substr(3);
	}

	// Expose int operators
	@:op(A & B) static function and(a:FlxDirectionFlags, b:FlxDirectionFlags):FlxDirectionFlags;

	@:op(A | B) static function or(a:FlxDirectionFlags, b:FlxDirectionFlags):FlxDirectionFlags;

	@:op(A > B) static function gt(a:FlxDirectionFlags, b:FlxDirectionFlags):Bool;

	@:op(A < B) static function lt(a:FlxDirectionFlags, b:FlxDirectionFlags):Bool;

	@:op(A >= B) static function gte(a:FlxDirectionFlags, b:FlxDirectionFlags):Bool;

	@:op(A <= B) static function lte(a:FlxDirectionFlags, b:FlxDirectionFlags):Bool;
}
