package flixel;

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

/**
 * The main "game object" class, the sprite is a <code>FlxObject</code>
 * with a bunch of graphics options and abilities, like animation and stamping.
 */
class FlxSprite extends FlxObject
{
	/**
	 * Set <code>facing</code> using <code>FlxObject.LEFT</code>,<code>RIGHT</code>,
	 * <code>UP</code>, and <code>DOWN</code> to take advantage of
	 * flipped sprites and/or just track player orientation more easily.
	 */
	public var facing(default, set_facing):Int;
	
	public var color(default, set_color):Int = 0xffffff;
	public var frame(default, set_frame):Int = 0;
	
	#if !flash
	public var isColored(default, null):Bool = false;
	#end
	
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
	public var antialiasing:Bool = false;
	
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
	 * A function that has 3 parameters: a string name, a uint frame number, and a uint frame index.
	 */
	private var _callback:String->Int->Int->Void;
	/**
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
	
	/**
	 * Link to current FlxFrame from loaded atlas
	 */
	private var _flxFrame:FlxFrame;
	
	#if !flash
	private var _red:Float = 1.0;
	private var _green:Float = 1.0;
	private var _blue:Float = 1.0;
	
	private var _facingMult:Int = 1;
	#end
	
	/**
	 * These vars are being used for rendering in some of FlxSprite subclasses 
	 * (FlxTileblock, FlxBar, FlxBitmapFont and FlxBitmapTextField)
	 * and for checks if the sprite is in camera's view
	 */
	private var _halfWidth:Float;
	private var _halfHeight:Float;
	
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
		
		facing = FlxObject.RIGHT;
		_animations = new Map<String, FlxAnim>();
		
		_matrix = new Matrix();
		
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
		_flxFrame = null;
		
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
		setCachedGraphics(FlxG.bitmap.add(Graphic, Unique, Key));
		
		flipped = (Reverse == true) ? _cachedGraphics.bitmap.width : 0;
		
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
		
		if (!isRegion)
		{
			key += ":" + Frame + ":" + width + "x" + height + ":" + Rotations;
		}
		
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
	public function makeGraphic(Width:Int, Height:Int, Color:Int = 0xffffffff, Unique:Bool = false, Key:String = null):FlxSprite
	{
		bakedRotation = 0;
		setCachedGraphics(FlxG.bitmap.create(Width, Height, Color, Unique, Key));
		_region = new Region();
		_region.width = Width;
		_region.height = Height;
		width = frameWidth = _cachedGraphics.bitmap.width;
		height = frameHeight = _cachedGraphics.bitmap.height;
		updateFrameData();
		resetHelpers();
		return this;
	}
	
	/**
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
	 */
	private function resetSize():Void
	{
		_flashRect.x = 0;
		_flashRect.y = 0;
		_flashRect.width = frameWidth;
		_flashRect.height = frameHeight;
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
		_flashRect2.x = 0;
		_flashRect2.y = 0;
		_flashRect2.width = _cachedGraphics.bitmap.width;
		_flashRect2.height = _cachedGraphics.bitmap.height;
		setOriginToCenter();
		
	#if flash
		if ((framePixels == null) || (framePixels.width != frameWidth) || (framePixels.height != frameHeight))
		{
			framePixels = new BitmapData(Std.int(width), Std.int(height));
		}
		framePixels.copyPixels(_cachedGraphics.bitmap, _flashRect, _flashPointZero);
		if (_useColorTransform) framePixels.colorTransform(_flashRect, _colorTransform);
	#end
		
		_curIndex = 0;
		
		if (_framesData != null)
		{
			frames = _framesData.frames.length;
			_flxFrame = _framesData.frames[_curIndex];
		}
		
		_halfWidth = frameWidth * 0.5;
		_halfHeight = frameHeight * 0.5;
	}
	
	override public function update():Void 
	{
		super.update();
		// TODO: add check if currAnim isn't null
		updateAnimation();
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
		
	#if !flash
		var drawItem:DrawStackItem;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		#if js
		var useAlpha:Bool = (alpha < 1);
		#end
		
		var cos:Float;
		var sin:Float;
	#end
		
		var isSimpleRender:Bool = simpleRenderSprite();
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !onScreen(camera))
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
			if (isSimpleRender)
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
			
			var x1:Float = (origin.x - _flxFrame.center.x);
			var y1:Float = (origin.y - _flxFrame.center.y);
			
			var x2:Float = x1;
			var y2:Float = y1;
			
			// transformation matrix coefficients
			var a:Float = csx;
			var b:Float = ssx;
			var c:Float = ssy;
			var d:Float = csy;
			
