package org.flixel.system;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BlendMode;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;
import org.flixel.FlxG;

/**
 * ...
 * @author Werdn
 */

@:bitmap ("org/flixel/data/logo.png") class ImgLogo extends BitmapData {}
@:bitmap ("org/flixel/data/logo_corners.png") class ImgLogoCorners extends BitmapData {}
@:bitmap ("org/flixel/data/logo_light.png") class ImgLogoLight extends BitmapData {}

class FlxPreloader extends NMEPreloader
{
	//TODO Improve neko BlendMode type
	#if flash
	private static inline var MY_SCREEN = BlendMode.SCREEN;
	private static inline var MY_OVERLAY = BlendMode.OVERLAY;
	#else
	private static inline var MY_SCREEN = "screen";
	private static inline var MY_OVERLAY = "overlay";	
	#end
	
	/**
	 * @private
	 */
	private var _init:Bool;
	/**
	 * @private
	 */
	private var _buffer:Sprite;
	/**
	 * @private
	 */
	private var _bmpBar:Bitmap;
	/**
	 * @private
	 */
	private var _text:TextField;
	/**
	 * Useful for storing "real" stage width if you're scaling your preloader graphics.
	 */
	private var _width:Int;
	/**
	 * Useful for storing "real" stage height if you're scaling your preloader graphics.
	 */
	private var _height:Int;
	/**
	 * @private
	 */
	private var _logo:Bitmap;
	/**
	 * @private
	 */
	private var _logoGlow:Bitmap;
	/**
	 * @private
	 */
	private var _min:Int;
	
	/**
	 * Percent from loaded movie
	 */
	private var _percent:Float;

	/**
	 * This should always be the name of your main project/document class (e.g. GravityHook).
	 */
	public var className:String;
	/**
	 * Set this to your game's URL to use built-in site-locking.
	 */
	public var myURL:String;
	/**
	 * Change this if you want the flixel logo to show for more or less time.  Default value is 0 seconds.
	 */
	public var minDisplayTime:Float;

	public function new() 
	{
		super();
		removeChild(outline);
		removeChild(progress);
		
		minDisplayTime = 0;
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		create();
	}
	
	private function create() 
	{
		_min = 0;
		if (!FlxG.debug)
		{
			_min = cast minDisplayTime * 1000;
		}
		_buffer = new Sprite();
		_buffer.scaleX = 2;
		_buffer.scaleY = 2;
		addChild(_buffer);
		_width = cast stage.stageWidth/_buffer.scaleX;
		_height = cast stage.stageHeight/_buffer.scaleY;
		_buffer.addChild(new Bitmap(new BitmapData(_width,_height,false,0x00345e)));
		var bitmap:Bitmap = new Bitmap(new ImgLogoLight(0, 0));
		bitmap.smoothing = true;
		bitmap.width = bitmap.height = _height;
		bitmap.x = (_width-bitmap.width)/2;
		_buffer.addChild(bitmap);
		_bmpBar = new Bitmap(new BitmapData(1,7,false,0x5f6aff));
		_bmpBar.x = 4;
		_bmpBar.y = _height-11;
		_buffer.addChild(_bmpBar);
		_text = new TextField();
		_text.defaultTextFormat = new TextFormat("system", 8, 0x5f6aff);
		_text.embedFonts = true;
		_text.selectable = false;
		_text.multiline = false;
		_text.x = 2;
		_text.y = _bmpBar.y - 11;
		_text.width = 80;
		_buffer.addChild(_text);
		_logo = new Bitmap( new ImgLogo(0, 0));
		_logo.scaleX = _logo.scaleY = _height/8;
		_logo.x = (_width-_logo.width)/2;
		_logo.y = (_height-_logo.height)/2;
		_buffer.addChild(_logo);
		_logoGlow = new Bitmap( new ImgLogo(0, 0));
		_logoGlow.smoothing = true;
		_logoGlow.blendMode = MY_SCREEN;
		_logoGlow.scaleX = _logoGlow.scaleY = _height/8;
		_logoGlow.x = (_width-_logoGlow.width)/2;
		_logoGlow.y = (_height-_logoGlow.height)/2;
		_buffer.addChild(_logoGlow);
		bitmap = new Bitmap(new ImgLogoCorners(0, 0));
		bitmap.smoothing = true;
		bitmap.width = _width;
		bitmap.height = _height;
		_buffer.addChild(bitmap);
		bitmap = new Bitmap(new BitmapData(_width,_height,false,0xffffff));
		var i:Int = 0;
		var j:Int = 0;
		while(i < _height)
		{
			j = 0;
			while(j < _width)
				bitmap.bitmapData.setPixel(j++,i,0);
			i+=2;
		}
		bitmap.blendMode = MY_OVERLAY;
		bitmap.alpha = 0.25;
		_buffer.addChild(bitmap);
	}
	
	private function destroy():Void
	{
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		removeChild(_buffer);
		_buffer = null;
		_bmpBar = null;
		_text = null;
		_logo = null;
		_logoGlow = null;
	}
	
	override public function onLoaded()
	{
		//Do nothing here
	}
	
	override public function onUpdate(bytesLoaded:Int, bytesTotal:Int)
	{
		_percent = bytesTotal != 0 ? bytesLoaded / bytesTotal : 0;
	}
	
	private function onEnterFrame(event:Event):Void
	{
		if(!this._init)
		{
			if((stage.stageWidth <= 0) || (stage.stageHeight <= 0))
				return;
			create();
			this._init = true;
		}
		graphics.clear();
		var time:Int = Lib.getTimer();
		if((_percent >= 1) && (time > _min))
		{
			super.onLoaded();
			destroy();
		}
		else
		{
			var percent = _percent;
			if ((_min > 0) && (percent > time / _min))
			{
				percent = time / _min;
			}
			update(percent);
		}
	}
	
	private function update(percent:Float):Void
	{
		_bmpBar.scaleX = percent*(_width-8);
		_text.text = "FLX v" + FlxG.LIBRARY_MAJOR_VERSION + "." + FlxG.LIBRARY_MINOR_VERSION + " " + Math.floor(percent * 100) + "%";
		_text.setTextFormat(_text.defaultTextFormat);
		if(percent < 0.1)
		{
			_logoGlow.alpha = 0;
			_logo.alpha = 0;
		}
		else if(percent < 0.15)
		{
			_logoGlow.alpha = Math.random();
			_logo.alpha = 0;
		}
		else if(percent < 0.2)
		{
			_logoGlow.alpha = 0;
			_logo.alpha = 0;
		}
		else if(percent < 0.25)
		{
			_logoGlow.alpha = 0;
			_logo.alpha = Math.random();
		}
		else if(percent < 0.7)
		{
			_logoGlow.alpha = (percent-0.45)/0.45;
			_logo.alpha = 1;
		}
		else if((percent > 0.8) && (percent < 0.9))
		{
			_logoGlow.alpha = 1-(percent-0.8)/0.1;
			_logo.alpha = 0;
		}
		else if(percent > 0.9)
		{
			_buffer.alpha = 1-(percent-0.9)/0.1;
		}
	}
	
}