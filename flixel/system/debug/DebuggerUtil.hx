package flixel.system.debug;

import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxColorUtil;

#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

class DebuggerUtil
{
	/**
	 * Helper method for textfield creation.
	 *
	 * @param	X		Textfield x position.
	 * @param	Y		Textfield y position.
	 * @param	Color	Textfield color, 0xAARRGGBB.
	 * @param	Size	Textfield size.
	 * @return	New label text field at specified position and format.
	 */
	public static function createTextField(X:Float = 0, Y:Float = 0, Color:Int = FlxColor.WHITE, Size:Int = 12):TextField
	{
		var tf:TextField = new TextField();
		tf.x = X;
		tf.y = Y;
		tf.multiline = false;
		tf.wordWrap = false;
		tf.embedFonts = true;
		tf.selectable = false;
		#if flash
		tf.antiAliasType = AntiAliasType.NORMAL;
		tf.gridFitType = GridFitType.PIXEL;
		#end
		tf.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, Size, FlxColorUtil.ARGBtoRGB(Color));
		tf.alpha = FlxColorUtil.getAlphaFloat(Color);
		return tf;
	}
}