package flixel.graphics.tile;

import flash.display.BitmapData;
import flixel.FlxG;
import openfl.display.Tilesheet;

class FlxTilesheet extends Tilesheet
{
	/**
	 * Tracks total number of drawTiles() calls made each frame.
	 */
	public static var _DRAWCALLS:Int = 0;
}