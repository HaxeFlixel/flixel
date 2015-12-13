package flixel.system.debug.completion;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import flixel.util.FlxColor;

class CompletionListEntry extends Sprite
{
	public static inline var WIDTH = 150;
	public static inline var HEIGHT = 20;
	
	private static inline var COLOR_NORMAL = 0xFF5F5F5F;
	private static inline var COLOR_HIGHLIGHT = 0xFF6D6D6D;
	private static inline var GUTTER = 4;
	
	private static var NORMAL_BITMAP_DATA =
		new BitmapData(WIDTH, HEIGHT, true, COLOR_NORMAL);
	
	private static var HIGHLIGHT_BITMAP_DATA =
		new BitmapData(WIDTH, HEIGHT, true, COLOR_HIGHLIGHT);
		
	public var selected(default, set):Bool = false;
	
	private var background:Bitmap;
	private var label:TextField;
	
	public function new() 
	{	
		super();
		
		addChild(background = new Bitmap());
		background.bitmapData = NORMAL_BITMAP_DATA;
		
		label = DebuggerUtil.createTextField();
		label.x = GUTTER;
		label.width = WIDTH;
		addChild(label);
	}
	
	public function setItem(item:String)
	{
		label.text = item;
	}
	
	private function set_selected(selected:Bool):Bool
	{
		if (selected == this.selected)
			return selected;
		
		background.bitmapData = selected ?
			HIGHLIGHT_BITMAP_DATA : NORMAL_BITMAP_DATA;
		
		return this.selected = selected;
	}
}