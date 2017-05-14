package flixel.system.render.blit;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class FlxRenderTexture implements IFlxDestroyable
{
	public var bitmap(default, null):BitmapData;
	public var graphic(default, null):FlxGraphic;
	
	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;
	public var powerOfTwo(default, null):Bool = false;
	public var smoothing:Bool;
	
	public var actualWidth(default, null):Int = 0;
	public var actualHeight(default, null):Int = 0;
	
	public var clearBeforeRender:Bool = true;
	
	public var clearRed:Float = 0.0;
	public var clearGreen:Float = 0.0;
	public var clearBlue:Float = 0.0;
	public var clearAlpha:Float = 0.0;
	
	public var clearColor(get, set):FlxColor;
	
	private var rect:Rectangle;
	
	public function new(width:Int, height:Int, smoothing:Bool = true, powerOfTwo:Bool = false) 
	{
		this.powerOfTwo = false;
		this.smoothing = smoothing;
		rect = new Rectangle();
		resize(width, height);
	}
	
	public function resize(width:Int, height:Int) 
	{
		if (this.width == width && this.height == height) 
			return;
		
		this.width = width;
		this.height = height;
		
		actualWidth = width;
		actualHeight = height;
		
		createTexture(width, height);
	}
	
	private inline function createTexture(width:Int, height:Int)
	{
		bitmap = new BitmapData(width, height, true, 0);
		graphic = FlxGraphic.fromBitmapData(bitmap, false, null, false);
		rect.setTo(0, 0, width, height);
	}
	
	public function destroy():Void
	{
		bitmap = FlxDestroyUtil.dispose(bitmap);
		graphic = FlxDestroyUtil.destroy(graphic);
		rect = null;
	}
	
	public function clear(?mask:Null<Int>):Void
	{	
		bitmap.fillRect(rect, clearColor);
	}
	
	private inline function get_clearColor():FlxColor
	{
		return FlxColor.fromRGBFloat(clearRed, clearGreen, clearBlue, clearAlpha);
	}
	
	private inline function set_clearColor(value:FlxColor):FlxColor
	{
		clearRed = value.redFloat;
		clearGreen = value.greenFloat;
		clearBlue = value.blueFloat;
		clearAlpha = value.alphaFloat;
		return value;
	}
}