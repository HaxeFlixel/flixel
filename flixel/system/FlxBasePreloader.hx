package flixel.system;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.GraphicsPathWinding;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.Lib;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import openfl.Vector;

class FlxBasePreloader extends DefaultPreloader
{
	/**
	 * Add this string to allowedURLs array if you want to be able to test game with enabled site-locking on local machine
	 */
	public static inline var LOCAL:String = "localhost";

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

	/**
	 * The title text to display on the sitelock failure screen.
	 * NOTE: This string should be reviewed for accuracy and may need to be localized.
	 *
	 * To customize this variable, create a class extending `FlxBasePreloader`, and override its value in the constructor:
	 *
	 * ```haxe
	 * class Preloader extends FlxBasePreloader
	 * {
	 *     public function new():Void
	 *     {
	 *         super(0, ["http://placeholder.domain.test/path/document.html"]);
	 *
	 *         siteLockTitleText = "Custom title text.";
	 *         siteLockBodyText = "Custom body text.";
	 *     }
	 * }
	 * ```
	 * @since 4.3.0
	 */
	public var siteLockTitleText:String = "Sorry.";

	/**
	 * The body text to display on the sitelock failure screen.
	 * NOTE: This string should be reviewed for accuracy and may need to be localized.
	 *
	 * To customize this variable, create a class extending `FlxBasePreloader`, and override its value in the constructor.
	 * @see `siteLockTitleText`
	 * @since 4.3.0
	 */
	public var siteLockBodyText:String =
		"It appears the website you are using is hosting an unauthorized copy of this game. "
		+ "Storage or redistribution of this content, without the express permission of the "
		+ "developer or other copyright holder, is prohibited under copyright law.\n\n"
		+ "Thank you for your interest in this game! Please support the developer by "
		+ "visiting the following website to play the game:";

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
	 * It is highly recommended that you do NOT override this.
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
	private function update(Percent:Float):Void {}

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
		if (_urlChecked)
			return;

