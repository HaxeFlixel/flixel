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
	
	private static var normalBitmapData:BitmapData;
	private static var highlightBitmapData:BitmapData;

	public var selected(default, set):Bool = false;
	
	private var background:Bitmap;
	private var label:TextField;
	
	public function new() 
	{	
		super();
		
		initBitmapDatas();
		
		addChild(background = new Bitmap());
		background.bitmapData = normalBitmapData;
		
		label = DebuggerUtil.createTextField();
		label.x = GUTTER;
		label.width = WIDTH;
		addChild(label);
	}
	
	private function initBitmapDatas()
	{
		if (normalBitmapData == null)
			normalBitmapData = new BitmapData(WIDTH, HEIGHT, true, COLOR_NORMAL);
		if (highlightBitmapData == null)
			highlightBitmapData = new BitmapData(WIDTH, HEIGHT, true, COLOR_HIGHLIGHT);
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
			highlightBitmapData : normalBitmapData;
		
		return this.selected = selected;
	}
}