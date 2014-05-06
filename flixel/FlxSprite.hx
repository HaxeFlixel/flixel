package flixel;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.animation.FlxAnimationController;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.system.layer.DrawStackItem;
import flixel.system.layer.frames.FlxFrame;
import flixel.system.layer.frames.FlxSpriteFrames;
import flixel.system.layer.frames.FrameType;
import flixel.system.layer.Region;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxColorUtil;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.loaders.CachedGraphics;
import flixel.util.loaders.TexturePackerData;
import flixel.util.loaders.TextureRegion;
import openfl.display.Tilesheet;

@:bitmap("assets/images/logo/default.png")
private class GraphicDefault extends BitmapData {}

/**
 * The main "game object" class, the sprite is a FlxObject
 * with a bunch of graphics options and abilities, like animation and stamping.
 */
class FlxSprite extends FlxObject
{
	/**
	 * Class that handles adding and playing animations on this sprite.
	 */
	public var animation:FlxAnimationController;
	/**
	 * The actual Flash BitmapData object representing the current display state of the sprite.
	 */
	public var framePixels:BitmapData;
	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 */
	public var antialiasing:Bool = false;
	/**
	 * Set this flag to true to force the sprite to update during the draw() call.
	 * NOTE: Rarely if ever necessary, most sprite operations will flip this flag automatically.
	 */
	public var dirty:Bool = true;
	
	#if FLX_RENDER_TILE
	public var isColored:Bool = false;
	#end
	
	/**
	 * Set pixels to any BitmapData object.
	 * Automatically adjust graphic size and render helpers.
	 */
	public var pixels(get, set):BitmapData;
	/**
	 * Link to current FlxFrame from loaded atlas
	 */
	public var frame(default, set):FlxFrame;
	/**
	 * The width of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 */
	public var frameWidth(default, null):Int = 0;
	/**
	 * The height of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 */
	public var frameHeight(default, null):Int = 0;
	/**
	 * The total number of frames in this image.  WARNING: assumes each row in the sprite sheet is full!
	 */
	public var frames(default, null):Int = 0;
	/**
	 * Rendering variables.
	 */
	public var region(default, null):Region;
	public var framesData(default, null):FlxSpriteFrames;
	public var cachedGraphics(default, set):CachedGraphics;
	/**
	 * The minimum angle (out of 360°) for which a new baked rotation exists. Example: 90 means there 
	 * are 4 baked rotations in the spritesheet. 0 if this sprite does not have any baked rotations.
	 */
	public var bakedRotationAngle(default, null):Float = 0;
	/**
	 * Set alpha to a number between 0 and 1 to change the opacity of the sprite.
	 */
	public var alpha(default, set):Float = 1.0;
	/**
	 * Set facing using FlxObject.LEFT, RIGHT, UP, and DOWN to take advantage 
	 * of flipped sprites and/or just track player orientation more easily.
	 */
	public var facing(default, set):Int = FlxObject.RIGHT;
	/**
	 * Whether this sprite is flipped on the X axis
	 */
	public var flipX(default, set):Bool = false;
	/**
	 * Whether this sprite is flipped on the Y axis
	 */
	public var flipY(default, set):Bool = false;
	 
	/**
	 * WARNING: The origin of the sprite will default to its center. If you change this, 
	 * the visuals and the collisions will likely be pretty out-of-sync if you do any rotation.
	 */
	public var origin(default, null):FlxPoint;
	/**
	 * Controls the position of the sprite's hitbox. Likely needs to be adjusted after
	 * changing a sprite's width, height or scale.
	 */
	public var offset(default, null):FlxPoint;
	/**
	 * Change the size of your sprite's graphic. NOTE: The hitbox is not automatically adjusted, use updateHitbox for that
	 * (or setGraphicSize(). WARNING: When using blitting (flash), scaling sprites decreases rendering performance by a factor of about x10!
	 */
	public var scale(default, null):FlxPoint;
	/**
	 * Blending modes, just like Photoshop or whatever, e.g. "multiply", "screen", etc.
	 */
	public var blend(default, set):BlendMode;

