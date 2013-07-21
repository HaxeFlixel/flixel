package flixel;

<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BlendMode;
import nme.display.Graphics;
import nme.display.Tilesheet;
import nme.filters.BitmapFilter;
import nme.filters.GlowFilter;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.system.layer.DrawStackItem;
import org.flixel.system.layer.frames.FlxFrame;
import org.flixel.system.layer.Node;

#if !flash
import org.flixel.system.layer.TileSheetData;
#end

import org.flixel.FlxG;
import org.flixel.system.FlxAnim;
=======
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.filters.BitmapFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.system.FlxAnim;
import flixel.system.FlxAssets;
import flixel.system.layer.DrawStackItem;
import flixel.system.layer.frames.FlxFrame;
import flixel.util.FlxAngle;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.system.layer.Region;
import flixel.util.loaders.CachedGraphics;
import flixel.util.loaders.TextureRegion;
import flixel.util.loaders.TexturePackerData;
import flixel.system.frontEnds.BitmapFrontEnd;
import openfl.display.Tilesheet;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental

/**
 * The main "game object" class, the sprite is a <code>FlxObject</code>
 * with a bunch of graphics options and abilities, like animation and stamping.
 */
class FlxSprite extends FlxObject
{
	private static var VERTICES:Array<FlxPoint> = [new FlxPoint(), new FlxPoint(), new FlxPoint(), new FlxPoint()];
	
	/**
	 * Set <code>facing</code> using <code>FlxObject.LEFT</code>,<code>RIGHT</code>,
	 * <code>UP</code>, and <code>DOWN</code> to take advantage of
	 * flipped sprites and/or just track player orientation more easily.
	 */
	public var facing(default, set_facing):Int;
	
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
	public var color(get_color, set_color):Int;
	public var frame(get_frame, set_frame):Int;
=======
	public var color(default, set_color):Int = 0xffffff;
	public var frame(default, set_frame):Int = 0;
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
	
	/**
	 * If the Sprite is flipped.
	 * This property shouldn't be changed unless you know what are you doing.
	 */
	public var flipped(default, null):Int = 0;
	
	/**
	 * Gets or sets the currently playing animation.
	 */
	public var curAnim(get_curAnim, set_curAnim):String;
	
	/**
	 * WARNING: The origin of the sprite will default to its center.
	 * If you change this, the visuals and the collisions will likely be
	 * pretty out-of-sync if you do any rotation.
	 */
	public var origin:FlxPoint;
	/**
	 * Controls the position of the sprite's hitbox. Likely needs to be adjusted after
     * changing a sprite's <code>width</code> or <code>height</code>.
	 */
	public var offset:FlxPoint;
	
	/**
	 * Change the size of your sprite's graphic.
	 * NOTE: Scale doesn't currently affect collisions automatically,
	 * you will need to adjust the width, height and offset manually.
	 * WARNING: scaling sprites decreases rendering performance for this sprite by a factor of 10x!
	 */
	public var scale:FlxPoint;
	/**
	 * Blending modes, just like Photoshop or whatever.
	 * E.g. "multiply", "screen", etc.
	 * @default null
	 */
	#if flash
	public var blend:BlendMode;
	#else
	private var _blend:BlendMode;
	private var _blendInt:Int = 0;
	/**
	 * Internal helper for less bitmapData manipulation (for FlxCollision Plugin)
	 */
	private var _calculatedPixelsIndex:Int = -1;
	private var _calculatedPixelsFacing:Int = FlxObject.RIGHT;
	#end
	/**
	 * Whether the current animation has finished its first (or only) loop.
	 */
	public var finished:Bool = false;
	/**
	 * Whether the current animation gets updated or not.
	 */
	public var paused(default, null):Bool = true;
	/**
	 * The width of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 * NOTE: Edit at your own risk!!  This is intended to be read-only.
	 */
	public var frameWidth:Int;
	/**
	 * The height of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 * NOTE: Edit at your own risk!!  This is intended to be read-only.
	 */
	public var frameHeight:Int;
	/**
	 * The total number of frames in this image.  WARNING: assumes each row in the sprite sheet is full!
	 */
	public var frames(default, null):Int;
	/**
	 * The actual Flash <code>BitmapData</code> object representing the current display state of the sprite.
	 */
	public var framePixels:BitmapData;
	/**
	 * Set this flag to true to force the sprite to update during the draw() call.
	 * NOTE: Rarely if ever necessary, most sprite operations will flip this flag automatically.
	 */
	public var dirty:Bool;
	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 * @default false
	 */
	public var antialiasing:Bool;
	
	/**
	 * Internal, stores all the animations that were added to this sprite.
	 */
	private var _animations:Map<String, FlxAnim>;
	/**
	 * Internal, keeps track of the current animation being played.
	 */
	private var _curAnim:FlxAnim;
	/**
	 * Internal, keeps track of the current frame of animation.
	 * This is NOT an index into the tile sheet, but the frame number in the animation object.
	 */
	private var _curFrame:Int = 0;
	/**
	 * Internal, keeps track of the current index into the tile sheet based on animation or rotation.
	 */
	private var _curIndex:Int = 0;
	/**
	 * Internal, used to time each frame of animation.
	 */
	private var _frameTimer:Float = 0;
	/**
	 * Internal tracker for the animation callback.  Default is null.
	 * If assigned, will be called each time the current frame changes.
	 * A function that has 3 parameters: a string name, a int frame number, and a int frame index.
	 */
	private var _callback:String->Int->Int->Void;
	/**
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
	 * Internal tracker for color tint, used with Flash getter/setter.
	 */
	private var _color:Int;
	/**
	 * Internal, stores the entire source graphic (not the current displayed animation frame), used with Flash getter/setter.
	 */
	private var _pixels:BitmapData;
	/**
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
	 * Internal, reused frequently during drawing and animating.
	 */
	private var _flashPoint:Point;
	/**
	 * Internal, reused frequently during drawing and animating.
	 */
	private var _flashRect:Rectangle;
	/**
	 * Internal, reused frequently during drawing and animating.
	 */
	private var _flashRect2:Rectangle;
	/**
	 * Internal, reused frequently during drawing and animating. Always contains (0,0).
	 */
	private var _flashPointZero:Point;
	/**
	 * Internal, helps with animation, caching and drawing.
	 */
	private var _colorTransform:ColorTransform;
	/**
	 * Internal, reflects the need to use _colorTransform object
	 */
	private var _useColorTransform:Bool;
	/**
	 * Internal, helps with animation, caching and drawing.
	 */
	private var _matrix:Matrix;
	
	/**
	 * An array that contains each filter object currently associated with this sprite.
	 */
	public var filters:Array<BitmapFilter>;
	/**
	 * Stores a copy of pixels before any bitmap filter is applied, this is necessary for native targets
	 * where bitmap filters only show when applied directly to _pixels, so a backup is needed to clear
	 * filters when removeFilter() is called or when filters are reapplied during calcFrame().
	 */
	public var _pixelsBackup:BitmapData;
	
	#if !flash
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
	private var _flxFrame:FlxFrame;
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
=======
	private var _red:Float = 1.0;
	private var _green:Float = 1.0;
	private var _blue:Float = 1.0;
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
	
	private var _halfWidth:Float;
	private var _halfHeight:Float;

	/**
	 * Internal, additional rotation for sprite. Used in FlxSpriteTex.
	 */
	private var _additionalAngle : Float;
	
	#end
	
	private var _aabb:FlxRect;
	
	/**
	 * Creates a white 8x8 square <code>FlxSprite</code> at the specified position.
	 * Optionally can load a simple, one-frame graphic instead.
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
	public function new(X:Float = 0, Y:Float = 0, SimpleGraphic:Dynamic = null)
	{
		super(X, Y);
		
		_flashPoint = new Point();
		_flashRect = new Rectangle();
		_flashRect2 = new Rectangle();
		_flashPointZero = new Point();
		offset = new FlxPoint();
		origin = new FlxPoint();
		scale = new FlxPoint(1.0, 1.0);
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		_color = 0x00ffffff;
		alpha = 1.0;
		#if flash
		blend = null;
		#else
		_blend = null;
		#end
		antialiasing = false;
		cameras = null;
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		
		antialiasing = FlxG.antialiasByDefault;
		_aabb = new FlxRect();
		
		facing = FlxObject.RIGHT;
		_animations = new Map<String, FlxAnim>();
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		_flipped = 0;
		_curAnim = null;
		_curFrame = 0;
		_curIndex = 0;
		_frameTimer = 0;

		_matrix = new Matrix();
		_callback = null;
		
		#if !flash
		_red = 1.0;
		_green = 1.0;
		_blue = 1.0;
		
		_flxFrame = null;
		_additionalAngle = 0.0;
		#end
=======

		_matrix = new Matrix();
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		
		if (SimpleGraphic == null)
		{
			SimpleGraphic = FlxAssets.IMG_DEFAULT;
		}
		loadGraphic(SimpleGraphic);
	}

	
	/**
	 * WARNING: This will remove this sprite entirely. Use <code>kill()</code> if you 
	 * want to disable it temporarily only and <code>reset()</code> it later to revive it.
	 * Used to clean up memory.
	 */
	override public function destroy():Void
	{
		if(_animations != null)
		{
			for (anim in _animations)
			{
				if (anim != null)
				{
					anim.destroy();
				}
			}
			_animations = null;
		}
		
		_flashPoint = null;
		_flashRect = null;
		_flashRect2 = null;
		_flashPointZero = null;
		offset = null;
		origin = null;
		scale = null;
		_curAnim = null;
		_matrix = null;
		_callback = null;
		_colorTransform = null;
		if (framePixels != null)
		{
			framePixels.dispose();
		}
		framePixels = null;	
		#if flash
		blend = null;
		#else
		_blend = null;
		#end
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
=======
		_aabb = null;
		_flxFrame = null;
		
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
		super.destroy();
	}
	
