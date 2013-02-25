/**
 * FlxBar
 * -- Part of the Flixel Power Tools set
 * 
 * v1.6 Lots of bug fixes, more documentation, 2 new test cases, ability to set currentValue added
 * v1.5 Fixed bug in "get percent" function that allows it to work with any value range
 * v1.4 Added support for min/max callbacks and "kill on min"
 * v1.3 Renamed from FlxHealthBar and made less specific / far more flexible
 * v1.2 Fixed colour values for fill and gradient to include alpha
 * v1.1 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.6 - October 10th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import nme.Assets;
import nme.display.BitmapInt32;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.system.layer.DrawStackItem;

/**
 * FlxBar is a quick and easy way to create a graphical bar which can
 * be used as part of your UI/HUD, or positioned next to a sprite. It could represent
 * a loader, progress or health bar.
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
	
	#if flash
	private var fillDirection:UInt;
	#else
	private var fillDirection:Int;
	#end
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
	public function new(x:Int, y:Int, direction:Int = FILL_LEFT_TO_RIGHT, width:Int = 100, height:Int = 10, parentRef:Dynamic = null, variable:String = "", min:Float = 0, max:Float = 100, border:Bool = false)
	{
		fixedPosition = true;
		zeroOffset = new Point();
		
		super(x, y);
		
		barWidth = width;
		barHeight = height;
		
		#if flash
		makeGraphic(barWidth, barHeight, FlxG.WHITE, true);
		#else
		this.width = frameWidth = width;
		this.height = frameHeight = height;
		origin.make(frameWidth * 0.5, frameHeight * 0.5);
		_halfWidth = 0.5 * frameWidth;
		_halfHeight = 0.5 * frameHeight;
		
		_framesPosition = FRAMES_POSITION_HORIZONTAL;
		#end
		
		filledBarPoint = new Point(0, 0);
		
		#if flash
 		canvas = new BitmapData(width, height, true, FlxG.TRANSPARENT);
		#end
		
		if (parentRef != null)
		{
			parent = parentRef;
			parentVariable = variable;
		}
		
		setFillDirection(direction);
		
		setRange(min, max);
		
		#if !neko
		createFilledBar(0xff005100, 0xff00F400, border);
		#else
		createFilledBar({rgb: 0x005100, a: 0xff}, {rgb: 0x00F400, a: 0xff}, border);
		#end
		
		emptyKill = false;
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
	 * Sets callbacks which will be triggered when the value of this FlxBar reaches min or max.<br>
	 * Functions will only be called once and not again until the value changes.<br>
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
	
	#if !FLX_NO_DEBUG
	public function debug():Void
	{
		trace("FlxBar - Min: " + min + " Max: " + max + " Range: " + range + " pct: " + pct + " pxp: " + pxPerPercent + " Value: " + value);
	}
	#end
	
	public var stats(get_stats, null):Hash<Dynamic>;
	
	private function get_stats():Hash<Dynamic>
	{
		var data = new Hash<Dynamic>();
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
	#if flash
	public function createFilledBar(empty:UInt, fill:UInt, showBorder:Bool = false, ?border:UInt = 0xffffffff):Void
	#else
	public function createFilledBar(empty:BitmapInt32, fill:BitmapInt32, showBorder:Bool = false, ?border:BitmapInt32):Void
	#end
	{
		#if !flash
		if (border == null)
		{
			border = FlxG.WHITE;
		}
		#end
		
		barType = BAR_FILLED;
		
		#if (cpp || js)
		var emptyA:Int = (empty >> 24) & 255;
		var emptyRGB:Int = empty & 0x00ffffff;
		var fillA:Int = (fill >> 24) & 255;
		var fillRGB:Int = fill & 0x00ffffff;
		var borderA:Int = (border >> 24) & 255;
		var borderRGB:Int = border & 0x00ffffff;
		#elseif neko
		var emptyA:Int = empty.a;
		var emptyRGB:Int = empty.rgb;
		var fillA:Int = fill.a;
		var fillRGB:Int = fill.rgb;
		var borderA:Int = border.a;
		var borderRGB:Int = border.rgb;
		#end
		
		#if !flash
		var emptyKey:String = "empty: " + barWidth + "x" + barHeight + ":" + emptyA + "." + emptyRGB + "showBorder: " + showBorder;
		var filledKey:String = "filled: " + barWidth + "x" + barHeight + ":" + fillA + "." + fillRGB + "showBorder: " + showBorder;
		if (showBorder)
		{
			emptyKey = emptyKey + "border: " + borderA + "." + borderRGB;
			filledKey = filledKey + "border: " + borderA + "." + borderRGB;
		}
		
		var key:String = emptyKey + "_" + filledKey;
		
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
			emptyBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), empty);
			
			filledBar = new BitmapData(barWidth, barHeight, true, border);
			filledBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), fill);
		#else
			if (FlxG._cache.exists(key) == false)
			{
				if (_framesPosition == FRAMES_POSITION_HORIZONTAL)
				{
					_pixels = FlxG.createBitmap(barWidth + 1, 2 * (barHeight + 1), FlxG.TRANSPARENT, false, key);
					_pixels.fillRect(new Rectangle(0, 0, barWidth, barHeight), border);
					_pixels.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), empty);
					
					_pixels.fillRect(new Rectangle(0, barHeight + 1, barWidth, barHeight), border);
					_pixels.fillRect(new Rectangle(1, barHeight + 2, barWidth - 2, barHeight - 2), fill);
				}
				else
				{
					_pixels = FlxG.createBitmap(2 * (barWidth + 1), barHeight + 1, FlxG.TRANSPARENT, false, key);
					_pixels.fillRect(new Rectangle(0, 0, barWidth, barHeight), border);
					_pixels.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), empty);
					
					_pixels.fillRect(new Rectangle(barWidth + 1, 0, barWidth, barHeight), border);
					_pixels.fillRect(new Rectangle(barWidth + 2, 1, barWidth - 2, barHeight - 2), fill);
				}
			}
			pixels = FlxG._cache.get(key);
		#end
		}
		else
		{
		#if flash
			emptyBar = new BitmapData(barWidth, barHeight, true, empty);
			filledBar = new BitmapData(barWidth, barHeight, true, fill);
		#else
			if (FlxG._cache.exists(key) == false)
			{
				if (_framesPosition == FRAMES_POSITION_HORIZONTAL)
				{
					_pixels = FlxG.createBitmap(barWidth + 1, 2 * (barHeight + 1), FlxG.TRANSPARENT, false, key);
					_pixels.fillRect(new Rectangle(0, 0, barWidth, barHeight), empty);
					_pixels.fillRect(new Rectangle(0, barHeight + 1, barWidth, barHeight), fill);
				}
				else
				{
					_pixels = FlxG.createBitmap(2 * (barWidth + 1), barHeight + 1, FlxG.TRANSPARENT, false, key);
					_pixels.fillRect(new Rectangle(0, 0, barWidth, barHeight), empty);
					_pixels.fillRect(new Rectangle(barWidth + 1, 0, barWidth, barHeight), fill);
				}
			}
			pixels = FlxG._cache.get(key);
		#end
		}
		
		#if flash
		filledBarRect = new Rectangle(0, 0, filledBar.width, filledBar.height);
		emptyBarRect = new Rectangle(0, 0, emptyBar.width, emptyBar.height);
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
	#if flash
	public function createGradientBar(empty:Array<UInt>, fill:Array<UInt>, chunkSize:Int = 1, rotation:Int = 180, showBorder:Bool = false, ?border:UInt = 0xffffffff):Void
	#else
	public function createGradientBar(empty:Array<BitmapInt32>, fill:Array<BitmapInt32>, chunkSize:Int = 1, rotation:Int = 180, showBorder:Bool = false, ?border:BitmapInt32):Void
	#end
	{
		#if !flash
		if (border == null)
		{
			border = FlxG.WHITE;
		}
		#end
		
		barType = BAR_GRADIENT;
		
		#if !flash
		var colA:Int;
		var colRGB:Int;
		
		var emptyKey:String = "Gradient: " + barWidth + " x " + barHeight + ", colors: [";
		for (col in empty)
		{
			#if (cpp || js)
			colA = (col >> 24) & 255;
			colRGB = col & 0x00ffffff;
			#elseif neko
			colA = col.a;
			colRGB = col.rgb;
			#end
			
			emptyKey = emptyKey + colRGB + "_" + colA + ", ";
		}
		emptyKey = emptyKey + "], chunkSize: " + chunkSize + ", rotation: " + rotation + "showBorder: " + showBorder;
		
		var filledKey:String = "Gradient: " + barWidth + " x " + barHeight + ", colors: [";
		for (col in fill)
		{
			#if (cpp || js)
			colA = (col >> 24) & 255;
			colRGB = col & 0x00ffffff;
			#elseif neko
			colA = col.a;
			colRGB = col.rgb;
			#end
			
			filledKey = filledKey + colRGB + "_" + colA + ", ";
		}
		filledKey = filledKey + "], chunkSize: " + chunkSize + ", rotation: " + rotation + "showBorder: " + showBorder;
		
		if (showBorder)
		{
			#if (cpp || js)
			var borderA:Int = (border >> 24) & 255;
			var borderRGB:Int = border & 0x00ffffff;
			#elseif neko
			var borderA:Int = border.a;
			var borderRGB:Int = border.rgb;
			#end
			
			emptyKey = emptyKey + "border: " + borderA + "." + borderRGB;
			filledKey = filledKey + "border: " + borderA + "." + borderRGB;
		}
		
		var key:String = emptyKey + "_" + filledKey;
		
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
			if (FlxG._cache.exists(key) == false)
			{
				if (_framesPosition == FRAMES_POSITION_HORIZONTAL)
				{
					_pixels = FlxG.createBitmap(barWidth + 1, 2 * (barHeight + 1), FlxG.TRANSPARENT, false, key);
					_pixels.fillRect(new Rectangle(0, 0, barWidth, barHeight), border);
					FlxGradient.overlayGradientOnBitmapData(_pixels, barWidth - 2, barHeight - 2, empty, 1, 1, chunkSize, rotation);
					
					_pixels.fillRect(new Rectangle(0, barHeight + 1, barWidth, barHeight), border);
					FlxGradient.overlayGradientOnBitmapData(_pixels, barWidth - 2, barHeight - 2, fill, 1, barHeight + 2, chunkSize, rotation);
				}
				else
				{
					_pixels = FlxG.createBitmap(2 * (barWidth + 1), barHeight + 1, FlxG.TRANSPARENT, false, key);
					_pixels.fillRect(new Rectangle(0, 0, barWidth, barHeight), border);
					FlxGradient.overlayGradientOnBitmapData(_pixels, barWidth - 2, barHeight - 2, empty, 1, 1, chunkSize, rotation);
					
					_pixels.fillRect(new Rectangle(barWidth + 1, 0, barWidth, barHeight), border);
					FlxGradient.overlayGradientOnBitmapData(_pixels, barWidth - 2, barHeight - 2, fill, barWidth + 2, 1, chunkSize, rotation);
				}
			}
			pixels = FlxG._cache.get(key);
			#end
		}
		else
		{
			#if flash
			emptyBar = FlxGradient.createGradientBitmapData(barWidth, barHeight, empty, chunkSize, rotation);
			filledBar = FlxGradient.createGradientBitmapData(barWidth, barHeight, fill, chunkSize, rotation);
			#else
			if (FlxG._cache.exists(key) == false)
			{
				if (_framesPosition == FRAMES_POSITION_HORIZONTAL)
				{
					_pixels = FlxG.createBitmap(barWidth + 1, 2 * (barHeight + 1), FlxG.TRANSPARENT, false, key);
					FlxGradient.overlayGradientOnBitmapData(_pixels, barWidth, barHeight, empty, 0, 0, chunkSize, rotation);
					FlxGradient.overlayGradientOnBitmapData(_pixels, barWidth, barHeight, fill, 0, barHeight + 1, chunkSize, rotation);
				}
				else
				{
					_pixels = FlxG.createBitmap(2 * (barWidth + 1), barHeight + 1, FlxG.TRANSPARENT, false, key);
					FlxGradient.overlayGradientOnBitmapData(_pixels, barWidth, barHeight, empty, 0, 0, chunkSize, rotation);
					FlxGradient.overlayGradientOnBitmapData(_pixels, barWidth, barHeight, fill, barWidth + 1, 0, chunkSize, rotation);
				}
			}
			pixels = FlxG._cache.get(key);
			#end
		}
		
		#if flash
		emptyBarRect = new Rectangle(0, 0, emptyBar.width, emptyBar.height);
		filledBarRect = new Rectangle(0, 0, filledBar.width, filledBar.height);
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
	#if flash
	public function createImageBar(empty:Dynamic = null, fill:Dynamic = null, ?emptyBackground:UInt = 0xff000000, ?fillBackground:UInt = 0xff00ff00):Void
	#else
	public function createImageBar(empty:Dynamic = null, fill:Dynamic = null, ?emptyBackground:BitmapInt32, ?fillBackground:BitmapInt32):Void
	#end
	{
		#if !flash
		if (emptyBackground == null)
		{
			emptyBackground = FlxG.BLACK;
		}
		if (fillBackground == null)
		{
			#if !neko
			fillBackground = 0xff00ff00;
			#else
			fillBackground = { rgb: 0x00ff00, a: 0xff };
			#end
		}
		#end
		
		var emptyBitmapData:BitmapData = FlxG.addBitmap(empty); 
		var fillBitmapData:BitmapData = FlxG.addBitmap(fill);
		
	#if !flash
		var key:String = "";
		
		if (empty != null)
		{
			if (Std.is(empty, Class))
			{
				key += Type.getClassName(cast(empty, Class<Dynamic>));
			}
			else if (Std.is(empty, String))
			{
				key += empty;
			}
		}
		
		key += "_";
		
		if (fill != null)
		{
			if (Std.is(fill, Class))
			{
				key += Type.getClassName(cast(fill, Class<Dynamic>));
			}
			else if (Std.is(fill, String))
			{
				key += fill;
			}
		}
		
		#if (cpp || js)
		var emptyBackgroundA:Int = (emptyBackground >> 24) & 255;
		var emptyBackgroundRGB:Int = emptyBackground & 0x00ffffff;
		var fillBackgroundA:Int = (fillBackground >> 24) & 255;
		var fillBackgroundRGB:Int = fillBackground & 0x00ffffff;
		#elseif neko
		var emptyBackgroundA:Int = emptyBackground.a;
		var emptyBackgroundRGB:Int = emptyBackground.rgb;
		var fillBackgroundA:Int = fillBackground.a;
		var fillBackgroundRGB:Int = fillBackground.rgb;
		#end
		
		#if !flash
		key = key + "emptyBackground: " + emptyBackgroundA + "." + emptyBackgroundRGB;
		key = key + "fillBackground: " + fillBackgroundA + "." + fillBackgroundRGB;
		#end
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
			
			if (FlxG._cache.exists(key) == false)
			{
				if (_framesPosition == FRAMES_POSITION_HORIZONTAL)
				{
					_pixels = FlxG.createBitmap(barWidth + 1, 2 * (barHeight + 1), FlxG.TRANSPARENT, false, key);
					_pixels.copyPixels(emptyBitmapData, emptyBitmapData.rect, new Point());
					_pixels.fillRect(new Rectangle(0, barHeight + 1, barWidth, barHeight), fillBackground);
				}
				else
				{
					_pixels = FlxG.createBitmap(2 * (barWidth + 1), barHeight + 1, FlxG.TRANSPARENT, false, key);
					_pixels.copyPixels(emptyBitmapData, emptyBitmapData.rect, new Point());
					_pixels.fillRect(new Rectangle(barWidth + 1, 0, barWidth, barHeight), fillBackground);
				}
				
			}
			pixels = FlxG._cache.get(key);
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
			
			if (FlxG._cache.exists(key) == false)
			{
				if (_framesPosition == FRAMES_POSITION_HORIZONTAL)
				{
					_pixels = FlxG.createBitmap(barWidth + 1, 2 * (barHeight + 1), FlxG.TRANSPARENT, false, key);
					_pixels.fillRect(new Rectangle(0, 0, barWidth, barHeight), emptyBackground);
					_pixels.copyPixels(fillBitmapData, fillBitmapData.rect, new Point(0, barHeight + 1));
				}
				else
				{
					_pixels = FlxG.createBitmap(2 * (barWidth + 1), barHeight + 1, FlxG.TRANSPARENT, false, key);
					_pixels.fillRect(new Rectangle(0, 0, barWidth, barHeight), emptyBackground);
					_pixels.copyPixels(fillBitmapData, fillBitmapData.rect, new Point(barWidth + 1, 0));
				}
			}
			pixels = FlxG._cache.get(key);
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
			
			if (FlxG._cache.exists(key) == false)
			{
				if (_framesPosition == FRAMES_POSITION_HORIZONTAL)
				{
					_pixels = FlxG.createBitmap(barWidth + 1, 2 * (barHeight + 1), FlxG.TRANSPARENT, false, key);
					_pixels.copyPixels(emptyBitmapData, emptyBitmapData.rect, new Point(0, 0));
					_pixels.copyPixels(fillBitmapData, emptyBitmapData.rect, new Point(0, barHeight + 1));
				}
				else
				{
					_pixels = FlxG.createBitmap(2 * (barWidth + 1), barHeight + 1, FlxG.TRANSPARENT, false, key);
					_pixels.copyPixels(emptyBitmapData, emptyBitmapData.rect, new Point(0, 0));
					_pixels.copyPixels(fillBitmapData, emptyBitmapData.rect, new Point(barWidth + 1, 0));
				}
			}
			pixels = FlxG._cache.get(key);
			#end
		}
		
		#if flash
		canvas = new BitmapData(barWidth, barHeight, true, 0x0);
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
	#if flash
	public function setFillDirection(direction:UInt):Void
	#else
	public function setFillDirection(direction:Int):Void
	#end
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
				filledBarPoint.y = Std.int((barHeight- filledBarRect.height) / 2);
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
	}
	
	public var percent(get_percent, set_percent):Float;
	
	/**
	 * The percentage of how full the bar is (a value between 0 and 100)
	 */
	private function get_percent():Float
	{
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
		if (_atlas == null)
		{
			return;
		}
		
		if (_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker)
			{
				return;
			}
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		var percentFrame:Int = 2 * (Math.floor(percent) - 1);
		
		var currDrawData:Array<Float>;
		var currIndex:Int;
		var drawItem:DrawStackItem;
		var isColored:Bool = isColored();
		
		while (i < l)
		{
			camera = cameras[i++];
			#if !js
			var isColoredCamera:Bool = camera.isColored();
			var redMult:Float = _red;
			var greenMult:Float = _green;
			var blueMult:Float = _blue;
			if (isColoredCamera)
			{
				redMult *= camera.red;
				greenMult *= camera.green;
				blueMult *= camera.blue;
			}
			drawItem = camera.getDrawStackItem(_atlas, (isColored || isColoredCamera), _blendInt);
			#else
			var useAlpha:Bool = (alpha < 0);
			drawItem = camera.getDrawStackItem(_atlas, useAlpha);
			#end
			
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			if (!onScreenSprite(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x) + origin.x;
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y) + origin.y;
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end
			
			if (simpleRenderSprite())
			{	//Simple render
				
				// Draw empty bar
				currDrawData[currIndex++] = _point.x;
				currDrawData[currIndex++] = _point.y;
				
				currDrawData[currIndex++] = _emptyBarFrameID;
				
				currDrawData[currIndex++] = 1;
				currDrawData[currIndex++] = 0;
				currDrawData[currIndex++] = 0;
				currDrawData[currIndex++] = 1;
				#if !js
				if (isColored || isColoredCamera)
				{
					currDrawData[currIndex++] = redMult; 
					currDrawData[currIndex++] = greenMult;
					currDrawData[currIndex++] = blueMult;
				}
				currDrawData[currIndex++] = alpha;
				#else
				if (useAlpha)
				{
					currDrawData[currIndex++] = alpha;
				}
				#end
				
				if (percentFrame >= 0)
				{
					// Draw filled bar
					if (fillHorizontal)
					{
						currDrawData[currIndex++] = _point.x + _filledBarFrames[percentFrame];
						currDrawData[currIndex++] = _point.y;
					}
					else
					{
						currDrawData[currIndex++] = _point.x;
						currDrawData[currIndex++] = _point.y + _filledBarFrames[percentFrame];
					}
					
					currDrawData[currIndex++] = _filledBarFrames[percentFrame + 1];
					
					currDrawData[currIndex++] = 1;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 1;
					
					#if !js
					if (isColored || isColoredCamera)
					{
						currDrawData[currIndex++] = redMult; 
						currDrawData[currIndex++] = greenMult;
						currDrawData[currIndex++] = blueMult;
					}
					currDrawData[currIndex++] = alpha;
					#else
					if (useAlpha)
					{
						currDrawData[currIndex++] = alpha;
					}
					#end
				}
			}
			else
			{	
				//Advanced render
				var radians:Float = -angle * FlxG.RAD;
				var cos:Float = Math.cos(radians);
				var sin:Float = Math.sin(radians);
				
				var csx:Float = cos * scale.x;
				var ssy:Float = sin * scale.y;
				var ssx:Float = sin * scale.x;
				var csy:Float = cos * scale.y;
				
				var x1:Float = (origin.x - _halfWidth);
				var y1:Float = (origin.y - _halfHeight);
				
				var x2:Float = x1 * csx + y1 * ssy;
				var y2:Float = -x1 * ssx + y1 * csy;
				
				// Draw empty bar
				currDrawData[currIndex++] = _point.x - x2;
				currDrawData[currIndex++] = _point.y - y2;
				
				currDrawData[currIndex++] = _emptyBarFrameID;
				
				currDrawData[currIndex++] = csx;
				currDrawData[currIndex++] = ssy;
				currDrawData[currIndex++] = -ssx;
				currDrawData[currIndex++] = csy;
				
				#if !js
				if (isColored || isColoredCamera)
				{
					currDrawData[currIndex++] = redMult; 
					currDrawData[currIndex++] = greenMult;
					currDrawData[currIndex++] = blueMult;
				}
				currDrawData[currIndex++] = alpha;
				#else
				if (useAlpha)
				{
					currDrawData[currIndex++] = alpha;
				}
				#end
				
				if (percentFrame >= 0)
				{
					// Draw filled bar
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
					currDrawData[currIndex++] = ssy;
					currDrawData[currIndex++] = -ssx;
					currDrawData[currIndex++] = csy;
					
					#if !js
					if (isColored || isColoredCamera)
					{
						currDrawData[currIndex++] = redMult; 
						currDrawData[currIndex++] = greenMult;
						currDrawData[currIndex++] = blueMult;
					}
					currDrawData[currIndex++] = alpha;
					#else
					if (useAlpha)
					{
						currDrawData[currIndex++] = alpha;
					}
					#end
				}
			}
			
			drawItem.position = currIndex;
			
			FlxBasic._VISIBLECOUNT++;
			
			#if !FLX_NO_DEBUG
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
			#end
		}
	}
	
	override private function set_pixels(Pixels:BitmapData):BitmapData
	{
		_pixels = Pixels;
		if (_framesPosition == FRAMES_POSITION_HORIZONTAL)
		{
			width = frameWidth = _pixels.width - 1;
			height = frameHeight = Std.int(0.5 * (_pixels.height - 2));
		}
		else
		{
			width = frameWidth = Std.int(0.5 * (_pixels.width - 2));
			height = frameHeight = _pixels.height - 1;
		}
		
		resetHelpers();
		_bitmapDataKey = FlxG.getCacheKeyFor(_pixels);
		if (_bitmapDataKey == null)
		{
			_bitmapDataKey = FlxG.getUniqueBitmapKey();
			FlxG.addBitmap(Pixels, false, false, _bitmapDataKey);
		}
		
		updateAtlasInfo(true);
		return _pixels;
	}
	#end
	
	override public function updateFrameData():Void 
	{	
	#if !flash
		if (_node != null && barWidth >= 1 && barHeight >= 1)
		{
			_halfWidth = 0.5 * barWidth;
			_halfHeight = 0.5 * barHeight;
			
			_emptyBarFrameID = _node.addTileRect(new Rectangle(0, 0, barWidth, barHeight), new Point(0.5 * barWidth, 0.5 * barHeight));
			_filledBarFrames = [];
			
			var frameRelativePosition:Float;
			var frameX:Float;
			var frameY:Float;
			var frameWidth:Float = 0;
			var frameHeight:Float = 0;
			
			var startX:Int = 0;
			var startY:Int = barHeight + 1;
			
			if (_framesPosition != FRAMES_POSITION_HORIZONTAL)
			{
				startX = barWidth + 1;
				startY = 0;
			}
			
			for (i in 1...(100 + 1))
			{
				frameX = startX;
				frameY = startY;
				
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
				
				_filledBarFrames.push(_node.addTileRect(new Rectangle(frameX, frameY, frameWidth, frameHeight), new Point(0.5 * frameWidth, 0.5 * frameHeight)));
			}
		}
	#end
	}
	
}