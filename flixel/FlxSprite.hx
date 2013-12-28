package flixel;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.system.FlxAssets;
import flixel.system.layer.DrawStackItem;
import flixel.system.layer.frames.FlxFrame;
import flixel.system.layer.Region;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flixel.animation.FlxAnimationController;
import flixel.util.FlxAngle;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxColorUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.loaders.CachedGraphics;
import flixel.util.loaders.TexturePackerData;
import flixel.util.loaders.TextureRegion;
import openfl.display.Tilesheet;

/**
 * The main "game object" class, the sprite is a <code>FlxObject</code>
 * with a bunch of graphics options and abilities, like animation and stamping.
 */
class FlxSprite extends FlxObject
{
	/**
	 * Class that handles adding and playing animations on this sprite.
	 */
	public var animation:FlxAnimationController;
	/**
	 * Set <code>pixels</code> to any <code>BitmapData</code> object.
	 * Automatically adjust graphic size and render helpers.
	 */
	public var pixels(get, set):BitmapData;
	/**
	 * Link to current FlxFrame from loaded atlas
	 */
	public var frame(default, set):FlxFrame;
	/**
	 * The actual Flash <code>BitmapData</code> object representing the current display state of the sprite.
	 */
	public var framePixels:BitmapData;
	/**
	 * The width of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 */
	public var frameWidth(default, null):Int;
	/**
	 * The height of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 */
	public var frameHeight(default, null):Int;
	/**
	 * The total number of frames in this image.  WARNING: assumes each row in the sprite sheet is full!
	 */
	public var frames(default, null):Int;
	/**
	 * How many frames of "baked" rotation there are (if any).
	 */
	public var bakedRotation(default, null):Float;
	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the sprite.
	 */
	public var alpha(default, set):Float = 1.0;
	/**
	 * Set <code>facing</code> using <code>FlxObject.LEFT</code>,<code>RIGHT</code>, <code>UP</code>, 
	 * and <code>DOWN</code> to take advantage of flipped sprites and/or just track player orientation more easily.
	 */
	public var facing(default, set):Int;
	/**
	 * If the Sprite is flipped. Shouldn't be changed unless you know what are you doing.
	 */
	public var flipped(default, null):Int;
	/**
	 * WARNING: The origin of the sprite will default to its center. If you change this, 
	 * the visuals and the collisions will likely be pretty out-of-sync if you do any rotation.
	 */
	public var origin(default, set):FlxPoint;
	/**
	 * Controls the position of the sprite's hitbox. Likely needs to be adjusted after
	 * changing a sprite's <code>width</code>, <code>height</code> or <code>scale</code>.
	 */
	public var offset(default, set):FlxPoint;
	/**
	 * Change the size of your sprite's graphic. NOTE: The hitbox is not automatically adjusted, use <code>updateHitbox</code> for that
	 * (or <code>setGraphicDimensions()</code>. WARNING: scaling sprites decreases rendering performance by a factor of about x10!
	 */
	public var scale(default, set):FlxPoint;
	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 * @default false
	 */
	public var antialiasing:Bool = false;
	/**
	 * Set this flag to true to force the sprite to update during the draw() call.
	 * NOTE: Rarely if ever necessary, most sprite operations will flip this flag automatically.
	 */
	public var dirty:Bool;
	/**
	 * Blending modes, just like Photoshop or whatever, e.g. "multiply", "screen", etc.
	 * @default null
	 */
	public var blend(get, set):BlendMode;
	private var _blend:BlendMode;
	#if !flash
	private var _blendInt:Int = 0;
	#end
	/**
	 * Set <code>color</code> to a number in this format: 0xRRGGBB. <code>color</code> IGNORES ALPHA.  
	 * To change the opacity use <code>alpha</code>. Tints the whole sprite to be this color (similar to OpenGL vertex colors).
	 */
	public var color(default, set):Int = 0xffffff;
	/**
	 * TODO: Needs docs
	 */
	public var colorTransform(get_colorTransform, never):ColorTransform;
	/**
	 * TODO: Needs docs
	 */
	#if !flash
	public var isColored:Bool;
	private var _red:Float = 1.0;
	private var _green:Float = 1.0;
	private var _blue:Float = 1.0;
	private var _facingMult:Int = 1;
	#end
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
	public var useColorTransform(default, null):Bool = false;
	/**
	 * Internal, helps with animation, caching and drawing.
	 */
	private var _matrix:Matrix;
	/**
	 * These vars are being used for rendering in some of FlxSprite subclasses (FlxTileblock, FlxBar, 
	 * FlxBitmapFont and FlxBitmapTextField) and for checks if the sprite is in camera's view.
	 */
	private var _halfWidth:Float;
	private var _halfHeight:Float;
	private var _sinAngle:Float = 0;
	private var _cosAngle:Float = 1;
	private var _angleChanged:Bool = false;
	/**
	 * Internal statically typed FlxPoint vars, for performance reasons.
	 */
	private var _offset:FlxPoint;
	private var _origin:FlxPoint;
	private var _scale:FlxPoint;
	
