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
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxClippedFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxImageFrame;
import flixel.graphics.frames.FlxTileFrames;
import flixel.graphics.tile.FlxDrawTilesItem;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.Tilesheet;

@:bitmap("assets/images/logo/default.png")
private class GraphicDefault extends BitmapData {}

// TODO: add updateSizeFromFrame bool which will tell sprite whether to update it's size to frame's size (when frame setter is called) or not (useful for sprites with adjusted hitbox)
// And don't forget about sprites with clipped frames: what i should do with their size in this case?

// TODO: add option to "center origin" or create special subclass for it

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
	 * WARNING: can be null in FLX_RENDER_TILE mode unless you call getFlxFrameBitmapData() beforehand.
	 */
	public var framePixels:BitmapData;
	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 */
	public var antialiasing(default, set):Bool = false;
	/**
	 * Set this flag to true to force the sprite to update during the draw() call.
	 * NOTE: Rarely if ever necessary, most sprite operations will flip this flag automatically.
	 */
	public var dirty:Bool = true;
	
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
	public var numFrames(default, null):Int = 0;
	/**
	 * Rendering variables.
	 */
	public var frames(default, set):FlxFramesCollection;
	public var graphic(default, set):FlxGraphic;
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
	public var color(default, set):FlxColor = 0xffffff;
	
	public var colorTransform(default, null):ColorTransform;
	
	/**
	 * Whether or not to use a colorTransform set via setColorTransform.
	 */
	public var useColorTransform(default, null):Bool = false;
	
	/**
	 * Clipping rectangle for this sprite.
	 * Changing it's properties doesn't change graphic of the sprite, so you should reapply clipping rect on sprite again.
	 * Set clipRect to null to discard graphic frame clipping 
	 */
	public var clipRect(default, set):FlxRect;
	
	private var _clipRect:FlxRect;
	
	#if FLX_RENDER_TILE
	private var _facingHorizontalMult:Int = 1;
	private var _facingVerticalMult:Int = 1;
	private var _blendInt:Int = 0;
	private var isColored:Bool = false;
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
	private var _matrix:FlxMatrix;
	
	/**
	 * Rendering helper variable
	 */
	private var _halfSize:FlxPoint;
	
	/**
	 * These vars are being used for rendering in some of FlxSprite subclasses (FlxTileblock, FlxBar, 
	 * and FlxBitmapText) and for checks if the sprite is in camera's view.
	 */
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
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
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
		_halfSize = FlxPoint.get();
		_matrix = new FlxMatrix();
		colorTransform = new ColorTransform();
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
		_halfSize = FlxDestroyUtil.put(_halfSize);
		
		framePixels = FlxDestroyUtil.dispose(framePixels);
		
		_flashPoint = null;
		_flashRect = null;
		_flashRect2 = null;
		_flashPointZero = null;
		_matrix = null;
		colorTransform = null;
		blend = null;
		frame = null;
		
		frames = null;
		graphic = null;
	}
	
	public function clone():FlxSprite
	{
		return (new FlxSprite()).loadGraphicFromSprite(this);
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
		frames = Sprite.frames;
		bakedRotationAngle = Sprite.bakedRotationAngle;
		if (bakedRotationAngle > 0)
		{
			width = Sprite.width;
			height = Sprite.height;
			centerOffsets();
		}
		antialiasing = Sprite.antialiasing;
		animation.copyFrom(Sprite.animation);
		graphicLoaded();
		clipRect = Sprite.clipRect;
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
	public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite
	{
		var graph:FlxGraphic = FlxG.bitmap.add(Graphic, Unique, Key);
		
		if (Width == 0)
		{
			Width = (Animated == true) ? graph.height : graph.width;
			Width = (Width > graph.width) ? graph.width : Width;
		}
		
		if (Height == 0)
		{
			Height = (Animated == true) ? Width : graph.height;
			Height = (Height > graph.height) ? graph.height : Height;
		}
		
		if (Animated)
		{
			frames = FlxTileFrames.fromGraphic(graph, new FlxPoint(Width, Height));
		}
		else
		{
			frames = graph.imageFrame;
		}
		
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
	 * @param	Key				Optional, set this parameter if you're loading BitmapData.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadRotatedGraphic(Graphic:FlxGraphicAsset, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false, ?Key:String):FlxSprite
	{
		var brushGraphic:FlxGraphic = FlxG.bitmap.add(Graphic, false, Key);
		var brush:BitmapData = brushGraphic.bitmap;
		var key:String = brushGraphic.key;
		
		if (Frame >= 0)
		{
			// we assume that source graphic has one row frame animation with equal width and height
			var brushSize:Int = brush.height;
			var framesNum:Int = Std.int(brush.width / brushSize);
			Frame = (framesNum > Frame) ? Frame : (Frame % framesNum);
			key += ":" + Frame;
			
			var full:BitmapData = brush;
			brush = new BitmapData(brushSize, brushSize, true, FlxColor.TRANSPARENT);
			_flashRect.setTo(Frame * brushSize, 0, brushSize, brushSize);
			brush.copyPixels(full, _flashRect, _flashPointZero);
		}
		
		key = key + ":" + Rotations + ":" + AutoBuffer;
		
		//Generate a new sheet if necessary, then fix up the width and height
		var tempGraph:FlxGraphic = FlxG.bitmap.get(key);
		if (tempGraph == null)
		{
			var bitmap:BitmapData = FlxBitmapDataUtil.generateRotations(brush, Rotations, AntiAliasing, AutoBuffer);
			tempGraph = FlxGraphic.fromBitmapData(bitmap, false, key);
		}
		
		var max:Int = (brush.height > brush.width) ? brush.height : brush.width;
		max = (AutoBuffer) ? Std.int(max * 1.5) : max;
		
		frames = FlxTileFrames.fromGraphic(tempGraph, new FlxPoint(max, max));
		
		if (AutoBuffer)
		{
			width = brush.width;
			height = brush.height;
			centerOffsets();
		}
		
		bakedRotationAngle = 360 / Rotations;
		animation.createPrerotated();
		return this;
	}
	
	/**
	 * Helper method which makes it possible to use FlxFrames as graphic source for sprite's loadRotatedGraphic() method 
	 * (since it accepts only FlxGraphic, BitmapData and String types).
	 * 
	 * @param	frame			Frame to load into this sprite.
	 * @param	rotations		The number of rotation frames the final sprite should have. For small sprites this can be quite a large number (360 even) without any problems.
	 * @param	antiAliasing	Whether to use high quality rotations when creating the graphic. Default is false.
	 * @param	autoBuffer		Whether to automatically increase the image size to accomodate rotated corners.  Default is false.  Will create frames that are 150% larger on each axis than the original frame or graphic.
	 * @return	this FlxSprite with loaded rotated graphic in it.
	 */
	public function loadRotatedFrame(Frame:FlxFrame, Rotations:Int = 16, AntiAliasing:Bool = false, AutoBuffer:Bool = false):FlxSprite
	{
		var key:String = Frame.parent.key;
		if (Frame.name != null)
		{
			key += ":" + Frame.name;
		}
		else
		{
			key += ":" + Frame.frame.toString();
		}
		
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic == null)
		{
			graphic = FlxGraphic.fromBitmapData(Frame.getBitmap().clone(), false, key);
		}
		
		return loadRotatedGraphic(graphic, Rotations, -1, AntiAliasing, AutoBuffer);
	}
	
	/**
	 * This function creates a flat colored square image dynamically.
	 * 
	 * @param	Width		The width of the sprite you want to generate.
	 * @param	Height		The height of the sprite you want to generate.
	 * @param	Color		Specifies the color of the generated block (ARGB format).
	 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @param	Key			Optional parameter - specify a string key to identify this graphic in the cache.  Trumps Unique flag.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function makeGraphic(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite
	{
		var graph:FlxGraphic = FlxG.bitmap.create(Width, Height, Color, Unique, Key);
		frames = graph.imageFrame;
		return this;
	}
	
	/**
	 * Called whenever a new graphic is loaded for this sprite
	 * - after loadGraphic(), makeGraphic() etc.
	 */
	public function graphicLoaded():Void {}
	
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
		_halfSize.set(0.5 * frameWidth, 0.5 * frameHeight);
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
		if (Width <= 0 && Height <= 0)
		{
			return;
		}
		
		var newScaleX:Float = Width / frameWidth;
		var newScaleY:Float = Height / frameHeight;
		scale.set(newScaleX, newScaleY);
		
		if (Width <= 0)
		{
			scale.x = newScaleY;
		}
		else if (Height <= 0)
		{
			scale.y = newScaleX;
		}	
	}
	
	/**
	 * Updates the sprite's hitbox (width, height, offset) according to the current scale. 
	 * Also calls setOriginToCenter(). Called by setGraphicSize().
	 */
	public function updateHitbox():Void
	{
		width = Math.abs(scale.x) * frameWidth;
		height = Math.abs(scale.y) * frameHeight;
		offset.set( -0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		centerOrigin();
	}
	
	/**
	 * Resets some important variables for sprite optimization and rendering.
	 */
	private function resetHelpers():Void
	{
		resetFrameSize();
		resetSizeFromFrame();
		_flashRect2.x = 0;
		_flashRect2.y = 0;
		
		if (graphic != null)
		{
			_flashRect2.width = graphic.width;
			_flashRect2.height = graphic.height;
		}
		
		centerOrigin();
		
	#if FLX_RENDER_BLIT
		dirty = true;
		getFlxFrameBitmapData();
	#end
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		updateAnimation(elapsed);
	}
	
	/**
	 * This is separated out so it can be easily overriden
	 */
	private function updateAnimation(elapsed:Float):Void
	{
		animation.update(elapsed);
	}
	
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	override public function draw():Void
	{
		if (frame == null)
		{
			#if !FLX_NO_DEBUG
			loadGraphic(FlxGraphic.fromClass(GraphicDefault));
			#else
			return;
			#end
		}
		
		if (alpha == 0 || frame.type == FlxFrameType.EMPTY)
		{
			return;
		}
		
		if (dirty)	//rarely 
		{
			calcFrame();
		}
		
	#if FLX_RENDER_TILE
		var drawItem:FlxDrawTilesItem;
		
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
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
			{
				continue;
			}
			
			getScreenPosition(_point, camera).subtractPoint(offset);
			
#if FLX_RENDER_BLIT
			if (isSimpleRender(camera))
			{
				_point.floor().copyToFlash(_flashPoint);
				camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, null, null, true);
			}
			else
			{
				_matrix.identity();
				_matrix.translate(-origin.x, -origin.y);
				_matrix.scale(scale.x, scale.y);
				
				if ((angle != 0) && (bakedRotationAngle <= 0))
				{
					_matrix.rotate(angle * FlxAngle.TO_RAD);
				}
				
				_point.addPoint(origin).floor();
				
				_matrix.translate(_point.x, _point.y);
				camera.buffer.draw(framePixels, _matrix, null, blend, null, (antialiasing || camera.antialiasing));
			}
#else
			drawItem = camera.getDrawTilesItem(frame.parent, isColored, _blendInt, antialiasing);
			
			_matrix.identity();
			
			if (frame.angle != FlxFrameAngle.ANGLE_0)
			{
				// handle rotated frames
				frame.prepareFrameMatrix(_matrix);
			}
			
			var x1:Float = (ox - frame.center.x);
			var y1:Float = (oy - frame.center.y);
			_matrix.translate(x1, y1);
			
			var sx:Float = scale.x * _facingHorizontalMult;
			var sy:Float = scale.y * _facingVerticalMult;
			_matrix.scale(sx * camera.totalScaleX, sy * camera.totalScaleY);
			
			// rotate matrix if sprite's graphic isn't prerotated
			if (!isSimpleRender(camera))
			{
				if (_angleChanged && (bakedRotationAngle <= 0))
				{
					var radians:Float = angle * FlxAngle.TO_RAD;
					_sinAngle = Math.sin(radians);
					_cosAngle = Math.cos(radians);
					_angleChanged = false;
				}
				
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}
			
			_point.addPoint(origin);
			
			_point.x *= camera.totalScaleX;
			_point.y *= camera.totalScaleY;
			
			if (isPixelPerfectRender(camera))
			{
				_point.floor();
			}
			
			_point.subtract(_matrix.tx, _matrix.ty);
			
			setDrawData(drawItem, camera, _matrix);
#end
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			drawDebug();
		}
		#end
	}
	
	#if FLX_RENDER_TILE
	private inline function setDrawData(drawItem:FlxDrawTilesItem, camera:FlxCamera, matrix:Matrix, ?tileID:Float)
	{
		drawItem.setDrawData(_point, (tileID == null) ? frame.tileID : tileID, matrix, isColored, color, alpha * camera.alpha);
	}
	#end
	
	/**
	 * Stamps / draws another FlxSprite onto this FlxSprite. 
	 * This function is NOT intended to replace draw()!
	 * 
	 * @param	Brush	The sprite you want to use as a brush or stamp or pen or whatever.
	 * @param	X		The X coordinate of the brush's top left corner on this sprite.
	 * @param	Y		They Y coordinate of the brush's top left corner on this sprite.
	 */
	public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void
	{
		if (this.graphic == null || Brush.graphic == null)
		{
			throw "Cannot stamp to or from a FlxSprite with no graphics.";
		}
		
		var bitmapData:BitmapData = Brush.getFlxFrameBitmapData();
		
		if (isSimpleRenderBlit()) // simple render
		{
			_flashPoint.x = X + frame.frame.x;
			_flashPoint.y = Y + frame.frame.y;
			_flashRect2.width = bitmapData.width;
			_flashRect2.height = bitmapData.height;
			graphic.bitmap.copyPixels(bitmapData, _flashRect2, _flashPoint, null, null, true);
			_flashRect2.width = graphic.bitmap.width;
			_flashRect2.height = graphic.bitmap.height;
			resetFrameBitmaps();
			#if FLX_RENDER_BLIT
			dirty = true;
			calcFrame();
			#end
		}
		else // complex render
		{
			_matrix.identity();
			_matrix.translate(-Brush.origin.x, -Brush.origin.y);
			_matrix.scale(Brush.scale.x, Brush.scale.y);
			if (Brush.angle != 0)
			{
				_matrix.rotate(Brush.angle * FlxAngle.TO_RAD);
			}
			_matrix.translate(X + frame.frame.x + Brush.origin.x, Y + frame.frame.y + Brush.origin.y);
			var brushBlend:BlendMode = Brush.blend;
			graphic.bitmap.draw(bitmapData, _matrix, null, brushBlend, null, Brush.antialiasing);
			resetFrameBitmaps();
			#if FLX_RENDER_BLIT
			dirty = true;
			calcFrame();
			#end
		}
	}
	
	/**
	 * Request (or force) that the sprite update the frame before rendering.
	 * Useful if you are doing procedural generation or other weirdness!
	 * 
	 * @param	Force	Force the frame to redraw, even if its not flagged as necessary.
	 */
	public function drawFrame(Force:Bool = false):Void
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
	 * 
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
	 * Replaces all pixels with specified Color with NewColor pixels. 
	 * WARNING: very expensive (especially on big graphics) as it iterates over every single pixel.
	 * 
	 * @param	Color				Color to replace
	 * @param	NewColor			New color
	 * @param	FetchPositions		Whether we need to store positions of pixels which colors were replaced
	 * @return	Array replaced pixels positions
	 */
	public function replaceColor(Color:FlxColor, NewColor:FlxColor, FetchPositions:Bool = false):Array<FlxPoint>
	{
		var positions:Array<FlxPoint> = FlxBitmapDataUtil.replaceColor(graphic.bitmap, Color, NewColor, FetchPositions);
		if (positions != null)
		{
			dirty = true;
			resetFrameBitmaps();
		}
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
		color = FlxColor.fromRGBFloat(redMultiplier, greenMultiplier, blueMultiplier).to24Bit();
		alpha = alphaMultiplier;
		
		colorTransform.redMultiplier = redMultiplier;
		colorTransform.greenMultiplier = greenMultiplier;
		colorTransform.blueMultiplier = blueMultiplier;
		colorTransform.alphaMultiplier = alphaMultiplier;
		colorTransform.redOffset = redOffset;
		colorTransform.greenOffset = greenOffset;
		colorTransform.blueOffset = blueOffset;
		colorTransform.alphaOffset = alphaOffset;
		
		useColorTransform = ((alpha != 1) || (color != 0xffffff) || (redOffset != 0) || (greenOffset != 0) || (blueOffset != 0) || (alphaOffset != 0));
		dirty = true;
	}
	
	private function updateColorTransform():Void
	{
		if ((alpha != 1) || (color != 0xffffff))
		{
			colorTransform.redMultiplier = color.redFloat;
			colorTransform.greenMultiplier = color.greenFloat;
			colorTransform.blueMultiplier = color.blueFloat;
			colorTransform.alphaMultiplier = alpha;
			useColorTransform = true;
		}
		else
		{
			colorTransform.redMultiplier = 1;
			colorTransform.greenMultiplier = 1;
			colorTransform.blueMultiplier = 1;
			colorTransform.alphaMultiplier = 1;
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
	 * @param	Camera		Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		getScreenPosition(_point, Camera);
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
			var pixelColor:FlxColor = frameData.getPixel32(Std.int(_flashPoint.x), Std.int(_flashPoint.y));
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
		if (frame == null)	
		{
			loadGraphic(FlxGraphic.fromClass(GraphicDefault));
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
	 * Retrieves BitmapData of current FlxFrame. Updates framePixels.
	 */
	public inline function getFlxFrameBitmapData():BitmapData
	{
		if (frame != null && dirty)
		{
			if (!flipX && !flipY && frame.type == FlxFrameType.REGULAR)
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
					FlxDestroyUtil.dispose(framePixels);
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
	public inline function resetFrameBitmaps():Void
	{
		graphic.resetFrameBitmaps();
	}
	
	/**
	 * Check and see if this object is currently on screen. Differs from FlxObject's implementation
	 * in that it takes the actual graphic into account, not just the hitbox or bounding box or whatever.
	 * 
	 * @param	Camera		Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
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
			var radiusX:Float = _halfSize.x;
			var radiusY:Float = _halfSize.y;
			
			if (origin.x == radiusX)
			{
				radiusX = Math.abs(radiusX * scale.x);
			}
			else
			{
				var sox:Float = scale.x * origin.x;
				var sfw:Float = scale.x * frameWidth;
				var x1:Float = Math.abs(sox);
				var x2:Float = Math.abs(sfw - sox);
				radiusX = Math.max(x2, x1);
			}
			
			if (origin.y == radiusY)
			{
				radiusY = Math.abs(radiusY * scale.y);
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
	 * Returns the result of isSimpleRenderBlit() if FLX_RENDER_BLIT is 
	 * defined or isSimpleRenderTile() if FLX_RENDER_TILE is defined.
	 */
	public function isSimpleRender(?camera:FlxCamera):Bool
	{ 
		#if FLX_RENDER_BLIT
		return isSimpleRenderBlit(camera);
		#else
		return isSimpleRenderTile();
		#end
	}
	
	/**
	 * Determines the function used for rendering in blitting: copyPixels() for simple sprites, draw() for complex ones. 
	 * Sprites are considered simple when they have an angle of 0, a scale of 1, don't use blend and pixelPerfectRender is true.
	 * 
	 * @param	camera	If a camera is passed its pixelPerfectRender flag is taken into account
	 */
	public function isSimpleRenderBlit(?camera:FlxCamera):Bool
	{
		var result:Bool = (angle == 0 || bakedRotationAngle > 0)
			&& scale.x == 1 && scale.y == 1 && blend == null;
		result = result && (camera != null ? isPixelPerfectRender(camera) : pixelPerfectRender);
		return result;
	}
	
	/**
	 * Determines whether or not additional matrix calculations are required to render sprites via drawTiles().
	 * Sprites are considered simple when they have an angle of 0 and a scale of 1.
	 */
	public function isSimpleRenderTile():Bool
	{
		return ((angle == 0 && frame.angle == FlxFrameAngle.ANGLE_0) || (bakedRotationAngle > 0));
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
	 * Sets frames and allows you to save animations in sprite's animation controller
	 * 
	 * @param	Frames				Frames collection to set for this sprite
	 * @param	saveAnimations		Whether to save animations in animation controller or not
	 * @return	This sprite with loaded frames
	 */
	public function setFrames(Frames:FlxFramesCollection, saveAnimations:Bool = true):FlxSprite
	{
		if (saveAnimations)
		{
			var anim:FlxAnimationController = animation;
			animation = null;
			this.frames = Frames;
			frame = frames.frames[anim.frameIndex];
			animation = anim;
		}
		else
		{
			this.frames = Frames;
		}
		
		return this;
	}
	
	private function get_pixels():BitmapData
	{
		#if !FLX_NO_DEBUG
		if (graphic == null)
		{
			throw "FlxSprite object doesn't have any graphic! Please load graphic or call makeGraphic() on the sprite before trying to retrieve its graphic.";
		}
		#end
		return graphic.bitmap;
	}
	
	private function set_pixels(Pixels:BitmapData):BitmapData
	{
		var key:String = FlxG.bitmap.findKeyForBitmap(Pixels);
		
		if (key == null)
		{
			key = FlxG.bitmap.getUniqueKey();
			graphic = FlxG.bitmap.add(Pixels, false, key);
		}
		else
		{
			graphic = FlxG.bitmap.get(key);
		}
		
		frames = graphic.imageFrame;
		
		// not sure if i should add this line...
		// WARNING: this is causing unnecessary string allocations (Map.get) - use arrays, or figure out a way to not call this every frame.
		resetFrameBitmaps();
		
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
		else if (frames != null && frames.frames != null && numFrames > 0)
		{
			frame = frames.frames[0];
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
		alpha = FlxMath.bound(Alpha, 0, 1);
		updateColorTransform();
		return alpha;
	}
	
	private function set_color(Color:FlxColor):Int
	{
		if (color == Color)
		{
			return Color;
		}
		color = Color;
		updateColorTransform();
		
		#if FLX_RENDER_TILE
		isColored = color.to24Bit() != 0xffffff;
		#end
		
		return color;
	}
	
	override private function set_angle(Value:Float):Float
	{
		var newAngle = (angle != Value);
		var ret = super.set_angle(Value);
		if (newAngle)
		{
			_angleChanged = true;
			animation.update(0);
		}
		return ret;
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
	 * Internal function for setting graphic property for this object. 
	 * It changes graphics' useCount also for better memory tracking.
	 */
	private function set_graphic(Value:FlxGraphic):FlxGraphic
	{
		var oldGraphic:FlxGraphic = graphic;
		
		if ((graphic != Value) && (Value != null))
		{
			Value.useCount++;
		}
		
		if ((oldGraphic != null) && (oldGraphic != Value))
		{
			oldGraphic.useCount--;
		}
		
		return graphic = Value;
	}
	
	private function get_clipRect():FlxRect
	{
		return _clipRect;
	}
	
	private function set_clipRect(rect:FlxRect):FlxRect
	{
		if (frames != null)
		{
			var anim:FlxAnimationController = animation;
			animation = null;
			
			if (rect != null)
			{
				frames = FlxClippedFrames.clip(frames, rect);
				_clipRect = rect.copyTo(new FlxRect());
			}
			else
			{
				if (frames.type == FlxFrameCollectionType.CLIPPED)
				{
					frames = cast(frames, FlxClippedFrames).original;
				}
				
				_clipRect = null;
			}
			
			frame = frames.frames[anim.frameIndex];
			animation = anim;
		}
		
		return rect;
	}
	
	/**
	 * Frames setter. Used by "loadGraphic" methods, but you can load generated frames yourself 
	 * (this should be even faster since engine doesn't need to do bunch of additional stuff).
	 * 
	 * @param	Frames	frames to load into this sprite.
	 * @return	loaded frames.
	 */
	private function set_frames(Frames:FlxFramesCollection):FlxFramesCollection
	{
		if (animation != null)
		{
			animation.destroyAnimations();
		}
		
		if (Frames != null)
		{
			graphic = Frames.parent;
			frames = Frames;
			frame = frames.getByIndex(0);
			numFrames = frames.numFrames;
			resetHelpers();
			bakedRotationAngle = 0;
			animation.frameIndex = 0;
			graphicLoaded();
		}
		else
		{
			frames = null;
			frame = null;
			graphic = null;
		}
		
		_clipRect = null;
		return Frames;
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
	
	private function set_antialiasing(value:Bool):Bool
	{
		return antialiasing = value;
	}
}

interface IFlxSprite extends IFlxBasic 
{
	public var x(default, set):Float;
	public var y(default, set):Float;
	public var alpha(default, set):Float;
	public var angle(default, set):Float;
	public var facing(default, set):Int;
	public var moves(default, set):Bool;
	public var immovable(default, set):Bool;
	
	public var offset(default, null):FlxPoint;
	public var origin(default, null):FlxPoint;
	public var scale(default, null):FlxPoint;
	public var velocity(default, null):FlxPoint;
	public var maxVelocity(default, null):FlxPoint;
	public var acceleration(default, null):FlxPoint;
	public var drag(default, null):FlxPoint;
	public var scrollFactor(default, null):FlxPoint;

	public function reset(X:Float, Y:Float):Void;
	public function setPosition(X:Float = 0, Y:Float = 0):Void;
}
