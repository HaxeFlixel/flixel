package flixel.system.debug;
import flash.geom.Point;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flash.display.Bitmap;
import flash.display.BitmapData;
#if !FLX_NO_DEBUG

import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.debug.FlxDebugger;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;
import haxe.ds.StringMap;

/**
 * A simple trace output window for use in the debugger overlay.
 */
class BmpLog extends Window
{
	
	private var _canvas:Bitmap;
	private var _bmps:Array<BitmapData>;
	private var _currIndex:Int = 0;
	private var _zeroPt:Point = new Point();
	
	/**
	 * Creates a log window object.
	 */	
	public function new()
	{
		super("bmpLog", new GraphicBmpLog(0, 0));
		
		_bmps = [];
		
		_canvas = new Bitmap(new BitmapData(Std.int(width), Std.int(height - 15), true, 0x00000000));
		_canvas.x = 0;
		_canvas.y = 15;
		
		addChild(_canvas);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();
		
		clear();
		
		removeChild(_canvas);
		FlxDestroyUtil.dispose(_canvas.bitmapData);
		_canvas.bitmapData = null;
		_canvas = null;
		_bmps = null;
	}
	
	public override function resize(Width:Float,Height:Float):Void {
		super.resize(Width, Height);
		var bmp = _canvas.bitmapData;
		_canvas.bitmapData = null;
		FlxDestroyUtil.dispose(bmp);
		_canvas.bitmapData = new BitmapData(Std.int(_width - _canvas.x), Std.int(_height - _canvas.y), true, 0x00000000);
		refreshBmp(_currIndex);
	}
	
	public function next():Void {
		refreshBmp(_currIndex + 1);
	}
	
	public function previous():Void {
		refreshBmp(_currIndex - 1);
	}
	
	public function add(bmp:BitmapData):Bool
	{
		if (bmp == null)
		{
			return false;
		}
		_bmps.push(bmp.clone());
		return refreshBmp();
	}
	
	private function refreshBmp(Index:Int = -1):Bool
	{
		_canvas.bitmapData.fillRect(_canvas.bitmapData.rect, 0x00000000);
		
		if (Index == -1)
		{
			Index = _bmps.length - 1;
		}
		
		if (_bmps == null || _bmps.length <= 0)
		{
			_currIndex = 0;
			_title.text = "bmpLog";
			return false;
		}
		else if(Index >= _bmps.length-1)
		{
			Index = _bmps.length - 1;
		}
		
		_canvas.bitmapData.copyPixels(_bmps[Index], _canvas.bitmapData.rect, _zeroPt, null, null, true);
		_currIndex = Index;
		
		if(_bmps.length >= 0){
			_title.text = "bmpLog (" + (_currIndex + 1) + "/" + _bmps.length + ")";
		}else {
			_title.text = "bmpLog";
		}
		
		return true;
	}
	
	/**
	 * Clear one bitmap object from the log -- the last one, by default
	 * @param	Index
	 */
	
	public function clearAt(Index:Int=-1):Void
	{
		if (Index == -1)
		{
			Index = _bmps.length - 1;
		}
		FlxDestroyUtil.dispose(_bmps[Index]);
		_bmps[Index] = null;
		_bmps.splice(Index, 1);
		
		if (_currIndex > _bmps.length - 1) {
			_currIndex = _bmps.length - 1;
		}
		
		refreshBmp(_currIndex);
	}
	
	public function clear():Void
	{
		for (i in 0..._bmps.length) {
			FlxDestroyUtil.dispose(_bmps[i]);
			_bmps[i] = null;
		}
		FlxArrayUtil.clearArray(_bmps);
		refreshBmp(_currIndex);
	}
	
	/**
	 * Adjusts the width and height of the text field accordingly.
	 */
	override private function updateSize():Void
	{
		super.updateSize();
	}
}
#end