	/**
	 * Creates a white 8x8 square <code>FlxSprite</code> at the specified position. Optionally can load a simple, one-frame graphic instead.
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:Dynamic)
	{
		super(X, Y);
		
		facing = FlxObject.RIGHT;
		
		if (SimpleGraphic == null)
		{
			SimpleGraphic = FlxAssets.IMG_DEFAULT;
		}
		loadGraphic(SimpleGraphic);
	}
	
	override private function initVars():Void 
	{
		super.initVars();
		
		animation = new FlxAnimationController(this);
		
		_flashPoint = new Point();
		_flashRect = new Rectangle();
		_flashRect2 = new Rectangle();
		_flashPointZero = new Point();
		offset = new FlxPoint();
		origin = new FlxPoint();
		scale = new FlxPoint(1, 1);
		_matrix = new Matrix();
	}
	
	/**
	 * WARNING: This will remove this object entirely. Use <code>kill()</code> if you want to disable it temporarily only and <code>reset()</code> it later to revive it.
	 * Override this function to null out variables manually or call destroy() on class members if necessary. Don't forget to call super.destroy()!
	 */
	override public function destroy():Void
	{
		super.destroy();
		
		if (animation != null)
		{
			animation.destroy();
		}
		animation = null;
		
		_flashPoint = null;
		_flashRect = null;
		_flashRect2 = null;
		_flashPointZero = null;
		offset = null;
		origin = null;
		scale = null;
		_matrix = null;
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
		frame = null;
	}
	
	public function clone(NewSprite:FlxSprite = null):FlxSprite
	{
		if (NewSprite == null)
		{
			NewSprite = new FlxSprite();
		}
		
		NewSprite.loadfromSprite(this);
		return NewSprite;
	}
	
