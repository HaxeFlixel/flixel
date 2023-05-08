package flixel.util;

import flixel.math.FlxAngle;

/**
 * Uses bit flags to create a list of orthogonal directions. useful for
 * many `FlxObject` features like `allowCollisions` and `touching`.
 * @since 4.10.0
 */
enum abstract FlxDirectionFlags(Int) from Int from FlxDirection to Int
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
	 * Calculates the angle (in degrees) of the facing flags.
	 * Returns 0 if two opposing flags are true.
	 * @since 5.0.0
	 */
	public var degrees(get, never):Float;
	function get_degrees():Float
	{
		return switch (this) {
			case RIGHT: 0;
			case DOWN: 90;
			case UP: -90;
			case LEFT: 180;
			case f if (f == DOWN | RIGHT): 45;
			case f if (f == DOWN | LEFT): 135;
			case f if (f == UP | RIGHT): -45;
			case f if (f == UP | LEFT): -135;
			default: 0;
		}
	}

	/**
	 * Calculates the angle (in radians) of the facing flags.
	 * Returns 0 if two opposing flags are true.
	 * @since 5.0.0
	 */
	public var radians(get, never):Float;
	inline function get_radians():Float
	{
		return degrees * FlxAngle.TO_RAD;
	}

	/**
	 * Returns true if this contains **all** of the supplied flags.
	 */
	public inline function has(dir:FlxDirectionFlags):Bool
	{
		return this & dir == dir;
	}

	/**
	 * Returns true if this contains **any** of the supplied flags.
	 */
	public inline function hasAny(dir:FlxDirectionFlags):Bool
	{
		return this & dir > 0;
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

	/**
	 * Generates a FlxDirectonFlags instance from 4 bools
	 * @since 5.0.0
	 */
	public static function fromBools(left:Bool, right:Bool, up:Bool, down:Bool):FlxDirectionFlags
	{
		return (left  ? LEFT  : NONE)
			|  (right ? RIGHT : NONE)
			|  (up    ? UP    : NONE)
			|  (down  ? DOWN  : NONE);
	}

	// Expose int operators
	@:op(A & B) static function and(a:FlxDirectionFlags, b:FlxDirectionFlags):FlxDirectionFlags;

	@:op(A | B) static function or(a:FlxDirectionFlags, b:FlxDirectionFlags):FlxDirectionFlags;

	@:op(A > B) static function gt(a:FlxDirectionFlags, b:FlxDirectionFlags):Bool;

	@:op(A < B) static function lt(a:FlxDirectionFlags, b:FlxDirectionFlags):Bool;

	@:op(A >= B) static function gte(a:FlxDirectionFlags, b:FlxDirectionFlags):Bool;

	@:op(A <= B) static function lte(a:FlxDirectionFlags, b:FlxDirectionFlags):Bool;
}
