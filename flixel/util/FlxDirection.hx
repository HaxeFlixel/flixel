package flixel.util;

/**
 * Simple enum for orthogonal directions. Can be combined into `FlxDirectionFlags`.
 * @since 4.10.0
 */
enum abstract FlxDirection(Int) to Int
{
	var LEFT = 0x0001;
	var RIGHT = 0x0010;
	var UP = 0x0100;
	var DOWN = 0x1000;

	public function toString()
	{
		return switch (cast this : FlxDirection)
		{
			case LEFT: "L";
			case RIGHT: "R";
			case UP: "U";
			case DOWN: "D";
		}
	}
}
