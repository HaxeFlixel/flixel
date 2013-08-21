package flixel.system.debug;
#if !FLX_NO_DEBUG

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxBitmapUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;
import haxe.ds.StringMap;

/**
 * A simple trace output window for use in the debugger overlay.
 */
class BmpLog extends Window
{
	//static public var MAX_LOG_LINES:Int = 200;

	private var _bmps:Array<Bitmap>;
	//private var _text:TextField;
	//private var _lines:Array<String>;
	
	/**
	 * Creates a new window object.  This Flash-based class is mainly (only?) used by <code>FlxDebugger</code>.
	 * @param 	Title		The name of the window, displayed in the header bar.
	 * @param 	Width		The initial width of the window.
	 * @param 	Height		The initial height of the window.
	 * @param 	Resizable	Whether you can change the size of the window with a drag handle.
	 * @param 	Bounds		A rectangle indicating the valid screen area for the window.
	 */	
	public function new(Title:String, Width:Float, Height:Float, Resizable:Bool = true, ?Bounds:Rectangle)
	{
		super(Title, Width, Height, Resizable, Bounds);
		
		/*_text = new TextField();
		_text.x = 2;
		_text.y = 15;
		_text.multiline = true;
		_text.wordWrap = true;
		_text.selectable = true;
		_text.embedFonts = true;
		_text.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xffffff);
		addChild(_text);*/
		
		_bmps = new Array<Bitmap>();
		
		//_lines = new Array<String>();
		
		//FlxG.log.redirectTraces = true;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		clear();
		_bmps = null;
		super.destroy();
	}
	
	/**
	 * Adds a new image to the log window.
	 * @param 	Data		The image being logged.
	 * @param 	Style		The <code>LogStyle</code> to be used for the log
	 * @param 	FireOnce   	Whether you only want to log the Data in case it hasn't been added already
	 */
	public function add(Data:BitmapData, FireOnce:Bool = false):Bool
	{
		if (Data == null) 
		{
			return false;
		}
		
		// Check if the text has been added yet already
		if (FireOnce)
		{
			for (bmp in _bmps)
			{
				if (bmp.bitmapData != null)
				{
					if (FlxBitmapUtil.compare(Data, bmp.bitmapData) == 0)
					{
						return false;
					}
				}
			}
		}
		
		// Actually add it 
		var bmp:Bitmap = new Bitmap(Data.clone());
		bmp.x = 2;			
		if (_bmps.length > 0) 
		{
			var last:Bitmap = _bmps[_bmps.length - 1];
			bmp.y = last.y + last.height + 2;
		}
		else 
		{
			bmp.y = 15;
		}
		
		_bmps.push(bmp);		
		addChild(bmp);				
		return true;
	}
	
	public function clear():Void 
	{
		if (_bmps != null)
		{
			while (_bmps.length > 0) 
			{
				var bmp:Bitmap = _bmps.pop();
				removeChild(bmp);
				if (bmp != null) 
				{ 
					if (bmp.bitmapData != null)
					{
						bmp.bitmapData.dispose(); 
						bmp.bitmapData = null;
					}
					bmp = null; 
				}			
			}
		}
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