		if (!isHostUrlAllowed())
		{
			removeChildren();
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			createSiteLockFailureScreen();
		}
		else
		{
			_urlChecked = true;
		}
		#end
	}

	#if web
	/**
	 * When overridden, allows the customized creation of the sitelock failure screen.
	 * @since 4.3.0
	 */
	private function createSiteLockFailureScreen():Void
	{
		addChild(createSiteLockFailureBackground(0xffffff, 0xe5e5e5));
		addChild(createSiteLockFailureIcon(0xe5e5e5, 0.9));
		addChild(createSiteLockFailureText(30));
	}

	private function createSiteLockFailureBackground(innerColor:FlxColor, outerColor:FlxColor):Shape
	{
		var shape = new Shape();
		var graphics = shape.graphics;
		graphics.clear();

		var fillMatrix = new Matrix();
		fillMatrix.createGradientBox(1, 1, 0, -0.5, -0.5);
		var scaling = Math.max(stage.stageWidth, stage.stageHeight);
		fillMatrix.scale(scaling, scaling);
		fillMatrix.translate(0.5 * stage.stageWidth, 0.5 * stage.stageHeight);

		graphics.beginGradientFill(GradientType.RADIAL, [innerColor, outerColor], [1, 1], [0, 255], fillMatrix);
		graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		graphics.endFill();
		return shape;
	}

	private function createSiteLockFailureIcon(color:FlxColor, scale:Float):Shape
	{
		var shape = new Shape();
		var graphics = shape.graphics;
		graphics.clear();

		graphics.beginFill(color);
		graphics.drawPath(
			Vector.ofArray([1, 6, 2, 2, 2, 6, 6, 2, 2, 2, 6, 1, 6, 2, 6, 2, 6, 2, 6, 1, 6, 6, 2, 2, 2, 6, 6]),
			Vector.ofArray([120.0, 0, 164, 0, 200, 35, 200, 79, 200, 130, 160, 130, 160, 79, 160, 57, 142, 40,
				120, 40, 97, 40, 79, 57, 79, 79, 80, 130, 40, 130, 40, 79, 40, 35, 75, 0, 120, 0,
				220, 140, 231, 140, 240, 148, 240, 160, 240, 300, 240, 311, 231, 320, 220, 320,
				20, 320, 8, 320, 0, 311, 0, 300, 0, 160, 0, 148, 8, 140, 20, 140, 120, 190, 108,
				190, 100, 198, 100, 210, 100, 217, 104, 223, 110, 227, 110, 270, 130, 270, 130,
				227, 135, 223, 140, 217, 140, 210, 140, 198, 131, 190, 120, 190]),
			GraphicsPathWinding.NON_ZERO
		);
		graphics.endFill();

		var transformMatrix = new Matrix();
		transformMatrix.translate(-0.5 * shape.width, -0.5 * shape.height);
		var scaling = scale * Math.min(stage.stageWidth / shape.width, stage.stageHeight / shape.height);
		transformMatrix.scale(scaling, scaling);
		transformMatrix.translate(0.5 * stage.stageWidth, 0.5 * stage.stageHeight);
		shape.transform.matrix = transformMatrix;
		return shape;
	}

	private function createSiteLockFailureText(margin:Float):Sprite
	{
		var sprite = new Sprite();
		var bounds = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		bounds.inflate(-margin, -margin);

		var titleText = new TextField();
		var titleTextFormat = new TextFormat("_sans", 33, 0x333333, true);
		titleTextFormat.align = TextFormatAlign.LEFT;
		titleText.defaultTextFormat = titleTextFormat;
		titleText.selectable = false;
		titleText.width = bounds.width;
		titleText.text = siteLockTitleText;

		var bodyText = new TextField();
		var bodyTextFormat = new TextFormat("_sans", 22, 0x333333);
		bodyTextFormat.align = TextFormatAlign.JUSTIFY;
		bodyText.defaultTextFormat = bodyTextFormat;
		bodyText.multiline = true;
		bodyText.wordWrap = true;
		bodyText.selectable = false;
		bodyText.width = bounds.width;
		bodyText.text = siteLockBodyText;

		var hyperlinkText = new TextField();
		var hyperlinkTextFormat = new TextFormat("_sans", 22, 0x6e97cc, true, false, true);
		hyperlinkTextFormat.align = TextFormatAlign.CENTER;
		hyperlinkTextFormat.url = allowedURLs[siteLockURLIndex];
		hyperlinkText.defaultTextFormat = hyperlinkTextFormat;
		hyperlinkText.selectable = true;
		hyperlinkText.width = bounds.width;
		hyperlinkText.text = allowedURLs[siteLockURLIndex];

		// Do customization before final layout.
		adjustSiteLockTextFields(titleText, bodyText, hyperlinkText);

		var gutterSize = 4;
		titleText.height = titleText.textHeight + gutterSize;
		bodyText.height = bodyText.textHeight + gutterSize;
		hyperlinkText.height = hyperlinkText.textHeight + gutterSize;
		titleText.x = bodyText.x = hyperlinkText.x = bounds.left;
		titleText.y = bounds.top;
		bodyText.y = titleText.y + 2.0 * titleText.height;
		hyperlinkText.y = bodyText.y + bodyText.height + hyperlinkText.height;

		sprite.addChild(titleText);
		sprite.addChild(bodyText);
		sprite.addChild(hyperlinkText);
		return sprite;
	}

	/**
	 * When overridden, allows the customization of the text fields in the sitelock failure screen.
	 * @since 4.3.0
	 */
	private function adjustSiteLockTextFields(titleText:TextField, bodyText:TextField, hyperlinkText:TextField):Void {}

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
			return true;

		var homeURL:String = #if flash loaderInfo.loaderURL #elseif js js.Browser.location.href #end;
		var homeDomain:String = FlxStringUtil.getDomain(homeURL);
		for (allowedURL in allowedURLs)
		{
			var allowedDomain = FlxStringUtil.getDomain(allowedURL);
			if (allowedDomain == homeDomain)
				return true;
		}
		return false;
	}
	#end
}

