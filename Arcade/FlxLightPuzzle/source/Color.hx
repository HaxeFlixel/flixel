package;

/**
 * Internal representation of color in the game.
 * Abstract Int so that colors can be easily combined using the | (or) operator.
 * @author MSGHero
 */
@:enum
abstract Color(Int) from Int to Int
{
	var MIRROR = 0x01 << 0;
	var RED = 0x01 << 1;
	var YELLOW = 0x01 << 2;
	var BLUE = 0x01 << 3;
	// using binary gives us an easy way to combine colors
	var ORANGE = RED | YELLOW;
	var GREEN = YELLOW | BLUE;
	var PURPLE = RED | BLUE;
	var WHITE = RED | YELLOW | BLUE;
}