	/**
	 * Load graphic from another FlxSprite and copy it's tileSheet data. This method can usefull for non-flash targets (and used by FlxTrail effect)
	 * @param	Sprite			The FlxSprite from which you want to load graphic data
	 * 
	 * @return					This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadFromSprite(Sprite:FlxSprite):FlxSprite
	{
		setCachedGraphics(Sprite.cachedGraphics);
		_region = Sprite.region.clone();
		flipped = Sprite.flipped;
		bakedRotation = Sprite.bakedRotation;
		
		width = frameWidth = Sprite.frameWidth;
		height = frameHeight = Sprite.frameHeight;
		if (bakedRotation > 0)
		{
			width = Sprite.width;
			height = Sprite.height;
			centerOffsets();
		}
		
		updateFrameData();
		resetHelpers();
		antialiasing = Sprite.antialiasing;
		frame = Sprite.frame;
		
		return this;
	}
	
	/**
	 * Load an image from an embedded graphic file.
	 * @param	Graphic		The image you want to use.
	 * @param	Animated	Whether the Graphic parameter is a single sprite or a row of sprites.
	 * @param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames.
	 * @param	Width		Optional, specify the width of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
	 * @param	Height		Optional, specify the height of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
	 * @param	Unique		Optional, whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @param	Key			Optional, set this parameter if you're loading BitmapData.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGraphic(Graphic:Dynamic, Animated:Bool = false, Reverse:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, Key:String = null):FlxSprite
	{
		bakedRotation = 0;
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		#if !flash
<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
=======
>>>>>>> experimental
		_pixels = FlxG.addBitmap(Graphic, false, Unique, Key);
		_bitmapDataKey = FlxG._lastBitmapDataKey;
		
		_calculatedPixelsIndex = -1;
<<<<<<< HEAD
=======
		_pixels = FlxG.bitmap.add(Graphic, false, Unique, Key);
		_bitmapDataKey = FlxG.bitmap._lastBitmapDataKey;
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> experimental
		#else
		_pixels = FlxG.addBitmap(Graphic, Reverse, Unique, Key);
		#end
=======
		setCachedGraphics(FlxG.bitmap.add(Graphic, Unique, Key));
		
		flipped = (Reverse == true) ? _cachedGraphics.bitmap.width : 0;
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		
		if (Width == 0)
		{
			Width = (Animated == true) ? _cachedGraphics.bitmap.height : _cachedGraphics.bitmap.width;
		}
		
		if (Height == 0)
		{
			Height = (Animated == true) ? Width : _cachedGraphics.bitmap.height;
		}
		
		if (!Std.is(Graphic, TextureRegion))
		{
			_region = new Region(0, 0, Width, Height);
			_region.width = _cachedGraphics.bitmap.width;
			_region.height = _cachedGraphics.bitmap.height;
		}
<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		_pixels = FlxG.addBitmap(Graphic, false, Unique, Key, Width, Height);
		_bitmapDataKey = FlxG._lastBitmapDataKey;
=======
		_pixels = FlxG.bitmap.add(Graphic, false, Unique, Key, Width, Height);
		_bitmapDataKey = FlxG.bitmap._lastBitmapDataKey;
		#else
		nullTextureData();
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
		else
		{
			_region = cast(Graphic, TextureRegion).region.clone();
			
			if (_region.tileWidth > 0)
				Width = _region.tileWidth;
			else
				_region.tileWidth = _region.width;
			
			if (_region.tileHeight > 0)
				Height = _region.tileWidth;
			else
				_region.tileHeight = _region.height;
		}
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		_pixels = FlxG.addBitmap(Graphic, false, Unique, Key, Width, Height);
		_bitmapDataKey = FlxG._lastBitmapDataKey;
>>>>>>> experimental
		#end
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		
		width = frameWidth = Width;
		height = frameHeight = Height;
		
		updateFrameData();
		resetHelpers();
		
		return this;
	}
	
	/**
	 * Create a pre-rotated sprite sheet from a simple sprite.
	 * This can make a huge difference in graphical performance!
	 * @param	Graphic			The image you want to rotate and stamp.
	 * @param	Rotations		The number of rotation frames the final sprite should have.  For small sprites this can be quite a large number (360 even) without any problems.
	 * @param	Frame			If the Graphic has a single row of square animation frames on it, you can specify which of the frames you want to use here.  Default is -1, or "use whole graphic."
	 * @param	AntiAliasing	Whether to use high quality rotations when creating the graphic.  Default is false.
	 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners.  Default is false.  Will create frames that are 150% larger on each axis than the original frame or graphic.
	 * @param	Key			Optional, set this parameter if you're loading BitmapData.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadRotatedGraphic(Graphic:Dynamic, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false, Key:String = null):FlxSprite
	{
		//Create the brush and canvas
		var rows:Int = Std.int(Math.sqrt(Rotations));
		var brush:BitmapData = FlxG.bitmap.add(Graphic, false, Key).bitmap;
		var isRegion:Bool = Std.is(Graphic, TextureRegion);
		var spriteRegion:TextureRegion = (isRegion == true) ? cast Graphic : null;
		var tempRegion:Region = (isRegion == true) ? spriteRegion.region : null;
		
		if (Frame >= 0 || isRegion)
		{
			//Using just a segment of the graphic - find the right bit here
			var full:BitmapData = brush;
			
			if (isRegion)
			{
				brush = new BitmapData(tempRegion.width, tempRegion.height);
				_flashRect.x = tempRegion.startX;
				_flashRect.y = tempRegion.startY;
				_flashRect.width = tempRegion.width;
				_flashRect.height = tempRegion.height;
				brush.copyPixels(full, _flashRect, _flashPointZero);
			}
			else
			{
				brush = new BitmapData(full.height, full.height);
				var rx:Int = Frame * brush.width;
				var ry:Int = 0;
				var fw:Int = full.width;
				if (rx >= fw)
				{
					ry = Std.int(rx / fw) * brush.height;
					rx %= fw;
				}
				_flashRect.x = rx;
				_flashRect.y = ry;
				_flashRect.width = brush.width;
				_flashRect.height = brush.height;
				brush.copyPixels(full, _flashRect, _flashPointZero);
			}
		}
		
		var max:Int = brush.width;
		if (brush.height > max)
		{
			max = brush.height;
		}
		
		if (AutoBuffer)
		{
			max = Std.int(max * 1.5);
		}
		
		var columns:Int = Math.ceil(Rotations / rows);
		width = max * columns;
		height = max * rows;
		var key:String = "";
		if (Std.is(Graphic, String))
		{
			key = Graphic;
		}
		else if (Std.is(Graphic, Class))
		{
			key = Type.getClassName(Graphic);
		}
		else if (Std.is(Graphic, BitmapData) && Key != null)
		{
			key = Key;
		}
		else if (isRegion)
		{
			key = spriteRegion.data.key;
			key += ":" + tempRegion.startX + ":" + tempRegion.startY + ":" + tempRegion.width + ":" + tempRegion.height + ":" + Rotations;
		}
		else
		{
			return null;
		}
		
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		#if !flash
<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		_bitmapDataKey = FlxG._lastBitmapDataKey;
		_calculatedPixelsIndex = -1;
=======
		_bitmapDataKey = FlxG.bitmap._lastBitmapDataKey;
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
		_bitmapDataKey = FlxG._lastBitmapDataKey;
		_calculatedPixelsIndex = -1;
>>>>>>> experimental
		#end
=======
		if (!isRegion)
		{
			key += ":" + Frame + ":" + width + "x" + height + ":" + Rotations;
		}
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		
		var skipGen:Bool = FlxG.bitmap.checkCache(key);
		setCachedGraphics(FlxG.bitmap.create(Std.int(width) + columns - 1, Std.int(height) + rows - 1, FlxColor.TRANSPARENT, true, key));
		bakedRotation = 360 / Rotations;
		
		//Generate a new sheet if necessary, then fix up the width and height
		if (!skipGen)
		{
			var row:Int = 0;
			var column:Int;
			var bakedAngle:Float = 0;
			var halfBrushWidth:Int = Std.int(brush.width * 0.5);
			var halfBrushHeight:Int = Std.int(brush.height * 0.5);
			var midpointX:Int = Std.int(max * 0.5);
			var midpointY:Int = Std.int(max * 0.5);
			while (row < rows)
			{
				column = 0;
				while (column < columns)
				{
					_matrix.identity();
					_matrix.translate( -halfBrushWidth, -halfBrushHeight);
					_matrix.rotate(bakedAngle * FlxAngle.TO_RAD);
					_matrix.translate(max * column + midpointX + column, midpointY + row);
					bakedAngle += bakedRotation;
					_cachedGraphics.bitmap.draw(brush, _matrix, null, null, null, AntiAliasing);
					column++;
				}
				midpointY += max;
				row++;
			}
		}
		frameWidth = frameHeight = max;
		width = height = max;
		
		_region = new Region(0, 0, max, max, 1, 1);
		_region.width = _cachedGraphics.bitmap.width;
		_region.height = _cachedGraphics.bitmap.height;
		
		#if !flash
		antialiasing = AntiAliasing;
		#end
		
		updateFrameData();
		resetHelpers();
		
		if (AutoBuffer)
		{
			width = brush.width;
			height = brush.height;
			centerOffsets();
		}
		
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		#if !flash
		antialiasing = AntiAliasing;
		#end
		
		updateAtlasInfo();
		
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		return this;
	}
	
	/**
	 * This function creates a flat colored square image dynamically.
	 * @param	Width		The width of the sprite you want to generate.
	 * @param	Height		The height of the sprite you want to generate.
	 * @param	Color		Specifies the color of the generated block.
	 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @param	Key			Optional parameter - specify a string key to identify this graphic in the cache.  Trumps Unique flag.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
	public function makeGraphic(Width:Int, Height:Int, ?Color:Int = 0xffffffff, Unique:Bool = false, Key:String = null):FlxSprite
=======
	public function makeGraphic(Width:Int, Height:Int, Color:Int = 0xffffffff, Unique:Bool = false, Key:String = null):FlxSprite
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
	{
		bakedRotation = 0;
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		_pixels = FlxG.createBitmap(Width, Height, Color, Unique, Key);
		#if !flash
<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		_bitmapDataKey = FlxG._lastBitmapDataKey;
		_calculatedPixelsIndex = -1;
=======
		_bitmapDataKey = FlxG.bitmap._lastBitmapDataKey;
		#else
		nullTextureData();
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
		_bitmapDataKey = FlxG._lastBitmapDataKey;
		_calculatedPixelsIndex = -1;
>>>>>>> experimental
		#end
		width = frameWidth = _pixels.width;
		height = frameHeight = _pixels.height;
=======
		setCachedGraphics(FlxG.bitmap.create(Width, Height, Color, Unique, Key));
		_region = new Region();
		_region.width = Width;
		_region.height = Height;
		width = frameWidth = _cachedGraphics.bitmap.width;
		height = frameHeight = _cachedGraphics.bitmap.height;
		updateFrameData();
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		resetHelpers();
		return this;
	}
	
	/**
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
	 * Resets some important variables for sprite optimization and rendering.
=======
	 * Loads TexturePacker atlas.
	 * @param	Data		Atlas data holding links to json-data and atlas image
	 * @param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames. 
	 * @param	Unique		Optional, whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @param	FrameName	Default frame to show. If null then will be used first available frame.
	 * 
	 * @return This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadImageFromTexture(Data:Dynamic, Reverse:Bool = false, Unique:Bool = false, FrameName:String = null):FlxSprite
	{
		bakedRotation = 0;
		
		if (Std.is(Data, CachedGraphics))
		{
			setCachedGraphics(cast Data);
			if (_cachedGraphics.data == null)
			{
				return null;
			}
		}
		else if (Std.is(Data, TexturePackerData))
		{
			setCachedGraphics(FlxG.bitmap.add(Data.assetName, Unique));
			_cachedGraphics.data = cast Data;
		}
		else
		{
			return null;
		}
		
		_region = new Region();
		_region.width = _cachedGraphics.bitmap.width;
		_region.height = _cachedGraphics.bitmap.height;
		
		flipped = (Reverse == true) ? _cachedGraphics.bitmap.width : 0;
		
		updateFrameData();
		resetHelpers();
		
		if (FrameName != null)
		{
			frameName = FrameName;
		}
		
		return this;
	}
	
	/**
	 * Creates a pre-rotated sprite sheet from provided image in atlas.
	 * This can make a huge difference in graphical performance on flash target!
	 * @param	Data			Atlas data holding links to json-data and atlas image
	 * @param	Image			The image from atlas you want to rotate and stamp.
	 * @param	Rotations		The number of rotation frames the final sprite should have.  For small sprites this can be quite a large number (360 even) without any problems.
	 * @param	AntiAliasing	Whether to use high quality rotations when creating the graphic.  Default is false.
	 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners.
	 * 
	 * @return This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadRotatedImageFromTexture(Data:Dynamic, Image:String, Rotations:Int = 16, AntiAliasing:Bool = false, AutoBuffer:Bool = false):FlxSprite
	{
		var temp = loadImageFromTexture(Data);
		
		if (temp == null)
		{
			return null;
		}
		
		frameName = Image;
		
		#if !flash
		antialiasing = AntiAliasing;
		#else
		var frameBitmapData:BitmapData = getFlxFrameBitmapData();
		loadRotatedGraphic(frameBitmapData, Rotations, -1, AntiAliasing, AutoBuffer, Data.assetName + ":" + Image);
		#end
		
		return this;
	}
	
	/**
	 * Resets _flashRect variable used for frame bitmapData calculation
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
	 */
	private function resetHelpers():Void
	{
		_flashRect.x = 0;
		_flashRect.y = 0;
		_flashRect.width = frameWidth;
		_flashRect.height = frameHeight;
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
<<<<<<< HEAD
=======
		_flashRect2.x = 0;
		_flashRect2.y = 0;
		_flashRect2.width = _pixels.width;
		_flashRect2.height = _pixels.height;
		
		origin.make(frameWidth * 0.5, frameHeight * 0.5);
>>>>>>> experimental
=======
	}
	
