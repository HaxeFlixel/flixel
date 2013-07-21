package flixel.system;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import flash.text.Font;
import flash.utils.ByteArray;
import flixel.FlxG;
import flash.events.MouseEvent;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextField;
import flash.net.URLRequest;

#if js
class FlxPreloader extends NMEPreloader
{	
	public function new()
	{
		super();
	}
}
#else
@:font("assets/data/nokiafc22.ttf") class PreloaderFont extends Font { }

@:bitmap("assets/data/logo_light.png") class LogoLight extends BitmapData {}
@:bitmap("assets/data/logo_corners.png") class LogoCorners extends BitmapData {}

/**
 * This class handles the 8-bit style preloader.
 */
class FlxPreloader extends NMEPreloader
{	
	private static var BlendModeScreen = BlendMode.SCREEN;
	private static var BlendModeOverlay = BlendMode.OVERLAY;

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
	private var _logo:Sprite;
	/**
	 * @private
	 */
	private var _logoGlow:Sprite;
	/**
	 * @private
	 */
	private var _min:Int;
	
	/**
	 * @private
	 */
	private var _percent:Float;

	/**
	 * List of allowed URLs for built-in site-locking.
	 * Use full swf's addresses with 'http' or 'https'.
	 * Set it in FlxPreloader's subclass constructor as:
	 * allowedURLs = ['http://adamatomic.com/canabalt/', FlxPreloader.LOCAL];
	 */
	public var allowedURLs:Array<String>;
	
	/**
	 * @private
	 */
	private var _urlChecked:Bool;
	
	/**
	 * Add this string to allowedURLs array if you want to be able to test game with enabled site-locking on local machine 
	 */
	public static inline var LOCAL:String = "local";
	
	/**
	 * Change this if you want the flixel logo to show for more or less time.  Default value is 0 seconds.
	 */
	public var minDisplayTime:Float;
	
	/**
	 * Constructor
	 */
	public function new()
	{
		super();
		removeChild(outline);
		removeChild(progress);
		
		minDisplayTime = 0.3;
		this._init = false;
		_urlChecked = false;
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		create();
	}
	
	/**
	 * Override this to create your own preloader objects.
	 * Highly recommended you also override update()!
	 */
	private function create():Void
	{
		_min = 0;
		#if FLX_NO_DEBUG
		_min = Std.int(minDisplayTime * 1000);
		#end
		_buffer = new Sprite();
		_buffer.scaleX = _buffer.scaleY = 2;
		addChild(_buffer);
		_width = Std.int(Lib.current.stage.stageWidth / _buffer.scaleX);
		_height = Std.int(Lib.current.stage.stageHeight / _buffer.scaleY);
		_buffer.addChild(new Bitmap(new BitmapData(_width, _height, false, 0x00345e)));
		var bitmap:Bitmap = new Bitmap(new LogoLight(0, 0));
		bitmap.smoothing = true;
		bitmap.width = bitmap.height = _height;
		bitmap.x = (_width - bitmap.width) / 2;
		_buffer.addChild(bitmap);
		_bmpBar = new Bitmap(new BitmapData(1, 7, false, 0x5f6aff));
		_bmpBar.x = 4;
		_bmpBar.y = _height - 11;
		_buffer.addChild(_bmpBar);
		
		Font.registerFont(PreloaderFont);
		_text = new TextField();
		_text.defaultTextFormat = new TextFormat("Nokia Cellphone FC Small", 8, 0x5f6aff);
		_text.embedFonts = true;
		_text.selectable = false;
		_text.multiline = false;
		_text.x = 2;
		_text.y = _bmpBar.y - 11;
		_text.width = 200;
		_buffer.addChild(_text);
		
		_logo = new Sprite();
		drawLogo(_logo.graphics);
		_logo.scaleX = _logo.scaleY = _height / 8 * 0.04;
		_logo.x = (_width - _logo.width) / 2;
		_logo.y = (_height - _logo.height) / 2;
		_buffer.addChild(_logo);
		_logoGlow = new Sprite();
		drawLogo(_logoGlow.graphics);
		_logoGlow.blendMode = BlendModeScreen;
		_logoGlow.scaleX = _logoGlow.scaleY = _height / 8 * 0.04;
		_logoGlow.x = (_width - _logoGlow.width) / 2;
		_logoGlow.y = (_height - _logoGlow.height) / 2;
		_buffer.addChild(_logoGlow);
		bitmap = new Bitmap(new LogoCorners(0, 0));
		bitmap.smoothing = true;
		bitmap.width = _width;
		bitmap.height = _height;
		_buffer.addChild(bitmap);
		bitmap = new Bitmap(new BitmapData(_width, _height, false, 0xffffff));
		var i:Int = 0;
		var j:Int = 0;
		while(i < _height)
		{
			j = 0;
			while(j < _width)
			{
				bitmap.bitmapData.setPixel(j++, i, 0);
			}
			i += 2;
		}
		bitmap.blendMode = BlendModeOverlay;
		bitmap.alpha = 0.25;
		_buffer.addChild(bitmap);
	}
	
