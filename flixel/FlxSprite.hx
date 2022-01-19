package flixel;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic.IFlxBasic;
import flixel.animation.FlxAnimationController;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;

using flixel.util.FlxColorTransformUtil;

// TODO: add updateSizeFromFrame bool which will tell sprite whether to update it's size to frame's size (when frame setter is called) or not (useful for sprites with adjusted hitbox)
// And don't forget about sprites with clipped frames: what i should do with their size in this case?
// TODO: add option to "center origin" or create special subclass for it

/**
 * The main "game object" class, the sprite is a `FlxObject`
 * with a bunch of graphics options and abilities, like animation and stamping.
 *
 * Load an image onto a sprite using the `loadGraphic*()` functions,
 * or create a base monochromatic rectangle using `makeGraphic()`.
 * The image `BitmapData` is stored in the `pixels` field.
 */
class FlxSprite extends FlxObject
{
	/**
	 * Class that handles adding and playing animations on this sprite.
	 */
	public var animation:FlxAnimationController;

	// TODO: maybe convert this var to property...

	/**
	 * The current display state of the sprite including current animation frame,
	 * tint, flip etc... may be `null` unless `useFramePixels` is `true`.
	 */
	public var framePixels:BitmapData;

	/**
	 * Always `true` on `FlxG.renderBlit`. On `FlxG.renderTile` it determines whether
	 * `framePixels` is used and defaults to `false` for performance reasons.
	 */
	public var useFramePixels(default, set):Bool = true;

	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 */
	public var antialiasing(default, set):Bool = false;

	/**
	 * Set this flag to true to force the sprite to update during the `draw()` call.
	 * NOTE: Rarely if ever necessary, most sprite operations will flip this flag automatically.
	 */
	public var dirty:Bool = true;

	/**
	 * This sprite's graphic / `BitmapData` object.
	 * Automatically adjusts graphic size and render helpers if changed.
	 */
	public var pixels(get, set):BitmapData;

	/**
	 * Link to current `FlxFrame` from loaded atlas
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
	 * The total number of frames in this image.
	 * WARNING: assumes each row in the sprite sheet is full!
	 */
	public var numFrames(default, null):Int = 0;

	/**
	 * Rendering variables.
	 */
	public var frames(default, set):FlxFramesCollection;

	public var graphic(default, set):FlxGraphic;

	/**
	 * The minimum angle (out of 360°) for which a new baked rotation exists. Example: `90` means there
	 * are 4 baked rotations in the spritesheet. `0` if this sprite does not have any baked rotations.
	 */
	public var bakedRotationAngle(default, null):Float = 0;

	/**
	 * Set alpha to a number between `0` and `1` to change the opacity of the sprite.
	 */
	public var alpha(default, set):Float = 1.0;

	/**
	 * Can be set to `LEFT`, `RIGHT`, `UP`, and `DOWN` to take advantage
	 * of flipped sprites and/or just track player orientation more easily.
	 */
	public var facing(default, set):FlxDirectionFlags = RIGHT;

	/**
	 * Whether this sprite is flipped on the X axis.
	 */
	public var flipX(default, set):Bool = false;

	/**
	 * Whether this sprite is flipped on the Y axis.
	 */
	public var flipY(default, set):Bool = false;

	/**
	 * WARNING: The `origin` of the sprite will default to its center. If you change this,
	 * the visuals and the collisions will likely be pretty out-of-sync if you do any rotation.
	 */
	public var origin(default, null):FlxPoint;

	/**
	 * Controls the position of the sprite's hitbox. Likely needs to be adjusted after
	 * changing a sprite's `width`, `height` or `scale`.
	 */
	public var offset(default, null):FlxPoint;

	/**
	 * Change the size of your sprite's graphic.
	 * NOTE: The hitbox is not automatically adjusted, use `updateHitbox()` for that (or `setGraphicSize()`).
	 * WARNING: With `FlxG.renderBlit`, scaling sprites decreases rendering performance by a factor of about x10!
	 */
	public var scale(default, null):FlxPoint;

	/**
	 * Blending modes, just like Photoshop or whatever, e.g. "multiply", "screen", etc.
	 */
	public var blend(default, set):BlendMode;

	/**
	 * Tints the whole sprite to a color (`0xRRGGBB` format) - similar to OpenGL vertex colors. You can use
	 * `0xAARRGGBB` colors, but the alpha value will simply be ignored. To change the opacity use `alpha`.
	 */
	public var color(default, set):FlxColor = 0xffffff;

	public var colorTransform(default, null):ColorTransform;

	/**
	 * Whether or not to use a `ColorTransform` set via `setColorTransform()`.
	 */
	public var useColorTransform(default, null):Bool = false;