	/**
	 * Load graphic from another FlxSprite and copy its tileSheet data. 
	 * This method can useful for non-flash targets (and is used by the FlxTrail effect).
	 * @param	Sprite	The FlxSprite from which you want to load graphic data
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadfromSprite(Sprite:FlxSprite):FlxSprite
	{
		if (!exists)
		{
			FlxG.log.warn("Warning, trying to clone " + Type.getClassName(Type.getClass(this)) + " object that doesn't exist.");
		}
		
		region = Sprite.region.clone();
		flipped = Sprite.flipped;
		bakedRotation = Sprite.bakedRotation;
		cachedGraphics = Sprite.cachedGraphics;
		
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
		animation.copyFrom(Sprite.animation);
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
	public function loadGraphic(Graphic:Dynamic, Animated:Bool = false, Reverse:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite
	{
		bakedRotation = 0;
		cachedGraphics = FlxG.bitmap.add(Graphic, Unique, Key);
		
		flipped = (Reverse == true) ? cachedGraphics.bitmap.width : 0;
		
		if (Width == 0)
		{
			Width = (Animated == true) ? cachedGraphics.bitmap.height : cachedGraphics.bitmap.width;
		}
		
		if (Height == 0)
		{
			Height = (Animated == true) ? Width : cachedGraphics.bitmap.height;
		}
		
		if (!Std.is(Graphic, TextureRegion))
		{
			region = new Region(0, 0, Width, Height);
			region.width = cachedGraphics.bitmap.width;
			region.height = cachedGraphics.bitmap.height;
		}
		else
		{
			region = cast(Graphic, TextureRegion).region.clone();
			
			if (region.tileWidth > 0)
				Width = region.tileWidth;
			else
				region.tileWidth = region.width;
			
			if (region.tileHeight > 0)
				Height = region.tileWidth;
			else
				region.tileHeight = region.height;
		}
		
		width = frameWidth = Width;
		height = frameHeight = Height;
		
		animation.destroyAnimations();
		
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
	public function loadRotatedGraphic(Graphic:Dynamic, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false, ?Key:String):FlxSprite
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
		cachedGraphics = FlxG.bitmap.create(Std.int(width) + columns - 1, Std.int(height) + rows - 1, FlxColor.TRANSPARENT, true, key);
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
					cachedGraphics.bitmap.draw(brush, _matrix, null, null, null, AntiAliasing);
					column++;
				}
				midpointY += max;
				row++;
			}
		}
		frameWidth = frameHeight = max;
		width = height = max;
		
		region = new Region(0, 0, max, max, 1, 1);
		region.width = cachedGraphics.bitmap.width;
		region.height = cachedGraphics.bitmap.height;
		
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
		
		animation.createPrerotated();
		return this;
	}
	
	/**
	 * This function creates a flat colored square image dynamically.
	 * @param	Width		The width of the sprite you want to generate.
	 * @param	Height		The height of the sprite you want to generate.
	 * @param	Color		Specifies the color of the generated block (ARGB format).
	 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @param	Key			Optional parameter - specify a string key to identify this graphic in the cache.  Trumps Unique flag.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function makeGraphic(Width:Int, Height:Int, Color:Int = 0xffffffff, Unique:Bool = false, ?Key:String):FlxSprite
	{
		bakedRotation = 0;
		cachedGraphics = FlxG.bitmap.create(Width, Height, Color, Unique, Key);
		region = new Region();
		region.width = Width;
		region.height = Height;
		width = frameWidth = cachedGraphics.bitmap.width;
		height = frameHeight = cachedGraphics.bitmap.height;
		animation.destroyAnimations();
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
	public function loadImageFromTexture(Data:Dynamic, Reverse:Bool = false, Unique:Bool = false, ?FrameName:String):FlxSprite
	{
		bakedRotation = 0;
		
		if (Std.is(Data, CachedGraphics))
		{
			cachedGraphics = cast Data;
			if (cachedGraphics.data == null)
			{
				return null;
			}
		}
		else if (Std.is(Data, TexturePackerData))
		{
			cachedGraphics = FlxG.bitmap.add(Data.assetName, Unique);
			cachedGraphics.data = cast Data;
		}
		else
		{
			return null;
		}
		
		region = new Region();
		region.width = cachedGraphics.bitmap.width;
		region.height = cachedGraphics.bitmap.height;
		
		flipped = (Reverse == true) ? cachedGraphics.bitmap.width : 0;
		
		animation.destroyAnimations();
		updateFrameData();
		resetHelpers();
		
		if (FrameName != null)
		{
			animation.frameName = FrameName;
		}
		
		resetSizeFromFrame();
		setOriginToCenter();
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
		
		animation.frameName = Image;
		
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
	inline public function resetSize():Void
	{
		_flashRect.x = 0;
		_flashRect.y = 0;
		_flashRect.width = frameWidth;
		_flashRect.height = frameHeight;
	}
	
	/**
	 * Resets frame size to frame dimensions
	 */
	inline public function resetFrameSize():Void
	{
		frameWidth = Std.int(frame.sourceSize.x);
		frameHeight = Std.int(frame.sourceSize.y);
		resetSize();
	}
	
