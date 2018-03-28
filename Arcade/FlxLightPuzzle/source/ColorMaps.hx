package;

import flixel.util.FlxColor;

/**
 * Mappings to convert between the internally used "color" and the displayed color.
 * The mapping can change mid-game if desired.
 * @author MSGHero
 */
class ColorMaps
{
	// internally used color => display color
	public static var rybMap:Map<Color, FlxColor> = [
		Color.MIRROR => 0xFFAAAAAA, // FlxColor.GRAY is a bit too dark for this game, so we're defining our own grey
		Color.RED => FlxColor.RED,
		Color.YELLOW => FlxColor.YELLOW,
		Color.BLUE => FlxColor.BLUE,
		Color.ORANGE => FlxColor.ORANGE,
		Color.GREEN => FlxColor.LIME, // FlxColor.GREEN kinda blends in with grey
		Color.PURPLE => FlxColor.PURPLE,
		Color.WHITE => FlxColor.BLACK
	];
	
	// display color is different for RGB mapping than RYB mapping
	public static var rgbMap:Map<Color, FlxColor> = [
		Color.MIRROR => 0xFFAAAAAA,
		Color.RED => FlxColor.RED,
		Color.YELLOW => FlxColor.LIME,
		Color.BLUE => FlxColor.BLUE,
		Color.ORANGE => FlxColor.YELLOW,
		Color.GREEN => FlxColor.CYAN,
		Color.PURPLE => FlxColor.MAGENTA,
		Color.WHITE => FlxColor.WHITE
	];
	
	public static var cmyMap:Map<Color, FlxColor> = [
		Color.MIRROR => 0xFFAAAAAA,
		Color.RED => FlxColor.MAGENTA,
		Color.YELLOW => FlxColor.YELLOW,
		Color.BLUE => FlxColor.CYAN,
		Color.ORANGE => FlxColor.RED,
		Color.GREEN => FlxColor.LIME,
		Color.PURPLE => FlxColor.BLUE,
		Color.WHITE => FlxColor.BLACK
	];
	
	// the mapping that is actually used
	public static var defaultColorMap:Map<Color, FlxColor> = rybMap;
}