	/**
	 * Clipping rectangle for this sprite.
	 * Changing the rect's properties directly doesn't have any effect,
	 * reassign the property to update it (`sprite.clipRect = sprite.clipRect;`).
	 * Set to `null` to discard graphic frame clipping.
	 */
	public var clipRect(default, set):FlxRect;

	/**
	 * GLSL shader for this sprite. Only works with OpenFL Next or WebGL.
	 * Avoid changing it frequently as this is a costly operation.
	 * @since 4.1.0
	 */
	#if openfl_legacy
	@:noCompletion
	#end
	public var shader:FlxShader;

	/**
	 * The actual frame used for sprite rendering
	 */
	@:noCompletion
	var _frame:FlxFrame;

	/**
	 * Graphic of `_frame`. Used in tile render mode, when `useFramePixels` is `true`.
	 */
	@:noCompletion
	var _frameGraphic:FlxGraphic;

	@:noCompletion
	var _facingHorizontalMult:Int = 1;
	@:noCompletion
	var _facingVerticalMult:Int = 1;

	/**
	 * Internal, reused frequently during drawing and animating.
	 */
	@:noCompletion
	var _flashPoint:Point;

	/**
	 * Internal, reused frequently during drawing and animating.
	 */
	@:noCompletion
	var _flashRect:Rectangle;

	/**
	 * Internal, reused frequently during drawing and animating.
	 */
	@:noCompletion
	var _flashRect2:Rectangle;

	/**
	 * Internal, reused frequently during drawing and animating. Always contains `(0,0)`.
	 */
	@:noCompletion
	var _flashPointZero:Point;

	/**
	 * Internal, helps with animation, caching and drawing.
	 */
	@:noCompletion
	var _matrix:FlxMatrix;

	/**
	 * Rendering helper variable
	 */
	@:noCompletion
	var _halfSize:FlxPoint;

	/**
	 * These vars are being used for rendering in some of `FlxSprite` subclasses (`FlxTileblock`, `FlxBar`,
	 * and `FlxBitmapText`) and for checks if the sprite is in camera's view.
	 */
	@:noCompletion
	var _sinAngle:Float = 0;

	@:noCompletion
	var _cosAngle:Float = 1;
	@:noCompletion
	var _angleChanged:Bool = true;

	/**
	 * Maps `FlxDirectionFlags` values to axis flips
	 */
	@:noCompletion
	var _facingFlip:Map<FlxDirectionFlags, {x:Bool, y:Bool}> = new Map<FlxDirectionFlags, {x:Bool, y:Bool}>();

