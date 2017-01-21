package flixel.system;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

#if (openfl >= "4.5.0")
import openfl.display.Preloader.DefaultPreloader;
#end

class FlxBasePreloader extends #if (openfl < "4.5.0") NMEPreloader #else DefaultPreloader #end
{
	/**
	 * Add this string to allowedURLs array if you want to be able to test game with enabled site-locking on local machine 
	 */
	public static inline var LOCAL:String = #if flash "local" #else "localhost" #end;
	
	/**
	 * Change this if you want the flixel logo to show for more or less time.  Default value is 0 seconds (no delay).
	 */
	public var minDisplayTime:Float = 0;
	
	/**
	 * List of allowed URLs for built-in site-locking.
	 * Set it in FlxPreloader's constructor as: `['http://adamatomic.com/canabalt/', FlxPreloader.LOCAL]`;
	 */
	public var allowedURLs:Array<String>;

	/**
	 * The index of which URL in allowedURLs will be triggered when a user clicks on the Site-lock Message.
	 * For example, if allowedURLs is `['mysite.com', 'othersite.com']`, and `siteLockURLIndex = 1`, then
	 * the user will go to 'othersite.com' when they click the message, but sitelocking will allow either of those URLs to work.
	 * Defaults to 0.
	 */
	public var siteLockURLIndex:Int = 0;
	
	private var _percent:Float = 0;
	private var _width:Int;
	private var _height:Int;
	private var _loaded:Bool = false;
	private var _urlChecked:Bool = false;
	private var _startTime:Float;
	
	/**
	 * FlxBasePreloader Constructor.
	 * @param	MinDisplayTime	Minimum time (in seconds) the preloader should be shown. (Default = 0)
	 * @param	AllowedURLs		Allowed URLs used for Site-locking. If the game is run anywhere else, a message will be displayed on the screen (Default = [])
	 */
	public function new(MinDisplayTime:Float = 0, ?AllowedURLs:Array<String>)
	{
		super();
		
		removeChild(progress);
		removeChild(outline);
		
		minDisplayTime = MinDisplayTime;
		if (AllowedURLs != null)
			allowedURLs = AllowedURLs;
		else
			allowedURLs = [];
		
		_startTime = Date.now().getTime();
	}
	
	/**
	 * Override this to create your own preloader objects.
	 */
	private function create():Void {}
	
	/**
	 * This function is called externally to initialize the Preloader.
	 */
	override public function onInit() 
	{
		super.onInit();
		
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		create();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		checkSiteLock();
	}
	
	/**
	 * This function is called each update to check the load status of the project. 
	 * It is highly recommended that you do NOT override this.
	 */
	override public function onUpdate(bytesLoaded:Int, bytesTotal:Int) 
	{
		#if flash
		if (root.loaderInfo.bytesTotal == 0)
			bytesTotal = 50000;
		#end
		
		#if web
		_percent = (bytesTotal != 0) ? bytesLoaded / bytesTotal : 0;
		#else
		super.onUpdate(bytesLoaded, bytesTotal);
		#end
	}
	
