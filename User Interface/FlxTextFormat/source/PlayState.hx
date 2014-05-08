package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		var text = new FlxText(0, 60, FlxG.width, "Hello HaxeFlixel Community!");
		text.setFormat(null, 48, FlxColor.BLACK, "center");
		text.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		
		text.addFormat(new FlxTextFormat(0xE6E600, false, false, 0xFF8000, 6, 8));
		text.addFormat(new FlxTextFormat(0xFFAE5E, false, false, 0xFF8000, 8, 10));
		text.addFormat(new FlxTextFormat(0x008040, false, false, null, 10, 12));
		text.addFormat(new FlxTextFormat(0x0080C0, false, false, null, 12, 14));
		text.addFormat(new FlxTextFormat(0x00E6E6, false, false, null, 14, 16));
		text.addFormat(new FlxTextFormat(0x0080FF, false, false, 0xFFFFFF, 16, 100));
		
		add(text);
	}
}