	private function drawLogo(graph:Graphics):Void
	{
		// draw green area
		graph.beginFill(0x00b922);
		graph.moveTo(50, 13);
		graph.lineTo(51, 13);
		graph.lineTo(87, 50);
		graph.lineTo(87, 51);
		graph.lineTo(51, 87);
		graph.lineTo(50, 87);
		graph.lineTo(13, 51);
		graph.lineTo(13, 50);
		graph.lineTo(50, 13);
		graph.endFill();
		
		// draw yellow area
		graph.beginFill(0xffc132);
		graph.moveTo(0, 0);
		graph.lineTo(25, 0);
		graph.lineTo(50, 13);
		graph.lineTo(13, 50);
		graph.lineTo(0, 25);
		graph.lineTo(0, 0);
		graph.endFill();
		
		// draw red area
		graph.beginFill(0xf5274e);
		graph.moveTo(100, 0);
		graph.lineTo(75, 0);
		graph.lineTo(51, 13);
		graph.lineTo(87, 50);
		graph.lineTo(100, 25);
		graph.lineTo(100, 0);
		graph.endFill();
		
		// draw blue area
		graph.beginFill(0x3641ff);
		graph.moveTo(0, 100);
		graph.lineTo(25, 100);
		graph.lineTo(50, 87);
		graph.lineTo(13, 51);
		graph.lineTo(0, 75);
		graph.lineTo(0, 100);
		graph.endFill();
		
		// draw light-blue area
		graph.beginFill(0x04cdfb);
		graph.moveTo(100, 100);
		graph.lineTo(75, 100);
		graph.lineTo(51, 87);
		graph.lineTo(87, 51);
		graph.lineTo(100, 75);
		graph.lineTo(100, 100);
		graph.endFill();
	}
	
	private function destroy():Void
	{
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		if (_buffer != null)	
		{
			removeChild(_buffer);
		}
		_buffer = null;
		_bmpBar = null;
		_text = null;
		_logo = null;
		_logoGlow = null;
	}
	
	override public function onLoaded():Void 
	{
		// Do nothing here
	}
	
	override public function onUpdate(bytesLoaded:Int, bytesTotal:Int):Void 
	{
		_percent = (bytesTotal != 0) ? bytesLoaded / bytesTotal : 0;
	}
	
	private function onEnterFrame(event:Event):Void
	{
		if(!this._init)
		{
			if((Lib.current.stage.stageWidth <= 0) || (Lib.current.stage.stageHeight <= 0))
			{
				return;
			}
			create();
			this._init = true;
		}
		
		checkSiteLock();
		
		graphics.clear();
		var time:Int = Lib.getTimer();
		if((_percent >= 1) && (time > _min))
		{
			super.onLoaded();
			destroy();
		}
		else
		{
			var percent:Float = _percent;
			if((_min > 0) && (percent > time/_min))
			{
				percent = time / _min;
			}
			update(percent);
		}
	}
	
