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

	#if (haxe <= version("4.3.0"))
	var abstract(get, never):FlxDirectionFlags;
	inline function get_abstract():FlxDirectionFlags return cast this;
	#end
	
	public function toString()
	{
		return switch abstract
		{
			case LEFT: "L";
			case RIGHT: "R";
			case UP: "U";
			case DOWN: "D";
		}
	}
	
	@:deprecated("implicit cast from FlxDirection to Int is deprecated, use an explicit cast")
	@:to
	function toIntImplicit()
	{
		return this;
	}
	
}
