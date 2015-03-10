package flixel.graphics.frames;

import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Just a special frame for handling bitmap fonts
 */
class FlxGlyphFrame extends FlxFrame
{
	/**
	 * How much to jump after drawing this glyph.
	 */
	public var xAdvance:Int = 0;
	
	/**
	 * Utf8 code for this glyph
	 */
	public var charCode:Int;
	
	@:allow(flixel)
	private function new(parent:FlxGraphic, charCode:Int) 
	{
		super(parent);
		this.charCode = charCode;
		type = FlxFrameType.GLYPH;
	}
}