	/**
	 * Creates a `FlxSprite` at a specified position with a specified one-frame graphic.
	 * If none is provided, a 16x16 image of the HaxeFlixel logo is used.
	 *
	 * @param   X               The initial X position of the sprite.
	 * @param   Y               The initial Y position of the sprite.
	 * @param   SimpleGraphic   The graphic you want to display
	 *                          (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y);

		useFramePixels = FlxG.renderBlit;
		if (SimpleGraphic != null)
			loadGraphic(SimpleGraphic);
	}

	@:noCompletion
	override function initVars():Void
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
	 * **WARNING:** A destroyed `FlxBasic` can't be used anymore.
	 * It may even cause crashes if it is still part of a group or state.
	 * You may want to use `kill()` instead if you want to disable the object temporarily only and `revive()` it later.
	 *
	 * This function is usually not called manually (Flixel calls it automatically during state switches for all `add()`ed objects).
	 *
	 * Override this function to `null` out variables manually or call `destroy()` on class members if necessary.
	 * Don't forget to call `super.destroy()`!
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

		frames = null;
		graphic = null;
		_frame = FlxDestroyUtil.destroy(_frame);
		_frameGraphic = FlxDestroyUtil.destroy(_frameGraphic);

		shader = null;
	}

	public function clone():FlxSprite
	{
		return (new FlxSprite()).loadGraphicFromSprite(this);
	}

	/**
	 * Load graphic from another `FlxSprite` and copy its tile sheet data.
	 * This method can useful for non-flash targets.
	 *
	 * @param   Sprite   The `FlxSprite` from which you want to load graphic data.
	 * @return  This `FlxSprite` instance (nice for chaining stuff together, if you're into that).
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
	 * HaxeFlixel's graphic caching system keeps track of loaded image data.
	 * When you load an identical copy of a previously used image, by default
	 * HaxeFlixel copies the previous reference onto the `pixels` field instead
	 * of creating another copy of the image data, to save memory.
	 *
	 * @param   Graphic    The image you want to use.
	 * @param   Animated   Whether the `Graphic` parameter is a single sprite or a row / grid of sprites.
	 * @param   Width      Specify the width of your sprite
	 *                     (helps figure out what to do with non-square sprites or sprite sheets).
	 * @param   Height     Specify the height of your sprite
	 *                     (helps figure out what to do with non-square sprites or sprite sheets).
	 * @param   Unique     Whether the graphic should be a unique instance in the graphics cache.
	 *                     Set this to `true` if you want to modify the `pixels` field without changing
	 *                     the `pixels` of other sprites with the same `BitmapData`.
	 * @param   Key        Set this parameter if you're loading `BitmapData`.
	 * @return  This `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite
	{
		var graph:FlxGraphic = FlxG.bitmap.add(Graphic, Unique, Key);
		if (graph == null)
			return this;

		if (Width == 0)
		{
			Width = Animated ? graph.height : graph.width;
			Width = (Width > graph.width) ? graph.width : Width;
		}

		if (Height == 0)
		{
			Height = Animated ? Width : graph.height;
			Height = (Height > graph.height) ? graph.height : Height;
		}

		if (Animated)
			frames = FlxTileFrames.fromGraphic(graph, FlxPoint.get(Width, Height));
		else
			frames = graph.imageFrame;

		return this;
	}

	/**
	 * Create a pre-rotated sprite sheet from a simple sprite.
	 * This can make a huge difference in graphical performance on blitting targets!
	 *
	 * @param   Graphic        The image you want to rotate and stamp.
	 * @param   Rotations      The number of rotation frames the final sprite should have.
	 *                         For small sprites this can be quite a large number (`360` even) without any problems.
	 * @param   Frame          If the `Graphic` has a single row of square animation frames on it,
	 *                         you can specify which of the frames you want to use here.
	 *                         Default is `-1`, or "use whole graphic."
	 * @param   AntiAliasing   Whether to use high quality rotations when creating the graphic. Default is `false`.
	 * @param   AutoBuffer     Whether to automatically increase the image size to accommodate rotated corners.
	 *                         Will create frames that are 150% larger on each axis than the original frame or graphic.
	 * @param   Key            Optional, set this parameter if you're loading `BitmapData`.
	 * @return  This `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadRotatedGraphic(Graphic:FlxGraphicAsset, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false,
			?Key:String):FlxSprite
	{
		var brushGraphic:FlxGraphic = FlxG.bitmap.add(Graphic, false, Key);
		if (brushGraphic == null)
			return this;

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

		key += ":" + Rotations + ":" + AutoBuffer;

		// Generate a new sheet if necessary, then fix up the width and height
		var tempGraph:FlxGraphic = FlxG.bitmap.get(key);
		if (tempGraph == null)
		{
			var bitmap:BitmapData = FlxBitmapDataUtil.generateRotations(brush, Rotations, AntiAliasing, AutoBuffer);
			tempGraph = FlxGraphic.fromBitmapData(bitmap, false, key);
		}

		var max:Int = (brush.height > brush.width) ? brush.height : brush.width;
		max = AutoBuffer ? Std.int(max * 1.5) : max;

		frames = FlxTileFrames.fromGraphic(tempGraph, FlxPoint.get(max, max));

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
	 * Helper method which allows using `FlxFrame` as graphic source for sprite's `loadRotatedGraphic()` method.
	 *
	 * @param   frame          Frame to load into this sprite.
	 * @param   rotations      The number of rotation frames the final sprite should have.
	 *                         For small sprites this can be quite a large number (`360` even) without any problems.
	 * @param   antiAliasing   Whether to use high quality rotations when creating the graphic. Default is `false`.
	 * @param   autoBuffer     Whether to automatically increase the image size to accommodate rotated corners.
	 *                         Will create frames that are 150% larger on each axis than the original frame or graphic.
	 * @return  this FlxSprite with loaded rotated graphic in it.
	 */
	public function loadRotatedFrame(Frame:FlxFrame, Rotations:Int = 16, AntiAliasing:Bool = false, AutoBuffer:Bool = false):FlxSprite
	{
		var key:String = Frame.parent.key;
		if (Frame.name != null)
			key += ":" + Frame.name;
		else
			key += ":" + Frame.frame.toString();

		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic == null)
			graphic = FlxGraphic.fromBitmapData(Frame.paint(), false, key);

