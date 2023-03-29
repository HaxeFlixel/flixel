package flixel.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxImageFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxStringUtil;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

// TODO: better handling bars with borders (don't take border into account while drawing its front).

/**
 * `FlxBar` is a quick and easy way to create a graphical bar which can
 * be used as part of your UI/HUD, or positioned next to a sprite.
 * It could represent a loader, progress or health bar.
 *
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class FlxBar extends FlxSprite
{
	/**
	 * Whether the bar stays at a fixed position rather than tracking its parent.
	 * Default is `true`.
	 */
	public var fixedPosition:Bool = true;

	/**
	 * How many pixels = 1% of the bar (`barWidth` (or `barHeight`) / 100).
	 */
	public var pxPerPercent(default, null):Float;

	/**
	 * How far offset the `FlxBar` is from the parent sprite (if at all).
	 */
	public var positionOffset(default, null):FlxPoint;

	/**
	 * Whether this `FlxBar` should be killed when it's empty.
	 */
	public var killOnEmpty:Bool = false;

	/**
	 * The percentage of how full the bar is (a value between `0` and `100`).
	 */
	public var percent(get, set):Float;

	/**
	 * The current value. Must always be between `min` and `max`.
	 */
	@:isVar
	public var value(get, set):Float;

	/**
	 * The minimum value the bar can be (can never be `>= max`).
	 */
	public var min(default, null):Float;

	/**
	 * The maximum value the bar can be (can never be `<= min`).
	 */
	public var max(default, null):Float;

	/**
	 * The range of this bar (`max - min`).
	 */
	public var range(default, null):Float;

	/**
	 * What 1% of the bar is equal to in terms of value (`range / 100`).
	 */
	public var pct(default, null):Float;

	/**
	 * Number of frames this `FlxBar` will have. Default value is `100`.
	 * The bigger the value, the smoother the visual change.
	 * @since 4.1.0
	 */
	public var numDivisions(default, set):Int = 100;

	/**
	 * A function that is called when `value` hits its minimum.
	 */
	public var emptyCallback:Void->Void;

	/**
	 * A function that is called when `value` hits its maximum.
	 */
	public var filledCallback:Void->Void;

	/**
	 * Object to track value from.
	 */
	public var parent:Dynamic;

	/**
	 * Property of parent object to track.
	 */
	public var parentVariable:String;

	public var barWidth(default, null):Int;
	public var barHeight(default, null):Int;

	/**
	 * `FlxImageFrame` which will be used for filled bar rendering.
	 * It is recommended to use this property in tile render mode
	 * (although it will work in blit render mode also).
	 */
	@:isVar
	public var frontFrames(get, set):FlxImageFrame;

	public var backFrames(get, set):FlxImageFrame;

	/**
	 * The direction from which the bar will fill up. Default is from left to right. Change takes effect immediately.
	 */
	public var fillDirection(default, set):FlxBarFillDirection;

	var _fillHorizontal:Bool;

	/**
	 * `FlxFrame` which is used for rendering front graphics of the bar (showing value) in tile render mode.
	 */
	var _frontFrame:FlxFrame;

	var _filledFlxRect:FlxRect;

	var _emptyBar:BitmapData;
	var _emptyBarRect:Rectangle;

	var _filledBar:BitmapData;

	var _zeroOffset:Point;

	var _filledBarRect:Rectangle;
	var _filledBarPoint:Point;

	var _maxPercent:Int = 100;

	/**
	 * Creates a new `FlxBar` object.
	 *
	 * @param x The x-coordinate of the resulting bar (in world pixels).
	 * @param y The y-coordinate of the resulting bar (in world pixels).
	 * @param direction The fill direction. `LEFT_TO_RIGHT` by default.
	 * @param width The width of the bar in pixels.
	 * @param height The height of the bar in pixels.
	 * @param parentRef A reference to the object that the bar should track.
	 * @param variable The variable of the object that is used to determine the bar position. For example, if the parent was an `FlxObject`, this could be `"health"` to track the `health` value.
	 * @param min The minimum value (e.g., For a progress bar, this would be `0`).
	 * @param max The maximum value the bar can reach (e.g., For a progress bar, this would typically be `100`).
	 * @param showBorder Whether to include a 1px border around the bar (if `true`, it adds +2 to width and height to accommodate it).
	 */
	public function new(x:Float = 0, y:Float = 0, ?direction:FlxBarFillDirection, width:Int = 100, height:Int = 10, ?parentRef:Dynamic, variable:String = "",
			min:Float = 0, max:Float = 100, showBorder:Bool = false)
	{
		super(x, y);

		direction = (direction == null) ? FlxBarFillDirection.LEFT_TO_RIGHT : direction;

		barWidth = width;
		barHeight = height;

		_filledBarPoint = new Point();
		_filledBarRect = new Rectangle();
		if (FlxG.renderBlit)
		{
			_zeroOffset = new Point();
			_emptyBarRect = new Rectangle();
			makeGraphic(width, height, FlxColor.TRANSPARENT, true);
		}
		else
		{
			_filledFlxRect = FlxRect.get();
		}

		if (parentRef != null)
		{
			parent = parentRef;
			parentVariable = variable;
		}

		fillDirection = direction;
		createFilledBar(0xff005100, 0xff00F400, showBorder);
		setRange(min, max);
	}

	override public function destroy():Void
	{
		positionOffset = FlxDestroyUtil.put(positionOffset);

		if (FlxG.renderBlit)
		{
			_frontFrame = null;
			_filledFlxRect = FlxDestroyUtil.put(_filledFlxRect);
		}
		else
		{
			_emptyBarRect = null;
			_zeroOffset = null;
			_emptyBar = FlxDestroyUtil.dispose(_emptyBar);
			_filledBar = FlxDestroyUtil.dispose(_filledBar);
		}
		_filledBarRect = null;
		_filledBarPoint = null;

		parent = null;
		positionOffset = null;
		emptyCallback = null;
		filledCallback = null;

		super.destroy();
	}

	/**
	 * Tracks the parent `FlxSprite`s x-/y-coordinates. Could be used if you wanted your sprite to have a floating health bar above its head.
	 * If the bar is 10px tall and you wanted it to appear above your sprite, then set `offsetY` to be `-10`.
	 * If you wanted it to appear below your sprite, and your sprite was 32px tall, then set `offsetY` to be `32`. Same applies to `offsetX`.
	 *
	 * @param offsetX The x-offset in relation to the origin of the parent.
	 * @param offsetY The y-offset in relation to the origin of the parent.
	 * @see `stopTrackingParent()`
	 */
	public function trackParent(offsetX:Int, offsetY:Int):Void
	{
		fixedPosition = false;
		positionOffset = FlxPoint.get(offsetX, offsetY);

		if (Reflect.hasField(parent, "scrollFactor"))
		{
			scrollFactor.x = parent.scrollFactor.x;
			scrollFactor.y = parent.scrollFactor.y;
		}
	}

	/**
	 * Sets a parent for this `FlxBar`. Instantly replaces any previously set parent and refreshes the bar.
	 *
	 * @param parentRef A reference to the object that the bar should track.
	 * @param variable The variable of the object that is used to determine the bar position. For example, if the parent was an `FlxObject`, this could be `"health"` to track the `health` value.
	 * @param track Whether this `FlxBar` should track its parent's position. Default is `false`.
	 * @param offsetX The x-offset in relation to the origin of the parent.
	 * @param offsetY The y-offset in relation to the origin of the parent.
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
	}

	/**
	 * Tells the bar to stop following the parent sprite. The given `posX` and `posY` values are where it will remain on-screen.
	 *
	 * @param posX The x-coordinate of the bar, now that it's no longer tracking the parent sprite.
	 * @param posY The y-coordinate of the bar, now that it's no longer tracking the parent sprite.
	 */
	public function stopTrackingParent(posX:Int, posY:Int):Void
	{
		fixedPosition = true;
		x = posX;
		y = posY;
	}

	/**
	 * Sets callbacks which will be triggered when the value of this `FlxBar` reaches `min` or `max`.
	 * Functions will only be called once and not again until the value changes.
	 * Optionally the FlxBar can be killed if it reaches `min`, but if will fire the empty callback first (if set)
	 *
	 * @param onEmpty The function that is called if the value of this `FlxBar` reaches `min`.
	 * @param onFilled The function that is called if the value of this `FlxBar` reaches `max`.
	 * @param killOnEmpty Whether `kill()` will be called if the value reaches `min`. Defaults to `false`.
	 */
	public function setCallbacks(onEmpty:Void->Void, onFilled:Void->Void, killOnEmpty:Bool = false):Void
	{
		emptyCallback = (onEmpty != null) ? onEmpty : emptyCallback;
		filledCallback = (onFilled != null) ? onFilled : filledCallback;
		this.killOnEmpty = killOnEmpty;
	}

	/**
	 * Sets the minimum and maximum allowed values for this `FlxBar`.
	 *
	 * @param min The minimum value (e.g., For a progress bar, this would be `0`).
	 * @param max The maximum value the bar can reach (e.g., For a progress bar, this would typically be `100`).
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
		this.range = max - min;
		this.pct = range / _maxPercent;

		pxPerPercent = (_fillHorizontal) ? (barWidth / _maxPercent) : (barHeight / _maxPercent);

		if (!Math.isNaN(value))
		{
			value = Math.max(min, Math.min(value, max));
		}
		else
		{
			value = min;
		}
	}

	/**
	 * Creates a solid-color filled bar in the given colors, with optional 1px thick border.
	 * All color values are in ARGB format, so, if you want a slightly transparent bar, give it lower AA values.
	 *
	 * @param empty The color of the bar when empty in ARGB format (the background color).
	 * @param fill The color of the bar when full in ARGB format (the foreground color).
	 * @param showBorder Whether to include a 1px border around the bar.
	 * @param border The border color in ARGB format.
	 * @return This `FlxBar` object with generated images for front and background.
	 */
	public function createFilledBar(empty:FlxColor, fill:FlxColor, showBorder:Bool = false, border:FlxColor = FlxColor.WHITE):FlxBar
	{
		createColoredEmptyBar(empty, showBorder, border);
		createColoredFilledBar(fill, showBorder, border);
		return this;
	}

	/**
	 * Creates a solid-color filled background for the bar in the given color, with optional 1px thick border.
	 *
	 * @param empty The color of the bar when empty in ARGB format (the background color).
	 * @param showBorder Whether to include a 1px border around the bar.
	 * @param border The border color in ARGB format.
	 * @return This `FlxBar` object with generated image for rendering the bar's background.
	 */
	public function createColoredEmptyBar(empty:FlxColor, showBorder:Bool = false, border:FlxColor = FlxColor.WHITE):FlxBar
	{
		if (FlxG.renderTile)
		{
			var emptyKey:String = "empty: " + barWidth + "x" + barHeight + ":" + empty.toHexString();
			if (showBorder)
				emptyKey += ",border: " + border.toHexString();

			if (!FlxG.bitmap.checkCache(emptyKey))
			{
				var emptyBar:BitmapData = null;

				if (showBorder)
				{
					emptyBar = new BitmapData(barWidth, barHeight, true, border);
					emptyBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), empty);
				}
				else
				{
					emptyBar = new BitmapData(barWidth, barHeight, true, empty);
				}

				FlxG.bitmap.add(emptyBar, false, emptyKey);
			}

			frames = FlxG.bitmap.get(emptyKey).imageFrame;
		}
		else
		{
			if (showBorder)
			{
				_emptyBar = new BitmapData(barWidth, barHeight, true, border);
				_emptyBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), empty);
			}
			else
			{
				_emptyBar = new BitmapData(barWidth, barHeight, true, empty);
			}

			_emptyBarRect.setTo(0, 0, barWidth, barHeight);
			updateEmptyBar();
		}

		return this;
	}

	/**
	 * Creates a solid-color filled foreground for the bar in the given color, with optional 1px thick border.
	 * @param fill The color of the bar when full in ARGB format (the foreground color).
	 * @param showBorder Whether to include a 1px border around the bar.
	 * @param border The border color in ARGB format.
	 * @return This `FlxBar` object with generated image for rendering actual values.
	 */
	public function createColoredFilledBar(fill:FlxColor, showBorder:Bool = false, border:FlxColor = FlxColor.WHITE):FlxBar
	{
		if (FlxG.renderTile)
		{
			var filledKey:String = "filled: " + barWidth + "x" + barHeight + ":" + fill.toHexString();
			if (showBorder)
				filledKey += ",border: " + border.toHexString();

			if (!FlxG.bitmap.checkCache(filledKey))
			{
				var filledBar:BitmapData = null;

				if (showBorder)
				{
					filledBar = new BitmapData(barWidth, barHeight, true, border);
					filledBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), fill);
				}
				else
				{
					filledBar = new BitmapData(barWidth, barHeight, true, fill);
				}

				FlxG.bitmap.add(filledBar, false, filledKey);
			}

			frontFrames = FlxG.bitmap.get(filledKey).imageFrame;
		}
		else
		{
			if (showBorder)
			{
				_filledBar = new BitmapData(barWidth, barHeight, true, border);
				_filledBar.fillRect(new Rectangle(1, 1, barWidth - 2, barHeight - 2), fill);
			}
			else
			{
				_filledBar = new BitmapData(barWidth, barHeight, true, fill);
			}

			_filledBarRect.setTo(0, 0, barWidth, barHeight);
			updateFilledBar();
		}
		return this;
	}

	/**
	 * Creates a gradient filled bar using the given color ranges, with optional 1px thick border.
	 * All color values are in ARGB format, so, if you want a slightly transparent bar, give it lower AA values.
	 *
	 * @param empty Array of color values used to create the gradient of the bar when empty (the background color). Each color must be in ARGB format.
	 * @param fill Array of color values used to create the gradient of the bar when full (the foreground color). Each color must be in ARGB format.
	 * @param chunkSize If you want a more old-school looking chunky gradient, increase this value!
	 * @param rotation Angle of the gradient in degrees. 90 = top to bottom; 180 = left to right. Any angle is valid.
	 * @param showBorder Whether to include a 1px border around the bar.
	 * @param border The border color in ARGB format.
	 * @return This `FlxBar` object with generated images for front and background.
	 */
	public function createGradientBar(empty:Array<FlxColor>, fill:Array<FlxColor>, chunkSize:Int = 1, rotation:Int = 180, showBorder:Bool = false,
			border:FlxColor = FlxColor.WHITE):FlxBar
	{
		createGradientEmptyBar(empty, chunkSize, rotation, showBorder, border);
		createGradientFilledBar(fill, chunkSize, rotation, showBorder, border);
		return this;
	}

	/**
	 * Creates a gradient filled background for the bar using the given color range, with optional 1px thick border.
	 *
	 * @param empty Array of color values used to create the gradient of the bar when empty (the background color). Each color must be in ARGB format.
	 * @param chunkSize If you want a more old-school looking chunky gradient, increase this value!
	 * @param rotation Angle of the gradient in degrees. 90 = top to bottom; 180 = left to right. Any angle is valid.
	 * @param showBorder Whether to include a 1px border around the bar.
	 * @param border The border color in ARGB format.
	 * @return This `FlxBar` object with generated image for background rendering.
	 */
	public function createGradientEmptyBar(empty:Array<FlxColor>, chunkSize:Int = 1, rotation:Int = 180, showBorder:Bool = false,
			border:FlxColor = FlxColor.WHITE):FlxBar
	{
		if (FlxG.renderTile)
		{
			var emptyKey:String = "Gradient:" + barWidth + "x" + barHeight + ",colors:[";
			for (col in empty)
			{
				emptyKey += col.toHexString() + ",";
			}
			emptyKey += "],chunkSize: " + chunkSize + ",rotation: " + rotation;

			if (showBorder)
			{
				emptyKey += ",border: " + border.toHexString();
			}

			if (!FlxG.bitmap.checkCache(emptyKey))
			{
				var emptyBar:BitmapData = null;

				if (showBorder)
				{
					emptyBar = new BitmapData(barWidth, barHeight, true, border);
					FlxGradient.overlayGradientOnBitmapData(emptyBar, barWidth - 2, barHeight - 2, empty, 1, 1, chunkSize, rotation);
				}
				else
				{
					emptyBar = FlxGradient.createGradientBitmapData(barWidth, barHeight, empty, chunkSize, rotation);
				}

				FlxG.bitmap.add(emptyBar, false, emptyKey);
			}

			frames = FlxG.bitmap.get(emptyKey).imageFrame;
		}
		else
		{
			if (showBorder)
			{
				_emptyBar = new BitmapData(barWidth, barHeight, true, border);
				FlxGradient.overlayGradientOnBitmapData(_emptyBar, barWidth - 2, barHeight - 2, empty, 1, 1, chunkSize, rotation);
			}
			else
			{
				_emptyBar = FlxGradient.createGradientBitmapData(barWidth, barHeight, empty, chunkSize, rotation);
			}

			_emptyBarRect.setTo(0, 0, barWidth, barHeight);
			updateEmptyBar();
		}

		return this;
	}

	/**
	 * Creates a gradient filled foreground for the bar using the given color range, with optional 1px thick border.
	 *
	 * @param fill Array of color values used to create the gradient of the bar when full (the foreground color). Each color must be in ARGB format.
	 * @param chunkSize If you want a more old-school looking chunky gradient, increase this value!
	 * @param rotation Angle of the gradient in degrees. 90 = top to bottom; 180 = left to right. Any angle is valid.
	 * @param showBorder Whether to include a 1px border around the bar.
	 * @param border The border color in ARGB format.
	 * @return This `FlxBar` object with generated image for rendering actual values.
	 */
	public function createGradientFilledBar(fill:Array<FlxColor>, chunkSize:Int = 1, rotation:Int = 180, showBorder:Bool = false,
			border:FlxColor = FlxColor.WHITE):FlxBar
	{
		if (FlxG.renderTile)
		{
			var filledKey:String = "Gradient:" + barWidth + "x" + barHeight + ",colors:[";
			for (col in fill)
			{
				filledKey += col.toHexString() + ",";
			}
			filledKey += "],chunkSize: " + chunkSize + ",rotation: " + rotation;

			if (showBorder)
			{
				filledKey += ",border: " + border.toHexString();
			}

			if (!FlxG.bitmap.checkCache(filledKey))
			{
				var filledBar:BitmapData = null;

				if (showBorder)
				{
					filledBar = new BitmapData(barWidth, barHeight, true, border);
					FlxGradient.overlayGradientOnBitmapData(filledBar, barWidth - 2, barHeight - 2, fill, 1, 1, chunkSize, rotation);
				}
				else
				{
					filledBar = FlxGradient.createGradientBitmapData(barWidth, barHeight, fill, chunkSize, rotation);
				}

				FlxG.bitmap.add(filledBar, false, filledKey);
			}

			frontFrames = FlxG.bitmap.get(filledKey).imageFrame;
		}
		else
		{
			if (showBorder)
			{
				_filledBar = new BitmapData(barWidth, barHeight, true, border);
				FlxGradient.overlayGradientOnBitmapData(_filledBar, barWidth - 2, barHeight - 2, fill, 1, 1, chunkSize, rotation);
			}
			else
			{
				_filledBar = FlxGradient.createGradientBitmapData(barWidth, barHeight, fill, chunkSize, rotation);
			}

			_filledBarRect.setTo(0, 0, barWidth, barHeight);
			updateFilledBar();
		}

		return this;
	}

	/**
	 * Creates a bar filled using the given graphics.
	 * You can provide "empty" (background) and "fill" (foreground) images. either one or both images (empty / fill), and use the optional empty/fill color values
	 * All color values are in ARGB format, so, if you want a slightly transparent bar, give it lower AA values.
	 * NOTE: This method doesn't check whether the empty image has the same size as fill image.
	 *
	 * @param empty Graphic used as the background (empty part) of the bar. If `null`, the `emptyBackground` color is used.
	 * @param fill Graphic used as the foreground (filled part) of the bar. If `null`, the `fillBackground` color is used.
	 * @param emptyBackground If no background (empty) image is given, use this color value instead. ARGB format.
	 * @param fillBackground If no foreground (fill) image is given, use this color value instead. ARGB format.
	 * @return This `FlxBar` object with generated images for front and background.
	 */
	public function createImageBar(?empty:FlxGraphicAsset, ?fill:FlxGraphicAsset, emptyBackground:FlxColor = FlxColor.BLACK,
			fillBackground:FlxColor = FlxColor.LIME):FlxBar
	{
		createImageEmptyBar(empty, emptyBackground);
		createImageFilledBar(fill, fillBackground);
		return this;
	}

	/**
	 * Loads given graphic for the bar's background.
	 *
	 * @param empty Graphic used as the background (empty part) of the bar. If `null`, the `emptyBackground` color is used.
	 * @param emptyBackground If no background (empty) image is given, use this color value instead. ARGB format.
	 * @return This `FlxBar` object with generated image for background rendering.
	 */
	public function createImageEmptyBar(?empty:FlxGraphicAsset, emptyBackground:FlxColor = FlxColor.BLACK):FlxBar
	{
		if (empty != null)
		{
			var emptyGraphic:FlxGraphic = FlxG.bitmap.add(empty);

			if (FlxG.renderTile)
			{
				frames = emptyGraphic.imageFrame;
			}
			else
			{
				_emptyBar = emptyGraphic.bitmap.clone();

				barWidth = _emptyBar.width;
				barHeight = _emptyBar.height;

				_emptyBarRect.setTo(0, 0, barWidth, barHeight);

				if (graphic == null || (frame.sourceSize.x != barWidth || frame.sourceSize.y != barHeight))
				{
					makeGraphic(barWidth, barHeight, FlxColor.TRANSPARENT, true);
				}

				updateEmptyBar();
			}
		}
		else
		{
			createColoredEmptyBar(emptyBackground);
		}

		return this;
	}

	/**
	 * Loads given graphic for the bar's foreground.
	 *
	 * @param fill Graphic used as the foreground (filled part) of the bar. If `null`, the `fillBackground` color is used.
	 * @param fillBackground If no foreground (fill) image is given, use this color value instead. ARGB format.
	 * @return This `FlxBar` object with generated image for rendering actual values.
	 */
	public function createImageFilledBar(?fill:FlxGraphicAsset, fillBackground:FlxColor = FlxColor.LIME):FlxBar
	{
		if (fill != null)
		{
			var filledGraphic:FlxGraphic = FlxG.bitmap.add(fill);

			if (FlxG.renderTile)
			{
				frontFrames = filledGraphic.imageFrame;
			}
			else
			{
				_filledBar = filledGraphic.bitmap.clone();

				_filledBarRect.setTo(0, 0, barWidth, barHeight);

				if (graphic == null || (frame.sourceSize.x != barWidth || frame.sourceSize.y != barHeight))
				{
					makeGraphic(barWidth, barHeight, FlxColor.TRANSPARENT, true);
				}

				pxPerPercent = (_fillHorizontal) ? (barWidth / _maxPercent) : (barHeight / _maxPercent);
				updateFilledBar();
			}
		}
		else
		{
			createColoredFilledBar(fillBackground);
		}

		return this;
	}

	function set_fillDirection(direction:FlxBarFillDirection):FlxBarFillDirection
	{
		fillDirection = direction;

		switch (direction)
		{
			case LEFT_TO_RIGHT, RIGHT_TO_LEFT, HORIZONTAL_INSIDE_OUT, HORIZONTAL_OUTSIDE_IN:
				_fillHorizontal = true;

			case TOP_TO_BOTTOM, BOTTOM_TO_TOP, VERTICAL_INSIDE_OUT, VERTICAL_OUTSIDE_IN:
				_fillHorizontal = false;
		}

		return fillDirection;
	}

	function updateValueFromParent():Void
	{
		value = Reflect.getProperty(parent, parentVariable);
	}

	/**
	 * Updates the bar view according its current value.
	 * Called when the bar detects a change in the variable of its parent.
	 */
	public function updateBar():Void
	{
		updateEmptyBar();
		updateFilledBar();
	}

	/**
	 * Stamps the bar's background on its pixels.
	 */
	public function updateEmptyBar():Void
	{
		if (FlxG.renderBlit)
		{
			pixels.copyPixels(_emptyBar, _emptyBarRect, _zeroOffset);
			dirty = true;
		}
	}

	/**
	 * Stamps the bar's foreground on its pixels.
	 */
	public function updateFilledBar():Void
	{
		_filledBarRect.width = barWidth;
		_filledBarRect.height = barHeight;

		var fraction:Float = (value - min) / range;
		var percent:Float = fraction * _maxPercent;
		var maxScale:Float = (_fillHorizontal) ? barWidth : barHeight;
		var scaleInterval:Float = maxScale / numDivisions;
		var interval:Float = Math.round(Std.int(fraction * maxScale / scaleInterval) * scaleInterval);

		if (_fillHorizontal)
		{
			_filledBarRect.width = Std.int(interval);
		}
		else
		{
			_filledBarRect.height = Std.int(interval);
		}

		if (percent > 0)
		{
			switch (fillDirection)
			{
				case LEFT_TO_RIGHT, TOP_TO_BOTTOM:
				//	Already handled above

				case BOTTOM_TO_TOP:
					_filledBarRect.y = barHeight - _filledBarRect.height;
					_filledBarPoint.y = barHeight - _filledBarRect.height;

				case RIGHT_TO_LEFT:
					_filledBarRect.x = barWidth - _filledBarRect.width;
					_filledBarPoint.x = barWidth - _filledBarRect.width;

				case HORIZONTAL_INSIDE_OUT:
					_filledBarRect.x = Std.int((barWidth / 2) - (_filledBarRect.width / 2));
					_filledBarPoint.x = Std.int((barWidth / 2) - (_filledBarRect.width / 2));

				case HORIZONTAL_OUTSIDE_IN:
					_filledBarRect.width = Std.int(maxScale - interval);
					_filledBarPoint.x = Std.int((barWidth - _filledBarRect.width) / 2);

				case VERTICAL_INSIDE_OUT:
					_filledBarRect.y = Std.int((barHeight / 2) - (_filledBarRect.height / 2));
					_filledBarPoint.y = Std.int((barHeight / 2) - (_filledBarRect.height / 2));

				case VERTICAL_OUTSIDE_IN:
					_filledBarRect.height = Std.int(maxScale - interval);
					_filledBarPoint.y = Std.int((barHeight - _filledBarRect.height) / 2);
			}

			if (FlxG.renderBlit)
			{
				pixels.copyPixels(_filledBar, _filledBarRect, _filledBarPoint, null, null, true);
			}
			else
			{
				if (frontFrames != null)
				{
					_filledFlxRect.copyFromFlash(_filledBarRect).round();
					if (Std.int(percent) > 0)
					{
						_frontFrame = frontFrames.frame.clipTo(_filledFlxRect, _frontFrame);
					}
				}
			}
		}

		if (FlxG.renderBlit)
		{
			dirty = true;
		}
	}

	override public function update(elapsed:Float):Void
	{
		if (parent != null)
		{
			if (Reflect.getProperty(parent, parentVariable) != value)
			{
				updateValueFromParent();
			}

			if (!fixedPosition)
			{
				x = parent.x + positionOffset.x;
				y = parent.y + positionOffset.y;
			}
		}

		super.update(elapsed);
	}

	override public function draw():Void
	{
		super.draw();

		if (!FlxG.renderTile)
			return;

		if (alpha == 0)
			return;

		if (percent > 0 && _frontFrame.type != FlxFrameType.EMPTY)
		{
			for (camera in cameras)
			{
				if (!camera.visible || !camera.exists || !isOnScreen(camera))
				{
					continue;
				}

				getScreenPosition(_point, camera).subtractPoint(offset);

				_frontFrame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, flipX, flipY);
				_matrix.translate(-origin.x, -origin.y);
				_matrix.scale(scale.x, scale.y);

				// rotate matrix if sprite's graphic isn't prerotated
				if (angle != 0)
				{
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
				}

				_point.add(origin.x, origin.y);
				if (isPixelPerfectRender(camera))
				{
					_point.floor();
				}

				_matrix.translate(_point.x, _point.y);
				camera.drawPixels(_frontFrame, _matrix, colorTransform, blend, antialiasing, shader);
			}
		}
	}

	override function set_pixels(Pixels:BitmapData):BitmapData
	{
		if (FlxG.renderTile)
		{
			return Pixels; // hack
		}
		else
		{
			return super.set_pixels(Pixels);
		}
	}

	override public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("min", min),
			LabelValuePair.weak("max", max),
			LabelValuePair.weak("range", range),
			LabelValuePair.weak("%", pct),
			LabelValuePair.weak("px/%", pxPerPercent),
			LabelValuePair.weak("value", value)
		]);
	}

	function get_percent():Float
	{
		if (value > max)
		{
			return _maxPercent;
		}

		return Math.floor(((value - min) / range) * _maxPercent);
	}

	function set_percent(newPct:Float):Float
	{
		if (newPct >= 0 && newPct <= _maxPercent)
		{
			value = pct * newPct;
		}
		return newPct;
	}

	function set_value(newValue:Float):Float
	{
		value = Math.max(min, Math.min(newValue, max));

		if (value == min && emptyCallback != null)
		{
			emptyCallback();
		}

		if (value == max && filledCallback != null)
		{
			filledCallback();
		}

		if (value == min && killOnEmpty)
		{
			kill();
		}

		updateBar();
		return newValue;
	}

	function get_value():Float
	{
		#if neko
		if (value == null)
		{
			value = min;
		}
		#end

		return value;
	}

	function set_numDivisions(newValue:Int):Int
	{
		numDivisions = (newValue > 0) ? newValue : 100;
		updateFilledBar();
		return newValue;
	}

	function get_frontFrames():FlxImageFrame
	{
		if (FlxG.renderTile)
		{
			return frontFrames;
		}
		return null;
	}

	function set_frontFrames(value:FlxImageFrame):FlxImageFrame
	{
		if (FlxG.renderTile)
		{
			frontFrames = value;
			_frontFrame = (value != null) ? value.frame.copyTo(_frontFrame) : null;
		}
		else
		{
			createImageFilledBar(value.frame.paint());
		}
		return value;
	}

	function get_backFrames():FlxImageFrame
	{
		if (FlxG.renderTile)
		{
			return cast frames;
		}
		return null;
	}

	function set_backFrames(value:FlxImageFrame):FlxImageFrame
	{
		if (FlxG.renderTile)
		{
			frames = value;
		}
		else
		{
			createImageEmptyBar(value.frame.paint());
		}
		return value;
	}
}

enum FlxBarFillDirection
{
	LEFT_TO_RIGHT;
	RIGHT_TO_LEFT;
	TOP_TO_BOTTOM;
	BOTTOM_TO_TOP;
	HORIZONTAL_INSIDE_OUT;
	HORIZONTAL_OUTSIDE_IN;
	VERTICAL_INSIDE_OUT;
	VERTICAL_OUTSIDE_IN;
}