	/**
	 * This function is triggered on each 'frame'.
	 * It is highly reccommended that you do NOT override this.
	 */
	private function onEnterFrame(E:Event):Void
	{
		var time = Date.now().getTime() - _startTime;
		var min = minDisplayTime * 1000;
		var percent:Float = _percent;
		if ((min > 0) && (_percent > time / min))
			percent = time / min;
		update(percent);
		
		if (_loaded && (min <= 0 || time / min >= 1))
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			super.onLoaded();
			destroy();
		}
	}
	
	/**
	 * This function is called when the project has finished loading.
	 * Override it to remove all of your objects.
	 */
	private function destroy():Void {}
	
	/**
	 * Override to draw your preloader objects in response to the Percent
	 * 
	 * @param	Percent		How much of the program has loaded.
	 */
	function update(Percent:Float):Void {}
	
	/**
	 * This function is called EXTERNALLY once the movie has actually finished being loaded. 
	 * Highly recommended you DO NO override.
	 */
	override public function onLoaded() 
	{
		_loaded = true;
		_percent = 1;
	}
	
	/**
	 * This should be used whenever you want to create a Bitmap that uses BitmapData embedded with the
	 * @:bitmap metadata, if you want to support both Flash and HTML5. Because the embedded data is loaded
	 * asynchronously in HTML5, any code that depends on the pixel data or size of the bitmap should be
	 * in the onLoad function; any such code executed before it is called will fail on the HTML5 target.
	 * 
	 * @param	bitmapDataClass		A reference to the BitmapData child class that contains the embedded data which is to be used.
	 * @param	onLoad				Executed once the bitmap data is finished loading in HTML5, and immediately in Flash. The new Bitmap instance is passed as an argument.
	 * @return  The Bitmap instance that was created.
	 */
	private function createBitmap(bitmapDataClass:Class<BitmapData>, onLoad:Bitmap->Void):Bitmap
	{
		#if html5
		var bmp = new Bitmap();
		bmp.bitmapData = Type.createInstance(bitmapDataClass, [0, 0, true, 0xFFFFFFFF, function(_) onLoad(bmp)]);
		return bmp;
		#else
		var bmp = new Bitmap(Type.createInstance(bitmapDataClass, [0, 0]));
		onLoad(bmp);
		return bmp;
		#end
	}
	
	/**
	 * This should be used whenever you want to create a BitmapData object from a class containing data embedded with
	 * the @:bitmap metadata. Often, you'll want to use the BitmapData in a Bitmap object; in this case, createBitmap()
	 * can should be used instead. Because the embedded data is loaded asynchronously in HTML5, any code that depends on
	 * the pixel data or size of the bitmap should be in the onLoad function; any such code executed before it is called
	 * will fail on the HTML5 target.
	 * 
	 * @param	bitmapDataClass		A reference to the BitmapData child class that contains the embedded data which is to be used.
	 * @param	onLoad				Executed once the bitmap data is finished loading in HTML5, and immediately in Flash. The new BitmapData instance is passed as an argument.
	 * @return  The BitmapData instance that was created.
	 */
	private function loadBitmapData(bitmapDataClass:Class<BitmapData>, onLoad:BitmapData->Void):BitmapData
	{
		#if html5
		return Type.createInstance(bitmapDataClass, [0, 0, true, 0xFFFFFFFF, onLoad]);
		#else
		var bmpData = Type.createInstance(bitmapDataClass, [0, 0]);
		onLoad(bmpData);
		return bmpData;
		#end
	}
	
	/**
	 * Site-locking Functionality
	 */
	private function checkSiteLock():Void
	{
		#if web
		if (!_urlChecked && (allowedURLs != null))
		{
			if (!isHostUrlAllowed())
			{
				var tmp = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, FlxColor.WHITE));
				addChild(tmp);
				
				var format = new TextFormat();
				format.color = 0x000000;
				format.size = 16;
				format.align = TextFormatAlign.CENTER;
				format.bold = true;
				format.font = "system";
				
				var textField = new TextField();
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
			}
			else
			{
				_urlChecked = true;
			}
		}
		#end
	}
	
	#if web
	private function goToMyURL(?e:MouseEvent):Void
	{
		//if the chosen URL isn't "local", use FlxG's openURL() function.
		if (allowedURLs[siteLockURLIndex] != FlxBasePreloader.LOCAL)
			FlxG.openURL(allowedURLs[siteLockURLIndex]);
		else
			Lib.getURL(new URLRequest(allowedURLs[siteLockURLIndex]));
	}
	
	private function isHostUrlAllowed():Bool
	{
		if (allowedURLs.length == 0)
		{
			return true;
		}
		
		var homeDomain:String = FlxStringUtil.getDomain(#if flash loaderInfo.loaderURL #elseif js js.Browser.location.href #end);
		for (allowedURL in allowedURLs)
		{
			if (FlxStringUtil.getDomain(allowedURL) == homeDomain)
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
}