	/**
	 * Resets sprite's size back to frame size
	 */
	inline public function resetSizeFromFrame():Void
	{
		width = frameWidth;
		height = frameHeight;
	}
	
	/**
	 * Sets the sprite's origin to its center - useful after adjusting 
	 * <code>scale</code> to make sure rotations work as expected.
	 */
	inline public function setOriginToCenter():Void
	{
		_origin.set(frameWidth * 0.5, frameHeight * 0.5);
	}
	
	/**
	 * Helper function to set the graphic's dimensions by using scale, allowing you to keep the current aspect ratio
	 * should one of the Integers be <= 0. Also updates the sprite's hitbox, offset and origin for you by default!
	 * 
	 * @param	Width			How wide the graphic should be. If <= 0, and a Height is set, the aspect ratio will be kept.
	 * @param	Height			How high the graphic should be. If <= 0, and a Width is set, the aspect ratio will be kept.
	 * @param	UpdateHitbox	Whether or not to update the hitbox dimensions, offset and origin accordingly.
	 */
	public function setGraphicDimensions(Width:Int = 0, Height:Int = 0, UpdateHitbox:Bool = true):Void
	{
		if (Width <= 0 && Height <= 0) {
			return;
		}
		
		var newScaleX:Float = Width / frameWidth;
		var newScaleY:Float = Height / frameHeight;
		scale.set(newScaleX, newScaleY);
		
		if (Width <= 0) {
			scale.x = newScaleY;
		}
		else if (Height <= 0) {
			scale.y = newScaleX;
		}
		
		if (UpdateHitbox) 
		{
			updateHitbox();
		}	
	}
	
	/**
	 * Updates the sprite's hitbox (width, height, offset) according to the current scale. 
	 * Also calls setOriginToCenter(). Called by setGraphicDimensions().
	 */
	public function updateHitbox():Void
	{
		var newWidth:Float = scale.x * frameWidth;
		var newHeight:Float = scale.y * frameHeight;
		
		width = newWidth;
		height = newHeight;
		offset.set( - ((newWidth - frameWidth) * 0.5), - ((newHeight - frameHeight) * 0.5));
		setOriginToCenter();
	}
	
	/**
	 * Resets some important variables for sprite optimization and rendering.
	 */
	private function resetHelpers():Void
	{
		resetSize();
		_flashRect2.x = 0;
		_flashRect2.y = 0;
		_flashRect2.width = cachedGraphics.bitmap.width;
		_flashRect2.height = cachedGraphics.bitmap.height;
		setOriginToCenter();
		
	#if flash
		if ((framePixels == null) || (framePixels.width != frameWidth) || (framePixels.height != frameHeight))
		{
			framePixels = new BitmapData(Std.int(width), Std.int(height));
		}
		framePixels.copyPixels(cachedGraphics.bitmap, _flashRect, _flashPointZero);
		if (useColorTransform) framePixels.colorTransform(_flashRect, _colorTransform);
	#end
		
		_halfWidth = frameWidth * 0.5;
		_halfHeight = frameHeight * 0.5;
	}
	