			if (!isSimpleRender)
			{
				if (_angleChanged)
				{
					var radians:Float = -angle * FlxAngle.TO_RAD;
					_sinAngle = Math.sin(radians);
					_cosAngle = Math.cos(radians);
					_angleChanged = false;
				}
				
				var sx:Float = scale.x * _facingMult;
				
				if (_flxFrame.rotated)
				{
					cos = -_sinAngle;
					sin = _cosAngle;
					
					csx = cos * sx;
					ssy = sin * scale.y;
					ssx = sin * sx;
					csy = cos * scale.y;
					
					x2 = x1 * ssx - y1 * csy;
					y2 = x1 * csx + y1 * ssy;
					
					a = csy;
					b = ssy;
					c = ssx;
					d = csx;
				}
				else
				{
					cos = _cosAngle;
					sin = _sinAngle;
					
					csx = cos * sx;
					ssy = sin * scale.y;
					ssx = sin * sx;
					csy = cos * scale.y;
					
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
				csx *= _facingMult;
				
				x2 = x1 * csx + y1 * ssy;
				y2 = -x1 * ssx + y1 * csy;
				
				a *= _facingMult;
			}
			
			currDrawData[currIndex++] = _point.x - x2;
			currDrawData[currIndex++] = _point.y - y2;
			
			currDrawData[currIndex++] = _flxFrame.tileID;
			
			currDrawData[currIndex++] = a;
			currDrawData[currIndex++] = -b;
			currDrawData[currIndex++] = c;
			currDrawData[currIndex++] = d;
			
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
			_cachedGraphics.bitmap.copyPixels(bitmapData, _flashRect2, _flashPoint, null, null, true);
			_flashRect2.width = _cachedGraphics.bitmap.width;
			_flashRect2.height = _cachedGraphics.bitmap.height;
			
			resetFrameBitmapDatas();
			
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
		_cachedGraphics.bitmap.draw(bitmapData, _matrix, null, brushBlend, null, Brush.antialiasing);
		resetFrameBitmapDatas();
		#if flash
		calcFrame();
		#end
	}
	
