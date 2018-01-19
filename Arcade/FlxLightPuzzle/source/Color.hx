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
	var ORANGE = 6; // equal to RED | YELLOW
	var GREEN = 12; // equal to YELLOW | BLUE
	var PURPLE = 10; // equal to RED | BLUE
	
	var WHITE = 14; // equal to RED | YELLOW | BLUE
}