	override public function update():Void 
	{
		super.update();
		animation.update();
	}
	
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	override public function draw():Void
	{
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
			drawItem = camera.getDrawStackItem(cachedGraphics, isColored, _blendInt, antialiasing);
			#else
			drawItem = camera.getDrawStackItem(cachedGraphics, useAlpha);
			#end
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			_point.x = x - (camera.scroll.x * _scrollFactor.x) - (_offset.x);
			_point.y = y - (camera.scroll.y * _scrollFactor.y) - (_offset.y);
			
			_point.x = (_point.x) + _origin.x;
			_point.y = (_point.y) + _origin.y;
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end
		#else
			_point.x = x - (camera.scroll.x * _scrollFactor.x) - (_offset.x);
			_point.y = y - (camera.scroll.y * _scrollFactor.y) - (_offset.y);
		#end
#if flash
			if (isSimpleRender)
			{
				_flashPoint.x = Math.floor(_point.x);
				_flashPoint.y = Math.floor(_point.y);
				
				camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, null, null, true);
			}
			else
			{
				_matrix.identity();
				_matrix.translate( -_origin.x, -_origin.y);
				_matrix.scale(_scale.x, _scale.y);
				if ((angle != 0) && (bakedRotation <= 0))
				{
					_matrix.rotate(angle * FlxAngle.TO_RAD);
				}
				_matrix.translate(_point.x + _origin.x, _point.y + _origin.y);
				camera.buffer.draw(framePixels, _matrix, null, blend, null, (antialiasing || camera.antialiasing));
			}
#else
			var csx:Float = _facingMult;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = 1;
			
			var x1:Float = (_origin.x - frame.center.x);
			var y1:Float = (_origin.y - frame.center.y);
			
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
				
				var sx:Float = _scale.x * _facingMult;
				
				if (frame.rotated)
				{
					cos = -_sinAngle;
					sin = _cosAngle;
					
					csx = cos * sx;
					ssy = sin * _scale.y;
					ssx = sin * sx;
					csy = cos * _scale.y;
					
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
					ssy = sin * _scale.y;
					ssx = sin * sx;
					csy = cos * _scale.y;
					
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
				x2 = x1 * csx;
			}
			
			currDrawData[currIndex++] = _point.x - x2;
			currDrawData[currIndex++] = _point.y - y2;
			
			currDrawData[currIndex++] = frame.tileID;
			
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
		if (((Brush.angle == 0) || (Brush.bakedRotation > 0)) && (Brush._scale.x == 1) && (Brush._scale.y == 1) && (Brush.blend == null))
		{
			_flashPoint.x = X + region.startX;
			_flashPoint.y = Y + region.startY;
			_flashRect2.width = bitmapData.width;
			_flashRect2.height = bitmapData.height;
			cachedGraphics.bitmap.copyPixels(bitmapData, _flashRect2, _flashPoint, null, null, true);
			_flashRect2.width = cachedGraphics.bitmap.width;
			_flashRect2.height = cachedGraphics.bitmap.height;
			
			resetFrameBitmapDatas();
			
			#if flash
			calcFrame();
			#end
			return;
		}
		
