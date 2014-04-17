package flixel.system;
#if !doc
#if js
class FlxPreloaderBase extends NMEPreloader
{
	public function new()
	{
		super();
	}
}
#else
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLRequest;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;



/**
 * This class handles the 8-bit style preloader.
 */
class FlxPreloaderBase extends Sprite
{	
	/**
	 * Add this string to allowedURLs array if you want to be able to test game with enabled site-locking on local machine 
	 */
	public static inline var LOCAL:String = "local";
	
	/**
	 * Change this if you want the flixel logo to show for more or less time.  Default value is 0 seconds (no delay).
	 */
	public var minDisplayTime:Float = 0;
	
	/**
	 * List of allowed URLs for built-in site-locking.
	 * Set it in FlxPreloader's constructor as: ['http://adamatomic.com/canabalt/', FlxPreloader.LOCAL];
	 */
	public var allowedURLs:Array<String>;

	/**
	* The index of which URL in allowedURLs will be triggered when a user clicks on the Site-lock Message.
	* For example, if allowedURLs is ['mysite.com', 'othersite.com'], and siteLockURLIndex = 1, then
	* the user will go to 'othersite.com' when they click the message, but sitelocking will allow either of those URLs to work.
	* Defaults to 0.
	*/
	public var siteLockURLIndex:Int = 0;

	/**
	 * Useful for storing "real" stage width if you're scaling your preloader graphics.
	 */
	private var _width:Int;
	/**
	 * Useful for storing "real" stage height if you're scaling your preloader graphics.
	 */
	private var _height:Int;
	
	private var _init:Bool = false;	
	private var _percent:Float;
	private var _urlChecked:Bool = false;
	private var _loaded:Bool = false;
	private var _firstPass:Bool = true;
	
	/**
	 * FlxPreloaderBase Constructor.
	 * @param	MinDisplayTime	Minimum time the preloader should be shown. (Default = 0)
	 * @param	AllowedURLs		Allowed URLs used for Site-locking. If the game is run anywhere else, a message will be displayed on the screen (Default = [])
	 */
	public function new(MinDisplayTime:Float = 0, ?AllowedURLs:Array<String>)
	{
		super();
		minDisplayTime = MinDisplayTime;
		if (AllowedURLs != null)
			allowedURLs = AllowedURLs;
		else
			allowedURLs = [];
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	/**
	 * This function is used to create the Preloader. Do not override.
	 * @param	e
	 */
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
	 * Make sure you call super.create() - Highly recommended you also override update()!
	 */
	private function create():Void
	{
		_init = true;
	}
	
	
	/**
	 * This function is called when the project has finished loading to clean up and remove itself.
	 * If overriding, make sure you remove the ENTER_FRAME event listener!
	 */
	private function destroy():Void
	{
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	/**
	 * This function is called each update to check the load status of the project. 
	 * It is highly recommended that you do NOT override this.
	 */
	public function onUpdate(bytesLoaded:Int, bytesTotal:Int):Void 
	{
		#if !(desktop || mobile)
		//in case there is a problem with reading the bytesTotal (Gzipped swf)
		if (root.loaderInfo.bytesTotal == 0) 
		{
			//To avoid "stucking" the preloader use X (=bytesTotal) like so: Actual file size > X > 0.
			//Attention! use the actual file size (minus a few KB) for better accuracy on Chrome.
			var bytesTotal:Int = 50000; 
			_percent = (bytesTotal != 0) ? bytesLoaded / bytesTotal : 0;
		}
		else //Continue regulary
		{
			_percent = (bytesTotal != 0) ? bytesLoaded / bytesTotal : 0;
		}
		#end
	}

	/**
	 * This function is called once the project is completely loaded, AND at least _minDisplayTime has passed.
	 * It triggers the parent class that everything is finished loading and then destroys this instance.
	 */
	public function load():Void
	{
		dispatchEvent(new Event(Event.COMPLETE));
		destroy();
	}
	
	/**
	 * This function is triggered on each 'frame'.
	 * It is highly reccommended that you do NOT override this.
	 */
	private function onEnterFrame(event:Event):Void
	{
		if (_loaded || !_init)
			return;
		
		checkSiteLock();
		
		graphics.clear();
		var time:Int = Lib.getTimer();
		var min:Int = Std.int(minDisplayTime * 1000);
		var percent:Float = _percent;
		if ((min > 0) && (percent > time/min))
		{
			percent = time / min;
		}
		update(percent);
		
		if (!_firstPass && (_percent >= 1) && (time > min))
		{	
			_loaded = true;
			load();
		}
		_firstPass = false;
	}
	
	private function checkSiteLock():Void
	{
		#if flash
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
	
	#if flash
	private function goToMyURL(?e:MouseEvent):Void
	{
		//if the chosen URL isn't "local", use FlxG's openURL() function.
		if (allowedURLs[siteLockURLIndex] != FlxPreloaderBase.LOCAL)
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
		
		var homeDomain:String = FlxStringUtil.getDomain(loaderInfo.loaderURL);
		for (allowedURL in allowedURLs)
		{
			if (FlxStringUtil.getDomain(allowedURL) == homeDomain)
			{
				return true;
			}
			else if ((allowedURL == LOCAL) && (homeDomain == LOCAL))
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
	}
	
	/**
	 * ----------------------------------------------------------------------------------------------
	 * These functions need to exist, but should be empty (unless you really know what you're doing!)
	 */
	public function onInit()
	{
		// EMPTY
	}
	
	public function onLoaded()
	{
		// EMPTY
	}
	/**
	 * ----------------------------------------------------------------------------------------------
	 */
}
#end
#end