	/**
	 * Internal function for updating the sprite's animation.
	 * Useful for cases when you need to update this but are buried down in too many supers.
	 * This function is called automatically by <code>FlxSprite.postUpdate()</code>.
	 */
	private function updateAnimation():Void
	{
		if (bakedRotation > 0)
		{
			var oldIndex:Int = _curIndex;
			var angleHelper:Int = Math.floor((angle) % 360);
			
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
					resetFrameSize();
				}
				
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
	 * Pass in a function to be called whenever this sprite's animation changes.
	 * @param	AnimationCallback		A function that has 3 parameters: a string name, a uint frame number, and a uint frame index.
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
		
		if (_framesData != null)
		{
			_flxFrame = _framesData.frames[_curIndex];
		}
		
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
			
			if (_framesData != null)
			{
				_flxFrame = _framesData.frames[_curIndex];
			}
			
			dirty = true;
			paused = false;
			return;
		}
		
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
			resetFrameSize();
		}
		
		paused = true;
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
	
	/**
	 * Replaces all pixels with specified Color with NewColor pixels
	 * @param	Color				Color to replace
	 * @param	NewColor			New color
	 * @param	FetchPositions		Whether we need to store positions of pixels which colors were replaced
	 * @return	Array replaced pixels positions
	 */
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
				if (_cachedGraphics.bitmap.getPixel32(column, row) == cast Color)
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
		
		resetFrameBitmapDatas();
		return positions;
	}
	
	/**
	 * Set <code>pixels</code> to any <code>BitmapData</code> object.
	 * Automatically adjust graphic size and render helpers.
	 */
	public var pixels(get, set):BitmapData;
	
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
		
		setCachedGraphics(FlxG.bitmap.get(key));
		_region = new Region();
		_region.width = _cachedGraphics.bitmap.width;
		_region.height = _cachedGraphics.bitmap.height;
		
		width = frameWidth = _cachedGraphics.bitmap.width;
		height = frameHeight = _cachedGraphics.bitmap.height;
		updateFrameData();
		resetHelpers();
		return Pixels;
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
		#if !flash
		_facingMult = ((flipped != 0) && (facing == FlxObject.LEFT)) ? -1 : 1;
		#end
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
	private function set_color(Color:Int):Int
	{
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
		
		#if !flash
		_red = (color >> 16) / 255;
		_green = (color >> 8 & 0xff) / 255;
		_blue = (color & 0xff) / 255;
		isColored = color < 0xffffff;
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
			resetFrameSize();
		}
		
		paused = true;
		dirty = true;
		return Frame;
	}
	
	/**
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
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		var minX:Float = x - offset.x - Camera.scroll.x * scrollFactor.x;
		var minY:Float = y - offset.y - Camera.scroll.y * scrollFactor.y;
		var maxX:Float = 0;
		var maxY:Float = 0;
		
		if ((angle == 0 || bakedRotation > 0) && (scale.x == 1) && (scale.y == 1))
		{
			maxX = minX + frameWidth;
			maxY = minY + frameHeight;
		}
		else
		{
			var radiusX:Float = _halfWidth;
			var radiusY:Float = _halfHeight;
			
			if (origin.x == _halfWidth)
			{
				radiusX = Math.abs(_halfWidth * scale.x);
			}
			else
			{
				var sox:Float = scale.x * origin.x;
				var sfw:Float = scale.x * frameWidth;
				var x1:Float = Math.abs(sox);
				var x2:Float = Math.abs(sfw - sox);
				radiusX = Math.max(x2, x1);
			}
			
			if (origin.y == _halfHeight)
			{
				radiusY = Math.abs(_halfHeight * scale.y);
			}
			else
			{
				var soy:Float = scale.y * origin.y;
				var sfh:Float = scale.y * frameHeight;
				var y1:Float = Math.abs(soy);
				var y2:Float = Math.abs(sfh - soy);
				radiusY = Math.max(y2, y1);
			}
			
			var radius:Float = Math.max(radiusX, radiusY);
			radius *= 1.415; // Math.sqrt(2);
			
			minX += origin.x;
			maxX = minX + radius;
			minX -= radius;
			
			minY += origin.y;
			maxY = minY + radius;
			minY -= radius;
		}
		
		if (maxX < 0 || minX > Camera.width)
			return false;
		
		if (maxY < 0 || minY > Camera.height)
			return false;
		
		return true;
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
			var frameData:BitmapData = getFlxFrameBitmapData();
			var pixelColor:Int = frameData.getPixel32(Std.int(_flashPoint.x), Std.int(_flashPoint.y));
			var pixelAlpha:Int = (pixelColor >> 24) & 0xFF;
			return (pixelAlpha * alpha >= Mask);
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
		// TODO: Maybe remove 'AreYouSure' parameter
		if (AreYouSure)
		{
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
	//	updateAtlasInfo(true);
		#end
		
		// TODO: check this later
		resetFrameBitmapDatas();
		
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
		// TODO: check this later for flash target when sprite have _textureData
		makeGraphic(width, height, 0x0, true);
		
		stamp(tempSpr, Std.int(diffSize.x / 2), Std.int(diffSize.y / 2));
		
		this.x -= diffSize.x * 0.5;
		this.y -= diffSize.y * 0.5;
		
		tempSpr.destroy();*/
	}
	
	/**
	 * Shortcut for setting both width and Height.
	 * 
	 * @param	Width	The new sprite width.
	 * @param	Height	The new sprite height.
	 */
	public function setSize(Width:Float, Height:Float)
	{
		width = Width;
		height = Height;
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
		
	//	updateAtlasInfo(true);
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
		return (((angle == 0 && _flxFrame.additionalAngle == 0) || (bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1));
		#end
	}
	
	private var _angleChanged:Bool = false;
	private var _sinAngle:Float = 0;
	private var _cosAngle:Float = 1;
	
	override private function set_angle(value:Float):Float
	{
		_angleChanged = (angle != value);
		return angle = value;
	}
	
	#if !flash
	public var blend(get_blend, set_blend):BlendMode;
	
	private function get_blend():BlendMode 
	{
		return _blend;
	}
	
	private function set_blend(value:BlendMode):BlendMode 
	{
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
		{
			_blendInt = 0;
		}
		
		_blend = value;
		return value;
	}
	#end
	
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

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var X:Float = point.x - Camera.scroll.x;
		var Y:Float = point.y - Camera.scroll.y;
		getScreenXY(_point, Camera);
		return (X > _point.x - 0.5 * width * (scale.x - 1)) && (X < _point.x + width + 0.5 * width * (scale.x - 1)) && (Y > _point.y - 0.5 * height * (scale.y - 1)) && (Y < _point.y + height + 0.5 * height * (scale.y - 1));
	}
	
	/**
	 * Use this method for creating tileSheet for FlxSprite. Must be called after makeGraphic(), loadGraphic or loadRotatedGraphic().
	 * If you forget to call it then you will not see this FlxSprite on c++ target
	 */
	override public function updateFrameData():Void
	{
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
	}
	
	/**
	 * Helper constants used for animation's frame sorting
	 */
	private static var prefixLength:Int = 0;
	private static var postfixLength:Int = 0;
	
	/**
	 * Helper frame sorting function used by addAnimationByPrefixFromTexture() method
	 */
	static function frameSortFunction(frame1:FlxFrame, frame2:FlxFrame):Int
	{
		var name1:String = frame1.name;
		var name2:String = frame2.name;
		
		var num1:Int = Std.parseInt(name1.substring(prefixLength, name1.length - postfixLength));
		var num2:Int = Std.parseInt(name2.substring(prefixLength, name2.length - postfixLength));
		
		if (num1 > num2)
		{
			return 1;
		}
		else if (num2 > num1)
		{
			return -1;
		}

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
}