		//Advanced draw
		_matrix.identity();
		_matrix.translate(-Brush._origin.x, -Brush._origin.y);
		_matrix.scale(Brush._scale.x, Brush._scale.y);
		if (Brush.angle != 0)
		{
			_matrix.rotate(Brush.angle * FlxAngle.TO_RAD);
		}
		_matrix.translate(X + region.startX + Brush._origin.x, Y + region.startY + Brush._origin.y);
		var brushBlend:BlendMode = Brush.blend;
		cachedGraphics.bitmap.draw(bitmapData, _matrix, null, brushBlend, null, Brush.antialiasing);
		resetFrameBitmapDatas();
		#if flash
		calcFrame();
		#end
	}
	
	/**
	 * Request (or force) that the sprite update the frame before rendering.
	 * Useful if you are doing procedural generation or other weirdness!
	 * @param	Force	Force the frame to redraw, even if its not flagged as necessary.
	 */
	inline public function drawFrame(Force:Bool = false):Void
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
	 * Helper function that adjusts the offset automatically to center the bounding box within the graphic.
	 * @param	AdjustPosition		Adjusts the actual X and Y position just once to match the offset change. Default is false.
	 */
	public function centerOffsets(AdjustPosition:Bool = false):Void
	{
		_offset.x = (frameWidth - width) * 0.5;
		_offset.y = (frameHeight - height) * 0.5;
		if (AdjustPosition)
		{
			x += _offset.x;
			y += _offset.y;
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
		
		var row:Int = region.startY;
		var column:Int;
		var rows:Int = region.height;
		var columns:Int = region.width;
		cachedGraphics.bitmap.lock();
		while(row < rows)
		{
			column = region.startX;
			while (column < columns)
			{
				if (cachedGraphics.bitmap.getPixel32(column, row) == cast Color)
				{
					cachedGraphics.bitmap.setPixel32(column, row, NewColor);
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
		cachedGraphics.bitmap.unlock();
		resetFrameBitmapDatas();
		return positions;
	}
	
	/**
	 * Set sprite's color transformation with control over color offsets. Works only on flash target
	 * @param	redMultiplier		The value for the red multiplier, in the range from 0 to 1. 
	 * @param	greenMultiplier		The value for the green multiplier, in the range from 0 to 1. 
	 * @param	blueMultiplier		The value for the blue multiplier, in the range from 0 to 1. 
	 * @param	alphaMultiplier		The value for the alpha transparency multiplier, in the range from 0 to 1. 
	 * @param	redOffset			The offset value for the red color channel, in the range from -255 to 255.
	 * @param	greenOffset			The offset value for the green color channel, in the range from -255 to 255. 
	 * @param	blueOffset			The offset for the blue color channel value, in the range from -255 to 255. 
	 * @param	alphaOffset			The offset for alpha transparency channel value, in the range from -255 to 255. 
	 */
	public function setColorTransformation(redMultiplier:Float = 1.0, greenMultiplier:Float = 1.0, blueMultiplier:Float = 1.0, alphaMultiplier:Float = 1.0, redOffset:Float = 0, greenOffset:Float = 0, blueOffset:Float = 0, alphaOffset:Float = 0):Void
	{
		color = FlxColorUtil.getColor24(Std.int(redMultiplier * 255), Std.int(greenMultiplier * 255), Std.int(blueMultiplier * 255));
		alpha = alphaMultiplier;
		
		if (_colorTransform == null)
		{
			_colorTransform = new ColorTransform();
		}
		else
		{
			_colorTransform.redMultiplier = redMultiplier;
			_colorTransform.greenMultiplier = greenMultiplier;
			_colorTransform.blueMultiplier = blueMultiplier;
			_colorTransform.alphaMultiplier = alphaMultiplier;
			_colorTransform.redOffset = redOffset;
			_colorTransform.greenOffset = greenOffset;
			_colorTransform.blueOffset = blueOffset;
			_colorTransform.alphaOffset = alphaOffset;
		}
		
		useColorTransform = ((alpha != 1) || (color != 0xffffff) || (redOffset != 0) || (greenOffset != 0) || (blueOffset != 0) || (alphaOffset != 0));
		dirty = true;
	}
	
	private function updateColorTransform():Void
	{
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
			useColorTransform = true;
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
			
			useColorTransform = false;
		}
		dirty = true;
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
		
		var minX:Float = x - _offset.x - Camera.scroll.x * _scrollFactor.x;
		var minY:Float = y - _offset.y - Camera.scroll.y * _scrollFactor.y;
		var maxX:Float = 0;
		var maxY:Float = 0;
		
		if ((angle == 0 || bakedRotation > 0) && (_scale.x == 1) && (_scale.y == 1))
		{
			maxX = minX + frameWidth;
			maxY = minY + frameHeight;
		}
		else
		{
			var radiusX:Float = _halfWidth;
			var radiusY:Float = _halfHeight;
			
			if (_origin.x == _halfWidth)
			{
				radiusX = Math.abs(_halfWidth * _scale.x);
			}
			else
			{
				var sox:Float = _scale.x * _origin.x;
				var sfw:Float = _scale.x * frameWidth;
				var x1:Float = Math.abs(sox);
				var x2:Float = Math.abs(sfw - sox);
				radiusX = Math.max(x2, x1);
			}
			
			if (_origin.y == _halfHeight)
			{
				radiusY = Math.abs(_halfHeight * _scale.y);
			}
			else
			{
				var soy:Float = _scale.y * _origin.y;
				var sfh:Float = _scale.y * frameHeight;
				var y1:Float = Math.abs(soy);
				var y2:Float = Math.abs(sfh - soy);
				radiusY = Math.max(y2, y1);
			}
			
			var radius:Float = Math.max(radiusX, radiusY);
			radius *= 1.415; // Math.sqrt(2);
			
			minX += _origin.x;
			maxX = minX + radius;
			minX -= radius;
			
			minY += _origin.y;
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
	 * Checks to see if a point in 2D world space overlaps this <code>FlxSprite</code> object.
	 * @param	Point			The point in world space you want to check.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	override public function overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (_scale.x == 1 && _scale.y == 1)
		{
			return super.overlapsPoint(point, InScreenSpace, Camera);
		}
		
		if (!InScreenSpace)
		{
			return (point.x > x - 0.5 * width * (_scale.x - 1)) && (point.x < x + width + 0.5 * width * (_scale.x - 1)) && (point.y > y - 0.5 * height * (_scale.y - 1)) && (point.y < y + height + 0.5 * height * (_scale.y - 1));
		}

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var X:Float = point.x - Camera.scroll.x;
		var Y:Float = point.y - Camera.scroll.y;
		getScreenXY(_point, Camera);
		return (X > _point.x - 0.5 * width * (_scale.x - 1)) && (X < _point.x + width + 0.5 * width * (_scale.x - 1)) && (Y > _point.y - 0.5 * height * (_scale.y - 1)) && (Y < _point.y + height + 0.5 * height * (_scale.y - 1));
	}
	
	/**
	 * Checks to see if a point in 2D world space overlaps this <code>FlxSprite</code> object's current displayed pixels.
	 * This check is ALWAYS made in screen space, and always takes scroll factors into account.
	 * @param	Point		The point in world space you want to check.
	 * @param	Mask		Used in the pixel hit test to determine what counts as solid.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		getScreenXY(_point, Camera);
		_point.x = _point.x - _offset.x;
		_point.y = _point.y - _offset.y;
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
			if (frame != null)
			{
				if ((framePixels == null) || (framePixels.width != frameWidth) || (framePixels.height != frameHeight))
				{
					if (framePixels != null)
						framePixels.dispose();
					
					framePixels = new BitmapData(Std.int(frame.sourceSize.x), Std.int(frame.sourceSize.y));
				}
				
				framePixels.copyPixels(getFlxFrameBitmapData(), _flashRect, _flashPointZero);
			}
			
			if (useColorTransform) 
			{
				framePixels.colorTransform(_flashRect, _colorTransform);
			}
	#if !flash
		}
	#end
		
		dirty = false;
	}
	
	/**
	 * Use this method for creating tileSheet for FlxSprite. Must be called after makeGraphic(), loadGraphic or loadRotatedGraphic().
	 * If you forget to call it then you will not see this FlxSprite on c++ target
	 */
	public function updateFrameData():Void
	{
		if (cachedGraphics == null)
		{
			return;
		}
		
		if (cachedGraphics.data != null && (region.tileWidth == 0 && region.tileHeight == 0))
		{
			framesData = cachedGraphics.tilesheet.getTexturePackerFrames(cachedGraphics.data);
		}
		else
		{
			framesData = cachedGraphics.tilesheet.getSpriteSheetFrames(region, null);
		}
		
		frame = framesData.frames[0];
		frames = framesData.frames.length;
		resetSizeFromFrame();
	}
	
	/**
	 * Retrieves BitmapData of current FlxFrame
	 */
	public inline function getFlxFrameBitmapData():BitmapData
	{
		var frameBmd:BitmapData = null;
		if (frame != null)
		{
			if (facing == FlxObject.LEFT && flipped > 0)
			{
				frameBmd = frame.getHReversedBitmap();
			}
			else
			{
				frameBmd = frame.getBitmap();
			}
		}
		
		return frameBmd;
	}
	
	/**
	 * Helper function for reseting precalculated FlxFrame bitmapdatas.
	 * Useful when _pixels bitmapdata changes (e.g. after stamp(), FlxSpriteUtil.drawLine() and other similar method calls).
	 */
	inline public function resetFrameBitmapDatas():Void
	{
		cachedGraphics.tilesheet.destroyFrameBitmapDatas();
	}
	
	/**
	 * Checks if the Sprite is being rendered in "simple mode" (via copyPixels). True for flash when no angle, bakedRotations, 
	 * scaling or blend modes are used. This enables the sprite to be rendered much faster if true.
	 */
	private function simpleRenderSprite():Bool
	{ 
		#if flash
		return (((angle == 0) || (bakedRotation > 0)) && (_scale.x == 1) && (_scale.y == 1) && (blend == null) && (forceComplexRender == false));
		#else
		return (((angle == 0 && frame.additionalAngle == 0) || (bakedRotation > 0)) && (_scale.x == 1) && (_scale.y == 1));
		#end
	}
	
	/**
	 * PROPERTIES
	 */
	private function get_pixels():BitmapData
	{
		return cachedGraphics.bitmap;
	}
	
	private function set_pixels(Pixels:BitmapData):BitmapData
	{
		var key:String = FlxG.bitmap.getCacheKeyFor(Pixels);
		
		if (key == null)
		{
			key = FlxG.bitmap.getUniqueKey();
			FlxG.bitmap.add(Pixels, false, key);
		}
		
		cachedGraphics = FlxG.bitmap.get(key);
		
		if (region == null)	
		{
			region = new Region();
		}
		
		region.startX = 0;
		region.startY = 0;
		region.tileWidth = 0;
		region.tileHeight = 0;
		region.spacingX = 0;
		region.spacingY = 0;
		region.width = cachedGraphics.bitmap.width;
		region.height = cachedGraphics.bitmap.height;
		
		width = frameWidth = cachedGraphics.bitmap.width;
		height = frameHeight = cachedGraphics.bitmap.height;
		animation.destroyAnimations();
		
		updateFrameData();
		resetHelpers();
		// not sure if i should add this line...
		resetFrameBitmapDatas();
		
		return Pixels;
	}
	
	private function set_frame(Value:FlxFrame):FlxFrame
	{
		frame = Value;
		if (frame != null)
		{
			resetFrameSize();
			dirty = true;
		}
		else if(framesData != null && framesData.frames != null && framesData.frames.length > 0)
		{
			frame = framesData.frames[0];
			dirty = true;
		}
		return frame;
	}
	
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
		updateColorTransform();
		return alpha;
	}
	
	private function set_color(Color:Int):Int
	{
		Color &= 0x00ffffff;
		if (color == Color)
		{
			return Color;
		}
		color = Color;
		updateColorTransform();
		
		#if !flash
		_red = (color >> 16) / 255;
		_green = (color >> 8 & 0xff) / 255;
		_blue = (color & 0xff) / 255;
		isColored = color < 0xffffff;
		#end
		
		return color;
	}
	
	private function get_colorTransform():ColorTransform 
	{
		return _colorTransform;
	}
	
	override private function set_angle(Value:Float):Float
	{
		_angleChanged = (angle != Value) || _angleChanged;
		return super.set_angle(Value);
	}
	
	private function set_origin(Value:FlxPoint):FlxPoint
	{
		_origin = cast Value;
		return origin = Value;
	}
	
	private function set_offset(Value:FlxPoint):FlxPoint
	{
		_offset = cast Value;
		return offset = Value;
	}
	
	private function set_scale(Value:FlxPoint):FlxPoint
	{
		_scale = cast Value;
		return scale = Value;
	}
	
	inline private function get_blend():BlendMode 
	{
		return _blend;
	}
	
	private function set_blend(Value:BlendMode):BlendMode 
	{
		#if !flash
		if (Value != null)
		{
			switch (Value)
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
		#end
		_blend = Value;
		return Value;
	}
}