	/**
	 * Resets frame size to _flxFrame dimensions
	 */
	private function resetFrameSize():Void
	{
		frameWidth = Std.int(_flxFrame.sourceSize.x);
		frameHeight = Std.int(_flxFrame.sourceSize.y);
		resetSize();
	}
	
	/**
	 * Resets sprite's size back to frame size
	 */
	public function resetSizeFromFrame():Void
	{
		width = frameWidth;
		height = frameHeight;
	}
	
	public function setOriginToCenter():Void
	{
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
	}
	
	/**
	 * Resets some important variables for sprite optimization and rendering.
	 */
	private function resetHelpers():Void
	{
		resetSize();
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> experimental
		_flashRect2.x = 0;
		_flashRect2.y = 0;
		_flashRect2.width = _cachedGraphics.bitmap.width;
		_flashRect2.height = _cachedGraphics.bitmap.height;
		setOriginToCenter();
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		
	#if flash
		if ((framePixels == null) || (framePixels.width != width) || (framePixels.height != height))
		{
			framePixels = new BitmapData(Std.int(width), Std.int(height));
		}
		framePixels.copyPixels(_cachedGraphics.bitmap, _flashRect, _flashPointZero);
		if (_useColorTransform) framePixels.colorTransform(_flashRect, _colorTransform);
		
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		frames = Std.int(_flashRect2.width / _flashRect.width * _flashRect2.height / _flashRect.height);
	#else
		frames = Std.int(_flashRect2.width / (_flashRect.width + 1) * _flashRect2.height / (_flashRect.height + 1));
		if (frames == 0) frames = 1;
		if (_flipped > 0)
		{
			frames *= 2;
		}
	#end
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		_curIndex = 0;
		
		if (_framesData != null)
		{
			frames = _framesData.frames.length;
			_flxFrame = _framesData.frames[_curIndex];
		}
		
		#if !flash
		_halfWidth = frameWidth * 0.5;
		_halfHeight = frameHeight * 0.5;
		#end
		calcAABB();
	}
	
	override public function update():Void 
	{
		super.update();
		updateAnimation();
	}
	
	inline public function isColored():Bool
	{
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		return (_color < 0xffffff);
=======
		return (color < 0xffffff);
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
	}
	
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	override public function draw():Void
	{
		if (_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker)
			{
				return;
			}
		}
		
		if (dirty)	//rarely 
		{
			calcFrame();
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
	#if !flash
		var drawItem:DrawStackItem;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		#if !js
		var isColored:Bool = isColored();
		#else
		var useAlpha:Bool = (alpha < 1);
		#end
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
	#end
		
		while (i < l)
		{
			camera = cameras[i++];
			
			if (!camera.visible || !camera.exists || !onScreenSprite(camera))
			{
				continue;
			}
			
		#if !flash
			#if !js
			drawItem = camera.getDrawStackItem(_cachedGraphics, isColored, _blendInt, antialiasing);
			#else
			drawItem = camera.getDrawStackItem(_cachedGraphics, useAlpha);
			#end
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x);
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y);
			
			_point.x = (_point.x) + origin.x;
			_point.y = (_point.y) + origin.y;
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end
		#else
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x);
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y);
		#end
