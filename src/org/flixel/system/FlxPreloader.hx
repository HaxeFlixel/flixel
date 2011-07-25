package org.flixel.system;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.errors.Error;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
//import flash.net.navigateToURL;
import flash.text.TextField;
import flash.text.TextFormat;
//import flash.utils.getDefinitionByName;
//import flash.utils.getTimer;
import flash.Lib;

import org.flixel.FlxG;

/**
 * This class handles the 8-bit style preloader.
 */
class FlxPreloader extends MovieClip
{
	[Embed(source="../data/logo.png")] private var ImgLogo:Class<Bitmap>;
	[Embed(source="../data/logo_corners.png")] private var ImgLogoCorners:Class<Bitmap>;
	[Embed(source="../data/logo_light.png")] private var ImgLogoLight:Class<Bitmap>;

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
	private var _width:UInt;
	/**
	 * Useful for storing "real" stage height if you're scaling your preloader graphics.
	 */
	private var _height:UInt;
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
	private var _min:UInt;

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
	
	/**
	 * Constructor
	 */
	public function new()
	{
		super();
		
		minDisplayTime = 0;
		
		stop();
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		//Check if we are on debug or release mode and set _DEBUG accordingly
		try
		{
			throw new Error("Setting global debug flag...");
		}
		catch(E:Error)
		{
			var re:EReg = ~/\[.*:[0-9]+\]/;
			FlxG.debug = re.test(E.getStackTrace());
		}
		
		var tmp:Bitmap;
		if(!FlxG.debug && (myURL != null) && (root.loaderInfo.url.indexOf(myURL) < 0))
		{
			tmp = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0xFFFFFFFF));
			addChild(tmp);
			
			var format:TextFormat = new TextFormat();
			format.color = 0x000000;
			format.size = 16;
			format.align = "center";
			format.bold = true;
			format.font = "system";
			
			var textField:TextField = new TextField();
			textField.width = tmp.width-16;
			textField.height = tmp.height-16;
			textField.y = 8;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.embedFonts = true;
			textField.defaultTextFormat = format;
			textField.text = "Hi there!  It looks like somebody copied this game without my permission.  Just click anywhere, or copy-paste this URL into your browser.\n\n"+myURL+"\n\nto play the game at my site.  Thanks, and have fun!";
			addChild(textField);
			
			textField.addEventListener(MouseEvent.CLICK, goToMyURL);
			tmp.addEventListener(MouseEvent.CLICK, goToMyURL);
			return;
		}
		this._init = false;
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function goToMyURL(?event:MouseEvent = null):Void
	{
		Lib.getURL(new URLRequest("http://"+myURL));
	}
	
	private function onEnterFrame(event:Event):Void
	{
		if(!this._init)
		{
			if ((stage.stageWidth <= 0) || (stage.stageHeight <= 0))
			{
				return;
			}
			create();
			this._init = true;
		}
		graphics.clear();
		var time:UInt = Lib.getTimer();
		if((framesLoaded >= totalFrames) && (time > _min))
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			nextFrame();
			var mainClass:Class = Class(getDefinitionByName(className));
			if(mainClass)
			{
				var app:Dynamic = Type.createInstance(mainClass, []);
				addChild(cast(app, DisplayObject));
			}
			destroy();
		}
		else
		{
			var percent:Float = root.loaderInfo.bytesLoaded/root.loaderInfo.bytesTotal;
			if ((_min > 0) && (percent > time / _min))
			{
				percent = time/_min;
			}
			update(percent);
		}
	}
	
	/**
	 * Override this to create your own preloader objects.
	 * Highly recommended you also override update()!
	 */
	private function create():Void
	{
		_min = 0;
		if (!FlxG.debug)
		{
			_min = minDisplayTime*1000;
		}
		_buffer = new Sprite();
		_buffer.scaleX = 2;
		_buffer.scaleY = 2;
		addChild(_buffer);
		_width = stage.stageWidth/_buffer.scaleX;
		_height = stage.stageHeight/_buffer.scaleY;
		_buffer.addChild(new Bitmap(new BitmapData(_width,_height,false,0x00345e)));
		var bitmap:Bitmap = new ImgLogoLight();
		bitmap.smoothing = true;
		bitmap.width = bitmap.height = _height;
		bitmap.x = (_width-bitmap.width)/2;
		_buffer.addChild(bitmap);
		_bmpBar = new Bitmap(new BitmapData(1,7,false,0x5f6aff));
		_bmpBar.x = 4;
		_bmpBar.y = _height-11;
		_buffer.addChild(_bmpBar);
		_text = new TextField();
		_text.defaultTextFormat = new TextFormat("system",8,0x5f6aff);
		#if flash9
		_text.embedFonts = true;
		#end
		_text.selectable = false;
		_text.multiline = false;
		_text.x = 2;
		_text.y = _bmpBar.y - 11;
		_text.width = 80;
		_buffer.addChild(_text);
		_logo = new ImgLogo();
		_logo.scaleX = _logo.scaleY = _height/8;
		_logo.x = (_width-_logo.width)/2;
		_logo.y = (_height-_logo.height)/2;
		_buffer.addChild(_logo);
		_logoGlow = new ImgLogo();
		_logoGlow.smoothing = true;
		_logoGlow.blendMode = "screen";
		_logoGlow.scaleX = _logoGlow.scaleY = _height/8;
		_logoGlow.x = (_width-_logoGlow.width)/2;
		_logoGlow.y = (_height-_logoGlow.height)/2;
		_buffer.addChild(_logoGlow);
		bitmap = new ImgLogoCorners();
		bitmap.smoothing = true;
		bitmap.width = _width;
		bitmap.height = _height;
		_buffer.addChild(bitmap);
		bitmap = new Bitmap(new BitmapData(_width,_height,false,0xffffff));
		var i:UInt = 0;
		var j:UInt = 0;
		while(i < _height)
		{
			j = 0;
			while (j < _width)
			{
				bitmap.bitmapData.setPixel(j++,i,0);
			}
			i+=2;
		}
		bitmap.blendMode = "overlay";
		bitmap.alpha = 0.25;
		_buffer.addChild(bitmap);
	}
	
	private function destroy():Void
	{
		removeChild(_buffer);
		_buffer = null;
		_bmpBar = null;
		_text = null;
		_logo = null;
		_logoGlow = null;
	}
	
	/**
	 * Override this function to manually update the preloader.
	 * @param	Percent		How much of the program has loaded.
	 */
	private function update(Percent:Float):Void
	{
		_bmpBar.scaleX = Percent * (_width - 8);
		_text.text = "FLX v"+FlxG.LIBRARY_MAJOR_VERSION+"."+FlxG.LIBRARY_MINOR_VERSION+" "+Math.floor(Percent*100)+"%";
		_text.setTextFormat(_text.defaultTextFormat);
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
			_logoGlow.alpha = (Percent-0.45)/0.45;
			_logo.alpha = 1;
		}
		else if((Percent > 0.8) && (Percent < 0.9))
		{
			_logoGlow.alpha = 1-(Percent-0.8)/0.1;
			_logo.alpha = 0;
		}
		else if(Percent > 0.9)
		{
			_buffer.alpha = 1-(Percent-0.9)/0.1;
		}
	}
}