		return loadRotatedGraphic(graphic, Rotations, -1, AntiAliasing, AutoBuffer);
	}

	/**
	 * This function creates a flat colored rectangular image dynamically.
	 *
	 * HaxeFlixel's graphic caching system keeps track of loaded image data.
	 * When you make an identical copy of a previously used image, by default
	 * HaxeFlixel copies the previous reference onto the pixels field instead
	 * of creating another copy of the image data, to save memory.
	 *
	 * @param   Width    The width of the sprite you want to generate.
	 * @param   Height   The height of the sprite you want to generate.
	 * @param   Color    Specifies the color of the generated block (ARGB format).
	 * @param   Unique   Whether the graphic should be a unique instance in the graphics cache. Default is `false`.
	 *                   Set this to `true` if you want to modify the `pixels` field without changing the
	 *                   `pixels` of other sprites with the same `BitmapData`.
	 * @param   Key      An optional `String` key to identify this graphic in the cache.
	 *                   If `null`, the key is determined by `Width`, `Height` and `Color`.
	 *                   If `Unique` is `true` and a graphic with this `Key` already exists,
	 *                   it is used as a prefix to find a new unique name like `"Key3"`.
	 * @return  This `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function makeGraphic(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite
	{
		var graph:FlxGraphic = FlxG.bitmap.create(Width, Height, Color, Unique, Key);
		frames = graph.imageFrame;
		return this;
	}

	/**
	 * Called whenever a new graphic is loaded for this sprite (after `loadGraphic()`, `makeGraphic()` etc).
	 */
	public function graphicLoaded():Void {}

	/**
	 * Resets some internal variables used for frame `BitmapData` calculation.
	 */
	public inline function resetSize():Void
	{
		_flashRect.x = 0;
		_flashRect.y = 0;
		_flashRect.width = frameWidth;
		_flashRect.height = frameHeight;
	}

	/**
	 * Resets frame size to frame dimensions.
	 */
	public inline function resetFrameSize():Void
	{
		if (frame != null)
		{
			frameWidth = Std.int(frame.sourceSize.x);
			frameHeight = Std.int(frame.sourceSize.y);
		}
		_halfSize.set(0.5 * frameWidth, 0.5 * frameHeight);
		resetSize();
	}

	/**
	 * Resets sprite's size back to frame size.
	 */
	public inline function resetSizeFromFrame():Void
	{
		width = frameWidth;
		height = frameHeight;
	}

	/**
	 * Helper method just for convenience, so you don't need to type
	 * `sprite.frame = sprite.frame;`
	 * You may need this method in tile render mode,
	 * when you want sprite to use its original graphic, not the graphic generated from its `framePixels`.
	 */
	public inline function resetFrame():Void
	{
		frame = this.frame;
	}

	/**
	 * Helper function to set the graphic's dimensions by using `scale`, allowing you to keep the current aspect ratio
	 * should one of the Integers be `<= 0`. It might make sense to call `updateHitbox()` afterwards!
	 *
	 * @param   Width    How wide the graphic should be. If `<= 0`, and `Height` is set, the aspect ratio will be kept.
	 * @param   Height   How high the graphic should be. If `<= 0`, and `Width` is set, the aspect ratio will be kept.
	 */
	public function setGraphicSize(Width:Int = 0, Height:Int = 0):Void
	{
		if (Width <= 0 && Height <= 0)
			return;

		var newScaleX:Float = Width / frameWidth;
		var newScaleY:Float = Height / frameHeight;
		scale.set(newScaleX, newScaleY);

		if (Width <= 0)
			scale.x = newScaleY;
		else if (Height <= 0)
			scale.y = newScaleX;
	}

	/**
	 * Updates the sprite's hitbox (`width`, `height`, `offset`) according to the current `scale`.
	 * Also calls `centerOrigin()`.
	 */
	public function updateHitbox():Void
	{
		width = Math.abs(scale.x) * frameWidth;
		height = Math.abs(scale.y) * frameHeight;
		offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		centerOrigin();
	}

	/**
	 * Resets some important variables for sprite optimization and rendering.
	 */
	@:noCompletion
	function resetHelpers():Void
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

		if (FlxG.renderBlit)
		{
			dirty = true;
			updateFramePixels();
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		updateAnimation(elapsed);
	}

	/**
	 * This is separated out so it can be easily overridden.
	 */
	function updateAnimation(elapsed:Float):Void
	{
		animation.update(elapsed);
	}

	@:noCompletion
	function checkEmptyFrame()
	{
		if (_frame == null)
			loadGraphic("flixel/images/logo/default.png");
	}

	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen.
	 */
	override public function draw():Void
	{
		checkEmptyFrame();

		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;

		if (dirty) // rarely
			calcFrame(useFramePixels);

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			getScreenPosition(_point, camera).subtractPoint(offset);

			if (isSimpleRender(camera))
				drawSimple(camera);
			else
				drawComplex(camera);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	@:noCompletion
	function drawSimple(camera:FlxCamera):Void
	{
		if (isPixelPerfectRender(camera))
			_point.floor();

		_point.copyToFlash(_flashPoint);
		camera.copyPixels(_frame, framePixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing);
	}

	@:noCompletion
	function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	/**
	 * Stamps / draws another `FlxSprite` onto this `FlxSprite`.
	 * This function is NOT intended to replace `draw()`!
	 *
	 * @param   Brush   The sprite you want to use as a brush or stamp or pen or whatever.
	 * @param   X       The X coordinate of the brush's top left corner on this sprite.
	 * @param   Y       They Y coordinate of the brush's top left corner on this sprite.
	 */
	public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void
	{
		Brush.drawFrame();

		if (graphic == null || Brush.graphic == null)
			throw "Cannot stamp to or from a FlxSprite with no graphics.";

		var bitmapData:BitmapData = Brush.framePixels;

		if (isSimpleRenderBlit()) // simple render
		{
			_flashPoint.x = X + frame.frame.x;
			_flashPoint.y = Y + frame.frame.y;
			_flashRect2.width = bitmapData.width;
			_flashRect2.height = bitmapData.height;
			graphic.bitmap.copyPixels(bitmapData, _flashRect2, _flashPoint, null, null, true);
			_flashRect2.width = graphic.bitmap.width;
			_flashRect2.height = graphic.bitmap.height;
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
		}

		if (FlxG.renderBlit)
		{
			dirty = true;
			calcFrame();
		}
	}

	/**
	 * Request (or force) that the sprite update the frame before rendering.
	 * Useful if you are doing procedural generation or other weirdness!
	 *
	 * @param   Force   Force the frame to redraw, even if its not flagged as necessary.
	 */
	public function drawFrame(Force:Bool = false):Void
	{
		if (FlxG.renderBlit)
		{
			if (Force || dirty)
			{
				dirty = true;
				calcFrame();
			}
		}
		else
		{
			dirty = true;
			calcFrame(true);
		}
	}

	/**
	 * Helper function that adjusts the offset automatically to center the bounding box within the graphic.
	 *
	 * @param   AdjustPosition   Adjusts the actual X and Y position just once to match the offset change.
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
	 * `scale` to make sure rotations work as expected.
	 */
	public inline function centerOrigin():Void
	{
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
	}

	/**
	 * Replaces all pixels with specified `Color` with `NewColor` pixels.
	 * WARNING: very expensive (especially on big graphics) as it iterates over every single pixel.
	 *
	 * @param   Color            Color to replace
	 * @param   NewColor         New color
	 * @param   FetchPositions   Whether we need to store positions of pixels which colors were replaced.
	 * @return  `Array` with replaced pixels positions
	 */
	public function replaceColor(Color:FlxColor, NewColor:FlxColor, FetchPositions:Bool = false):Array<FlxPoint>
	{
		var positions = FlxBitmapDataUtil.replaceColor(graphic.bitmap, Color, NewColor, FetchPositions);
		if (positions != null)
			dirty = true;
		return positions;
	}

	/**
	 * Sets the sprite's color transformation with control over color offsets.
	 * With `FlxG.renderTile`, offsets are only supported on OpenFL Next version 3.6.0 or higher.
	 *
	 * @param   redMultiplier     The value for the red multiplier, in the range from `0` to `1`.
	 * @param   greenMultiplier   The value for the green multiplier, in the range from `0` to `1`.
	 * @param   blueMultiplier    The value for the blue multiplier, in the range from `0` to `1`.
	 * @param   alphaMultiplier   The value for the alpha transparency multiplier, in the range from `0` to `1`.
	 * @param   redOffset         The offset value for the red color channel, in the range from `-255` to `255`.
	 * @param   greenOffset       The offset value for the green color channel, in the range from `-255` to `255`.
	 * @param   blueOffset        The offset for the blue color channel value, in the range from `-255` to `255`.
	 * @param   alphaOffset       The offset for alpha transparency channel value, in the range from `-255` to `255`.
	 */
	public function setColorTransform(redMultiplier:Float = 1.0, greenMultiplier:Float = 1.0, blueMultiplier:Float = 1.0, alphaMultiplier:Float = 1.0,
			redOffset:Int = 0, greenOffset:Int = 0, blueOffset:Int = 0, alphaOffset:Int = 0):Void
	{
		color = FlxColor.fromRGBFloat(redMultiplier, greenMultiplier, blueMultiplier).to24Bit();
		alpha = alphaMultiplier;

		colorTransform.setMultipliers(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		colorTransform.setOffsets(redOffset, greenOffset, blueOffset, alphaOffset);

		useColorTransform = alpha != 1 || color != 0xffffff || colorTransform.hasRGBOffsets();
		dirty = true;
	}

	function updateColorTransform():Void
	{
		if (colorTransform == null)
			colorTransform = new ColorTransform();

		useColorTransform = alpha != 1 || color != 0xffffff;
		if (useColorTransform)
			colorTransform.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, alpha);
		else
			colorTransform.setMultipliers(1, 1, 1, 1);

		dirty = true;
	}

	/**
	 * Checks to see if a point in 2D world space overlaps this `FlxSprite` object's current displayed pixels.
	 * This check is ALWAYS made in screen space, and always takes `scrollFactor` into account.
	 *
	 * @param   Point    The point in world space you want to check.
	 * @param   Mask     Used in the pixel hit test to determine what counts as solid.
	 * @param   Camera   Specify which game camera you want.  If `null`, it will just grab the first global camera.
	 * @return  Whether or not the point overlaps this object.
	 */
	public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
	{
		if (Camera == null)
			Camera = FlxG.camera;

		getScreenPosition(_point, Camera);
		_point.subtractPoint(offset);
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
			var frameData:BitmapData = updateFramePixels();
			var pixelColor:FlxColor = frameData.getPixel32(Std.int(_flashPoint.x), Std.int(_flashPoint.y));
			return pixelColor.alpha * alpha >= Mask;
		}
	}

	/**
	 * Internal function to update the current animation frame.
	 *
	 * @param   RunOnCpp   Whether the frame should also be recalculated if we're on a non-flash target
	 */
	@:noCompletion
	function calcFrame(RunOnCpp:Bool = false):Void
	{
		checkEmptyFrame();

		if (FlxG.renderTile && !RunOnCpp)
			return;

		updateFramePixels();
	}

	/**
	 * Retrieves the `BitmapData` of the current `FlxFrame`. Updates `framePixels`.
	 */
	public function updateFramePixels():BitmapData
	{
		if (_frame == null || !dirty)
			return framePixels;

		// don't try to regenerate frame pixels if _frame already uses it as source of graphics
		// if you'll try then it will clear framePixels and you won't see anything
		if (FlxG.renderTile && _frameGraphic != null)
		{
			dirty = false;
			return framePixels;
		}

		var doFlipX:Bool = checkFlipX();
		var doFlipY:Bool = checkFlipY();

		if (!doFlipX && !doFlipY && _frame.type == FlxFrameType.REGULAR)
		{
			framePixels = _frame.paint(framePixels, _flashPointZero, false, true);
		}
		else
		{
			framePixels = _frame.paintRotatedAndFlipped(framePixels, _flashPointZero, FlxFrameAngle.ANGLE_0, doFlipX, doFlipY, false, true);
		}

		if (useColorTransform)
		{
			framePixels.colorTransform(_flashRect, colorTransform);
		}

		if (FlxG.renderTile && useFramePixels)
		{
			// recreate _frame for native target, so it will use modified framePixels
			_frameGraphic = FlxDestroyUtil.destroy(_frameGraphic);
			_frameGraphic = FlxGraphic.fromBitmapData(framePixels, false, null, false);
			_frame = _frameGraphic.imageFrame.frame.copyTo(_frame);
		}

		dirty = false;
		return framePixels;
	}

	/**
	 * Retrieve the midpoint of this sprite's graphic in world coordinates.
	 *
	 * @param   point   Allows you to pass in an existing `FlxPoint` if you're so inclined.
	 *                  Otherwise a new one is created.
	 * @return  A `FlxPoint` containing the midpoint of this sprite's graphic in world coordinates.
	 */
	public function getGraphicMidpoint(?point:FlxPoint):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();
		return point.set(x + frameWidth * 0.5, y + frameHeight * 0.5);
	}

	/**
	 * Check and see if this object is currently on screen. Differs from `FlxObject`'s implementation
	 * in that it takes the actual graphic into account, not just the hitbox or bounding box or whatever.
	 *
	 * @param   Camera  Specify which game camera you want. If `null`, it will just grab the first global camera.
	 * @return  Whether the object is on screen or not.
	 */
	override public function isOnScreen(?camera:FlxCamera):Bool
	{
		if (camera == null)
			camera = FlxG.camera;
		
		return camera.containsRect(getScreenBounds(_rect, camera));
	}

	/**
	 * Returns the result of `isSimpleRenderBlit()` if `FlxG.renderBlit` is
	 * `true`, or `false` if `FlxG.renderTile` is `true`.
	 */
	public function isSimpleRender(?camera:FlxCamera):Bool
	{
		if (FlxG.renderTile)
			return false;

		return isSimpleRenderBlit(camera);
	}

	/**
	 * Determines the function used for rendering in blitting:
	 * `copyPixels()` for simple sprites, `draw()` for complex ones.
	 * Sprites are considered simple when they have an `angle` of `0`, a `scale` of `1`,
	 * don't use `blend` and `pixelPerfectRender` is `true`.
	 *
	 * @param   camera   If a camera is passed its `pixelPerfectRender` flag is taken into account
	 */
	public function isSimpleRenderBlit(?camera:FlxCamera):Bool
	{
		var result:Bool = (angle == 0 || bakedRotationAngle > 0) && scale.x == 1 && scale.y == 1 && blend == null;
		result = result && (camera != null ? isPixelPerfectRender(camera) : pixelPerfectRender);
		return result;
	}

	/**
	 * Calculates the smallest globally aligned bounding box that encompasses this
	 * sprite's width and height, at its current rotation.
	 * Note, if called on a `FlxSprite`, the origin is used, but scale and offset are ignored.
	 * Use `getScreenBounds` to use these properties.
	 * @param newRect The optional output `FlxRect` to be returned, if `null`, a new one is created.
	 * @return A globally aligned `FlxRect` that fully contains the input object's width and height.
	 * @since 4.11.0
	 */
	override function getRotatedBounds(?newRect:FlxRect)
	{
		if (newRect == null)
			newRect = FlxRect.get();
		
		newRect.set(x, y, width, height);
		return newRect.getRotatedBounds(angle, origin, newRect);
	}
	
	/**
	 * Calculates the smallest globally aligned bounding box that encompasses this sprite's graphic as it
	 * would be displayed. Honors scrollFactor, rotation, scale, offset and origin.
	 * @param newRect Optional output `FlxRect`, if `null`, a new one is created.
	 * @param camera  Optional camera used for scrollFactor, if null `FlxG.camera` is used.
	 * @return A globally aligned `FlxRect` that fully contains the input sprite.
	 * @since 4.11.0
	 */
	public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		if (newRect == null)
			newRect = FlxRect.get();
		
		if (camera == null)
			camera = FlxG.camera;
		
		newRect.setPosition(x, y);
		if (pixelPerfectPosition)
			newRect.floor();
		var scaledOrigin = FlxPoint.weak(origin.x * scale.x, origin.y * scale.y);
		newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - scaledOrigin.x;
		newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - scaledOrigin.y;
		if (isPixelPerfectRender(camera))
			newRect.floor();
		newRect.setSize(frameWidth * Math.abs(scale.x), frameHeight * Math.abs(scale.y));
		return newRect.getRotatedBounds(angle, scaledOrigin, newRect);
	}
	
	/**
	 * Set how a sprite flips when facing in a particular direction.
	 *
	 * @param   Direction   Use constants `LEFT`, `RIGHT`, `UP`, and `DOWN`.
	 *                      These may be combined with the bitwise OR operator.
	 *                      E.g. To make a sprite flip horizontally when it is facing both `UP` and `LEFT`,
	 *                      use `setFacingFlip(LEFT | UP, true, false);`
	 * @param   FlipX       Whether to flip the sprite on the X axis.
	 * @param   FlipY       Whether to flip the sprite on the Y axis.
	 */
	public inline function setFacingFlip(Direction:FlxDirectionFlags, FlipX:Bool, FlipY:Bool):Void
	{
		_facingFlip.set(Direction, {x: FlipX, y: FlipY});
	}

	/**
	 * Sets frames and allows you to save animations in sprite's animation controller
	 *
	 * @param   Frames           Frames collection to set for this sprite.
	 * @param   saveAnimations   Whether to save animations in animation controller or not.
	 * @return  This sprite with loaded frames
	 */
	@:access(flixel.animation.FlxAnimationController)
	public function setFrames(Frames:FlxFramesCollection, saveAnimations:Bool = true):FlxSprite
	{
		if (saveAnimations)
		{
			var animations = animation._animations;
			var reverse:Bool = false;
			var index:Int = 0;
			var frameIndex:Int = animation.frameIndex;
			var currName:String = null;

			if (animation.curAnim != null)
			{
				reverse = animation.curAnim.reversed;
				index = animation.curAnim.curFrame;
				currName = animation.curAnim.name;
			}

			animation._animations = null;
			this.frames = Frames;
			frame = frames.frames[frameIndex];
			animation._animations = animations;

			if (currName != null)
			{
				animation.play(currName, false, reverse, index);
			}
		}
		else
		{
			this.frames = Frames;
		}

		return this;
	}

	@:noCompletion
	function get_pixels():BitmapData
	{
		return (graphic == null) ? null : graphic.bitmap;
	}

	@:noCompletion
	function set_pixels(Pixels:BitmapData):BitmapData
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
		return Pixels;
	}

	@:noCompletion
	function set_frame(Value:FlxFrame):FlxFrame
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
		else
		{
			return null;
		}

		if (FlxG.renderTile)
		{
			_frameGraphic = FlxDestroyUtil.destroy(_frameGraphic);
		}

		if (clipRect != null)
		{
			_frame = frame.clipTo(clipRect, _frame);
		}
		else
		{
			_frame = frame.copyTo(_frame);
		}

		return frame;
	}

	@:noCompletion
	function set_facing(Direction:FlxDirectionFlags):FlxDirectionFlags
	{
		var flip = _facingFlip.get(Direction);
		if (flip != null)
		{
			flipX = flip.x;
			flipY = flip.y;
		}

		return facing = Direction;
	}

	@:noCompletion
	function set_alpha(Alpha:Float):Float
	{
		if (alpha == Alpha)
		{
			return Alpha;
		}
		alpha = FlxMath.bound(Alpha, 0, 1);
		updateColorTransform();
		return alpha;
	}

	@:noCompletion
	function set_color(Color:FlxColor):Int
	{
		if (color == Color)
		{
			return Color;
		}
		color = Color;
		updateColorTransform();
		return color;
	}

	@:noCompletion
	override function set_angle(Value:Float):Float
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

	@:noCompletion
	inline function updateTrig():Void
	{
		if (_angleChanged)
		{
			var radians:Float = angle * FlxAngle.TO_RAD;
			_sinAngle = Math.sin(radians);
			_cosAngle = Math.cos(radians);
			_angleChanged = false;
		}
	}

	@:noCompletion
	function set_blend(Value:BlendMode):BlendMode
	{
		return blend = Value;
	}

	/**
	 * Internal function for setting graphic property for this object.
	 * It changes graphics' `useCount` also for better memory tracking.
	 */
	@:noCompletion
	function set_graphic(Value:FlxGraphic):FlxGraphic
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

	@:noCompletion
	function set_clipRect(rect:FlxRect):FlxRect
	{
		if (rect != null)
			clipRect = rect.round();
		else
			clipRect = null;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}

	/**
	 * Frames setter. Used by `loadGraphic` methods, but you can load generated frames yourself
	 * (this should be even faster since engine doesn't need to do bunch of additional stuff).
	 *
	 * @param   Frames   frames to load into this sprite.
	 * @return  loaded frames.
	 */
	@:noCompletion
	function set_frames(Frames:FlxFramesCollection):FlxFramesCollection
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

		return Frames;
	}

	@:noCompletion
	function set_flipX(Value:Bool):Bool
	{
		if (FlxG.renderTile)
		{
			_facingHorizontalMult = Value ? -1 : 1;
		}
		dirty = (flipX != Value) || dirty;
		return flipX = Value;
	}

	@:noCompletion
	function set_flipY(Value:Bool):Bool
	{
		if (FlxG.renderTile)
		{
			_facingVerticalMult = Value ? -1 : 1;
		}
		dirty = (flipY != Value) || dirty;
		return flipY = Value;
	}

	@:noCompletion
	function set_antialiasing(value:Bool):Bool
	{
		return antialiasing = value;
	}

	@:noCompletion
	function set_useFramePixels(value:Bool):Bool
	{
		if (FlxG.renderTile)
		{
			if (value != useFramePixels)
			{
				useFramePixels = value;
				resetFrame();

				if (value)
				{
					updateFramePixels();
				}
			}

			return value;
		}
		else
		{
			useFramePixels = true;
			return true;
		}
	}

	@:noCompletion
	inline function checkFlipX():Bool
	{
		var doFlipX = (flipX != _frame.flipX);
		if (animation.curAnim != null)
		{
			return doFlipX != animation.curAnim.flipX;
		}
		return doFlipX;
	}

	@:noCompletion
	inline function checkFlipY():Bool
	{
		var doFlipY = (flipY != _frame.flipY);
		if (animation.curAnim != null)
		{
			return doFlipY != animation.curAnim.flipY;
		}
		return doFlipY;
	}
}

interface IFlxSprite extends IFlxBasic
{
	var x(default, set):Float;
	var y(default, set):Float;
	var alpha(default, set):Float;
	var angle(default, set):Float;
	var facing(default, set):FlxDirectionFlags;
	var moves(default, set):Bool;
	var immovable(default, set):Bool;

	var offset(default, null):FlxPoint;
	var origin(default, null):FlxPoint;
	var scale(default, null):FlxPoint;
	var velocity(default, null):FlxPoint;
	var maxVelocity(default, null):FlxPoint;
	var acceleration(default, null):FlxPoint;
	var drag(default, null):FlxPoint;
	var scrollFactor(default, null):FlxPoint;

	function reset(X:Float, Y:Float):Void;
	function setPosition(X:Float = 0, Y:Float = 0):Void;
}
