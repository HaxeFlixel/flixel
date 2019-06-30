package flixel.system.debug.completion;

import flixel.math.FlxMath;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

class CompletionListScrollBar extends Sprite
{
	static inline var BG_COLOR = 0xFF444444;
	static inline var HANDLE_COLOR = 0xFF222222;

	var handle:Bitmap;

	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		super();

		this.x = x;
		this.y = y;

		addChild(new Bitmap(new BitmapData(width, height, true, BG_COLOR)));
		handle = new Bitmap(new BitmapData(width, 1, true, HANDLE_COLOR));
		addChild(handle);
	}

	public function updateHandle(lower:Int, items:Int, entries:Int)
	{
		handle.scaleY = Math.min((height / items) * entries, height);
		handle.y = (height / items) * lower;
		handle.y = FlxMath.bound(handle.y, 0, height - handle.scaleY);
	}
}
