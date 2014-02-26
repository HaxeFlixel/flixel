package flixel.ui;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flixel.util.FlxStringUtil;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxPoint;
import flixel.system.layer.Region;
import flixel.system.layer.DrawStackItem;
import flixel.util.loaders.CachedGraphics;

/**
 * FlxBar is a quick and easy way to create a graphical bar which can
 * be used as part of your UI/HUD, or positioned next to a sprite. It could represent
 * a loader, progress or health bar.
 * 
 * @version 1.6 - October 10th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class FlxBar extends FlxSprite
{
	#if flash
	private var canvas:BitmapData;
	#end
	
	private var barType:Int;
	private var barWidth:Int;
	private var barHeight:Int;
	
	private var parent:Dynamic;
	private var parentVariable:String;
	
	/**
	 * fixedPosition controls if the FlxBar sprite is at a fixed location on screen, or tracking its parent
	 */
	public var fixedPosition:Bool;
	
	/**
	 * The positionOffset controls how far offset the FlxBar is from the parent sprite (if at all)
	 */
	public var positionOffset:FlxPoint;
	
	/**
	 * The minimum value the bar can be (can never be >= max)
	 */
	private var min:Float;
	
	/**
	 * The maximum value the bar can be (can never be <= min)
	 */
	private var max:Float;
	
	/**
	 * How wide is the range of this bar? (max - min)
	 */
	private var range:Float;
		
	/**
	 * What 1% of the bar is equal to in terms of value (range / 100)
	 */
	private var pct:Float;
	
	/**
	 * The current value - must always be between min and max
	 */
	private var value:Float;
	
	/**
	 * How many pixels = 1% of the bar (barWidth (or height) / 100)
	 */
	public var pxPerPercent:Float;
	
	private var emptyCallback:Void->Void;
	private var emptyBar:BitmapData;
	private var emptyBarRect:Rectangle;
	private var emptyBarPoint:Point;
	private var emptyKill:Bool;
	private var zeroOffset:Point;
	
	private var filledCallback:Void->Void;
	private var filledBar:BitmapData;
	private var filledBarRect:Rectangle;
	private var filledBarPoint:Point;
	
	private var fillDirection:Int;
	private var fillHorizontal:Bool;
	
	public static inline var FILL_LEFT_TO_RIGHT:Int = 1;
	public static inline var FILL_RIGHT_TO_LEFT:Int = 2;
	public static inline var FILL_TOP_TO_BOTTOM:Int = 3;
	public static inline var FILL_BOTTOM_TO_TOP:Int = 4;
	public static inline var FILL_HORIZONTAL_INSIDE_OUT:Int = 5;
	public static inline var FILL_HORIZONTAL_OUTSIDE_IN:Int = 6;
	public static inline var FILL_VERTICAL_INSIDE_OUT:Int = 7;
	public static inline var FILL_VERTICAL_OUTSIDE_IN:Int = 8;
	
	private static inline var BAR_FILLED:Int = 1;
	private static inline var BAR_GRADIENT:Int = 2;
	private static inline var BAR_IMAGE:Int = 3;
	
	#if !flash
	private var _emptyBarFrameID:Int;
	private var _filledBarFrames:Array<Float>;
	
	private var _framesPosition:String;
	public static inline var FRAMES_POSITION_HORIZONTAL:String = "horizontal";
	public static inline var FRAMES_POSITION_VERTICAL:String = "vertical";
	
	private var _cachedFrontGraphics:CachedGraphics;
	private var _frontRegion:Region;
	#end
	
	/**
	 * Create a new FlxBar Object
	 * 
	 * @param	x			The x coordinate location of the resulting bar (in world pixels)
	 * @param	y			The y coordinate location of the resulting bar (in world pixels)
	 * @param	direction 	One of the FlxBar.FILL_ constants (such as FILL_LEFT_TO_RIGHT, FILL_TOP_TO_BOTTOM etc)
	 * @param	width		The width of the bar in pixels
	 * @param	height		The height of the bar in pixels
	 * @param	parentRef	A reference to an object in your game that you wish the bar to track
	 * @param	variable	The variable of the object that is used to determine the bar position. For example if the parent was an FlxSprite this could be "health" to track the health value
	 * @param	min			The minimum value. I.e. for a progress bar this would be zero (nothing loaded yet)
	 * @param	max			The maximum value the bar can reach. I.e. for a progress bar this would typically be 100.
	 * @param	border		Include a 1px border around the bar? (if true it adds +2 to width and height to accommodate it)
	 */
	public function new(x:Float = 0, y:Float = 0, direction:Int = FILL_LEFT_TO_RIGHT, width:Int = 100, height:Int = 10, parentRef:Dynamic = null, variable:String = "", min:Float = 0, max:Float = 100, border:Bool = false)
	{
		fixedPosition = true;
		zeroOffset = new Point();
		
		super(x, y);
		
		barWidth = width;
		barHeight = height;
		
		#if flash
		makeGraphic(barWidth, barHeight, FlxColor.WHITE, true);
		#else
		this.width = frameWidth = width;
		this.height = frameHeight = height;
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
		_halfWidth = 0.5 * frameWidth;
		_halfHeight = 0.5 * frameHeight;
		
		_framesPosition = FRAMES_POSITION_HORIZONTAL;
		#end
		
		filledBarPoint = new Point(0, 0);
		
		#if flash
 		canvas = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		#end
		
		if (parentRef != null)
		{
			parent = parentRef;
			parentVariable = variable;
		}
		
		setFillDirection(direction);
		
		setRange(min, max);
		
		createFilledBar(0xff005100, 0xff00F400, border);
		
		emptyKill = false;
		
		// Make sure the bar is drawn
		#if flash
		updateBar();
		#end
	}
	
	override public function destroy():Void 
	{
		#if flash
		canvas.dispose();
		canvas = null;
		#else
		_filledBarFrames = null;
		#end
		
		parent = null;
		positionOffset = null;
		emptyCallback = null;
		emptyBarRect = null;
		emptyBarPoint = null;
		zeroOffset = null;
		filledCallback = null;
		filledBarRect = null;
		filledBarPoint = null;
		
		if (emptyBar != null)
		{
			emptyBar.dispose();
			emptyBar = null;
		}
		
		if (filledBar != null)
		{
			filledBar.dispose();
			filledBar = null;
		}
		
		super.destroy();
	}
	
	/**
	 * Track the parent FlxSprites x/y coordinates. For example if you wanted your sprite to have a floating health-bar above their head.<br />
	 * If your health bar is 10px tall and you wanted it to appear above your sprite, then set offsetY to be -10<br />
	 * If you wanted it to appear below your sprite, and your sprite was 32px tall, then set offsetY to be 32. Same applies to offsetX.
	 * 
	 * @param	offsetX		The offset on X in relation to the origin x/y of the parent
	 * @param	offsetY		The offset on Y in relation to the origin x/y of the parent
	 * @see		stopTrackingParent
	 */
	public function trackParent(offsetX:Int, offsetY:Int):Void
	{
		fixedPosition = false;
		
		positionOffset = new FlxPoint(offsetX, offsetY);
		
		if (Reflect.hasField(parent, "scrollFactor"))
		{
			scrollFactor.x = parent.scrollFactor.x;
			scrollFactor.y = parent.scrollFactor.y;
		}
	}
	
	/**
	 * Sets a parent for this FlxBar. Instantly replaces any previously set parent and refreshes the bar.
	 * 
	 * @param	parentRef	A reference to an object in your game that you wish the bar to track
	 * @param	variable	The variable of the object that is used to determine the bar position. For example if the parent was an FlxSprite this could be "health" to track the health value
	 * @param	track		If you wish the FlxBar to track the x/y coordinates of parent set to true (default false)
	 * @param	offsetX		The offset on X in relation to the origin x/y of the parent
	 * @param	offsetY		The offset on Y in relation to the origin x/y of the parent
	 */
	public function setParent(parentRef:Dynamic, variable:String, track:Bool = false, offsetX:Int = 0, offsetY:Int = 0):Void
	{
		parent = parentRef;
		parentVariable = variable;
		
		if (track)
		{
			trackParent(offsetX, offsetY);
		}
		
		updateValueFromParent();
		updateBar();
	}
	
	/**
	 * Tells the health bar to stop following the parent sprite. The given posX and posY values are where it will remain on-screen.
	 * 
	 * @param	posX	X coordinate of the health bar now it's no longer tracking the parent sprite
	 * @param	posY	Y coordinate of the health bar now it's no longer tracking the parent sprite
	 */
	public function stopTrackingParent(posX:Int, posY:Int):Void
	{
		fixedPosition = true;
		
		x = posX;
		y = posY;
	}
	
	/**
	 * Sets callbacks which will be triggered when the value of this FlxBar reaches min or max.
	 * Functions will only be called once and not again until the value changes.
	 * Optionally the FlxBar can be killed if it reaches min, but if will fire the empty callback first (if set)
	 * 
	 * @param	onEmpty			The function that is called if the value of this FlxBar reaches min
	 * @param	onFilled		The function that is called if the value of this FlxBar reaches max
	 * @param	killOnEmpty		If set it will call FlxBar.kill() if the value reaches min
	 */
	public function setCallbacks(onEmpty:Void->Void, onFilled:Void->Void, killOnEmpty:Bool = false):Void
	{
		if (onEmpty != null)
		{
			emptyCallback = onEmpty;
		}
		
		if (onFilled != null)
		{
			filledCallback = onFilled;
		}
		
		if (killOnEmpty)
		{
			emptyKill = true;
		}
	}
	
	public var killOnEmpty(get_killOnEmpty, set_killOnEmpty):Bool;
	
	/**
	 * If this FlxBar should be killed when its value reaches empty, set to true
	 */
	private function set_killOnEmpty(value:Bool):Bool
	{
		emptyKill = value;
		return value;
	}
	
	private function get_killOnEmpty():Bool
	{
		return emptyKill;
	}
	
	/**
	 * Set the minimum and maximum allowed values for the FlxBar
	 * 
	 * @param	min			The minimum value. I.e. for a progress bar this would be zero (nothing loaded yet)
	 * @param	max			The maximum value the bar can reach. I.e. for a progress bar this would typically be 100.
	 */
	public function setRange(min:Float, max:Float):Void
	{
		if (max <= min)
		{
			throw "FlxBar: max cannot be less than or equal to min";
			return;
		}
		
		this.min = min;
		this.max = max;
		
		range = max - min;
		
		pct = range / 100;
		
		if (fillHorizontal)
		{
			pxPerPercent = barWidth / 100;
		}
		else
		{
			pxPerPercent = barHeight / 100;
		}
		
		if (!Math.isNaN(value))
		{
			if (value > max)
			{
				value = max;
			}
			
			if (value < min)
			{
				value = min;
			}
		}
		else
		{
			value = min;
		}
		
		#if !flash
		updateFrameData();
		#end
	}
	
	public var stats(get_stats, null):Map<String, Dynamic>;
	
	private function get_stats():Map<String, Dynamic>
	{
		var data = new Map<String, Dynamic>();
		data.set("min", min);
		data.set("max", max);
		data.set("range", range);
		data.set("pct", pct);
		data.set("pxPerPct", pxPerPercent);
		data.set("fillH", fillHorizontal);
		
		return data;
	}
	
	/**
	 * Creates a solid-colour filled health bar in the given colours, with optional 1px thick border.<br />
	 * All colour values are in 0xAARRGGBB format, so if you want a slightly transparent health bar give it lower AA values.
	 * 
	 * @param	empty		The color of the bar when empty in 0xAARRGGBB format (the background colour)
	 * @param	fill		The color of the bar when full in 0xAARRGGBB format (the foreground colour)
	 * @param	showBorder	Should the bar be outlined with a 1px solid border?
	 * @param	border		The border colour in 0xAARRGGBB format
	 */
	public function createFilledBar(empty:Int, fill:Int, showBorder:Bool = false, border:Int = 0xffffffff):Void
	{
		barType = BAR_FILLED;
		
		#if !flash
		var emptyA:Int = (empty >> 24) & 255;
		var emptyRGB:Int = empty & 0x00ffffff;
		var fillA:Int = (fill >> 24) & 255;
		var fillRGB:Int = fill & 0x00ffffff;
		var borderA:Int = (border >> 24) & 255;
		var borderRGB:Int = border & 0x00ffffff;
		
		var emptyKey:String = "empty: " + barWidth + "x" + barHeight + ":" + emptyA + "." + emptyRGB + "showBorder: " + showBorder;
		var filledKey:String = "filled: " + barWidth + "x" + barHeight + ":" + fillA + "." + fillRGB + "showBorder: " + showBorder;
		if (showBorder)
		{
			emptyKey = emptyKey + "border: " + borderA + "." + borderRGB;
			filledKey = filledKey + "border: " + borderA + "." + borderRGB;
		}
		
		if (barWidth >= barHeight)
		{
			_framesPosition = FRAMES_POSITION_HORIZONTAL;
		}
		else
		{
			_framesPosition = FRAMES_POSITION_VERTICAL;
		}
		#end
		
		if (showBorder)
		{
		#if !flash
			if (FlxG.bitmap.checkCache(emptyKey) == false)
			{
				var emptyBar:BitmapData = new BitmapData(barWidth, barHeight, true, border);
				emptyBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), empty);
				
				FlxG.bitmap.add(emptyBar, false, emptyKey);
			}
			
			if (FlxG.bitmap.checkCache(filledKey) == false)
			{
				var filledBar:BitmapData = new BitmapData(barWidth, barHeight, true, border);
				filledBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), fill);
				
				FlxG.bitmap.add(filledBar, false, filledKey);
			}
		#else
			emptyBar = new BitmapData(barWidth, barHeight, true, border);
			emptyBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), empty);
			
			filledBar = new BitmapData(barWidth, barHeight, true, border);
			filledBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), fill);
		#end
		}
		else
		{
		#if !flash
			if (FlxG.bitmap.checkCache(emptyKey) == false)
			{
				var emptyBar:BitmapData = new BitmapData(barWidth, barHeight, true, empty);
				FlxG.bitmap.add(emptyBar, false, emptyKey);
			}
			
			if (FlxG.bitmap.checkCache(filledKey) == false)
			{
				var filledBar:BitmapData = new BitmapData(barWidth, barHeight, true, fill);
				FlxG.bitmap.add(filledBar, false, filledKey);
			}
		#else
			emptyBar = new BitmapData(barWidth, barHeight, true, empty);
			filledBar = new BitmapData(barWidth, barHeight, true, fill);
		#end
		}
		
		#if flash
		filledBarRect = new Rectangle(0, 0, filledBar.width, filledBar.height);
		emptyBarRect = new Rectangle(0, 0, emptyBar.width, emptyBar.height);
		#else
		setCachedGraphics(FlxG.bitmap.get(emptyKey));
		setCachedFrontGraphics(FlxG.bitmap.get(filledKey));
		
		region = new Region();
		region.width = cachedGraphics.bitmap.width;
		region.height = cachedGraphics.bitmap.height;
		_frontRegion = new Region();
		_frontRegion.width = _cachedFrontGraphics.bitmap.width;
		_frontRegion.height = _cachedFrontGraphics.bitmap.height;
		updateFrameData();
		#end
	}
	
	/**
	 * Creates a gradient filled health bar using the given colour ranges, with optional 1px thick border.<br />
	 * All colour values are in 0xAARRGGBB format, so if you want a slightly transparent health bar give it lower AA values.
	 * 
	 * @param	empty		Array of colour values used to create the gradient of the health bar when empty, each colour must be in 0xAARRGGBB format (the background colour)
	 * @param	fill		Array of colour values used to create the gradient of the health bar when full, each colour must be in 0xAARRGGBB format (the foreground colour)
	 * @param	chunkSize	If you want a more old-skool looking chunky gradient, increase this value!
	 * @param	rotation	Angle of the gradient in degrees. 90 = top to bottom, 180 = left to right. Any angle is valid
	 * @param	showBorder	Should the bar be outlined with a 1px solid border?
	 * @param	border		The border colour in 0xAARRGGBB format
	 */
	public function createGradientBar(empty:Array<Int>, fill:Array<Int>, chunkSize:Int = 1, rotation:Int = 180, showBorder:Bool = false, border:Int = 0xffffffff):Void
	{
		barType = BAR_GRADIENT;
		
		#if !flash
		var colA:Int;
		var colRGB:Int;
		
		var emptyKey:String = "Gradient: " + barWidth + " x " + barHeight + ", colors: [";
		for (col in empty)
		{
			colA = (col >> 24) & 255;
			colRGB = col & 0x00ffffff;
			
			emptyKey = emptyKey + colRGB + "_" + colA + ", ";
		}
		emptyKey = emptyKey + "], chunkSize: " + chunkSize + ", rotation: " + rotation + "showBorder: " + showBorder;
		
		var filledKey:String = "Gradient: " + barWidth + " x " + barHeight + ", colors: [";
		for (col in fill)
		{
			colA = (col >> 24) & 255;
			colRGB = col & 0x00ffffff;
			
			filledKey = filledKey + colRGB + "_" + colA + ", ";
		}
		filledKey = filledKey + "], chunkSize: " + chunkSize + ", rotation: " + rotation + "showBorder: " + showBorder;
		
		if (showBorder)
		{
			var borderA:Int = (border >> 24) & 255;
			var borderRGB:Int = border & 0x00ffffff;
			
			emptyKey = emptyKey + "border: " + borderA + "." + borderRGB;
			filledKey = filledKey + "border: " + borderA + "." + borderRGB;
		}
		
		if (barWidth >= barHeight)
		{
			_framesPosition = FRAMES_POSITION_HORIZONTAL;
		}
		else
		{
			_framesPosition = FRAMES_POSITION_VERTICAL;
		}
		#end
		
		if (showBorder)
		{
			#if flash
			emptyBar = new BitmapData(barWidth, barHeight, true, border);
			FlxGradient.overlayGradientOnBitmapData(emptyBar, barWidth - 2, barHeight - 2, empty, 1, 1, chunkSize, rotation);
			
			filledBar = new BitmapData(barWidth, barHeight, true, border);
			FlxGradient.overlayGradientOnBitmapData(filledBar, barWidth - 2, barHeight - 2, fill, 1, 1, chunkSize, rotation);
			#else
			if (FlxG.bitmap.checkCache(emptyKey) == false)
			{
				var emptyBar:BitmapData = new BitmapData(barWidth, barHeight, true, border);
				FlxGradient.overlayGradientOnBitmapData(emptyBar, barWidth - 2, barHeight - 2, empty, 1, 1, chunkSize, rotation);
				FlxG.bitmap.add(emptyBar, false, emptyKey);
			}
			
			if (FlxG.bitmap.checkCache(filledKey) == false)
			{
				var filledBar:BitmapData = new BitmapData(barWidth, barHeight, true, border);
				FlxGradient.overlayGradientOnBitmapData(filledBar, barWidth - 2, barHeight - 2, fill, 1, 1, chunkSize, rotation);
				FlxG.bitmap.add(filledBar, false, filledKey);
			}
			#end
		}
		else
		{
			#if flash
			emptyBar = FlxGradient.createGradientBitmapData(barWidth, barHeight, empty, chunkSize, rotation);
			filledBar = FlxGradient.createGradientBitmapData(barWidth, barHeight, fill, chunkSize, rotation);
			#else
			if (FlxG.bitmap.checkCache(emptyKey) == false)
			{
				var emptyBar:BitmapData = FlxGradient.createGradientBitmapData(barWidth, barHeight, empty, chunkSize, rotation);
				FlxG.bitmap.add(emptyBar, false, emptyKey);
			}
			
			if (FlxG.bitmap.checkCache(filledKey) == false)
			{
				var filledBar:BitmapData = FlxGradient.createGradientBitmapData(barWidth, barHeight, fill, chunkSize, rotation);
				FlxG.bitmap.add(filledBar, false, filledKey);
			}
			#end
		}
		
		#if flash
		emptyBarRect = new Rectangle(0, 0, emptyBar.width, emptyBar.height);
		filledBarRect = new Rectangle(0, 0, filledBar.width, filledBar.height);
		#else
		setCachedGraphics(FlxG.bitmap.get(emptyKey));
		setCachedFrontGraphics(FlxG.bitmap.get(filledKey));
		
		region = new Region();
		region.width = cachedGraphics.bitmap.width;
		region.height = cachedGraphics.bitmap.height;
		_frontRegion = new Region();
		_frontRegion.width = _cachedFrontGraphics.bitmap.width;
		_frontRegion.height = _cachedFrontGraphics.bitmap.height;
		updateFrameData();
		#end
	}
	
	/**
	 * Creates a health bar filled using the given bitmap images.<br />
	 * You can provide "empty" (background) and "fill" (foreground) images. either one or both images (empty / fill), and use the optional empty/fill colour values 
	 * All colour values are in 0xAARRGGBB format, so if you want a slightly transparent health bar give it lower AA values.
	 * 
	 * @param	empty				Bitmap image used as the background (empty part) of the health bar, if null the emptyBackground colour is used
	 * @param	fill				Bitmap image used as the foreground (filled part) of the health bar, if null the fillBackground colour is used
	 * @param	emptyBackground		If no background (empty) image is given, use this colour value instead. 0xAARRGGBB format
	 * @param	fillBackground		If no foreground (fill) image is given, use this colour value instead. 0xAARRGGBB format
	 */
	public function createImageBar(empty:Dynamic = null, fill:Dynamic = null, emptyBackground:Int = 0xff000000, fillBackground:Int = 0xff00ff00):Void
	{
		var emptyGraphics:CachedGraphics = FlxG.bitmap.add(empty);
		var filledGraphics:CachedGraphics = FlxG.bitmap.add(fill);
		
		var emptyBitmapData:BitmapData = (emptyGraphics != null) ? emptyGraphics.bitmap : null; 
		var fillBitmapData:BitmapData = (filledGraphics != null) ? filledGraphics.bitmap : null;
		
	#if !flash
		var emptyKey:String = "";
		var filledKey:String = "";
		
		if (empty != null)
		{
			if (Std.is(empty, Class))
			{
				emptyKey += Type.getClassName(cast(empty, Class<Dynamic>));
			}
			else if (Std.is(empty, String))
			{
				emptyKey += empty;
			}
		}
		
		if (fill != null)
		{
			if (Std.is(fill, Class))
			{
				filledKey += Type.getClassName(cast(fill, Class<Dynamic>));
			}
			else if (Std.is(fill, String))
			{
				filledKey += fill;
			}
		}
		
		var emptyBackgroundA:Int = (emptyBackground >> 24) & 255;
		var emptyBackgroundRGB:Int = emptyBackground & 0x00ffffff;
		var fillBackgroundA:Int = (fillBackground >> 24) & 255;
		var fillBackgroundRGB:Int = fillBackground & 0x00ffffff;
		
		emptyKey += "emptyBackground: " + emptyBackgroundA + "." + emptyBackgroundRGB;
		filledKey += "fillBackground: " + fillBackgroundA + "." + fillBackgroundRGB;
	#end
		
		barType = BAR_IMAGE;
		
		if (empty == null && fill == null)
		{
			return;
		}
		
		if (empty != null && fill == null)
		{
			//	If empty is set, but fill is not ...
		#if flash
			emptyBar = emptyBitmapData;
			emptyBarRect = new Rectangle(0, 0, emptyBar.width, emptyBar.height);
			
			barWidth = Std.int(emptyBarRect.width);
			barHeight = Std.int(emptyBarRect.height);
			
			filledBar = new BitmapData(barWidth, barHeight, true, fillBackground);
			filledBarRect = new Rectangle(0, 0, barWidth, barHeight);
		#else
			barWidth = emptyBitmapData.width;
			barHeight = emptyBitmapData.height;
			
			if (barWidth >= barHeight)
			{
				_framesPosition = FRAMES_POSITION_HORIZONTAL;
			}
			else
			{
				_framesPosition = FRAMES_POSITION_VERTICAL;
			}
			// TODO: continue from here
			if (FlxG.bitmap.checkCache(emptyKey) == false)
			{
				FlxG.bitmap.add(emptyBitmapData, false, emptyKey);
			}
			
			if (FlxG.bitmap.checkCache(filledKey) == false)
			{
				var filledBar:BitmapData = new BitmapData(barWidth, barHeight, true, fillBackground);
				FlxG.bitmap.add(filledBar, false, filledKey);
			}
		#end
		}
		else if (empty == null && fill != null)
		{
			//	If fill is set, but empty is not ...
			#if flash
			filledBar = fillBitmapData;
			filledBarRect = new Rectangle(0, 0, filledBar.width, filledBar.height);
			
			barWidth = Std.int(filledBarRect.width);
			barHeight = Std.int(filledBarRect.height);
			
			emptyBar = new BitmapData(barWidth, barHeight, true, emptyBackground);
			emptyBarRect = new Rectangle(0, 0, barWidth, barHeight);
			#else
			barWidth = fillBitmapData.width;
			barHeight = fillBitmapData.height;
			
			if (barWidth >= barHeight)
			{
				_framesPosition = FRAMES_POSITION_HORIZONTAL;
			}
			else
			{
				_framesPosition = FRAMES_POSITION_VERTICAL;
			}
			
			if (FlxG.bitmap.checkCache(emptyKey) == false)
			{
				var emptyBar:BitmapData = new BitmapData(barWidth, barHeight, true, emptyBackground);
				FlxG.bitmap.add(emptyBar, false, emptyKey);
			}
			
			if (FlxG.bitmap.checkCache(filledKey) == false)
			{
				FlxG.bitmap.add(fillBitmapData, false, filledKey);
			}
			#end	
		}
		else if (empty != null && fill != null)
		{
			//	If both are set
			#if flash
			emptyBar = emptyBitmapData;
			emptyBarRect = new Rectangle(0, 0, emptyBar.width, emptyBar.height);
			
			filledBar = fillBitmapData;
			filledBarRect = new Rectangle(0, 0, filledBar.width, filledBar.height);
			
			barWidth = Std.int(emptyBarRect.width);
			barHeight = Std.int(emptyBarRect.height);
			#else
			barWidth = emptyBitmapData.width;
			barHeight = emptyBitmapData.height;
			
			if (barWidth >= barHeight)
			{
				_framesPosition = FRAMES_POSITION_HORIZONTAL;
			}
			else
			{
				_framesPosition = FRAMES_POSITION_VERTICAL;
			}
			
			if (FlxG.bitmap.checkCache(emptyKey) == false)
			{
				FlxG.bitmap.add(emptyBitmapData, false, emptyKey);
			}
			
			if (FlxG.bitmap.checkCache(filledKey) == false)
			{
				FlxG.bitmap.add(fillBitmapData, false, filledKey);
			}
			#end
		}
		
		#if flash
		canvas = new BitmapData(barWidth, barHeight, true, 0x0);
		#else
		setCachedGraphics(FlxG.bitmap.get(emptyKey));
		setCachedFrontGraphics(FlxG.bitmap.get(filledKey));
		
		region = new Region();
		region.width = cachedGraphics.bitmap.width;
		region.height = cachedGraphics.bitmap.height;
		_frontRegion = new Region();
		_frontRegion.width = _cachedFrontGraphics.bitmap.width;
		_frontRegion.height = _cachedFrontGraphics.bitmap.height;
		updateFrameData();
		#end
		
		if (fillHorizontal)
		{
			pxPerPercent = barWidth / 100;
		}
		else
		{
			pxPerPercent = barHeight / 100;
		}
	}
	
	/**
	 * Set the direction from which the health bar will fill-up. Default is from left to right. Change takes effect immediately.
	 * 
	 * @param	direction 			One of the FlxBar.FILL_ constants (such as FILL_LEFT_TO_RIGHT, FILL_TOP_TO_BOTTOM etc)
	 */
	public function setFillDirection(direction:Int):Void
	{
		if (direction == FILL_LEFT_TO_RIGHT || direction == FILL_RIGHT_TO_LEFT || direction == FILL_HORIZONTAL_INSIDE_OUT || direction == FILL_HORIZONTAL_OUTSIDE_IN)
		{
			fillDirection = direction;
			fillHorizontal = true;
		}
		else if (direction == FILL_TOP_TO_BOTTOM || direction == FILL_BOTTOM_TO_TOP || direction == FILL_VERTICAL_INSIDE_OUT || direction == FILL_VERTICAL_OUTSIDE_IN)
		{
			fillDirection = direction;
			fillHorizontal = false;
		}
		
		#if !flash
		updateFrameData();
		#end
	}
	
	private function updateValueFromParent():Void
	{
		updateValue(Reflect.getProperty(parent, parentVariable));
	}
	
	private function updateValue(newValue:Float):Void
	{
		if (newValue > max)
		{
			newValue = max;
		}
		
		if (newValue < min)
		{
			newValue = min;
		}
		
		value = newValue;
		
		if (value == min && emptyCallback != null)
		{
			emptyCallback();
		}
		
		if (value == max && filledCallback != null)
		{
			filledCallback();
		}
		
		if (value == min && emptyKill)
		{
			kill();
		}
	}
	
	/**
	 * Internal
	 * Called when the health bar detects a change in the health of the parent.
	 */
	private function updateBar():Void
	{
		#if flash
		if (fillHorizontal)
		{
			filledBarRect.width = Std.int(percent * pxPerPercent);
		}
		else
		{
			filledBarRect.height = Std.int(percent * pxPerPercent);
		}
		
		canvas.copyPixels(emptyBar, emptyBarRect, zeroOffset);
		
		if (percent > 0)
		{
			if (fillDirection == FILL_LEFT_TO_RIGHT || fillDirection == FILL_TOP_TO_BOTTOM)
			{
				//	Already handled above
			}
			else if (fillDirection == FILL_BOTTOM_TO_TOP)
			{
				filledBarRect.y = barHeight - filledBarRect.height;
				filledBarPoint.y = barHeight - filledBarRect.height;
			}
			else if (fillDirection == FILL_RIGHT_TO_LEFT)
			{
				filledBarRect.x = barWidth - filledBarRect.width;
				filledBarPoint.x = barWidth - filledBarRect.width;
			}
			else if (fillDirection == FILL_HORIZONTAL_INSIDE_OUT)
			{
				filledBarRect.x = Std.int((barWidth / 2) - (filledBarRect.width / 2));
				filledBarPoint.x = Std.int((barWidth / 2) - (filledBarRect.width / 2));
			}
			else if (fillDirection == FILL_HORIZONTAL_OUTSIDE_IN)
			{
				filledBarRect.width = Std.int(100 - percent * pxPerPercent);
				filledBarPoint.x = Std.int((barWidth - filledBarRect.width) / 2);
			}
			else if (fillDirection == FILL_VERTICAL_INSIDE_OUT)
			{
				filledBarRect.y = Std.int((barHeight / 2) - (filledBarRect.height / 2));
				filledBarPoint.y = Std.int((barHeight / 2) - (filledBarRect.height / 2));
			}
			else if (fillDirection == FILL_VERTICAL_OUTSIDE_IN)
			{
				filledBarRect.height = Std.int(100 - percent * pxPerPercent);
				filledBarPoint.y = Std.int((barHeight - filledBarRect.height) / 2);
			}
			
			canvas.copyPixels(filledBar, filledBarRect, filledBarPoint);
		}
		
		pixels = canvas;
		#end
	}
	
	override public function update():Void
	{
		if (parent != null)
		{
			if (Reflect.getProperty(parent, parentVariable) != value)
			{
				updateValueFromParent();
				updateBar();
			}
			
			if (fixedPosition == false)
			{
				x = parent.x + positionOffset.x;
				y = parent.y + positionOffset.y;
			}
		}
		
		super.update();
	}
	
	public var percent(get_percent, set_percent):Float;
	
	/**
	 * The percentage of how full the bar is (a value between 0 and 100)
	 */
	private function get_percent():Float
	{
		#if neko
		if (value == null) 
		{
			value = min;
		}
		#end

		if (value > max)
		{
			return 100;
		}
		
		return Math.floor((value / range) * 100);
	}
	
	/**
	 * Sets the percentage of how full the bar is (a value between 0 and 100). This changes FlxBar.currentValue
	 */
	private function set_percent(newPct:Float):Float
	{
		if (newPct >= 0 && newPct <= 100)
		{
			updateValue(pct * newPct);
			updateBar();
		}
		return newPct;
	}
	
	public var currentValue(get_currentValue, set_currentValue):Float;
	
	/**
	 * Set the current value of the bar (must be between min and max range)
	 */
	private function set_currentValue(newValue:Float):Float
	{
		updateValue(newValue);
		updateBar();
		return newValue;
	}
	
	/**
	 * The current actual value of the bar
	 */
	private function get_currentValue():Float
	{
		return value;
	}
	
	#if !flash
	override public function draw():Void 
	{
		if (_cachedFrontGraphics == null || cachedGraphics == null)
		{
			return;
		}
		
		var percentFrame:Int = 2 * (Math.floor(percent) - 1);
		
		var currDrawData:Array<Float>;
		var currIndex:Int;
		var drawItem:DrawStackItem;
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
			{
				continue;
			}
			#if !js
			drawItem = camera.getDrawStackItem(cachedGraphics, isColored, _blendInt, antialiasing);
			#else
			var useAlpha:Bool = (alpha < 0);
			drawItem = camera.getDrawStackItem(cachedGraphics, useAlpha);
			#end
			
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x) + origin.x;
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y) + origin.y;
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end

			var csx:Float = 1;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = 1;
			var x1:Float = 0;
			var y1:Float = 0;
			var x2:Float = 0;
			var y2:Float = 0;

			if (!isSimpleRender())
			{
				if (_angleChanged)
				{
					var radians:Float = -angle * FlxAngle.TO_RAD;
					_sinAngle = Math.sin(radians);
					_cosAngle = Math.cos(radians);
					_angleChanged = false;
				}
				
				csx = _cosAngle * scale.x;
				ssy = _sinAngle * scale.y;
				ssx = _sinAngle * scale.x;
				csy = _cosAngle * scale.y;
				
				x1 = (origin.x - _halfWidth);
				y1 = (origin.y - _halfHeight);
				x2 = x1 * csx + y1 * ssy;
				y2 = -x1 * ssx + y1 * csy;
			}

			// Draw empty bar
			currDrawData[currIndex++] = _point.x - x2;
			currDrawData[currIndex++] = _point.y - y2;
			
			currDrawData[currIndex++] = _emptyBarFrameID;
			
			currDrawData[currIndex++] = csx;
			currDrawData[currIndex++] = -ssx;
			currDrawData[currIndex++] = ssy;
			currDrawData[currIndex++] = csy;

			#if !js
			if (isColored)
			{
				currDrawData[currIndex++] = _red;
				currDrawData[currIndex++] = _green;
				currDrawData[currIndex++] = _blue;
			}
			currDrawData[currIndex++] = alpha;
			#else
			if (useAlpha)
			{
				currDrawData[currIndex++] = alpha;
			}
			#end
			
			drawItem.position = currIndex;
			
			// Draw filled bar
			#if !js
			drawItem = camera.getDrawStackItem(_cachedFrontGraphics, isColored, _blendInt, antialiasing);
			#else
			var useAlpha:Bool = (alpha < 0);
			drawItem = camera.getDrawStackItem(_cachedFrontGraphics, useAlpha);
			#end
			
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			if (percentFrame >= 0)
			{
				var currTileX:Float = -x1;
				var currTileY:Float = -y1;
				
				if (fillHorizontal)
				{
					currTileX += _filledBarFrames[percentFrame];
				}
				else
				{
					currTileY += _filledBarFrames[percentFrame];
				}
				
				var relativeX:Float = (currTileX * csx + currTileY * ssy);
				var relativeY:Float = (-currTileX * ssx + currTileY * csy);
				
				currDrawData[currIndex++] = _point.x + relativeX;
				currDrawData[currIndex++] = _point.y + relativeY;
				
				currDrawData[currIndex++] = _filledBarFrames[percentFrame + 1];
				
				currDrawData[currIndex++] = csx;
				currDrawData[currIndex++] = -ssx;
				currDrawData[currIndex++] = ssy;
				currDrawData[currIndex++] = csy;
				
				#if !js
				if (isColored)
				{
					currDrawData[currIndex++] = _red; 
					currDrawData[currIndex++] = _green;
					currDrawData[currIndex++] = _blue;
				}
				currDrawData[currIndex++] = alpha;
				#else
				if (useAlpha)
				{
					currDrawData[currIndex++] = alpha;
				}
				#end
			}
			
			drawItem.position = currIndex;
			
			#if !FLX_NO_DEBUG
			FlxBasic._VISIBLECOUNT++;
			#end
		}
	}
	
	override private function set_pixels(Pixels:BitmapData):BitmapData
	{
		return Pixels;
	}
	
	override public function isSimpleRender():Bool
	{ 
		return ((angle == 0) && (scale.x == 1) && (scale.y == 1));
	}
	#end
	
	override public function updateFrameData():Void 
	{	
	#if !flash
		if (cachedGraphics == null || _cachedFrontGraphics == null)
		{
			return;
		}
		
		_halfWidth = 0.5 * barWidth;
		_halfHeight = 0.5 * barHeight;
		
		_emptyBarFrameID = cachedGraphics.tilesheet.addTileRect(new Rectangle(0, 0, barWidth, barHeight), new Point(0.5 * barWidth, 0.5 * barHeight));
		_filledBarFrames = [];
		
		var frameRelativePosition:Float;
		var frameX:Float;
		var frameY:Float;
		var frameWidth:Float = 0;
		var frameHeight:Float = 0;
		
		for (i in 1...(100 + 1))
		{
			frameX = 0;
			frameY = 0;
			
			if (fillDirection == FILL_LEFT_TO_RIGHT)
			{
				frameWidth = barWidth * i / 100;
				frameHeight = barHeight;
				
				_filledBarFrames.push(-_halfWidth + frameWidth * 0.5);
			}
			else if (fillDirection == FILL_TOP_TO_BOTTOM)
			{
				frameWidth = barWidth;
				frameHeight = barHeight * i / 100;
				
				_filledBarFrames.push(-_halfHeight + frameHeight * 0.5);
			}
			else if (fillDirection == FILL_BOTTOM_TO_TOP)
			{
				frameWidth = barWidth;
				frameHeight = barHeight * i / 100;
				frameY += (barHeight - frameHeight);
				
				_filledBarFrames.push(_halfHeight - 0.5 * frameHeight);
			}
			else if (fillDirection == FILL_RIGHT_TO_LEFT)
			{
				frameWidth = barWidth * i / 100;
				frameHeight = barHeight;
				frameX += (barWidth - frameWidth);
				
				_filledBarFrames.push(_halfWidth - 0.5 * frameWidth);
			}
			else if (fillDirection == FILL_HORIZONTAL_INSIDE_OUT)
			{
				frameWidth = barWidth * i / 100;
				frameHeight = barHeight;
				frameX += (0.5 * (barWidth - frameWidth));
				
				_filledBarFrames.push(0);
			}
			else if (fillDirection == FILL_HORIZONTAL_OUTSIDE_IN)
			{
				frameWidth = barWidth * (100 - i) / 100;
				frameHeight = barHeight;
				frameX += 0.5 * (barWidth - frameWidth);
				
				_filledBarFrames.push(0);
			}
			else if (fillDirection == FILL_VERTICAL_INSIDE_OUT)
			{
				frameWidth = barWidth;
				frameHeight = barHeight * i / 100;
				frameY += (0.5 * (barHeight - frameHeight));
				
				_filledBarFrames.push(0);
			}
			else if (fillDirection == FILL_VERTICAL_OUTSIDE_IN)
			{
				frameWidth = barWidth;
				frameHeight = barHeight * (100 - i) / 100;
				frameY += (0.5 * (barHeight - frameHeight));
				
				_filledBarFrames.push(0);
			}
			
			_filledBarFrames.push(_cachedFrontGraphics.tilesheet.addTileRect(new Rectangle(frameX, frameY, frameWidth, frameHeight), new Point(0.5 * frameWidth, 0.5 * frameHeight)));
		}
	#end
	}
	
	#if !flash
	private inline function setCachedGraphics(value:CachedGraphics):Void
	{
		cachedGraphics = value;
	}
	private function setCachedFrontGraphics(value:CachedGraphics):Void
	{
		if (_cachedFrontGraphics != null && _cachedFrontGraphics != value)
		{
			_cachedFrontGraphics.useCount--;
		}
		
		if (_cachedFrontGraphics != value && value != null)
		{
			value.useCount++;
		}
		_cachedFrontGraphics = value;
	}
	#end
	
	override public function toString():String
	{
		return FlxStringUtil.getDebugString([ { label: "min", value: min }, 
		                                      { label: "max", value: max },
		                                      { label: "range", value: range },
		                                      { label: "%", value: pct },
		                                      { label: "px/%", value: pxPerPercent },
		                                      { label: "value", value: value } ]);
	}
}