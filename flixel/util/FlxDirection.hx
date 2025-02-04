package flixel.util;

/**
 * Simple enum for orthogonal directions. Can be combined into `FlxDirectionFlags`.
 * @since 4.10.0
 */
enum abstract FlxDirection(Int)
{
	var LEFT = 0x0001;
	var RIGHT = 0x0010;
	var UP = 0x0100;
	var DOWN = 0x1000;
	
	var self(get, never):FlxDirection;
	inline function get_self():FlxDirection
	{
		#if (haxe >= version("4.3.0"))
		return abstract;
		#else
		return cast this;
		#end
	}
	
	inline function new(value:Int)
	{
		this = value;
	}
	
	public function toString()
	{
		return switch self
		{
			case LEFT: "L";
			case RIGHT: "R";
			case UP: "U";
			case DOWN: "D";
		}
	}
	
	inline public function toInt()
	{
		return this;
	}
	
	public inline static function fromInt(value:Int):FlxDirection
	{
		return new FlxDirection(value);
	}
}