	/**
	 * Tints the whole sprite to a color (0xRRGGBB format) - similar to OpenGL vertex colors. You can use
	 * 0xAARRGGBB colors, but the alpha value will simply be ignored. To change the opacity use alpha. 
	 */
	public var color(default, set):Int = 0xffffff;
	
	public var colorTransform(default, null):ColorTransform;
	
	/**
	 * Whether or not to use a colorTransform set via setColorTransform.
	 */
	public var useColorTransform(default, null):Bool = false;
	
	#if FLX_RENDER_TILE
	private var _red:Float = 1.0;
	private var _green:Float = 1.0;
	private var _blue:Float = 1.0;
	private var _facingHorizontalMult:Int = 1;
	private var _facingVerticalMult:Int = 1;
	private var _blendInt:Int = 0;
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
	 * Maps FlxObject direction constants to axis flips
	 */
	private var _facingFlip:Map<Int, {x:Bool, y:Bool}> = new Map<Int, {x:Bool, y:Bool}>();
	
	/**
	 * Creates a FlxSprite at a specified position with a specified one-frame graphic. 
	 * If none is provided, a 16x16 image of the HaxeFlixel logo is used.
	 * 
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:Dynamic)
	{
		super(X, Y);
		
		if (SimpleGraphic != null)
		{
			loadGraphic(SimpleGraphic);
		}
	}
	
	override private function initVars():Void 
	{
		super.initVars();
		
		animation = new FlxAnimationController(this);
		
		_flashPoint = new Point();
		_flashRect = new Rectangle();
		_flashRect2 = new Rectangle();
		_flashPointZero = new Point();
		offset = FlxPoint.get();
		origin = FlxPoint.get();
		scale = FlxPoint.get(1, 1);
		_matrix = new Matrix();
	}
	
	/**
	 * WARNING: This will remove this object entirely. Use kill() if you want to disable it temporarily only and reset() it later to revive it.
	 * Override this function to null out variables manually or call destroy() on class members if necessary. Don't forget to call super.destroy()!
	 */
	override public function destroy():Void
	{
		super.destroy();
		
		animation = FlxDestroyUtil.destroy(animation);
		
		offset = FlxDestroyUtil.put(offset);
		origin = FlxDestroyUtil.put(origin);
		scale = FlxDestroyUtil.put(scale);
		
		framePixels = FlxDestroyUtil.dispose(framePixels);
		
		_flashPoint = null;
		_flashRect = null;
		_flashRect2 = null;
		_flashPointZero = null;
		_matrix = null;
		colorTransform = null;
		blend = null;
		frame = null;
		
		framesData = null;
		cachedGraphics = null;
		region = null;
	}
	
	public function clone(?NewSprite:FlxSprite):FlxSprite
	{
		if (NewSprite == null)
		{
			NewSprite = new FlxSprite();
		}
		
		return NewSprite.loadGraphicFromSprite(this);
	}
	