#if flash
			if (simpleRenderSprite())
			{
				_flashPoint.x = _point.x;
				_flashPoint.y = _point.y;
				
				camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, null, null, true);
			}
			else
			{
				_matrix.identity();
				_matrix.translate( -origin.x, -origin.y);
				_matrix.scale(scale.x, scale.y);
				if ((angle != 0) && (bakedRotation <= 0))
				{
					_matrix.rotate(angle * FlxAngle.TO_RAD);
				}
				_matrix.translate(_point.x + origin.x, _point.y + origin.y);
				camera.buffer.draw(framePixels, _matrix, null, blend, null, antialiasing);
			}
#else
			var csx:Float = 1;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = 1;
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
			var x2:Float = 0.0;
			var y2:Float = 0.0;

			if (!simpleRenderSprite())
			{
				radians = -(angle + _additionalAngle) * FlxG.RAD;
=======
			
			var x1:Float = (origin.x - _flxFrame.center.x);
			var y1:Float = (origin.y - _flxFrame.center.y);
			
			var x2:Float = x1;
			var y2:Float = y1;
			
			var facingMult:Int = ((flipped != 0) && (facing == FlxObject.LEFT)) ? -1 : 1;
			
			// transformation matrix coefficients
			var a:Float = csx;
			var b:Float = ssx;
			var c:Float = ssy;
			var d:Float = csy;
			
			if (!simpleRenderSprite())
			{
				radians = -(angle + _flxFrame.additionalAngle) * FlxAngle.TO_RAD;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				csx = cos * scale.x * facingMult;
				ssy = sin * scale.y;
				ssx = sin * scale.x * facingMult;
				csy = cos * scale.y;
				
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
				var x1:Float = (origin.x - _halfWidth);
				var y1:Float = (origin.y - _halfHeight);
				x2 = x1 * csx + y1 * ssy;
				y2 = -x1 * ssx + y1 * csy;
=======
				if (_flxFrame.rotated)
				{
					x2 = x1 * ssx - y1 * csy;
					y2 = x1 * csx + y1 * ssy;
					
					a = csy;
					b = ssy;
					c = ssx;
					d = csx;
				}
				else
				{
					x2 = x1 * csx + y1 * ssy;
					y2 = -x1 * ssx + y1 * csy;
					
					a = csx;
					b = ssx;
					c = ssy;
					d = csy;
				}
			}
			else
			{
				csx *= facingMult;
				
				x2 = x1 * csx + y1 * ssy;
				y2 = -x1 * ssx + y1 * csy;
				
				a *= facingMult;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
			}

			currDrawData[currIndex++] = _point.x - x2;
			currDrawData[currIndex++] = _point.y - y2;
			
			currDrawData[currIndex++] = _flxFrame.tileID;
			
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
			if ((_flipped != 0) && (facing == FlxObject.LEFT))
			{
				currDrawData[currIndex++] = -csx;
				currDrawData[currIndex++] = ssy;
				currDrawData[currIndex++] = ssx;
				currDrawData[currIndex++] = csy;
			}
			else
			{
				currDrawData[currIndex++] = csx;
				currDrawData[currIndex++] = ssy;
				currDrawData[currIndex++] = -ssx;
				currDrawData[currIndex++] = csy;
			}
=======
			currDrawData[currIndex++] = a;
			currDrawData[currIndex++] = -b;
			currDrawData[currIndex++] = c;
			currDrawData[currIndex++] = d;
			
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
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
#end
			#if !FLX_NO_DEBUG
			FlxBasic._VISIBLECOUNT++;
			#end
		}
	}
	
	/**
	 * This function draws or stamps one <code>FlxSprite</code> onto another.
	 * This function is NOT intended to replace <code>draw()</code>!
	 * @param	Brush		The image you want to use as a brush or stamp or pen or whatever.
	 * @param	X			The X coordinate of the brush's top left corner on this sprite.
	 * @param	Y			They Y coordinate of the brush's top left corner on this sprite.
	 */
	public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void
	{
		Brush.drawFrame();
		var bitmapData:BitmapData = Brush.framePixels;
		
		//Simple draw
		if (((Brush.angle == 0) || (Brush.bakedRotation > 0)) && (Brush.scale.x == 1) && (Brush.scale.y == 1) && (Brush.blend == null))
		{
			_flashPoint.x = X + _region.startX;
			_flashPoint.y = Y + _region.startY;
			_flashRect2.width = bitmapData.width;
			_flashRect2.height = bitmapData.height;
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
			_pixels.copyPixels(bitmapData, _flashRect2, _flashPoint, null, null, true);
			_flashRect2.width = _pixels.width;
			_flashRect2.height = _pixels.height;
=======
			_cachedGraphics.bitmap.copyPixels(bitmapData, _flashRect2, _flashPoint, null, null, true);
			_flashRect2.width = _cachedGraphics.bitmap.width;
			_flashRect2.height = _cachedGraphics.bitmap.height;
			
			resetFrameBitmapDatas();
			
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
			#if flash
			calcFrame();
			#end
			return;
		}
		
		//Advanced draw
		_matrix.identity();
		_matrix.translate(-Brush.origin.x, -Brush.origin.y);
		_matrix.scale(Brush.scale.x, Brush.scale.y);
		if (Brush.angle != 0)
		{
			_matrix.rotate(Brush.angle * FlxAngle.TO_RAD);
		}
		_matrix.translate(X + _region.startX + Brush.origin.x, Y + _region.startY + Brush.origin.y);
		var brushBlend:BlendMode = Brush.blend;
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		#if !flash
		_calculatedPixelsIndex = -1;
		#end
		_pixels.draw(bitmapData, _matrix, null, brushBlend, null, Brush.antialiasing);
		#if flash
		calcFrame();
		#end
		updateAtlasInfo(true);
	}
	
	/**
<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
=======
>>>>>>> experimental
	 * This function draws a line on this sprite from position X1,Y1
	 * to position X2,Y2 with the specified color.
	 * @param	StartX		X coordinate of the line's start point.
	 * @param	StartY		Y coordinate of the line's start point.
	 * @param	EndX		X coordinate of the line's end point.
	 * @param	EndY		Y coordinate of the line's end point.
	 * @param	Color		The line's color.
	 * @param	Thickness	How thick the line is in pixels (default value is 1).
	 */
	public function drawLine(StartX:Float, StartY:Float, EndX:Float, EndY:Float, Color:Int, Thickness:Int = 1):Void
	{
		//Draw line
		var gfx:Graphics = FlxG.flashGfx;
		gfx.clear();
		gfx.moveTo(StartX, StartY);
		var alphaComponent:Float = ((Color >> 24) & 255) / 255;
		if (alphaComponent <= 0)
		{
			alphaComponent = 1;
		}
		gfx.lineStyle(Thickness, Color, alphaComponent);
		gfx.lineTo(EndX, EndY);
		
		//Cache line to bitmap
		_pixels.draw(FlxG.flashGfxSprite);
		dirty = true;
		
		#if !flash
		_calculatedPixelsIndex = -1;
		#end
		
		updateAtlasInfo(true);
	}
	
	/**
	 * This function draws a circle on this sprite at position X,Y
	 * with the specified color.
	 * @param   X           X coordinate of the circle's center
	 * @param   Y           Y coordinate of the circle's center
	 * @param   Radius      Radius of the circle
	 * @param   Color       Color of the circle
	 */
	public function drawCircle(X:Float, Y:Float, Radius:Float, Color:Int):Void
	{
		var gfx:Graphics = FlxG.flashGfx;
		gfx.clear();
		gfx.beginFill(Color, 1);
		gfx.drawCircle(X, Y, Radius);
		gfx.endFill();

		_pixels.draw(FlxG.flashGfxSprite);
		dirty = true;
		
		#if !flash
		_calculatedPixelsIndex = -1;
		#end
		
		updateAtlasInfo(true);
	}
	
	/**
	 * Fills this sprite's graphic with a specific color.
	 * @param	Color		The color with which to fill the graphic, format 0xAARRGGBB.
	 */
	public function fill(Color:Int):Void
	{
		_pixels.fillRect(_flashRect2, Color);
		if (_pixels != framePixels)
		{
			dirty = true;
		}
		#if !flash
		_calculatedPixelsIndex = -1;
		#end
		updateAtlasInfo(true);
=======
		_cachedGraphics.bitmap.draw(bitmapData, _matrix, null, brushBlend, null, Brush.antialiasing);
		resetFrameBitmapDatas();
		#if flash
		calcFrame();
		#end
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
	}
	
	/**
<<<<<<< HEAD
=======
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> experimental
	 * Internal function for updating the sprite's animation.
	 * Useful for cases when you need to update this but are buried down in too many supers.
	 * This function is called automatically by <code>FlxSprite.postUpdate()</code>.
	 */
	private function updateAnimation():Void
	{
		if (bakedRotation > 0)
		{
			var oldIndex:Int = _curIndex;
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
#if flash
			var angleHelper:Int = Math.floor((angle) % 360);
#else
			var angleHelper:Int = Math.floor((angle + _additionalAngle) % 360);
#end
=======
			var angleHelper:Int = Math.floor((angle) % 360);
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
			
			while (angleHelper < 0)
			{
				angleHelper += 360;
			}
			
			_curIndex = Math.floor(angleHelper / bakedRotation + 0.5);
			_curIndex = Std.int(_curIndex % frames);
			
			if (_framesData != null)
			{
				_flxFrame = _framesData.frames[_curIndex];
			}
			
			if (oldIndex != _curIndex)
			{
				dirty = true;
			}
		}
		else if ((_curAnim != null) && (_curAnim.delay > 0) && (_curAnim.looped || !finished) && !paused)
		{
			_frameTimer += FlxG.elapsed;
			while (_frameTimer > _curAnim.delay)
			{
				_frameTimer = _frameTimer - _curAnim.delay;
				if (_curFrame == _curAnim.frames.length - 1)
				{
					if (_curAnim.looped)
					{
						_curFrame = 0;
					}
					finished = true;
				}
				else
				{
					_curFrame++;
				}
				_curIndex = _curAnim.frames[_curFrame];
				if (_framesData != null)
				{
					_flxFrame = _framesData.frames[_curIndex];
				}
				#end
				dirty = true;
			}
		}
		
		if (dirty)
		{
			calcFrame();
		}
	}
	
	/**
	 * Request (or force) that the sprite update the frame before rendering.
	 * Useful if you are doing procedural generation or other weirdness!
	 * @param	Force	Force the frame to redraw, even if its not flagged as necessary.
	 */
	public function drawFrame(Force:Bool = false):Void
	{
		#if flash
		if (Force || dirty)
		{
			calcFrame();
		}
		#else
		calcFrame(true);
		#end
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * @param	Name		What this animation should be called (e.g. "run").
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped		Whether or not the animation is looped or just plays once.
	 */
	public function addAnimation(Name:String, Frames:Array<Int>, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		// Check animation frames
		var numFrames:Int = Frames.length - 1;
		var i:Int = numFrames;
		while (i >= 0)
		{
			if (Frames[i] >= frames)
			{
				Frames.splice(i, 1);
			}
			i--;
		}
		_animations.set(Name, new FlxAnim(Name, Frames, FrameRate, Looped));
	}
	
	/**
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
=======
	 * Adds a new animation to the sprite.
	 * @param	Name			What this animation should be called (e.g. "run").
	 * @param	FrameNames		An array of image names from atlas indicating what frames to play in what order.
	 * @param	FrameRate		The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the animation is looped or just plays once.
	 */
	public function addAnimationByNamesFromTexture(Name:String, FrameNames:Array<String>, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		if (_cachedGraphics != null && _cachedGraphics.data != null)
		{
			var indices:Array<Int> = new Array<Int>();
			var l:Int = FrameNames.length;
			for (i in 0...l)
			{
				var name:String = FrameNames[i];
				if (_framesData.framesHash.exists(name))
				{
					var frameToAdd:FlxFrame = _framesData.framesHash.get(name);
					indices.push(getFrameIndex(frameToAdd));
				}
			}
			
			if (indices.length > 0)
			{
				_animations.set(Name, new FlxAnim(Name, indices, FrameRate, Looped));
			}
		}
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * @param	Name			What this animation should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	Indicies		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	Postfix			Common ending of image names in atlas (e.g. ".png")
	 * @param	FrameRate		The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the animation is looped or just plays once.
	 */
	public function addAnimationByIndiciesFromTexture(Name:String, Prefix:String, Indicies:Array<Int>, Postfix:String, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		if (_cachedGraphics != null && _cachedGraphics.data != null)
		{
			var frameIndices:Array<Int> = new Array<Int>();
			var l:Int = Indicies.length;
			for (i in 0...l)
			{
				var name:String = Prefix + Indicies[i] + Postfix;
				if (_framesData.framesHash.exists(name))
				{
					var frameToAdd:FlxFrame = _framesData.framesHash.get(name);
					frameIndices.push(getFrameIndex(frameToAdd));
				}
			}
			
			if (frameIndices.length > 0)
			{
				_animations.set(Name, new FlxAnim(Name, frameIndices, FrameRate, Looped));
			}
		}
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * @param	Name			What this animation should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	FrameRate		The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the animation is looped or just plays once.
	*/
	public function addAnimationByPrefixFromTexture(Name:String, Prefix:String, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		if (_cachedGraphics != null && _cachedGraphics.data != null)
		{
			var animFrames:Array<FlxFrame> = new Array<FlxFrame>();
			var l:Int = _framesData.frames.length;
			for (i in 0...l)
			{
				if (StringTools.startsWith(_framesData.frames[i].name, Prefix))
				{
					animFrames.push(_framesData.frames[i]);
				}
			}
			
			if (animFrames.length > 0)
			{
				var name:String = animFrames[0].name;
				var postFix:String = name.substring(name.indexOf(".", Prefix.length), name.length);
				FlxSprite.prefixLength = Prefix.length;
				FlxSprite.postfixLength = postFix.length;
				animFrames.sort(FlxSprite.frameSortFunction);
				var frameIndices:Array<Int> = new Array<Int>();
				
				l = animFrames.length;
				for (i in 0...l)
				{
					frameIndices.push(getFrameIndex(animFrames[i]));
				}
				
				_animations.set(Name, new FlxAnim(Name, frameIndices, FrameRate, Looped));
			}
		}
	}
	
	/**
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
	 * Pass in a function to be called whenever this sprite's animation changes.
	 * @param	AnimationCallback		A function that has 3 parameters: a string name, a int frame number, and a int frame index.
	 */
	public function addAnimationCallback(AnimationCallback:String->Int->Int->Void):Void
	{
		_callback = AnimationCallback;
	}
	
	/**
	 * Plays an existing animation (e.g. "run").
	 * If you call an animation that is already playing it will be ignored.
	 * @param	AnimName	The string name of the animation you want to play.
	 * @param	Force		Whether to force the animation to restart.
	 * @param	Frame		The frame number in animation you want to start from (0 by default). If you pass negative value then it will start from random frame
	 */
	public function play(AnimName:String, Force:Bool = false, Frame:Int = 0):Void
	{
		if (!Force && (_curAnim != null) && (AnimName == _curAnim.name) && (_curAnim.looped || !finished)) 
		{
			paused = false;
			return;
		}
		_curFrame = 0;
		_curIndex = 0;
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		#if !flash
=======
		
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		if (_framesData != null)
		{
			_flxFrame = _framesData.frames[_curIndex];
		}
		#end
		_frameTimer = 0;
		if (_animations.exists(AnimName))
		{
			_curAnim = _animations.get(AnimName);
			if (_curAnim.delay <= 0)
			{
				finished = true;
			}
			else
			{
				finished = false;
			}
			
			if (Frame < 0)
			{
				_curFrame = Std.int(Math.random() * _curAnim.frames.length);
			}
			else if (_curAnim.frames.length > Frame)
			{
				_curFrame = Frame;
			}
			
			_curIndex = _curAnim.frames[_curFrame];
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
			#if !flash
=======
			
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
			if (_framesData != null)
			{
				_flxFrame = _framesData.frames[_curIndex];
			}
			#end
			dirty = true;
			paused = false;
			return;
		}
		
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		FlxG.warn("No animation called \""+AnimName+"\"");
=======
		FlxG.log.warn("No animation called \"" + AnimName + "\"");
	}
	
	/**
	 * Sends the playhead to the specified frame in current animation and plays from that frame.
	 * @param	Frame	frame number in current animation
	 */
	public function gotoAndPlay(Frame:Int = 0):Void
	{
		if (_curAnim == null || _curAnim.frames.length <= Frame)
		{
			return;
		}
		
		play(_curAnim.name, true, Frame);
	}
	
	/**
	 * Sends the playhead to the specified frame in current animation and pauses it there.
	 * @param	Frame	frame number in current animation
	 */
	public function gotoAndStop(Frame:Int = 0):Void
	{
		if (_curAnim == null || _curAnim.frames.length <= Frame)
		{
			return;
		}
		
		_frameTimer = 0;
		if (_curAnim.delay <= 0)
		{
			finished = true;
		}
		else
		{
			finished = false;
		}
		
		_curFrame = Frame;
		_curIndex = _curAnim.frames[_curFrame];
		
		if (_framesData != null)
		{
			_flxFrame = _framesData.frames[_curIndex];
		}
		
		dirty = true;
		paused = true;
		return;
	}
	
	/**
	 * Pauses current animation
	 */
	public function pauseAnimation():Void
	{
		paused = true;
	}
	
	/**
	 * Resumes current animation if it's exist and not finished
	 */
	public function resumeAnimation():Void
	{
		if (_curAnim != null && !finished)
			paused = false;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
	}
	
	/**
  	 * Gets the FlxAnim object with the specified name.
	*/
	public function getAnimation(name:String):FlxAnim
	{
		return _animations.get(name); 
	}
	
	/**
	 * Tell the sprite to change to a random frame of animation
	 * Useful for instantiating particles or other weird things.
	 */
	public function randomFrame():Void
	{
		_curAnim = null;
		_curIndex = Std.int(FlxRandom.float() * frames);
		if (_framesData != null)
		{
			_flxFrame = _framesData.frames[_curIndex];
		}
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		#end
=======
		
		paused = true;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
		dirty = true;
	}
	
	/**
	 * Helper function that just sets origin to (0,0)
	 */
	public function setOriginToCorner():Void
	{
		origin.x = origin.y = 0;
	}
	
	/**
	 * Helper function that adjusts the offset automatically to center the bounding box within the graphic.
	 * @param	AdjustPosition		Adjusts the actual X and Y position just once to match the offset change. Default is false.
	 */
	public function centerOffsets(AdjustPosition:Bool = false):Void
	{
		offset.x = (frameWidth - width) * 0.5;
		offset.y = (frameHeight - height) * 0.5;
		if (AdjustPosition)
		{
			x += offset.x;
			y += offset.y;
		}
	}
	
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
=======
	/**
	 * Replaces all pixels with specified Color with NewColor pixels
	 * @param	Color				Color to replace
	 * @param	NewColor			New color
	 * @param	FetchPositions		Whether we need to store positions of pixels which colors were replaced
	 * @return	Array replaced pixels positions
	 */
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
	public function replaceColor(Color:Int, NewColor:Int, FetchPositions:Bool = false):Array<FlxPoint>
	{
		var positions:Array<FlxPoint> = null;
		if (FetchPositions)
		{
			positions = new Array<FlxPoint>();
		}
		
		var row:Int = _region.startY;
		var column:Int;
		var rows:Int = _region.height;
		var columns:Int = _region.width;
		while(row < rows)
		{
			column = _region.startX;
			while (column < columns)
			{
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
				if(_pixels.getPixel32(column,row) == cast Color)
=======
<<<<<<< HEAD
				if(_pixels.getPixel32(column, row) == cast Color)
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
				if (_cachedGraphics.bitmap.getPixel32(column, row) == cast Color)
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
				{
					_cachedGraphics.bitmap.setPixel32(column, row, NewColor);
					if (FetchPositions)
					{
						positions.push(new FlxPoint(column, row));
					}
					dirty = true;
				}
				column++;
			}
			row++;
		}
		
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		updateAtlasInfo(true);
=======
		resetFrameBitmapDatas();
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		return positions;
	}
	
	public var pixels(get_pixels, set_pixels):BitmapData;
	
	/**
	 * Set <code>pixels</code> to any <code>BitmapData</code> object.
	 * Automatically adjust graphic size and render helpers.
	 */
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
=======
	public var pixels(get, set):BitmapData;
	
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
	private function get_pixels():BitmapData
	{
		return _cachedGraphics.bitmap;
	}
	
	private function set_pixels(Pixels:BitmapData):BitmapData
	{
		var key:String = FlxG.bitmap.getCacheKeyFor(Pixels);
		
		if (key == null)
		{
			key = FlxG.bitmap.getUniqueKey();
			FlxG.bitmap.add(Pixels, false, key);
		}
		
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		_calculatedPixelsIndex = -1;
		#end
		updateAtlasInfo(true);
		return _pixels;
=======
		setCachedGraphics(FlxG.bitmap.get(key));
		_region = new Region();
		_region.width = _cachedGraphics.bitmap.width;
		_region.height = _cachedGraphics.bitmap.height;
		
		width = frameWidth = _cachedGraphics.bitmap.width;
		height = frameHeight = _cachedGraphics.bitmap.height;
		updateFrameData();
		resetHelpers();
		return Pixels;
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
	}
	
	/**
	 * @private
	 */
	private function set_facing(Direction:Int):Int
	{
		if (facing != Direction)
		{
			dirty = true;
		}
		facing = Direction;
		return Direction;
	}
	
	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the sprite.
	 */
	public var alpha(default, set_alpha):Float = 1.0;
	
	/**
	 * @private
	 */
	private function set_alpha(Alpha:Float):Float
	{
		if (Alpha > 1)
		{
			Alpha = 1;
		}
		if (Alpha < 0)
		{
			Alpha = 0;
		}
		if (Alpha == alpha)
		{
			return alpha;
		}
		alpha = Alpha;
		#if flash
		if ((alpha != 1) || (color != 0xffffff))
		{
			if (_colorTransform == null)
			{
				_colorTransform = new ColorTransform((color >> 16) / 255, (color >> 8 & 0xff) / 255, (color & 0xff) / 255, alpha);
			}
			else
			{
				_colorTransform.redMultiplier = (color >> 16) / 255;
				_colorTransform.greenMultiplier = (color >> 8 & 0xff) / 255;
				_colorTransform.blueMultiplier = (color & 0xff) / 255;
				_colorTransform.alphaMultiplier = alpha;
			}
			_useColorTransform = true;
		}
		else
		{
			if (_colorTransform != null)
			{
				_colorTransform.redMultiplier = 1;
				_colorTransform.greenMultiplier = 1;
				_colorTransform.blueMultiplier = 1;
				_colorTransform.alphaMultiplier = 1;
			}
			
			_useColorTransform = false;
		}
		dirty = true;
		#end
		return alpha;
	}
	
	/**
	 * Set <code>color</code> to a number in this format: 0xRRGGBB.
	 * <code>color</code> IGNORES ALPHA.  To change the opacity use <code>alpha</code>.
	 * Tints the whole sprite to be this color (similar to OpenGL vertex colors).
	 */
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
	private function get_color():Int
	{
		return _color;
	}
	
	/**
	 * @private
	 */
	private function set_color(Color:Int):Int
	{
=======
	private function set_color(Color:Int):Int
	{
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		Color &= 0x00ffffff;
		if (color == Color)
		{
			return Color;
		}
		color = Color;
		if ((alpha != 1) || (color != 0x00ffffff))
		{
			if (_colorTransform == null)
			{
				_colorTransform = new ColorTransform((color >> 16) / 255, (color >> 8 & 0xff) / 255, (color & 0xff) / 255, alpha);
			}
			else
			{
				_colorTransform.redMultiplier = (color >> 16) / 255;
				_colorTransform.greenMultiplier = (color >> 8 & 0xff) / 255;
				_colorTransform.blueMultiplier = (color & 0xff) / 255;
				_colorTransform.alphaMultiplier = alpha;
			}
			_useColorTransform = true;
		}
		else
		{
			if (_colorTransform != null)
			{
				_colorTransform.redMultiplier = 1;
				_colorTransform.greenMultiplier = 1;
				_colorTransform.blueMultiplier = 1;
				_colorTransform.alphaMultiplier = 1;
			}
			_useColorTransform = false;
		}
		
		dirty = true;
		
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		#if (cpp || js)
		_red = (_color >> 16) / 255;
		_green = (_color >> 8 & 0xff) / 255;
		_blue = (_color & 0xff) / 255;
=======
		#if !flash
		_red = (color >> 16) / 255;
		_green = (color >> 8 & 0xff) / 255;
		_blue = (color & 0xff) / 255;
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		#end
		
		return color;
	}
	
	/**
	 * Tell the sprite to change to a specific frame of animation.
	 * 
	 * @param	Frame	The frame you want to display.
	 */
	private function get_frame():Int
	{
		return _curIndex;
	}
	
	/**
	 * @private
	 */
	private function set_frame(Frame:Int):Int
	{
		_curAnim = null;
		frame = _curIndex = Frame % frames;
		if (_framesData != null)
		{
			_flxFrame = _framesData.frames[_curIndex];
		}
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		#end
=======
		
		paused = true;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
		dirty = true;
		return Frame;
	}
	
	/**
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
=======
	 * Tell the sprite to change to a frame with specific name.
	 * Useful for sprites with loaded TexturePacker atlas.
	 */
	public var frameName(get_frameName, set_frameName):String;
	
	private function get_frameName():String
	{
		if (_flxFrame != null)
		{
			return _flxFrame.name;
		}
		
		return null;
	}
	
	private function set_frameName(value:String):String
	{
		if (_cachedGraphics.data != null && _framesData != null && _framesData.framesHash.exists(value))
		{
			_curAnim = null;
			if (_framesData != null)
			{
				_flxFrame = _framesData.framesHash.get(value);
				_curIndex = getFrameIndex(_flxFrame);
				resetFrameSize();
			}
			paused = true;
			dirty = true;
		}
		
		return value;
	}
	
	/**
	 * Helper function used for finding index of FlxFrame in _framesData's frames array
	 * @param	Frame	FlxFrame to find
	 * @return	position of specified FlxFrame object.
	 */
	public function getFrameIndex(Frame:FlxFrame):Int
	{
		return FlxArrayUtil.indexOf(_framesData.frames, Frame);
	}
	
	/**
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
	 * Gets the currently playing animation, or null if no animation is playing
	 */
	private function get_curAnim():String
	{
		if (_curAnim != null && !finished)
			return _curAnim.name;
		return null;
	}
	
	/**
	 * Plays a specified animation (same as calling play)
	 * 
	 * @param	AnimName	The name of the animation you want to play.
	 */
	private function set_curAnim(AnimName:String):String
	{
		play(AnimName);
		return AnimName;
	}
	
	/**
	 * Check and see if this object is currently on screen.
	 * Differs from <code>FlxObject</code>'s implementation
	 * in that it takes the actual graphic into account,
	 * not just the hitbox or bounding box or whatever.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether the object is on screen or not.
	 */
	override public function onScreen(Camera:FlxCamera = null):Bool
	{
		return onScreenSprite(Camera);
	}
	
	/*inline*/ private function onScreenSprite(Camera:FlxCamera = null):Bool
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		var result:Bool = false;
		var notRotated = angle == 0.0;
#if !flash
		notRotated = notRotated && _additionalAngle != 0.0;
#end
		if ((notRotated || (bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1))
=======
		calcAABB();
		
		var scx = Camera.scroll.x * scrollFactor.x;
		var scy = Camera.scroll.y * scrollFactor.y;
		
		var minX:Float = _aabb.x - scx;
		var minY:Float = _aabb.y - scy;
		var maxX:Float = minX + _aabb.width;
		var maxY:Float = minY + _aabb.height;
		
		return 	(maxX >= 0) &&
				(minX <= Camera.width) &&
				(maxY >= 0) &&
				(minY <= Camera.height);
	}

	/**
	 * calculate AABB of graphic frame
	 * called internally once each update call
	 */
	inline private function calcAABB():Void
	{
		if ((angle == 0 || bakedRotation > 0) && (scale.x == 1) && (scale.y == 1))
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
		{
			_aabb.set(x - offset.x, y - offset.x, frameWidth, frameHeight);
		}
		else
		{
			var sx:Float = ((flipped != 0) && (facing == FlxObject.LEFT)) ? -scale.x : scale.x;
			
			var sox:Float = sx * origin.x;
			var soy:Float = scale.y * origin.y;
			var sfw:Float = sx * frameWidth;
			var sfh:Float = scale.y * frameHeight;
			
			VERTICES[0].set( -sox, -soy);
			VERTICES[1].set(sfw - sox, -soy);
			VERTICES[2].set(-sox, sfh - soy);
			VERTICES[3].set(sfw - sox, sfh - soy);
			
			var radians:Float = -angle * FlxAngle.TO_RAD;
			var cos:Float = Math.cos(radians);
			var sin:Float = Math.sin(radians);
			
			var genX:Float = x + origin.x - offset.x;
			var genY:Float = y + origin.y - offset.y;
			
			for (i in 0...4) 
			{
				var cp:FlxPoint = VERTICES[i];
				var xt:Float = cp.x * cos + cp.y * sin;
				var yt:Float = -cp.x * sin + cp.y * cos;
				
				cp.x = xt + genX;
				cp.y = yt + genY;
			}
			
			var minX:Float = Math.min(Math.min(VERTICES[0].x, VERTICES[1].x), Math.min(VERTICES[2].x, VERTICES[3].x));
			var minY:Float = Math.min(Math.min(VERTICES[0].y, VERTICES[1].y), Math.min(VERTICES[2].y, VERTICES[3].y));
			var maxX:Float = Math.max(Math.max(VERTICES[0].x, VERTICES[1].x), Math.max(VERTICES[2].x, VERTICES[3].x));
			var maxY:Float = Math.max(Math.max(VERTICES[0].y, VERTICES[1].y), Math.max(VERTICES[2].y, VERTICES[3].y));
			_aabb.set(minX, minY, maxX - minX, maxY - minY);
		}
	}
	
	/**
	 * Checks to see if a point in 2D world space overlaps this <code>FlxSprite</code> object's current displayed pixels.
	 * This check is ALWAYS made in screen space, and always takes scroll factors into account.
	 * @param	Point		The point in world space you want to check.
	 * @param	Mask		Used in the pixel hit test to determine what counts as solid.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, Camera:FlxCamera = null):Bool
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		getScreenXY(_point, Camera);
		_point.x = _point.x - offset.x;
		_point.y = _point.y - offset.y;
		_flashPoint.x = (point.x - Camera.scroll.x) - _point.x;
		_flashPoint.y = (point.y - Camera.scroll.y) - _point.y;
		#if flash
		return untyped framePixels.hitTest(_flashPointZero, Mask, _flashPoint);
		#else
		// 1. Check to see if the point is outside of framePixels rectangle
		if (_flashPoint.x < 0 || _flashPoint.x > frameWidth || _flashPoint.y < 0 || _flashPoint.y > frameHeight)
		{
			return false;
		}
		else // 2. Check pixel at (_flashPoint.x, _flashPoint.y)
		{
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
			// this code is from calcFrame() method
			var indexX:Int = _curIndex * (frameWidth + 1);
			var indexY:Int = 0;

			//Handle sprite sheets
			var widthHelper:Int = (_flipped != 0) ? _flipped : _pixels.width;
			if(indexX >= widthHelper)
			{
				indexY = Std.int(indexX / widthHelper) * (frameHeight + 1);
				indexX %= widthHelper;
			}
			
			var pixelColor:Int = FlxG.TRANSPARENT;
			// handle reversed sprites
			if ((_flipped != 0) && (facing == FlxObject.LEFT))
			{
				pixelColor = _pixels.getPixel32(Std.int(indexX + frameWidth - _flashPoint.x), Std.int(indexY + _flashPoint.y));
			}
			else
			{
				pixelColor = _pixels.getPixel32(Std.int(indexX + _flashPoint.x), Std.int(indexY + _flashPoint.y));
			}
			// end of code from calcFrame() method
			var pixelAlpha:Int = (pixelColor >> 24) & 0xFF;
			return (pixelAlpha >= Mask);
=======
			var frameData:BitmapData = getFlxFrameBitmapData();
			var pixelColor:Int = frameData.getPixel32(Std.int(_flashPoint.x), Std.int(_flashPoint.y));
			var pixelAlpha:Int = (pixelColor >> 24) & 0xFF;
			return (pixelAlpha * alpha >= Mask);
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
		}
		#end
	}
	
	/**
	 * Internal function to update the current animation frame.
	 */
	#if flash
	private function calcFrame():Void
	#else
	private function calcFrame(AreYouSure:Bool = false):Void
	#end
	{
	#if !flash
		if (AreYouSure)
		{
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
			if (_calculatedPixelsIndex == _curIndex && _calculatedPixelsFacing == facing)
			{
<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
				return;
=======
				if (framePixels != null)
				{
					framePixels.dispose();
				}
				framePixels = new BitmapData(Std.int(_flxFrame.sourceSize.x), Std.int(_flxFrame.sourceSize.y));
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
				return;
>>>>>>> experimental
			}
			if ((framePixels == null) || (framePixels.width != width) || (framePixels.height != height))
			{
				framePixels = new BitmapData(Std.int(frameWidth), Std.int(frameHeight));
			}
	#end
			// TODO: Maybe remove 'AreYouSure' parameter
			#if flash
			var indexX:Int = _curIndex * frameWidth;
			#else
			var indexX:Int = _curIndex * (frameWidth + 1);
			_calculatedPixelsIndex = _curIndex;
			_calculatedPixelsFacing = facing;
			#end
			var indexY:Int = 0;

			//Handle sprite sheets
			#if flash
			var widthHelper:Int = (_flipped != 0) ? _flipped : _pixels.width;
			#else
			var widthHelper:Int = _pixels.width;
			#end
			if (indexX >= widthHelper)
			{
				#if flash
				indexY = Std.int(indexX / widthHelper) * frameHeight;
				#else
				indexY = Std.int(indexX / widthHelper) * (frameHeight + 1);
				#end
				indexX %= widthHelper;
			}
			
			#if flash
			//handle reversed sprites
			if ((_flipped != 0) && (facing == FlxObject.LEFT))
			{
				indexX = (_flipped << 1) - indexX - frameWidth;
			}
			#end
			
			//Update display bitmap
			_flashRect.x = indexX;
			_flashRect.y = indexY;
			framePixels.copyPixels(_pixels, _flashRect, _flashPointZero);
			#if !flash
			if ((_flipped != 0) && (facing == FlxObject.LEFT))
			{
				var temp:BitmapData = framePixels.clone();
				_matrix.identity();
				_matrix.scale( -1, 1);
				_matrix.translate(temp.width, 0);
				framePixels.fillRect(framePixels.rect, FlxG.TRANSPARENT);
				framePixels.draw(temp, _matrix);
			}
			#end
			_flashRect.x = _flashRect.y = 0;
=======
	#end
			if (_flxFrame != null)
			{
				if ((framePixels == null) || (framePixels.width != frameWidth) || (framePixels.height != frameHeight))
				{
					if (framePixels != null)
						framePixels.dispose();
					
					framePixels = new BitmapData(Std.int(_flxFrame.sourceSize.x), Std.int(_flxFrame.sourceSize.y));
				}
				
				framePixels.copyPixels(getFlxFrameBitmapData(), _flashRect, _flashPointZero);
			}
			
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
			if (_useColorTransform) 
			{
				framePixels.colorTransform(_flashRect, _colorTransform);
			}
	#if !flash
		}
	#end
		
		if (_callback != null)
		{
			_callback(((_curAnim != null) ? (_curAnim.name) : null), _curFrame, _curIndex);
		}
		
		dirty = false;
		
		/*
		// Updates the filter effects on framePixels.
		if (filters != null)
		{
			#if flash 
			for (filter in filters) 
			{
				framePixels.applyFilter(framePixels, _flashRect, _flashPointZero, filter);
			}
			#else
			_pixels.copyPixels(_pixelsBackup, _pixels.rect, _flashPointZero);
			for (filter in filters) 
			{
				_pixels.applyFilter(_pixels, _flashRect, _flashPointZero, filter);
			}
			#end
		}
		*/
	}
	
	/**
	 * Adds a filter to this sprite, the sprite becomes unique and won't share its graphics with other sprites.
	 * Note that for effects like outer glow, or drop shadow, updating the sprite clipping
	 * area may be required, use widthInc or heightInc to increase the sprite area.
	 * 
	 * @param	filter		The filter to be added.
	 * @param	widthInc	The ammount of pixels to increase the width of the sprite.
	 * @param	heightInc	The ammount of pixels to increase the height of the sprite.
	 */
	public function addFilter(filter:BitmapFilter, widthInc:Int = 0, heightInc:Int = 0)
	{	
		/*
		// This makes the sprite graphic unique, essential for native target that uses texture atlas,
		setClipping(frameWidth + widthInc , frameHeight + heightInc);
		
		if (filters == null) 
		{
			filters = new Array<BitmapFilter>();
		}
		
		filters.push(filter);
		
		#if !flash
		if (_pixelsBackup == null) 
		{
			_pixelsBackup = new BitmapData(Std.int(_pixels.rect.width), Std.int(_pixels.rect.height));
			_pixelsBackup.copyPixels(_pixels, _pixels.rect, _flashPointZero);
			
		}
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		_calculatedPixelsIndex = -1;
		updateAtlasInfo(true);
=======
	//	updateAtlasInfo(true);
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		#end
		
		drawFrame(true); // at the end of calcframe() filters will be applied.
		*/
	}
	
	/**
	 * Sets this sprite clipping width and height, the current graphic is centered
	 * at the middle.
	 * 
	 * @param	width	The new sprite width.
	 * @param	height	The new sprite height.
	 */
	public function setClipping(width:Int, height:Int)
	{
		/*var tempSpr:FlxSprite = new FlxSprite(0, 0, _pixels);
		var diffSize:FlxPoint = new FlxPoint(width - frameWidth, height - frameHeight);
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		makeGraphic(width, height, 0x0);
=======
		// TODO: check this later for flash target when sprite have _textureData
		makeGraphic(width, height, 0x0, true);
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
		
		stamp(tempSpr, Std.int(diffSize.x / 2), Std.int(diffSize.y / 2));
		
		this.x -= diffSize.x * 0.5;
		this.y -= diffSize.y * 0.5;
		
		tempSpr.destroy();*/
	}
	
	/**
	 * Removes a filter from the sprite.
	 * 
	 * @param	filter	The filter to be removed.
	 */
	public function removeFilter(filter:BitmapFilter)
	{
		/*if(filters == null || filter == null)
		{
			return;
		}
		
		filters.remove(filter);
		
		drawFrame(true);
		
		if (filters.length == 0)
		{
			filters = null;
		}*/
	}
	
	/**
	 * Removes all filters from the sprite, additionally you may call loadGraphic() after removing
	 * the filters to reuse cached graphics/bitmaps and stop this sprite from being unique.
	 */
	public function removeAllFilters()
	{
		/*if (filters == null) return;
		
		while (filters.length != 0) 
		{
			filters.pop();
		}
		
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		
		#if !flash
		_calculatedPixelsIndex = -1;
		#end
		
		updateAtlasInfo(true);
=======
	//	updateAtlasInfo(true);
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		drawFrame(true);
		
		filters = null;*/
	}
	
	/**
	 * How many frames of "baked" rotation there are (if any).
	 */
	public var bakedRotation(default, null):Float;
	
	/**
	 * If the Sprite is being rendered in "simple mode" (via copyPixels).
	 * True for flash when no angle, bakedRotations, scaling or blend modes are used.
	 * This enables the sprite to be rendered much faster if true.
	 */
	public var simpleRender(get_simpleRender, null):Bool;
	
	private function get_simpleRender():Bool
	{ 
		return simpleRenderSprite();
	}
	
	inline private function simpleRenderSprite():Bool
	{
		#if flash
		return (((angle == 0) || (bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null) && (forceComplexRender == false));
		#else
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		return (((angle == 0 && _additionalAngle == 0) || (bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1));
=======
		return (((angle == 0 && _flxFrame.additionalAngle == 0) || (bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1));
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
		#end
	}
	
	public var aabb(get_aabb, null):FlxRect;
	
	function get_aabb():FlxRect 
	{
		return _aabb;
	}
	
	#if !flash
	public var blend(get_blend, set_blend):BlendMode;
	
	private function get_blend():BlendMode 
	{
		return _blend;
	}
	
	private function set_blend(value:BlendMode):BlendMode 
	{
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		switch (value)
=======
		if (value != null)
		{
			switch (value)
			{
				case BlendMode.ADD:
					_blendInt = Tilesheet.TILE_BLEND_ADD;
			#if !js
				case BlendMode.MULTIPLY:
					_blendInt = Tilesheet.TILE_BLEND_MULTIPLY;
				case BlendMode.SCREEN:
					_blendInt = Tilesheet.TILE_BLEND_SCREEN;
			#end
				default:
					_blendInt = Tilesheet.TILE_BLEND_NORMAL;
			}
		}
		else
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
		{
			case BlendMode.ADD:
				_blendInt = Tilesheet.TILE_BLEND_ADD;
			default:
				_blendInt = 0;
		}
		
		_blend = value;
		return value;
	}
	#end
	
	/**
	 * Use this method for creating tileSheet for FlxSprite. Must be called after makeGraphic(), loadGraphic or loadRotatedGraphic().
	 * If you forget to call it then you will not see this FlxSprite on c++ target
	 */
	override public function updateFrameData():Void
	{
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
	#if !flash
		if (_node != null && frameWidth >= 1 && frameHeight >= 1)
		{
			if (frames > 1)
			{
				_framesData = _node.getSpriteSheetFrames(Std.int(frameWidth), Std.int(frameHeight), null, 0, 0, 0, 0, 1, 1);
			}
			else
			{
				_framesData = _node.getSpriteSheetFrames(Std.int(frameWidth), Std.int(frameHeight));
			}
			_flxFrame = _framesData.frames[_curIndex];
		}
	#end
=======
		if (_cachedGraphics == null)
		{
			return;
		}
		
		if (_cachedGraphics.data != null && (_region.tileWidth == 0 && _region.tileHeight == 0))
		{
			_framesData = _cachedGraphics.tilesheet.getTexturePackerFrames(_cachedGraphics.data);
		}
		else
		{
			_framesData = _cachedGraphics.tilesheet.getSpriteSheetFrames(_region, null);
		}
		
		_flxFrame = _framesData.frames[0];
		resetFrameSize();
		resetSizeFromFrame();
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
	}
	
	override public function overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, Camera:FlxCamera = null):Bool
	{
		if (scale.x == 1 && scale.y == 1)
		{
			return super.overlapsPoint(point, InScreenSpace, Camera);
		}
		
		if (!InScreenSpace)
		{
			return (point.x > x - 0.5 * width * (scale.x - 1)) && (point.x < x + width + 0.5 * width * (scale.x - 1)) && (point.y > y - 0.5 * height * (scale.y - 1)) && (point.y < y + height + 0.5 * height * (scale.y - 1));
		}

<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var X:Float = point.x - Camera.scroll.x;
		var Y:Float = point.y - Camera.scroll.y;
		getScreenXY(_point, Camera);
		return (X > _point.x - 0.5 * width * (scale.x - 1)) && (X < _point.x + width + 0.5 * width * (scale.x - 1)) && (Y > _point.y - 0.5 * height * (scale.y - 1)) && (Y < _point.y + height + 0.5 * height * (scale.y - 1));
	}
	
<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/FlxSprite.hx
=======
>>>>>>> experimental
=======
		return 0;
	}
	
	/**
	 * Retrieves BitmapData of current FlxFrame
	 */
	public inline function getFlxFrameBitmapData():BitmapData
	{
		var frameBmd:BitmapData = null;
		if (_flxFrame != null)
		{
			if (facing == FlxObject.LEFT && flipped > 0)
			{
				frameBmd = _flxFrame.getReversedBitmap();
			}
			else
			{
				frameBmd = _flxFrame.getBitmap();
			}
		}
		
		return frameBmd;
	}
	
	/**
	 * Helper function for reseting precalculated FlxFrame bitmapdatas.
	 * Useful when _pixels bitmapdata changes (e.g. after stamp(), FlxSpriteUtil.drawLine() and other similar method calls).
	 */
	public function resetFrameBitmapDatas():Void
	{
		_cachedGraphics.tilesheet.destroyFrameBitmapDatas();
	}
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/FlxSprite.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSprite.hx
>>>>>>> experimental
}