#if (openfl >= "4.0.0")
@:dox(hide) class DefaultPreloader extends Sprite
{
	private var endAnimation:Int;
	private var outline:Sprite;
	private var progress:Sprite;
	private var startAnimation:Int;
	
	public function new ()
	{
		super ();
		
		var backgroundColor = getBackgroundColor ();
		var r = backgroundColor >> 16 & 0xFF;
		var g = backgroundColor >> 8  & 0xFF;
		var b = backgroundColor & 0xFF;
		var perceivedLuminosity = (0.299 * r + 0.587 * g + 0.114 * b);
		var color = 0x000000;
		
		if (perceivedLuminosity < 70)
		{
			color = 0xFFFFFF;
		}
		
		var x = 30;
		var height = 7;
		var y = getHeight () / 2 - height / 2;
		var width = getWidth () - x * 2;
		
		var padding = 2;
		
		outline = new Sprite ();
		outline.graphics.beginFill (color, 0.07);
		outline.graphics.drawRect (0, 0, width, height);
		outline.x = x;
		outline.y = y;
		outline.alpha = 0;
		addChild (outline);
		
		progress = new Sprite ();
		progress.graphics.beginFill (color, 0.35);
		progress.graphics.drawRect (0, 0, width - padding * 2, height - padding * 2);
		progress.x = x + padding;
		progress.y = y + padding;
		progress.scaleX = 0;
		progress.alpha = 0;
		addChild (progress);
		
		startAnimation = Lib.getTimer () + 100;
		endAnimation = startAnimation + 1000;
		
		addEventListener (Event.ADDED_TO_STAGE, mOnAddedToStage);
	}
	
	public function getBackgroundColor ():Int
	{
		return Lib.current.stage.window.config.background;
	}
	
	public function getHeight ():Float
	{
		var height = Lib.current.stage.window.config.height;
		
		if (height > 0)
		{
			return height;
		}
		else
		{
			return Lib.current.stage.stageHeight;
		}
	}
	
	public function getWidth ():Float
	{
		var width = Lib.current.stage.window.config.width;
		
		if (width > 0)
		{
			return width;
		}
		else
		{
			return Lib.current.stage.stageWidth;
		}
	}
	
	@:keep public function onInit ():Void
	{
		addEventListener (Event.ENTER_FRAME, mOnEnterFrame);
	}
	
	@:keep public function onLoaded ():Void
	{
		removeEventListener (Event.ENTER_FRAME, mOnEnterFrame);
		
		dispatchEvent (new Event (Event.UNLOAD));
	}
	
	@:keep public function onUpdate (bytesLoaded:Int, bytesTotal:Int):Void
	{
		var percentLoaded = 0.0;
		
		if (bytesTotal > 0) {
			
			percentLoaded = bytesLoaded / bytesTotal;
			
			if (percentLoaded > 1) {
				
				percentLoaded = 1;
				
			}
			
		}
		
		progress.scaleX = percentLoaded;
	}
	
	// Event Handlers
	
	private function mOnAddedToStage (event:Event):Void {
		
		removeEventListener (Event.ADDED_TO_STAGE, mOnAddedToStage);
		
		onInit ();
		onUpdate (loaderInfo.bytesLoaded, loaderInfo.bytesTotal);
		
		addEventListener (ProgressEvent.PROGRESS, mOnProgress);
		addEventListener (Event.COMPLETE, mOnComplete);
		
	}
	
	private function mOnComplete (event:Event):Void
	{
		event.preventDefault ();
		
		removeEventListener (ProgressEvent.PROGRESS, mOnProgress);
		removeEventListener (Event.COMPLETE, mOnComplete);
		
		#if (openfl < "5.0.0")
		addEventListener (Event.COMPLETE, function (event)
		{
			dispatchEvent (new Event (Event.UNLOAD));
		});
		#end
		
		onLoaded ();
	}
	
	private function mOnEnterFrame (event:Event):Void
	{
		var elapsed = Lib.getTimer () - startAnimation;
		var total = endAnimation - startAnimation;
		
		var percent = elapsed / total;
		
		if (percent < 0) percent = 0;
		if (percent > 1) percent = 1;
		
		outline.alpha = percent;
		progress.alpha = percent;
	}
	
	private function mOnProgress (event:ProgressEvent):Void
	{
		onUpdate (Std.int (event.bytesLoaded), Std.int (event.bytesTotal));
	}
	
}
#else
typedef DefaultPreloader = NMEPreloader;
#end