	/**
	 * Load graphic from another FlxSprite and copy its tileSheet data. 
	 * This method can useful for non-flash targets (and is used by the FlxTrail effect).
	 * 
	 * @param	Sprite	The FlxSprite from which you want to load graphic data
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGraphicFromSprite(Sprite:FlxSprite):FlxSprite
	{
		if (!exists)
		{
			FlxG.log.warn("Warning, trying to clone " + Type.getClassName(Type.getClass(this)) + " object that doesn't exist.");
		}
		
		region = Sprite.region.clone();
		bakedRotationAngle = Sprite.bakedRotationAngle;
		cachedGraphics = Sprite.cachedGraphics;
		
		width = frameWidth = Sprite.frameWidth;
		height = frameHeight = Sprite.frameHeight;
		if (bakedRotationAngle > 0)
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
	 * 
	 * @param	Graphic		The image you want to use.
	 * @param	Animated	Whether the Graphic parameter is a single sprite or a row of sprites.
	 * @param	Width		Optional, specify the width of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
	 * @param	Height		Optional, specify the height of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
	 * @param	Unique		Optional, whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @param	Key			Optional, set this parameter if you're loading BitmapData.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGraphic(Graphic:Dynamic, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite
	{
		bakedRotationAngle = 0;
		cachedGraphics = FlxG.bitmap.add(Graphic, Unique, Key);
		
		if (Width == 0)
		{
			Width = (Animated == true) ? cachedGraphics.bitmap.height : cachedGraphics.bitmap.width;
			Width = (Width > cachedGraphics.bitmap.width) ? cachedGraphics.bitmap.width : Width;
		}
		
		if (Height == 0)
		{
			Height = (Animated == true) ? Width : cachedGraphics.bitmap.height;
			Height = (Height > cachedGraphics.bitmap.height) ? cachedGraphics.bitmap.height : Height;
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
	 * 
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
		bakedRotationAngle = 360 / Rotations;
		
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
					bakedAngle += bakedRotationAngle;
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
		
		#if FLX_RENDER_TILE
		antialiasing = AntiAliasing;
		#end
		
		updateFrameData();
		
		if (AutoBuffer)
		{
			width = brush.width;
			height = brush.height;
			centerOffsets();
		}
		
		animation.createPrerotated();
		resetHelpers();
		return this;
	}
	
	/**
	 * Loads TexturePacker atlas.
	 * 
	 * @param	Data		Atlas data holding links to json-data and atlas image
	 * @param	Unique		Optional, whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @param	FrameName	Default frame to show. If null then will be used first available frame.
	 * @return This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGraphicFromTexture(Data:Dynamic, Unique:Bool = false, ?FrameName:String):FlxSprite
	{
		bakedRotationAngle = 0;
		
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
		
		animation.destroyAnimations();
		updateFrameData();
		resetHelpers();
		
		if (FrameName != null)
		{
			animation.frameName = FrameName;
		}
		
		resetSizeFromFrame();
		centerOrigin();
		return this;
	}
	
	/**
	 * Creates a pre-rotated sprite sheet from provided image in atlas.
	 * This can make a huge difference in graphical performance on flash target!
	 * 
	 * @param	Data			Atlas data holding links to json-data and atlas image
	 * @param	Image			The image from atlas you want to rotate and stamp.
	 * @param	Rotations		The number of rotation frames the final sprite should have.  For small sprites this can be quite a large number (360 even) without any problems.
	 * @param	AntiAliasing	Whether to use high quality rotations when creating the graphic.  Default is false.
	 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners.
	 * @return This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadRotatedGraphicFromTexture(Data:Dynamic, Image:String, Rotations:Int = 16, AntiAliasing:Bool = false, AutoBuffer:Bool = false):FlxSprite
	{
		var temp = loadGraphicFromTexture(Data);
		
		if (temp == null)
		{
			return null;
		}
		
		animation.frameName = Image;
		
		#if FLX_RENDER_TILE
		antialiasing = AntiAliasing;
		#else
		var key:String = Data.assetName + ":" + Image;
		var frameBitmapData:BitmapData = getFlxFrameBitmapData();
		if (FlxG.bitmap.get(key) == null)
		{
			frameBitmapData = frameBitmapData.clone();
		}
		loadRotatedGraphic(frameBitmapData, Rotations, -1, AntiAliasing, AutoBuffer, key);
		#end
		
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
	public function makeGraphic(Width:Int, Height:Int, Color:Int = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite
	{
		bakedRotationAngle = 0;
		cachedGraphics = FlxG.bitmap.create(Width, Height, Color, Unique, Key);
		region = new Region();
		region.width = Width;
		region.height = Height;
		width = region.tileWidth = frameWidth = cachedGraphics.bitmap.width;
		height = region.tileHeight = frameHeight = cachedGraphics.bitmap.height;
		animation.destroyAnimations();
		updateFrameData();
		resetHelpers();
		return this;
	}
	
	/**
	 * Resets _flashRect variable used for frame bitmapData calculation
	 */
	public inline function resetSize():Void
	{
		_flashRect.x = 0;
		_flashRect.y = 0;
		_flashRect.width = frameWidth;
		_flashRect.height = frameHeight;
	}
	
	/**
	 * Resets frame size to frame dimensions
	 */
	public inline function resetFrameSize():Void
	{
		frameWidth = Std.int(frame.sourceSize.x);
		frameHeight = Std.int(frame.sourceSize.y);
		resetSize();
	}
	