	private function checkSiteLock():Void
	{
		#if flash
		if (_urlChecked == false && allowedURLs != null)
		{
			if (atHome() == false)
			{
				var tmp:Bitmap = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0xFFFFFFFF));
				addChild(tmp);
				
				var format:TextFormat = new TextFormat();
				format.color = 0x000000;
				format.size = 16;
				format.align = TextFormatAlign.CENTER;
				format.bold = true;
				format.font = "system";
				
				var textField:TextField = new TextField();
				textField.width = tmp.width - 16;
				textField.height = tmp.height - 16;
				textField.y = 8;
				textField.multiline = true;
				textField.wordWrap = true;
				textField.defaultTextFormat = format;
				textField.text = "Hi there!  It looks like somebody copied this game without my permission.  Just click anywhere, or copy-paste this URL into your browser.\n\n" + allowedURLs[0] + "\n\nto play the game at my site.  Thanks, and have fun!";
				addChild(textField);
				
				textField.addEventListener(MouseEvent.CLICK, goToMyURL);
				tmp.addEventListener(MouseEvent.CLICK, goToMyURL);
				
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				return;
			}
			else
			{
				_urlChecked = true;
			}
		}
		#end
	}
	
	#if flash
	private function goToMyURL(e:MouseEvent = null):Void
	{
		Lib.getURL(new URLRequest(allowedURLs[0]));
	}
	
	/**
	 * Gets home domain
	 */
	private function getHomeDomain():String
	{
		return getDomain(loaderInfo.loaderURL);
	}
	
	private function getDomain(url:String):String
	{
		var urlStart:Int = url.indexOf("://") + 3;
		var urlEnd:Int = url.indexOf("/", urlStart);
		var home:String = url.substring(urlStart, urlEnd);
		var LastDot:Int = home.lastIndexOf(".") - 1;
		var domEnd:Int = home.lastIndexOf(".", LastDot) + 1;
		home = home.substring(domEnd, home.length);
		home = home.split(":")[0];
		return (home == "") ? LOCAL : home;
	}
	
	/**
	 * Simple site-lock check
	 */
	private function atHome():Bool
	{
		if (allowedURLs.length == 0)
		{
			return true;
		}
		
		var homeDomain:String = getHomeDomain();
		for (i in 0...allowedURLs.length)
		{
			var allowedURL:String = allowedURLs[i];
			if (getDomain(allowedURL) == homeDomain)
			{
				return true;
			}
			else if (allowedURL == LOCAL && homeDomain == LOCAL)
			{
				return true;
			}
		}
		return false;
	}
	#end
	
	/**
	 * Override this function to manually update the preloader.
	 * 
	 * @param	Percent		How much of the program has loaded.
	 */
	private function update(Percent:Float):Void
	{
		_bmpBar.scaleX = Percent * (_width - 8);
		_text.text = "FLX v" + FlxG.LIBRARY_MAJOR_VERSION + "." + FlxG.LIBRARY_MINOR_VERSION + " " + Std.int(Percent * 100) + "%";
		if(Percent < 0.1)
		{
			_logoGlow.alpha = 0;
			_logo.alpha = 0;
		}
		else if(Percent < 0.15)
		{
			_logoGlow.alpha = Math.random();
			_logo.alpha = 0;
		}
		else if(Percent < 0.2)
		{
			_logoGlow.alpha = 0;
			_logo.alpha = 0;
		}
		else if(Percent < 0.25)
		{
			_logoGlow.alpha = 0;
			_logo.alpha = Math.random();
		}
		else if(Percent < 0.7)
		{
			_logoGlow.alpha = (Percent - 0.45) / 0.45;
			_logo.alpha = 1;
		}
		else if((Percent > 0.8) && (Percent < 0.9))
		{
			_logoGlow.alpha = 1 - (Percent - 0.8) / 0.1;
			_logo.alpha = 0;
		}
		else if(Percent > 0.9)
		{
			_buffer.alpha = 1 - (Percent - 0.9) / 0.1;
		}
	}
}
#end