	/**
	 * Resets sprite's size back to frame size
	 */
	public inline function resetSizeFromFrame():Void
	{
		width = frameWidth;
		height = frameHeight;
	}
	
	/**
	 * Helper function to set the graphic's dimensions by using scale, allowing you to keep the current aspect ratio
	 * should one of the Integers be <= 0. It might make sense to call updateHitbox() afterwards!
	 * 
	 * @param   Width    How wide the graphic should be. If <= 0, and a Height is set, the aspect ratio will be kept.
	 * @param   Height   How high the graphic should be. If <= 0, and a Width is set, the aspect ratio will be kept.
	 */
	public function setGraphicSize(Width:Int = 0, Height:Int = 0):Void
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
	}
	
	/**
	 * Updates the sprite's hitbox (width, height, offset) according to the current scale. 
	 * Also calls setOriginToCenter(). Called by setGraphicSize().
	 */
	public function updateHitbox():Void
	{
		var newWidth:Float = scale.x * frameWidth;
		var newHeight:Float = scale.y * frameHeight;
		
		width = newWidth;
		height = newHeight;
		offset.set( - ((newWidth - frameWidth) * 0.5), - ((newHeight - frameHeight) * 0.5));
		centerOrigin();
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
		centerOrigin();
		
	#if FLX_RENDER_BLIT
		dirty = true;
		getFlxFrameBitmapData();
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
		if (alpha == 0)
		{
			return;
		}
		
		if (dirty)	//rarely 
		{
			calcFrame();
		}
		
	#if FLX_RENDER_TILE
		var drawItem:DrawStackItem;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		
		var cos:Float;
		var sin:Float;
		
		var ox:Float = origin.x;
		if (_facingHorizontalMult != 1)
		{
			ox = frameWidth - ox;
		}
		var oy:Float = origin.y;
		if (_facingVerticalMult != 1)
		{
			oy = frameHeight - oy;
		}
	#end
		
		var simpleRender:Bool = isSimpleRender();
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
			{
				continue;
			}
			
		#if FLX_RENDER_TILE
			drawItem = camera.getDrawStackItem(cachedGraphics, isColored, _blendInt, antialiasing);
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x);
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y);
			
			_point.x = (_point.x) + origin.x;
			_point.y = (_point.y) + origin.y;
		#else
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x);
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y);
		#end
			
#if FLX_RENDER_BLIT
			if (simpleRender)
			{
				// Floor point to prevent rounding issues
				_flashPoint.x = Math.ffloor(_point.x);
				_flashPoint.y = Math.ffloor(_point.y);
				
				camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, null, null, true);
			}
			else
			{
				_matrix.identity();
				_matrix.translate( -origin.x, -origin.y);
				_matrix.scale(scale.x, scale.y);
				
				if ((angle != 0) && (bakedRotationAngle <= 0))
				{
					_matrix.rotate(angle * FlxAngle.TO_RAD);
				}
				
				_point.x += origin.x;
				_point.y += origin.y;
				
				if (pixelPerfectRender)
				{
					_point.floor();
				}
				
				_matrix.translate(_point.x, _point.y);
				camera.buffer.draw(framePixels, _matrix, null, blend, null, (antialiasing || camera.antialiasing));
			}
#else
			var csx:Float = _facingHorizontalMult;
			var csy:Float = _facingVerticalMult;
			var ssy:Float = 0;
			var ssx:Float = 0;
			
			var x1:Float = (ox - frame.center.x);
			var y1:Float = (oy - frame.center.y);
			
			var x2:Float = x1;
			var y2:Float = y1;
			
			// transformation matrix coefficients
			var a:Float = csx;
			var b:Float = ssx;
			var c:Float = ssy;
			var d:Float = csy;
			
			if (!simpleRender)
			{
				if (_angleChanged && (bakedRotationAngle <= 0))
				{
					var radians:Float = -angle * FlxAngle.TO_RAD;
					_sinAngle = Math.sin(radians);
					_cosAngle = Math.cos(radians);
					_angleChanged = false;
				}
				
				var sx:Float = scale.x * _facingHorizontalMult;
				var sy:Float = scale.y * _facingVerticalMult;
				
				if (frame.type == FrameType.ROTATED) // todo: handle different additional angles (since different packers adds different values, e.g. -90 or +90)
				{
					cos = -_sinAngle;
					sin = _cosAngle;
					
					csx = cos * sx;
					ssy = sin * sy;
					ssx = sin * sx;
					csy = cos * sy;
					
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
					ssy = sin * sy;
					ssx = sin * sx;
					csy = cos * sy;
					
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
				y2 = y1 * csy;
			}
			
			_point.x -= x2;
			_point.y -= y2;
			
			if (pixelPerfectRender)
			{
				_point.floor();
			}
			
			currDrawData[currIndex++] = _point.x;
			currDrawData[currIndex++] = _point.y;
			
			currDrawData[currIndex++] = frame.tileID;
			
			currDrawData[currIndex++] = a;
			currDrawData[currIndex++] = -b;
			currDrawData[currIndex++] = c;
			currDrawData[currIndex++] = d;
			
			if (isColored)
			{
				currDrawData[currIndex++] = _red; 
				currDrawData[currIndex++] = _green;
				currDrawData[currIndex++] = _blue;
			}
			currDrawData[currIndex++] = (alpha * camera.alpha);
			drawItem.position = currIndex;
#end
			#if !FLX_NO_DEBUG
			FlxBasic._VISIBLECOUNT++;
			#end
		}
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}
	
	/**
	 * This function draws or stamps one FlxSprite onto another.
	 * This function is NOT intended to replace draw()!
	 * @param	Brush		The image you want to use as a brush or stamp or pen or whatever.
	 * @param	X			The X coordinate of the brush's top left corner on this sprite.
	 * @param	Y			They Y coordinate of the brush's top left corner on this sprite.
	 */
	public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void
	{
		Brush.drawFrame();
		var bitmapData:BitmapData = Brush.framePixels;
		
		//Simple draw
		if (((Brush.angle == 0) || (Brush.bakedRotationAngle > 0)) && (Brush.scale.x == 1) && (Brush.scale.y == 1) && (Brush.blend == null))
		{
			_flashPoint.x = X + region.startX;
			_flashPoint.y = Y + region.startY;
			_flashRect2.width = bitmapData.width;
			_flashRect2.height = bitmapData.height;
			cachedGraphics.bitmap.copyPixels(bitmapData, _flashRect2, _flashPoint, null, null, true);
			_flashRect2.width = cachedGraphics.bitmap.width;
			_flashRect2.height = cachedGraphics.bitmap.height;
			
			resetFrameBitmapDatas();
			
			#if FLX_RENDER_BLIT
			dirty = true;
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
		_matrix.translate(X + region.startX + Brush.origin.x, Y + region.startY + Brush.origin.y);
		var brushBlend:BlendMode = Brush.blend;
		cachedGraphics.bitmap.draw(bitmapData, _matrix, null, brushBlend, null, Brush.antialiasing);
		resetFrameBitmapDatas();
		#if FLX_RENDER_BLIT
		dirty = true;
		calcFrame();
		#end
	}
	
	/**
	 * Request (or force) that the sprite update the frame before rendering.
	 * Useful if you are doing procedural generation or other weirdness!
	 * @param	Force	Force the frame to redraw, even if its not flagged as necessary.
	 */
	public inline function drawFrame(Force:Bool = false):Void
	{
		#if FLX_RENDER_BLIT
		if (Force || dirty)
		{
			dirty = true;
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
		offset.x = (frameWidth - width) * 0.5;
		offset.y = (frameHeight - height) * 0.5;
		if (AdjustPosition)
		{
			x += offset.x;
			y += offset.y;
		}
	}

	/**
	 * Sets the sprite's origin to its center - useful after adjusting 
	 * scale to make sure rotations work as expected.
	 */
	public inline function centerOrigin():Void
	{
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
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
		while (row < rows)
		{
			column = region.startX;
			while (column < columns)
			{
				if (cachedGraphics.bitmap.getPixel32(column, row) == cast Color)
				{
					cachedGraphics.bitmap.setPixel32(column, row, NewColor);
					if (FetchPositions)
					{
						positions.push(FlxPoint.get(column, row));
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
	 * Set sprite's color transformation with control over color offsets.
	 * 
	 * @param	redMultiplier		The value for the red multiplier, in the range from 0 to 1. 
	 * @param	greenMultiplier		The value for the green multiplier, in the range from 0 to 1. 
	 * @param	blueMultiplier		The value for the blue multiplier, in the range from 0 to 1. 
	 * @param	alphaMultiplier		The value for the alpha transparency multiplier, in the range from 0 to 1. 
	 * @param	redOffset			The offset value for the red color channel, in the range from -255 to 255.
	 * @param	greenOffset			The offset value for the green color channel, in the range from -255 to 255. 
	 * @param	blueOffset			The offset for the blue color channel value, in the range from -255 to 255. 
	 * @param	alphaOffset			The offset for alpha transparency channel value, in the range from -255 to 255. 
	 */
	public function setColorTransform(redMultiplier:Float = 1.0, greenMultiplier:Float = 1.0, blueMultiplier:Float = 1.0, alphaMultiplier:Float = 1.0, redOffset:Float = 0, greenOffset:Float = 0, blueOffset:Float = 0, alphaOffset:Float = 0):Void
	{
		color = FlxColorUtil.getColor24(Std.int(redMultiplier * 255), Std.int(greenMultiplier * 255), Std.int(blueMultiplier * 255));
		alpha = alphaMultiplier;
		
		if (colorTransform == null)
		{
			colorTransform = new ColorTransform();
		}
		else
		{
			colorTransform.redMultiplier = redMultiplier;
			colorTransform.greenMultiplier = greenMultiplier;
			colorTransform.blueMultiplier = blueMultiplier;
			colorTransform.alphaMultiplier = alphaMultiplier;
			colorTransform.redOffset = redOffset;
			colorTransform.greenOffset = greenOffset;
			colorTransform.blueOffset = blueOffset;
			colorTransform.alphaOffset = alphaOffset;
		}
		
		useColorTransform = ((alpha != 1) || (color != 0xffffff) || (redOffset != 0) || (greenOffset != 0) || (blueOffset != 0) || (alphaOffset != 0));
		dirty = true;
	}
	
	private function updateColorTransform():Void
	{
		if ((alpha != 1) || (color != 0xffffff))
		{
			if (colorTransform == null)
			{
				colorTransform = new ColorTransform((color >> 16) / 255, (color >> 8 & 0xff) / 255, (color & 0xff) / 255, alpha);
			}
			else
			{
				colorTransform.redMultiplier = (color >> 16) / 255;
				colorTransform.greenMultiplier = (color >> 8 & 0xff) / 255;
				colorTransform.blueMultiplier = (color & 0xff) / 255;
				colorTransform.alphaMultiplier = alpha;
			}
			useColorTransform = true;
		}
		else
		{
			if (colorTransform != null)
			{
				colorTransform.redMultiplier = 1;
				colorTransform.greenMultiplier = 1;
				colorTransform.blueMultiplier = 1;
				colorTransform.alphaMultiplier = 1;
			}
			
			useColorTransform = false;
		}
		dirty = true;
	}
	
	/**
	 * Checks to see if a point in 2D world space overlaps this FlxSprite object's current displayed pixels.
	 * This check is ALWAYS made in screen space, and always takes scroll factors into account.
	 * 
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
		_point.x = _point.x - offset.x;
		_point.y = _point.y - offset.y;
		_flashPoint.x = (point.x - Camera.scroll.x) - _point.x;
		_flashPoint.y = (point.y - Camera.scroll.y) - _point.y;
		
		point.putWeak();
		
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
	}
	
	/**
	 * Internal function to update the current animation frame.
	 * 
	 * @param	RunOnCpp	Whether the frame should also be recalculated if we're on a non-flash target
	 */
	private function calcFrame(RunOnCpp:Bool = false):Void
	{
		if (cachedGraphics == null)	
		{
			loadGraphic(GraphicDefault);
		}
		
		#if FLX_RENDER_TILE
		if (!RunOnCpp)
		{
			return;
		}
		#end
		
		getFlxFrameBitmapData();
	}
	
	/**
	 * Use this method for creating tileSheet for FlxSprite. Must be called after makeGraphic(), loadGraphic() or loadRotatedGraphic().
	 * If you forget to call it then you will not see this FlxSprite on c++ target
	 */
	public function updateFrameData():Void
	{
		if (cachedGraphics == null)
		{
			return;
		}
		
		if ((cachedGraphics.data != null) && (region.tileWidth == 0 && region.tileHeight == 0))
		{
			framesData = cachedGraphics.tilesheet.getTexturePackerFrames(cachedGraphics.data);
		}
		else
		{
			framesData = cachedGraphics.tilesheet.getSpriteSheetFrames(region, null);
		}
		
		frames = framesData.frames.length;
		animation.frameIndex = 0;
		frame = framesData.frames[0];
		
		resetSizeFromFrame();
	}
	
	/**
	 * Retrieves BitmapData of current FlxFrame
	 */
	public inline function getFlxFrameBitmapData():BitmapData
	{
		if (frame != null && dirty)
		{
			if (!flipX && !flipY && frame.type == FrameType.REGULAR)
			{
				framePixels = frame.paintOnBitmap(framePixels);
			}
			else
			{
				var frameBmd:BitmapData = null;
				
				if (flipX && flipY)
				{
					frameBmd = frame.getHVReversedBitmap();
				}
				else if (flipX)
				{
					frameBmd = frame.getHReversedBitmap();
				}
				else if (flipY)
				{
					frameBmd = frame.getVReversedBitmap();
				}
				else
				{
					frameBmd = frame.getBitmap();
				}
				
				if ((framePixels == null) || (framePixels.width != frameWidth) || (framePixels.height != frameHeight))
				{
					if (framePixels != null)
						framePixels.dispose();
						
					framePixels = new BitmapData(Std.int(frame.sourceSize.x), Std.int(frame.sourceSize.y));
				}
				
				framePixels.copyPixels(frameBmd, _flashRect, _flashPointZero);
			}
			
			if (useColorTransform) 
			{
				framePixels.colorTransform(_flashRect, colorTransform);
			}
			
			dirty = false;
			
		}
		
		return framePixels;
	}
	
	/**
	 * Retrieve the midpoint of this sprite's graphic in world coordinates.
	 * 
	 * @param	point	Allows you to pass in an existing FlxPoint object if you're so inclined. Otherwise a new one is created.
	 * @return	A FlxPoint object containing the midpoint of this sprite's graphic in world coordinates.
	 */
	public function getGraphicMidpoint(?point:FlxPoint):FlxPoint
	{
		if (point == null)
		{
			point = FlxPoint.get();
		}
		return point.set(x + frameWidth * 0.5, y + frameHeight * 0.5);
	}
	
	/**
	 * Helper function for reseting precalculated FlxFrame bitmapdatas.
	 * Useful when _pixels bitmapdata changes (e.g. after stamp(), FlxSpriteUtil.drawLine() and other similar method calls).
	 */
	public inline function resetFrameBitmapDatas():Void
	{
		cachedGraphics.tilesheet.destroyFrameBitmapDatas();
	}
	
	/**
	 * Check and see if this object is currently on screen. Differs from FlxObject's implementation
	 * in that it takes the actual graphic into account, not just the hitbox or bounding box or whatever.
	 * 
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether the object is on screen or not.
	 */
	override public function isOnScreen(?Camera:FlxCamera):Bool
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		var minX:Float = x - offset.x - Camera.scroll.x * scrollFactor.x;
		var minY:Float = y - offset.y - Camera.scroll.y * scrollFactor.y;
		var maxX:Float = 0;
		var maxY:Float = 0;
		
		if ((angle == 0 || bakedRotationAngle > 0) && (scale.x == 1) && (scale.y == 1))
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
			radius *= FlxMath.SQUARE_ROOT_OF_TWO;
			
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
	 * Checks if the Sprite is being rendered in "simple mode" (via copyPixels). True for flash when no angle, bakedRotations, 
	 * scaling or blend modes are used. This enables the sprite to be rendered much faster if true.
	 */
	public function isSimpleRender():Bool
	{ 
		#if FLX_RENDER_BLIT
		return (((angle == 0) || (bakedRotationAngle > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null) && pixelPerfectRender);
		#else
		return (((angle == 0 && frame.additionalAngle == 0) || (bakedRotationAngle > 0)) && (scale.x == 1) && (scale.y == 1));
		#end
	}
	
	/**
	 * Set how a sprite flips when facing in a particular direction.
	 * 
	 * @param	Direction Use constants from FlxObject: LEFT, RIGHT, UP, and DOWN.
	 * 			These may be combined with the bitwise OR operator.
	 * 			E.g. To make a sprite flip horizontally when it is facing both UP and LEFT,
	 * 			use setFacingFlip(FlxObject.LEFT | FlxObject.UP, true, false);
	 * @param	FlipX Whether to flip the sprite on the X axis
	 * @param	FlipY Whether to flip the sprite on the Y axis
	 */
	public inline function setFacingFlip(Direction:Int, FlipX:Bool, FlipY:Bool):Void
	{
		_facingFlip.set(Direction, {x: FlipX, y: FlipY});
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
			cachedGraphics = FlxG.bitmap.add(Pixels, false, key);
			cachedGraphics.destroyOnNoUse = true;
		}
		else
		{
			cachedGraphics = FlxG.bitmap.get(key);
		}
		
		if (region == null)	
		{
			region = new Region();
		}
		
		region.startX = 0;
		region.startY = 0;
		region.tileWidth = region.width = cachedGraphics.bitmap.width;
		region.tileHeight = region.height = cachedGraphics.bitmap.height;
		region.spacingX = 0;
		region.spacingY = 0;
		
		width = frameWidth = cachedGraphics.bitmap.width;
		height = frameHeight = cachedGraphics.bitmap.height;
		animation.destroyAnimations();
		
		updateFrameData();
		resetHelpers();
		
		// not sure if i should add this line...
		// WARNING: this is causing unnecessary string allocations (Map.get) - use arrays, or figure out a way to not call this every frame.
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
		else if (framesData != null && framesData.frames != null && framesData.frames.length > 0)
		{
			frame = framesData.frames[0];
			dirty = true;
		}
		return frame;
	}
	
	private function set_facing(Direction:Int):Int
	{		
		var flip = _facingFlip.get(Direction);
		if (flip != null)
		{
			flipX = flip.x;
			flipY = flip.y;
		}
		
		return facing = Direction;
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
		
		#if FLX_RENDER_TILE
		_red = (color >> 16) / 255;
		_green = (color >> 8 & 0xff) / 255;
		_blue = (color & 0xff) / 255;
		isColored = color < 0xffffff;
		#end
		
		return color;
	}
	
	override private function set_angle(Value:Float):Float
	{
		_angleChanged = (angle != Value) || _angleChanged;
		return super.set_angle(Value);
	}
	
	private function set_blend(Value:BlendMode):BlendMode 
	{
		#if FLX_RENDER_TILE
		if (Value != null)
		{
			switch (Value)
			{
				case BlendMode.ADD:
					_blendInt = Tilesheet.TILE_BLEND_ADD;
				#if !flash
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
		
		return blend = Value;
	}
	
	/**
	 * Internal function for setting cachedGraphics property for this object. 
	 * It changes cachedGraphics' useCount also for better memory tracking.
	 */
	private function set_cachedGraphics(Value:CachedGraphics):CachedGraphics
	{
		var oldCached:CachedGraphics = cachedGraphics;
		
		if ((cachedGraphics != Value) && (Value != null))
		{
			Value.useCount++;
		}
		
		if ((oldCached != null) && (oldCached != Value))
		{
			oldCached.useCount--;
		}
		
		return cachedGraphics = Value;
	}
	
	private function set_flipX(Value:Bool):Bool
	{
		#if FLX_RENDER_TILE
		_facingHorizontalMult = Value ? -1 : 1;
		#end
		if (flipX != Value)
		{
			dirty = true;
		}
		return flipX = Value;
	}
	
	private function set_flipY(Value:Bool):Bool
	{
		#if FLX_RENDER_TILE
		_facingVerticalMult = Value ? -1 : 1;
		#end
		if (flipY != Value)
		{
			dirty = true;
		}
		return flipY = Value;
	}
}
