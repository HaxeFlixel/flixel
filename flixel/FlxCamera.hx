package flixel;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.FlxCameraView;
import flixel.system.render.FlxVertexBuffer;
import flixel.system.render.blit.FlxBlitRenderer;
import flixel.system.render.blit.FlxBlitView;
import flixel.system.render.quad.FlxQuadRenderer;
import flixel.system.render.quad.FlxQuadView;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Vector;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using flixel.util.FlxColorTransformUtil;

/**
 * The camera class is used to display the game's visuals.
 * By default one camera is created automatically, that is the same size as window.
 * You can add more cameras or even replace the main camera using utilities in `FlxG.cameras`.
 */
@:access(flixel.system.render)
class FlxCamera extends FlxBasic
{
	/**
	 * Any `FlxCamera` with a zoom of 0 (the default value) will have this zoom value.
	 */
	public static var defaultZoom:Float = 1.0;
	
	/**
	 * Used behind-the-scenes during the draw phase so that members use the same default
	 * cameras as their parent.
	 * 
	 * This is the non-deprecated list that the public `defaultCameras` proxies. Allows flixel classes
	 * to use it without warning.
	 */
	@:allow(flixel.FlxBasic.get_cameras)
	@:allow(flixel.FlxBasic.get_camera)
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	@:allow(flixel.group.FlxTypedGroup.draw)
	static var _defaultCameras:Array<FlxCamera>;

	/**
	 * The X position of this camera's display. `zoom` does NOT affect this number.
	 * Measured in pixels from the left side of the window.
	 * You might be interested in using camera's `scroll.x` instead.
	 */
	public var x(default, set):Float = 0;

	/**
	 * The Y position of this camera's display. `zoom` does NOT affect this number.
	 * Measured in pixels from the top of the window.
	 * You might be interested in using camera's `scroll.y` instead.
	 */
	public var y(default, set):Float = 0;

	/**
	 * The scaling on horizontal axis for this camera.
	 * Setting `scaleX` changes `scaleX` and x coordinate of camera's internal display objects.
	 */
	public var scaleX(default, null):Float = 0;

	/**
	 * The scaling on vertical axis for this camera.
	 * Setting `scaleY` changes `scaleY` and y coordinate of camera's internal display objects.
	 */
	public var scaleY(default, null):Float = 0;

	/**
	 * Product of camera's `scaleX` and game's scale mode `scale.x` multiplication.
	 */
	public var totalScaleX(default, null):Float;

	/**
	 * Product of camera's scaleY and game's scale mode scale.y multiplication.
	 */
	public var totalScaleY(default, null):Float;

	/**
	 * Holds various rendering related objects
	 */
	public var view(default, null):FlxCameraView;

	/**
	 * This camera's `view`, typed as a `FlxQuadView`.
	 * 
	 * **NOTE**: May be null depending on the render implementation used.
	 */
	var viewQuad(default, null):Null<FlxQuadView>;

	/**
	 * This camera's `view`, typed as a `FlxBlitView`.
	 * 
	 * **NOTE**: May be null depending on the render implementation used.
	 */
	var viewBlit(default, null):Null<FlxBlitView>;

	/**
	 * Tells the camera to use this following style.
	 */
	public var style:FlxCameraFollowStyle;

	/**
	 * Tells the camera to follow this FlxObject object around.
	 */
	public var target:FlxObject;

	/**
	 * Offset the camera target.
	 */
	public var targetOffset(default, null):FlxPoint = FlxPoint.get();

	/**
	 * The ratio of the distance to the follow `target` the camera moves per 1/60 sec.
	 * Valid values range from `0.0` to `1.0`. `1.0` means the camera always snaps to its target
	 * position. `0.5` means the camera always travels halfway to the target position, `0.0` means
	 * the camera does not move. Generally, the lower the value, the more smooth.
	 */
	public var followLerp:Float = 1.0;

	/**
	 * You can assign a "dead zone" to the camera in order to better control its movement.
	 * The camera will always keep the focus object inside the dead zone, unless it is bumping up against
	 * the camera bounds. The `deadzone`'s coordinates are measured from the camera's upper left corner in game pixels.
	 * For rapid prototyping, you can use the preset deadzones (e.g. `PLATFORMER`) with `follow()`.
	 */
	public var deadzone:FlxRect;

	/**
	 * Lower bound of the camera's `scroll` on the x axis.
	 */
	public var minScrollX:Null<Float>;

	/**
	 * Upper bound of the camera's `scroll` on the x axis.
	 */
	public var maxScrollX:Null<Float>;

	/**
	 * Lower bound of the camera's `scroll` on the y axis.
	 */
	public var minScrollY:Null<Float>;

	/**
	 * Upper bound of the camera's `scroll` on the y axis.
	 */
	public var maxScrollY:Null<Float>;

	/**
	 * Stores the basic parallax scrolling values.
	 * This is basically the camera's top-left corner position in world coordinates.
	 * There is also `focusOn(point:FlxPoint)` which you can use to
	 * make the camera look at specified point in world coordinates.
	 */
	public var scroll:FlxPoint = FlxPoint.get();

	/**
	 * The natural background color of the camera, in `AARRGGBB` format. Defaults to `FlxG.cameras.bgColor`.
	 * On Flash, transparent backgrounds can be used in conjunction with `useBgAlphaBlending`.
	 */
	public var bgColor:FlxColor;

	/**
	 * Whether to use alpha blending for the camera's background fill or not.
	 * If `true`, then the previously drawn graphics won't be erased,
	 * and if the camera's `bgColor` is transparent/semitransparent, then you
	 * will be able to see the graphics of the previous frame.
	 *
	 * This is Useful for blit render mode (and only works in this mode).
	 * Default value is `false`.
	 */
	public var useBgAlphaBlending:Bool = false;

	/**
	 * Whether the positions of the objects rendered on this camera are rounded.
	 * If set on individual objects, they ignore the global camera setting.
	 * Defaults to `true` with the blitting renderer and `false` elsewhere.
	 * WARNING: setting this to `false` on blitting targets is very expensive.
	 */
	public var pixelPerfectRender:Bool;
	
	/**
	 * If true, screen shake will be rounded to game pixels. If null, pixelPerfectRender is used.
	 * @since 5.4.0
	 */
	public var pixelPerfectShake:Null<Bool> = null;

	/**
	 * How wide the camera display is, in game pixels.
	 */
	public var width(default, set):Int = 0;

	/**
	 * How tall the camera display is, in game pixels.
	 */
	public var height(default, set):Int = 0;

	/**
	 * The zoom level of this camera. `1` = 1:1, `2` = 2x zoom, etc.
	 * Indicates how far the camera is zoomed in.
	 * Note: Changing this property from it's initial value will change properties like:
	 * `viewX`, `viewY`, `viewWidth`, `viewHeight` and many others. Cameras always zoom in to
	 * their center, meaning as you zoom in, the view is cut off on all sides.
	 */
	public var zoom(default, set):Float;

	/**
	 * The margin cut off on the left and right by the camera zooming in (or out), in world space.
	 * @since 5.2.0
	 */
	public var viewMarginX(default, null):Float;

	/**
	 * The margin cut off on the top and bottom by the camera zooming in (or out), in world space.
	 * @since 5.2.0
	 */
	public var viewMarginY(default, null):Float;

	// delegates

	/**
	 * The margin cut off on the left by the camera zooming in (or out), in world space.
	 * @since 5.2.0
	 */
	public var viewMarginLeft(get, never):Float;

	/**
	 * The margin cut off on the top by the camera zooming in (or out), in world space
	 * @since 5.2.0
	 */
	public var viewMarginTop(get, never):Float;

	/**
	 * The margin cut off on the right by the camera zooming in (or out), in world space
	 * @since 5.2.0
	 */
	public var viewMarginRight(get, never):Float;

	/**
	 * The margin cut off on the bottom by the camera zooming in (or out), in world space
	 * @since 5.2.0
	 */
	public var viewMarginBottom(get, never):Float;

	/**
	 * The size of the camera's view, in world space.
	 * @since 5.2.0
	 */
	public var viewWidth(get, never):Float;

	/**
	 * The size of the camera's view, in world space.
	 * @since 5.2.0
	 */
	public var viewHeight(get, never):Float;

	/**
	 * The left of the camera's view, in world space.
	 * @since 5.2.0
	 */
	public var viewX(get, never):Float;

	/**
	 * The top of the camera's view, in world space.
	 * @since 5.2.0
	 */
	public var viewY(get, never):Float;

	/**
	 * The left of the camera's view, in world space.
	 * @since 5.2.0
	 */
	public var viewLeft(get, never):Float;

	/**
	 * The top of the camera's view, in world space.
	 * @since 5.2.0
	 */
	public var viewTop(get, never):Float;

	/**
	 * The right side of the camera's view, in world space.
	 * @since 5.2.0
	 */
	public var viewRight(get, never):Float;

	/**
	 * The bottom side of the camera's view, in world space.
	 * @since 5.2.0
	 */
	public var viewBottom(get, never):Float;

	/**
	 * The alpha value of this camera display (a number between `0.0` and `1.0`).
	 */
	public var alpha(default, set):Float = 1;

	/**
	 * The angle of the camera display (in degrees).
	 */
	public var angle(default, set):Float = 0;

	/**
	 * The color tint of the camera display.
	 */
	public var color(default, set):FlxColor = FlxColor.WHITE;

	/**
	 * Whether the camera display is smooth and filtered, or chunky and pixelated.
	 * Default behavior is chunky-style.
	 */
	@:noCompletion
	@:deprecated("camera.antialiasing is deprecated, use camera.view.anstialiasing instead")
	public var antialiasing(default, set):Bool = false;

	/**
	 * Used to force the camera to look ahead of the target.
	 */
	public var followLead(default, null):FlxPoint = FlxPoint.get();

	/**
	 * Enables or disables the filters set via the `filters` array.
	 */
	public var filtersEnabled:Bool = true;

	/**
	 * Internal, represents the color of `flash()` special effect.
	 */
	var _fxFlashColor:FlxColor = FlxColor.TRANSPARENT;

	/**
	 * Internal, stores `flash()` special effect duration.
	 */
	var _fxFlashDuration:Float = 0;

	/**
	 * Internal, camera's `flash()` complete callback.
	 */
	var _fxFlashComplete:Void->Void = null;

	/**
	 * Internal, used to control the `flash()` special effect.
	 */
	var _fxFlashAlpha:Float = 0;

	/**
	 * Internal, color of fading special effect.
	 */
	var _fxFadeColor:FlxColor = FlxColor.TRANSPARENT;

	/**
	 * Used to calculate the following target current velocity.
	 */
	var _lastTargetPosition:FlxPoint;

	/**
	 * Helper to calculate follow target current scroll.
	 */
	var _scrollTarget:FlxPoint = FlxPoint.get();

	/**
	 * Internal, `fade()` special effect duration.
	 */
	var _fxFadeDuration:Float = 0;

	/**
	 * Internal, "direction" of the `fade()` effect.
	 * `true` means that camera fades from a color, `false` - camera fades to it.
	 */
	var _fxFadeIn:Bool = false;

	/**
	 * Internal, used to control the `fade()` special effect complete callback.
	 */
	var _fxFadeComplete:Void->Void = null;

	/**
	 * Internal, alpha component of fade color.
	 * Changes from 0 to 1 or from 1 to 0 as the effect continues.
	 */
	var _fxFadeAlpha:Float = 0;

	/**
	 * Internal, percentage of screen size representing the maximum distance that the screen can move while shaking.
	 */
	var _fxShakeIntensity:Float = 0;

	/**
	 * Internal, duration of the `shake()` effect.
	 */
	var _fxShakeDuration:Float = 0;

	/**
	 * Internal, `shake()` effect complete callback.
	 */
	var _fxShakeComplete:Void->Void;

	/**
	 * Internal, defines on what axes to `shake()`. Default value is `XY` / both.
	 */
	var _fxShakeAxes:FlxAxes = XY;

	/**
	 * Internal, used for repetitive calculations and added to help avoid costly allocations.
	 */
	var _point:FlxPoint = FlxPoint.get();

	/**
	 * The filters array to be applied to the camera.
	 */
	public var filters:Null<Array<BitmapFilter>> = null;

	/**
	 * Camera's initial zoom value. Used for camera's scale handling.
	 */
	public var initialZoom(default, null):Float = 1;
	
	/**
	 * Helper method preparing debug rectangle for rendering in blit render mode
	 * @param	rect	rectangle to prepare for rendering
	 * @return	transformed rectangle with respect to camera's zoom factor
	 */
	inline function transformRect(rect:FlxRect):FlxRect
	{
		return view.transformRect(rect);
	}

	/**
	 * Helper method preparing debug point for rendering in blit render mode (for debug path rendering, for example)
	 * @param	point		point to prepare for rendering
	 * @return	transformed point with respect to camera's zoom factor
	 */
	inline function transformPoint(point:FlxPoint):FlxPoint
	{
		return view.transformPoint(point);
	}

	/**
	 * Helper method preparing debug vectors (relative positions) for rendering in blit render mode
	 * @param	vector	relative position to prepare for rendering
	 * @return	transformed vector with respect to camera's zoom factor
	 */
	inline function transformVector(vector:FlxPoint):FlxPoint
	{
		return view.transformVector(vector);
	}
	
	/**
	 * Instantiates a new camera at the specified location, with the specified size and zoom level.
	 *
	 * @param   x       X location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param   y       Y location of the camera's display in pixels. Uses native, 1:1 resolution, ignores zoom.
	 * @param   width   The width of the camera display in pixels.
	 * @param   height  The height of the camera display in pixels.
	 * @param   zoom    The initial zoom level of the camera.
	 *                  A zoom level of 2 will make all pixels display at 2x resolution.
	 */
	@:haxe.warning("-WDeprecated")
	public function new(x = 0.0, y = 0.0, width = 0, height = 0, zoom = 0.0)
	{
		super();

		this.x = x;
		this.y = y;

		if (zoom == 0)
			zoom = defaultZoom;
		
		// Use the game dimensions if width / height are <= 0
		if (width <= 0)
			width = Math.ceil(FlxG.width / zoom);
		if (height <= 0)
			height = Math.ceil(FlxG.height / zoom);
		
		this.width = width;
		this.height = height;

		view = createView();
		if (view is FlxQuadView)
		{
			viewQuad = Std.downcast(view, FlxQuadView);
			@:bypassAccessor _flashPoint = new Point();
			@:bypassAccessor _blitMatrix = new FlxMatrix();
			@:bypassAccessor _flashRect = new Rectangle();
			
			@:bypassAccessor flashSprite = viewQuad.flashSprite;
			@:bypassAccessor _flashOffset = viewQuad._flashOffset;
			@:bypassAccessor _scrollRect = viewQuad._scrollRect;
			@:bypassAccessor canvas = viewQuad.canvas;
			#if FLX_DEBUG
			@:bypassAccessor debugLayer = viewQuad.canvas;
			#end
			
			final renderQuad = cast(FlxG.renderer, FlxQuadRenderer);
			@:privateAccess @:bypassAccessor _bounds = renderQuad._bounds;
			@:privateAccess @:bypassAccessor _helperMatrix = renderQuad._helperMatrix;
			@:bypassAccessor _helperPoint = new Point();
		}
		else if (view is FlxBlitView)
		{
			viewBlit = Std.downcast(view, FlxBlitView);
			@:bypassAccessor _flashPoint = viewBlit._flashPoint;
			@:bypassAccessor flashSprite = viewQuad.flashSprite;
			@:bypassAccessor _flashOffset = viewBlit._flashOffset;
			@:bypassAccessor _scrollRect = viewBlit._scrollRect;
			@:bypassAccessor _flashRect = viewBlit._flashRect;
			
			@:bypassAccessor screen = viewBlit.screen;
			@:bypassAccessor buffer = viewBlit.buffer;
			@:bypassAccessor _flashBitmap = viewBlit._flashBitmap;
			@:bypassAccessor _blitMatrix = viewBlit._blitMatrix;
			@:bypassAccessor _fill = viewBlit._fill;
			
			final renderBlit = cast(FlxG.renderer, FlxBlitRenderer);
			@:privateAccess @:bypassAccessor _bounds = renderBlit._bounds;
			@:privateAccess @:bypassAccessor _helperMatrix = renderBlit._helperMatrix;
			@:privateAccess @:bypassAccessor _helperPoint = renderBlit._helperPoint;
		}

		pixelPerfectRender = FlxG.renderer.blit;

		set_color(FlxColor.WHITE);
		
		// sets the scale of flash sprite, which in turn loads flashOffset values
		this.zoom = initialZoom = zoom;
		
		updateScrollRect();
		updateFlashOffset();
		updateFlashSpritePosition();
		updateInternalSpritePositions();

		bgColor = FlxG.cameras.bgColor;
	}
	
	function createView()
	{
		return FlxG.renderer.createCameraView(this);
	}

	/**
	 * Clean up memory.
	 */
	@:haxe.warning("-WDeprecated")
	override public function destroy():Void
	{
		view.destroy();

		scroll = FlxDestroyUtil.put(scroll);
		targetOffset = FlxDestroyUtil.put(targetOffset);
		deadzone = FlxDestroyUtil.put(deadzone);

		target = null;
		_fxFlashComplete = null;
		_fxFadeComplete = null;
		_fxShakeComplete = null;
		
		// --- deprecated view fields
		@:bypassAccessor buffer = null;
		@:bypassAccessor screen = null;
		@:bypassAccessor flashSprite = null;
		@:bypassAccessor _blitMatrix = null;
		@:bypassAccessor _flashRect = null;
		@:bypassAccessor _flashPoint = null;
		@:bypassAccessor _flashOffset = null;
		@:bypassAccessor _fill = null;
		@:bypassAccessor _flashBitmap = null;
		@:bypassAccessor _scrollRect = null;
		@:bypassAccessor canvas = null;
		@:bypassAccessor debugLayer = null;
		@:bypassAccessor _currentDrawItem = null;
		@:bypassAccessor _headOfDrawStack = null;
		@:bypassAccessor _headTiles = null;
		@:bypassAccessor _headTriangles = null;
		@:bypassAccessor _bounds = null;
		@:bypassAccessor _helperMatrix = null;
		@:bypassAccessor _helperPoint = null;

		super.destroy();
	}

	/**
	 * Updates the camera scroll as well as special effects like screen-shake or fades.
	 */
	override public function update(elapsed:Float):Void
	{
		// follow the target, if there is one
		if (target != null)
		{
			updateFollow();
			updateLerp(elapsed);
		}

		updateScroll();
		updateFlash(elapsed);
		updateFade(elapsed);

		updateFlashSpritePosition();
		updateShake(elapsed);
	}

	/**
	 * Updates (bounds) the camera scroll.
	 * Called every frame by camera's `update()` method.
	 */
	public function updateScroll():Void
	{
		// Make sure we didn't go outside the camera's bounds
		bindScrollPos(scroll);
	}
	
	/**
	 * Takes the desired scroll position and restricts it to the camera's min/max scroll properties.
	 * This modifies the given point.
	 * 
	 * @param   scrollPos  The scroll position
	 * @return  The same point passed in, moved within the scroll bounds
	 * @since 5.4.0
	 */
	public function bindScrollPos(scrollPos:FlxPoint)
	{
		final minX:Null<Float> = minScrollX == null ? null : minScrollX - viewMarginLeft;
		final maxX:Null<Float> = maxScrollX == null ? null : maxScrollX - viewMarginRight;
		final minY:Null<Float> = minScrollY == null ? null : minScrollY - viewMarginTop;
		final maxY:Null<Float> = maxScrollY == null ? null : maxScrollY - viewMarginBottom;

		// keep point within bounds
		scrollPos.x = FlxMath.bound(scrollPos.x, minX, maxX);
		scrollPos.y = FlxMath.bound(scrollPos.y, minY, maxY);
		return scrollPos;
	}

	/**
	 * Updates camera's scroll.
	 * Called every frame by camera's `update()` method (if camera's `target` isn't `null`).
	 */
	function updateFollow():Void
	{
		// Either follow the object closely,
		// or double check our deadzone and update accordingly.
		if (deadzone == null)
		{
			target.getMidpoint(_point);
			_point.add(targetOffset);
			_scrollTarget.set(_point.x - width * 0.5, _point.y - height * 0.5);
		}
		else
		{
			var edge:Float;
			var targetX:Float = target.x + targetOffset.x;
			var targetY:Float = target.y + targetOffset.y;

			if (style == SCREEN_BY_SCREEN)
			{
				if (targetX >= viewRight)
				{
					_scrollTarget.x += viewWidth;
				}
				else if (targetX + target.width < viewLeft)
				{
					_scrollTarget.x -= viewWidth;
				}

				if (targetY >= viewBottom)
				{
					_scrollTarget.y += viewHeight;
				}
				else if (targetY + target.height < viewTop)
				{
					_scrollTarget.y -= viewHeight;
				}
				
				// without this we see weird behavior when switching to SCREEN_BY_SCREEN at arbitrary scroll positions
				bindScrollPos(_scrollTarget);
			}
			else
			{
				edge = targetX - deadzone.x;
				if (_scrollTarget.x > edge)
				{
					_scrollTarget.x = edge;
				}
				edge = targetX + target.width - deadzone.x - deadzone.width;
				if (_scrollTarget.x < edge)
				{
					_scrollTarget.x = edge;
				}

				edge = targetY - deadzone.y;
				if (_scrollTarget.y > edge)
				{
					_scrollTarget.y = edge;
				}
				edge = targetY + target.height - deadzone.y - deadzone.height;
				if (_scrollTarget.y < edge)
				{
					_scrollTarget.y = edge;
				}
			}

			if ((target is FlxSprite))
			{
				if (_lastTargetPosition == null)
				{
					_lastTargetPosition = FlxPoint.get(target.x, target.y); // Creates this point.
				}
				_scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}
		}
	}
	
	function updateLerp(elapsed:Float)
	{
		if (followLerp >= 1.0)
		{
			scroll.copyFrom(_scrollTarget); // no easing
		}
		else if (followLerp > 0.0)
		{
			// Adjust lerp based on the current frame rate so lerp is less framerate dependant
			final adjustedLerp = 1.0 - Math.pow(1.0 - followLerp, elapsed * 60);
			
			scroll.x += (_scrollTarget.x - scroll.x) * adjustedLerp;
			scroll.y += (_scrollTarget.y - scroll.y) * adjustedLerp;
		}
	}

	function updateFlash(elapsed:Float):Void
	{
		// Update the "flash" special effect
		if (_fxFlashAlpha > 0.0)
		{
			_fxFlashAlpha -= elapsed / _fxFlashDuration;
			if ((_fxFlashAlpha <= 0) && (_fxFlashComplete != null))
			{
				_fxFlashComplete();
			}
		}
	}

	function updateFade(elapsed:Float):Void
	{
		if (_fxFadeDuration == 0.0)
			return;

		if (_fxFadeIn)
		{
			_fxFadeAlpha -= elapsed / _fxFadeDuration;
			if (_fxFadeAlpha <= 0.0)
			{
				_fxFadeAlpha = 0.0;
				completeFade();
			}
		}
		else
		{
			_fxFadeAlpha += elapsed / _fxFadeDuration;
			if (_fxFadeAlpha >= 1.0)
			{
				_fxFadeAlpha = 1.0;
				completeFade();
			}
		}
	}

	function completeFade()
	{
		_fxFadeDuration = 0.0;
		if (_fxFadeComplete != null)
			_fxFadeComplete();
	}

	function updateShake(elapsed:Float):Void
	{
		if (_fxShakeDuration > 0)
		{
			_fxShakeDuration -= elapsed;
			if (_fxShakeDuration <= 0)
			{
				if (_fxShakeComplete != null)
				{
					_fxShakeComplete();
				}
			}
			else
			{
				var offsetX:Float = 0;
				var offsetY:Float = 0;

				final pixelPerfect = pixelPerfectShake == null ? pixelPerfectRender : pixelPerfectShake;
				if (_fxShakeAxes.x)
				{
					var shakePixels = FlxG.random.float(-1, 1) * _fxShakeIntensity * width;
					if (pixelPerfect)
						shakePixels = Math.round(shakePixels);
					
					offsetX = shakePixels * zoom * FlxG.scaleMode.scale.x;
				}
				
				if (_fxShakeAxes.y)
				{
					var shakePixels = FlxG.random.float(-1, 1) * _fxShakeIntensity * height;
					if (pixelPerfect)
						shakePixels = Math.round(shakePixels);
					
					offsetY = shakePixels * zoom * FlxG.scaleMode.scale.y;
				}

				view.offsetView(offsetX, offsetY);
			}
		}
	}

	/**
	 * Recalculates `flashSprite` position.
	 * Called every frame by camera's `update()` method and every time you change camera's position.
	 */
	function updateFlashSpritePosition():Void
	{
		if (view != null)
			view.updatePosition();
	}

	/**
	 * Recalculates `_flashOffset` point, which is used for positioning flashSprite in the game.
	 * It's called every time you resize the camera or the game.
	 */
	function updateFlashOffset():Void
	{
		if (view != null)
			view.updateOffset();
	}

	/**
	 * Updates `_scrollRect` sprite to crop graphics of the camera:
	 * 1) `scrollRect` property of this sprite
	 * 2) position of this sprite inside `flashSprite`
	 *
	 * It takes camera's size and game's scale into account.
	 * It's called every time you resize the camera or the game.
	 */
	function updateScrollRect():Void
	{
		if (view != null)
			view.updateScrollRect();
	}

	/**
	 * Modifies position of `_flashBitmap` in blit render mode and `canvas` and `debugSprite`
	 * in tile render mode (these objects are children of `_scrollRect` sprite).
	 * It takes camera's size and game's scale into account.
	 * It's called every time you resize the camera or the game.
	 */
	function updateInternalSpritePositions():Void
	{
		if (view != null)
			view.updateInternals();
	}

	/**
	 * Tells this camera object what `FlxObject` to track.
	 *
	 * @param   target   The object you want the camera to track. Set to `null` to not follow anything.
	 * @param   style    Leverage one of the existing "deadzone" presets. Default is `LOCKON`.
	 *                   If you use a custom deadzone, ignore this parameter and
	 *                   manually specify the deadzone after calling `follow()`.
	 * @param   lerp     How much lag the camera should have (can help smooth out the camera movement).
	 */
	public function follow(target:FlxObject, style = LOCKON, lerp = 1.0):Void
	{
		this.style = style;
		this.target = target;
		followLerp = lerp;
		_lastTargetPosition = FlxDestroyUtil.put(_lastTargetPosition);
		deadzone = FlxDestroyUtil.put(deadzone);

		switch (style)
		{
			case LOCKON:
				var w:Float = 0;
				var h:Float = 0;
				if (target != null)
				{
					w = target.width;
					h = target.height;
				}
				deadzone = FlxRect.get((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);

			case PLATFORMER:
				final w:Float = (width / 8);
				final h:Float = (height / 3);
				deadzone = FlxRect.get((width - w) / 2, (height - h) / 2 - h * 0.25, w, h);

			case TOPDOWN:
				final helper = Math.max(width, height) / 4;
				deadzone = FlxRect.get((width - helper) / 2, (height - helper) / 2, helper, helper);

			case TOPDOWN_TIGHT:
				final helper = Math.max(width, height) / 8;
				deadzone = FlxRect.get((width - helper) / 2, (height - helper) / 2, helper, helper);

			case SCREEN_BY_SCREEN:
				deadzone = FlxRect.get(0, 0, width, height);

			case NO_DEAD_ZONE:
				deadzone = null;
		}
	}

	/**
	 * Snaps the camera to the current `target`. Useful to move the camera without
	 * any easing when the `target` position changes and there is a `followLerp`.
	 */
	public function snapToTarget():Void
	{
		updateFollow();
		scroll.copyFrom(_scrollTarget);
	}

	/**
	 * Move the camera focus to this location instantly.
	 *
	 * @param   Point   Where you want the camera to focus.
	 */
	public inline function focusOn(point:FlxPoint):Void
	{
		scroll.set(point.x - width * 0.5, point.y - height * 0.5);
		point.putWeak();
	}

	/**
	 * The screen is filled with this color and gradually returns to normal.
	 *
	 * @param   Color        The color you want to use.
	 * @param   Duration     How long it takes for the flash to fade.
	 * @param   OnComplete   A function you want to run when the flash finishes.
	 * @param   Force        Force the effect to reset.
	 */
	public function flash(Color:FlxColor = FlxColor.WHITE, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void
	{
		if (!Force && (_fxFlashAlpha > 0.0))
			return;

		_fxFlashColor = Color;
		if (Duration <= 0)
			Duration = 0.000001;
		_fxFlashDuration = Duration;
		_fxFlashComplete = OnComplete;
		_fxFlashAlpha = 1.0;
	}

	/**
	 * The screen is gradually filled with this color.
	 *
	 * @param   Color        The color you want to use.
	 * @param   Duration     How long it takes for the fade to finish.
	 * @param   FadeIn       `true` fades from a color, `false` fades to it.
	 * @param   OnComplete   A function you want to run when the fade finishes.
	 * @param   Force        Force the effect to reset.
	 */
	public function fade(Color:FlxColor = FlxColor.BLACK, Duration:Float = 1, FadeIn:Bool = false, ?OnComplete:Void->Void, Force:Bool = false):Void
	{
		if (_fxFadeDuration > 0 && !Force)
			return;

		_fxFadeColor = Color;
		if (Duration <= 0)
			Duration = 0.000001;

		_fxFadeIn = FadeIn;
		_fxFadeDuration = Duration;
		_fxFadeComplete = OnComplete;

		_fxFadeAlpha = _fxFadeIn ? 0.999999 : 0.000001;
	}

	/**
	 * A simple screen-shake effect.
	 *
	 * @param   Intensity    Percentage of screen size representing the maximum distance
	 *                       that the screen can move while shaking.
	 * @param   Duration     The length in seconds that the shaking effect should last.
	 * @param   OnComplete   A function you want to run when the shake effect finishes.
	 * @param   Force        Force the effect to reset (default = `true`, unlike `flash()` and `fade()`!).
	 * @param   Axes         On what axes to shake. Default value is `FlxAxes.XY` / both.
	 */
	public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, ?OnComplete:Void->Void, Force:Bool = true, ?Axes:FlxAxes):Void
	{
		if (Axes == null)
			Axes = XY;

		if (!Force && _fxShakeDuration > 0)
			return;

		_fxShakeIntensity = Intensity;
		_fxShakeDuration = Duration;
		_fxShakeComplete = OnComplete;
		_fxShakeAxes = Axes;
	}

	/**
	 * Stops the fade effect on `this` camera.
	 */
	public function stopFade():Void
	{
		_fxFadeAlpha = 0.0;
		_fxFadeDuration = 0.0;
	}

	/**
	 * Stops the flash effect on `this` camera.
	 */
	public function stopFlash():Void
	{
		_fxFlashAlpha = 0.0;
		updateFlashSpritePosition();
	}

	/**
	 * Stops the shake effect on `this` camera.
	 */
	public function stopShake():Void
	{
		_fxShakeDuration = 0.0;
	}

	/**
	 * Stops all effects on `this` camera.
	 */
	public function stopFX():Void
	{
		_fxFadeAlpha = 0.0;
		_fxFadeDuration = 0.0;
		_fxFlashAlpha = 0.0;
		updateFlashSpritePosition();
		_fxShakeDuration = 0.0;
	}

	/**
	 * Copy the bounds, focus object, and `deadzone` info from an existing camera.
	 *
	 * @param   Camera  The camera you want to copy from.
	 * @return  A reference to this `FlxCamera` object.
	 */
	public function copyFrom(Camera:FlxCamera):FlxCamera
	{
		setScrollBounds(Camera.minScrollX, Camera.maxScrollX, Camera.minScrollY, Camera.maxScrollY);

		target = Camera.target;

		if (target != null)
		{
			if (Camera.deadzone == null)
			{
				deadzone = null;
			}
			else
			{
				if (deadzone == null)
				{
					deadzone = FlxRect.get();
				}
				deadzone.copyFrom(Camera.deadzone);
			}
		}
		return this;
	}

	/**
	 * Internal helper function, handles the actual drawing of all the special effects.
	 */
	@:allow(flixel.system.render.FlxCameraView)
	function drawFX():Void
	{
		// Draw the "flash" special effect onto the buffer
		if (_fxFlashAlpha > 0.0)
		{
			var color = _fxFlashColor;
			color.alphaFloat *= _fxFlashAlpha;
			view.fill(color);
		}
		
		// Draw the "fade" special effect onto the buffer
		if (_fxFadeAlpha > 0.0)
		{
			var color = _fxFadeColor;
			color.alphaFloat *= _fxFadeAlpha;
			view.fill(color);
		}
	}
	
	/**
	 * Shortcut for setting both `width` and `height`.
	 *
	 * @param   Width    The new camera width.
	 * @param   Height   The new camera height.
	 */
	public inline function setSize(Width:Int, Height:Int)
	{
		width = Width;
		height = Height;
	}

	/**
	 * Helper function to set the coordinates of this camera.
	 * Handy since it only requires one line of code.
	 *
	 * @param   X   The new x position.
	 * @param   Y   The new y position.
	 */
	public inline function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		x = X;
		y = Y;
	}
	
	/**
	 * Helper for coordinate converters
	 */
	static inline function safeGetX(p:Null<FlxPoint>, backup:Float)
	{
		return p == null ? backup : p.x;
	}
	
	/**
	 * Helper for coordinate converters
	 */
	static inline function safeGetY(p:Null<FlxPoint>, backup:Float)
	{
		return p == null ? backup : p.y;
	}
	
	/**
	 * Takes a world position and gives the position it will be displayed in the camera's view
	 * 
	 * @param   worldPos       The position in the world
	 * @param   scrollFactorX  How much this camera's scroll affects the result, for parallax
	 * @param   scrollFactorY  How much this camera's scroll affects the result, for parallax
	 * @param   result         Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function worldToViewPosition(worldPos:FlxPoint, scrollFactorX = 1.0, scrollFactorY = 1.0, ?result:FlxPoint)
	{
		result = worldToViewHelper(worldPos.x, worldPos.y, scrollFactorX, scrollFactorY, result);
		worldPos.putWeak();
		return result;
	}
	
	/**
	 * Takes a world position and gives the position it will be displayed in the camera's view
	 * 
	 * @param   worldPos      The position in the world
	 * @param   scrollFactor  How much this camera's scroll affects the result, for parallax
	 * @param   result        Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function worldToViewPosition(worldPos:FlxPoint, ?scrollFactor:FlxPoint, ?result:FlxPoint)
	{
		result = worldToViewHelper(worldPos.x, worldPos.y, safeGetX(scrollFactor, 1.0), safeGetY(scrollFactor, 1.0), result);
		worldPos.putWeak();
		FlxDestroyUtil.putWeak(scrollFactor);
		return result;
	}
	
	/**
	 * Takes a world position and gives the position it will be displayed in the camera's view
	 * 
	 * @param   worldX        The position in the world
	 * @param   worldY        The position in the world
	 * @param   scrollFactor  How much this camera's scroll affects the result, for parallax=
	 * @param   result        Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function worldToViewPosition(worldX:Float, worldY:Float, ?scrollFactor:FlxPoint, ?result:FlxPoint)
	{
		result = worldToViewHelper(worldX, worldY, safeGetX(scrollFactor, 1.0), safeGetY(scrollFactor, 1.0), result);
		FlxDestroyUtil.putWeak(scrollFactor);
		return result;
	}
	
	/**
	 * Takes a world position and gives the position it will be displayed in the camera's view
	 * 
	 * @param   worldX        The position in the world
	 * @param   worldY        The position in the world
	 * @param   scrollFactorX  How much this camera's scroll affects the result, for parallax
	 * @param   scrollFactorY  How much this camera's scroll affects the result, for parallax
	 * @param   result         Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function worldToViewPosition(worldX:Float, worldY:Float, scrollFactorX = 1.0, scrollFactorY = 1.0, ?result)
	{
		return worldToViewHelper(worldX, worldY, scrollFactorX, scrollFactorY, result);
	}
	
	function worldToViewHelper(worldX:Float, worldY:Float, scrollFactorX = 1.0, scrollFactorY = 1.0, ?result:FlxPoint):FlxPoint
	{
		if (result == null)
			result = FlxPoint.get();
		
		return result.set(worldToViewX(worldX, scrollFactorX), worldToViewY(worldY, scrollFactorY));
	}
	
	/**
	 * Takes a world position and gives the position it will be displayed in the camera's view
	 * 
	 * @param   worldX        The position in the world
	 * @param   scrollFactor  How much this camera's scroll affects the result, for parallax
	 * @param   result         Optional arg for the returning point
	 * @since 6.2.0
	 */
	public function worldToViewX(worldX:Float, scrollFactor = 1.0)
	{
		return worldX - (scroll.x * scrollFactor) - viewMarginX;
	}
	
	/**
	 * Takes a world position and gives the position it will be displayed in the camera's view
	 * 
	 * @param   worldY        The position in the world
	 * @param   scrollFactor  How much this camera's scroll affects the result, for parallax
	 * @param   result        Optional arg for the returning point
	 * @since 6.2.0
	 */
	public function worldToViewY(worldY:Float, scrollFactor = 1.0)
	{
		return worldY - (scroll.y * scrollFactor) - viewMarginY;
	}
	
	/**
	 * Takes a position in this camera's view and gives the world position being displayed
	 * 
	 * @param   viewPos        The position in this camera's view
	 * @param   scrollFactorX  How much this camera's scroll affects the result, for parallax
	 * @param   scrollFactorY  How much this camera's scroll affects the result, for parallax
	 * @param   result         Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function viewToWorldPosition(viewPos:FlxPoint, scrollFactorX = 1.0, scrollFactorY = 1.0, ?result:FlxPoint)
	{
		result = viewToWorldHelper(viewPos.x, viewPos.y, scrollFactorX, scrollFactorY, result);
		viewPos.putWeak();
		return result;
	}
	
	/**
	 * Takes a position in this camera's view and gives the world position being displayed
	 * 
	 * @param   viewPos       The position in this camera's view
	 * @param   scrollFactor  How much this camera's scroll affects the result, for parallax
	 * @param   result        Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function viewToWorldPosition(viewPos:FlxPoint, ?scrollFactor:FlxPoint, ?result:FlxPoint)
	{
		result = viewToWorldHelper(viewPos.x, viewPos.y, safeGetX(scrollFactor, 1.0), safeGetY(scrollFactor, 1.0), result);
		viewPos.putWeak();
		FlxDestroyUtil.putWeak(scrollFactor);
		return result;
	}
	
	/**
	 * Takes a position in this camera's view and gives the world position being displayed
	 * 
	 * @param   viewX         The position in this camera's view
	 * @param   viewY         The position in this camera's view
	 * @param   scrollFactor  How much this camera's scroll affects the result, for parallax
	 * @param   result        Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function viewToWorldPosition(viewX:Float, viewY:Float, ?scrollFactor:FlxPoint, ?result:FlxPoint)
	{
		result = viewToWorldHelper(viewX, viewY, safeGetX(scrollFactor, 1.0), safeGetY(scrollFactor, 1.0), result);
		FlxDestroyUtil.putWeak(scrollFactor);
		return result;
	}
	
	/**
	 * Takes a position in this camera's view and gives the world position being displayed
	 * 
	 * @param   viewX          The position in this camera's view
	 * @param   viewY          The position in this camera's view
	 * @param   scrollFactorX  How much this camera's scroll affects the result, for parallax
	 * @param   scrollFactorY  How much this camera's scroll affects the result, for parallax
	 * @param   result         Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function viewToWorldPosition(viewX:Float, viewY:Float, scrollFactorX = 1.0, scrollFactorY = 1.0, ?result)
	{
		return viewToWorldHelper(viewX, viewY, scrollFactorX, scrollFactorY, result);
	}
	
	function viewToWorldHelper(viewX:Float, viewY:Float, scrollFactorX = 1.0, scrollFactorY = 1.0, ?result:FlxPoint):FlxPoint
	{
		if (result == null)
			result = FlxPoint.get();
		
		return result.set(viewToWorldX(viewX, scrollFactorX), viewToWorldY(viewY, scrollFactorY));
	}
	
	/**
	 * Takes a position in this camera's view and gives the world position being displayed
	 * 
	 * @param   viewX         The position in this camera's view
	 * @param   scrollFactor  How much this camera's scroll affects the result, for parallax
	 * @param   result        Optional arg for the returning point
	 * @since 6.2.0
	 */
	public function viewToWorldX(viewX:Float, scrollFactor = 1.0)
	{
		return viewX + (scroll.x * scrollFactor) + viewMarginX;
	}
	
	/**
	 * Takes a position in this camera's view and gives the world position being displayed
	 * 
	 * @param   viewY         The position in this camera's view
	 * @param   scrollFactor  How much this camera's scroll affects the result, for parallax
	 * @param   result        Optional arg for the returning point
	 * @since 6.2.0
	 */
	public function viewToWorldY(viewY:Float, scrollFactor = 1.0)
	{
		return viewY + (scroll.y * scrollFactor) + viewMarginY;
	}
	
	/**
	 * Takes a position in the `FlxGame` and gives the corresponding position in this camera's view
	 * 
	 * @param   gamePos  The position in the `FlxGame`
	 * @param   result   Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function gameToViewPosition(gamePos:FlxPoint, ?result)
	{
		return gameToViewHelper(gamePos.x, gamePos.y, result);
	}
	
	/**
	 * Takes a position in the `FlxGame` and gives the corresponding position in this camera's view
	 * 
	 * @param   gameX   The position in the `FlxGame`
	 * @param   gameY   The position in the `FlxGame`
	 * @param   result  Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function gameToViewPosition(gameX:Float, gameY:Float, ?result:FlxPoint)
	{
		return gameToViewHelper(gameX, gameY, result);
	}
	
	function gameToViewHelper(gameX:Float, gameY:Float, ?result:FlxPoint):FlxPoint
	{
		if (result == null)
			result = FlxPoint.get();
		
		return result.set(gameToViewX(gameX), gameToViewY(gameY));
	}
	
	/**
	 * Takes a position in the `FlxGame` and gives the corresponding position in this camera's view
	 * 
	 * @param   gameX   The position in the `FlxGame`
	 * @param   result  Optional arg for the returning point
	 * @since 6.2.0
	 */
	public function gameToViewX(gameX:Float)
	{
		return (gameX - x) / zoom;
	}
	
	/**
	 * Takes a position in the `FlxGame` and gives the corresponding position in this camera's view
	 * 
	 * @param   gameY   The position in the `FlxGame`
	 * @param   result  Optional arg for the returning point
	 * @since 6.2.0
	 */
	public function gameToViewY(gameY:Float)
	{
		return (gameY - y) / zoom;
	}
	
	/**
	 * Takes a position in this camera's view and gives the corresponding position in the `FlxGame`
	 * 
	 * @param   viewPos  The position in this camera's view
	 * @param   result   Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function viewToGamePosition(viewPos:FlxPoint, ?result)
	{
		return viewToGameHelper(viewPos.x, viewPos.y, result);
	}
	
	/**
	 * Takes a position in this camera's view and gives the corresponding position in the `FlxGame`
	 * 
	 * @param   viewX   The position in this camera's view
	 * @param   viewY   The position in this camera's view
	 * @param   result  Optional arg for the returning point
	 * @since 6.2.0
	 */
	overload public inline extern function viewToGamePosition(viewX:Float, viewY:Float, ?result:FlxPoint)
	{
		return viewToGameHelper(viewX, viewY, result);
	}
	
	function viewToGameHelper(viewX:Float, viewY:Float, ?result:FlxPoint):FlxPoint
	{
		if (result == null)
			result = FlxPoint.get();
		
		return result.set(viewToGameX(viewX), viewToGameY(viewY));
	}
	
	/**
	 * Takes a position in this camera's view and gives the corresponding position in the `FlxGame`
	 * 
	 * @param   viewX   The position in this camera's view
	 * @param   result  Optional arg for the returning point
	 * @since 6.2.0
	 */
	public function viewToGameX(viewX:Float)
	{
		// return (viewX - x) / zoom;
		return viewX * zoom + this.x;
	}
	
	/**
	 * Takes a position in this camera's view and gives the corresponding position in the `FlxGame`
	 * 
	 * @param   viewY   The position in this camera's view
	 * @param   result  Optional arg for the returning point
	 * @since 6.2.0
	 */
	public function viewToGameY(viewY:Float)
	{
		// return (viewY - y) / zoom;
		return viewY * zoom + this.y;
	}
	
	/**
	 * Specify the bounding rectangle of where the camera is allowed to move.
	 *
	 * @param   X             The smallest X value of your level (usually `0`).
	 * @param   Y             The smallest Y value of your level (usually `0`).
	 * @param   Width         The largest X value of your level (usually the level width).
	 * @param   Height        The largest Y value of your level (usually the level height).
	 * @param   UpdateWorld   Whether the global quad-tree's dimensions should be updated to match (default: `false`).
	 */
	public function setScrollBoundsRect(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0, UpdateWorld:Bool = false):Void
	{
		if (UpdateWorld)
		{
			FlxG.worldBounds.set(X, Y, Width, Height);
		}

		setScrollBounds(X, X + Width, Y, Y + Height);
	}

	/**
	 * Specify the bounds of where the camera is allowed to move.
	 * Set the boundary of a side to `null` to leave that side unbounded.
	 *
	 * @param   MinX   The minimum X value the camera can scroll to
	 * @param   MaxX   The maximum X value the camera can scroll to
	 * @param   MinY   The minimum Y value the camera can scroll to
	 * @param   MaxY   The maximum Y value the camera can scroll to
	 */
	public function setScrollBounds(MinX:Null<Float>, MaxX:Null<Float>, MinY:Null<Float>, MaxY:Null<Float>):Void
	{
		minScrollX = MinX;
		maxScrollX = MaxX;
		minScrollY = MinY;
		maxScrollY = MaxY;
		updateScroll();
	}

	/**
	 * Helper function to set the scale of this camera.
	 * Handy since it only requires one line of code.
	 *
	 * @param   X   The new scale on x axis
	 * @param   Y   The new scale of y axis
	 */
	public function setScale(X:Float, Y:Float):Void
	{
		scaleX = X;
		scaleY = Y;

		totalScaleX = scaleX * FlxG.scaleMode.scale.x;
		totalScaleY = scaleY * FlxG.scaleMode.scale.y;

		view.updateScale();
		
		calcMarginX();
		calcMarginY();

		updateScrollRect();
		updateInternalSpritePositions();

		FlxG.cameras.cameraResized.dispatch(this);
	}

	/**
	 * Called by camera front end every time you resize the game.
	 * It triggers reposition of camera's internal display objects.
	 */
	public function onResize():Void
	{
		updateFlashOffset();
		setScale(scaleX, scaleY);
	}
	
	/**
	 * The size and position of this camera's margins, via `viewMarginLeft`, `viewMarginTop`, `viewWidth`
	 * and `viewHeight`.
	 * @since 5.2.0
	 */
	public function getViewMarginRect(?rect:FlxRect)
	{
		if (rect == null)
			rect = FlxRect.get();
		
		return rect.set(viewMarginLeft, viewMarginTop, viewWidth, viewHeight);
	}
	
	/**
	 * Checks whether this camera contains a given point or rectangle, in
	 * screen coordinates.
	 * @since 4.3.0
	 */
	public inline function containsPoint(point:FlxPoint, width:Float = 0, height:Float = 0):Bool
	{
		var contained = (point.x + width > viewMarginLeft) && (point.x < viewMarginRight)
			&& (point.y + height > viewMarginTop) && (point.y < viewMarginBottom);
		point.putWeak();
		return contained;
	}
	
	/**
	 * Checks whether this camera contains a given rectangle, in screen coordinates.
	 * @since 4.11.0
	 */
	public inline function containsRect(rect:FlxRect):Bool
	{
		var contained = (rect.right > viewMarginLeft) && (rect.x < viewMarginRight)
			&& (rect.bottom > viewMarginTop) && (rect.y < viewMarginBottom);
		rect.putWeak();
		return contained;
	}

	function set_width(Value:Int):Int
	{
		if (width != Value && Value > 0)
		{
			width = Value;
			
			calcMarginX();
			updateFlashOffset();
			updateScrollRect();
			updateInternalSpritePositions();

			FlxG.cameras.cameraResized.dispatch(this);
		}
		return Value;
	}

	function set_height(Value:Int):Int
	{
		if (height != Value && Value > 0)
		{
			height = Value;

			calcMarginY();
			updateFlashOffset();
			updateScrollRect();
			updateInternalSpritePositions();

			FlxG.cameras.cameraResized.dispatch(this);
		}
		return Value;
	}

	function set_zoom(Zoom:Float):Float
	{
		zoom = (Zoom == 0) ? defaultZoom : Zoom;
		setScale(zoom, zoom);
		return zoom;
	}

	function set_alpha(value:Float):Float
	{
		return this.alpha = view.alpha = FlxMath.bound(value, 0, 1);
	}
	
	function set_angle(value:Float):Float
	{
		return this.angle = view.angle = value;
	}
	
	function set_color(value:FlxColor):FlxColor
	{
		return this.color = view.color = value;
	}
	
	function set_antialiasing(value:Bool):Bool
	{
		return this.antialiasing = view.antialiasing = value;
	}
	
	function set_x(x:Float):Float
	{
		this.x = x;
		updateFlashSpritePosition();
		return x;
	}

	function set_y(y:Float):Float
	{
		this.y = y;
		updateFlashSpritePosition();
		return y;
	}

	override function set_visible(value:Bool):Bool
	{
		return this.visible = view.visible = value;
	}

	inline function calcMarginX():Void
	{
		viewMarginX = 0.5 * width * (scaleX - initialZoom) / scaleX;
	}

	inline function calcMarginY():Void
	{
		viewMarginY = 0.5 * height * (scaleY - initialZoom) / scaleY;
	}
	
	static inline function get_defaultCameras():Array<FlxCamera>
	{
		return _defaultCameras;
	}
	
	static inline function set_defaultCameras(value:Array<FlxCamera>):Array<FlxCamera>
	{
		return _defaultCameras = value;
	}
	
	inline function get_viewMarginLeft():Float
	{
		return viewMarginX;
	}
	
	inline function get_viewMarginTop():Float
	{
		return viewMarginY;
	}
	
	inline function get_viewMarginRight():Float
	{
		return width - viewMarginX;
	}
	
	inline function get_viewMarginBottom():Float
	{
		return height - viewMarginY;
	}
	
	inline function get_viewWidth():Float
	{
		return width - viewMarginX * 2;
	}
	
	inline function get_viewHeight():Float
	{
		return height - viewMarginY * 2;
	}
	
	inline function get_viewX():Float
	{
		return scroll.x + viewMarginX;
	}
	
	inline function get_viewY():Float
	{
		return scroll.y + viewMarginY;
	}
	
	inline function get_viewLeft():Float
	{
		return viewX;
	}
	
	inline function get_viewTop():Float
	{
		return viewY;
	}
	
	inline function get_viewRight():Float
	{
		return scroll.x + viewMarginRight;
	}
	
	inline function get_viewBottom():Float
	{
		return scroll.y + viewMarginBottom;
	}
	
	/**
	 * Do not use the following fields! They only exists because FlxCamera extends FlxBasic,
	 * we're hiding them because they've only caused confusion.
	 */
	@:deprecated("don't reference camera.camera")
	@:noCompletion
	override function get_camera():FlxCamera throw "don't reference camera.camera";
	
	@:deprecated("don't reference camera.camera")
	@:noCompletion
	override function set_camera(value:FlxCamera):FlxCamera throw "don't reference camera.camera";
	
	@:deprecated("don't reference camera.cameras")
	@:noCompletion
	override function get_cameras():Array<FlxCamera> throw "don't reference camera.cameras";
	
	@:deprecated("don't reference camera.cameras")
	@:noCompletion
	override function set_cameras(value:Array<FlxCamera>):Array<FlxCamera> throw "don't reference camera.cameras";
	
	//{ region ------ DEPRECATED VIEW FIELDS ------
	
	@:noCompletion
	@:deprecated("camera.transformObject is deprecated, there will be no replacement")
	function transformObject(object:DisplayObject):DisplayObject
	{
		object.scaleX *= totalScaleX;
		object.scaleY *= totalScaleY;

		object.x -= scroll.x * totalScaleX;
		object.y -= scroll.y * totalScaleY;

		object.x -= 0.5 * width * (scaleX - initialZoom) * FlxG.scaleMode.scale.x;
		object.y -= 0.5 * height * (scaleY - initialZoom) * FlxG.scaleMode.scale.y;

		return object;
	}
	
	@:noCompletion
	@:deprecated("camera.startQuadBatch() is deprecated, use view.startQuadBatch() instead.") // 6.2.0
	public function startQuadBatch(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false, ?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader)
	{
		return viewQuad.startQuadBatch(graphic, colored, hasColorOffsets, blend, smooth, shader);
	}

	@:noCompletion
	@:deprecated("camera.startTrianglesBatch() is deprecated, use view.startTrianglesBatch() instead.") // 6.2.0
	public function startTrianglesBatch(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, ?blend:BlendMode, ?hasColorOffsets:Bool, ?shader:FlxShader):FlxDrawTrianglesItem
	{
		return viewQuad.startTrianglesBatch(graphic, smoothing, isColored, blend, hasColorOffsets, shader);
	}

	@:noCompletion
	@:deprecated("camera.getNewDrawTrianglesItem() is deprecated, use view.getNewDrawTrianglesItem() instead.") // 6.2.0
	public function getNewDrawTrianglesItem(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, ?blend:BlendMode, ?hasColorOffsets:Bool, ?shader:FlxShader):FlxDrawTrianglesItem
	{
		return viewQuad.getNewDrawTrianglesItem(graphic, smoothing, isColored, blend, hasColorOffsets, shader);
	}

	@:noCompletion
	@:deprecated("camera.render() is deprecated, use view.render() instead.") // 6.2.0
	function render():Void
	{
		view.render();
	}
	
	@:noCompletion
	@:deprecated("camera.fill() is deprecated, use camera.view.fill() instead.") // 6.2.0
	public function fill(color:FlxColor, blendAlpha:Bool = true, fxAlpha:Float = 1.0, ?graphics:Graphics):Void
	{
		color.alphaFloat = fxAlpha;
		
		final useTargetGraphic = graphics != null #if FLX_DEBUG && graphics != view.getDebugBuffer() #end;
		if (useTargetGraphic)
		{
			graphics.overrideBlendMode(null);
			final buffer:FlxVertexBuffer = cast graphics;
			// i'm drawing rect with these parameters to avoid light lines at the top and left of the camera,
			// which could appear while cameras fading
			buffer.drawFilledRect(camera.viewMarginLeft - 1, camera.viewMarginTop - 1, camera.viewWidth + 2, camera.viewHeight + 2, color);
			return;
		}

		view.fill(color, blendAlpha);
	}
	
	@:noCompletion
	@:deprecated("camera.clearDrawStack() is deprecated, use FlxG.renderer.render() instead.") // 6.2.0
	function clearDrawStack():Void
	{
		viewQuad.clearDrawStack();
	}
	
	@:noCompletion
	@:deprecated("camera.drawPixels() is deprecated, use FlxG.renderer.drawPixels() instead.") // 6.2.0
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false,
			?shader:FlxShader):Void
	{
		FlxG.renderer.drawPixels(view, frame, pixels, matrix, transform, blend, smoothing, shader);
	}
	
	@:noCompletion
	@:deprecated("camera.copyPixels() is deprecated, use FlxG.renderer.copyPixels() instead.") // 6.2.0
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
			?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		FlxG.renderer.copyPixels(view, frame, pixels, sourceRect, destPoint, transform, blend, smoothing, shader);
	}
	
	@:noCompletion
	@:deprecated("camera.drawTriangles() is deprecated, use FlxG.renderer.drawTriangles() instead.") // 6.2.0
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
			?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader):Void
	{
		FlxG.renderer.drawTriangles(view, graphic, vertices, indices, uvtData, colors, position, blend, repeat, smoothing, transform, shader);
	}
	
	@:noCompletion
	@:deprecated("checkResize() is deprecated") // 6.2.0
	function checkResize():Void
	{
		if (FlxG.renderer.blit)
			viewBlit.checkResize();
	}
	
	@:noCompletion
	@:deprecated("updateBlitMatrix() is deprecated, use camera.viewBlit.updateBlitMatrix(), instead") // 6.2.0
	inline function updateBlitMatrix():Void
	{
		viewBlit.updateBlitMatrix();
	}
	
	@:noCompletion
	@:deprecated("buffer is deprecated, use camera.viewBlit.buffer, instead") // 6.2.0
	@:isVar public var buffer(get, set):Null<BitmapData>;
	function get_buffer()
	{
		if (viewBlit != null)
			this.buffer = viewBlit.buffer;
		
		return this.buffer;
	}
	function set_buffer(value:BitmapData)
	{
		return if (viewBlit != null)
			this.buffer = viewBlit.buffer = value;
		else
			this.buffer = value;
	}
	
	@:noCompletion
	@:deprecated("screen is deprecated, use camera.viewBlit.screen, instead") // 6.2.0
	@:isVar public var screen(get, set):Null<FlxSprite>;
	function get_screen()
	{
		if (viewBlit != null)
			this.screen = viewBlit.screen;
		
		return this.screen;
	}
	function set_screen(value:FlxSprite)
	{
		return if (viewBlit != null)
			this.screen = viewBlit.screen = value;
		else
			this.screen = value;
	}
	
	@:noCompletion
	@:deprecated("flashSprite is deprecated, use camera.display, instead") // 6.2.0
	@:isVar public var flashSprite(get, set):Sprite;
	function get_flashSprite()
	{
		if (viewBlit != null)
			this.flashSprite = viewBlit.flashSprite;
		
		return this.flashSprite;
	}
	function set_flashSprite(value:Sprite)
	{
		return if (viewBlit != null)
			this.flashSprite = viewBlit.flashSprite = value;
		else
			this.flashSprite = value;
	}
	
	@:noCompletion
	@:deprecated("_blitMatrix is deprecated, use camera.viewBlit.blitMatrix, instead") // 6.2.0
	@:isVar var _blitMatrix(get, set):FlxMatrix;
	function get__blitMatrix()
	{
		if (viewBlit != null)
			this._blitMatrix = viewBlit._blitMatrix;
		
		return this._blitMatrix;
	}
	function set__blitMatrix(value:FlxMatrix)
	{
		return if (viewBlit != null)
			this._blitMatrix = viewBlit._blitMatrix = value;
		else
			this._blitMatrix = value;
	}
	
	@:noCompletion
	@:deprecated("_useBlitMatrix is deprecated, use camera.viewBlit._useBlitMatrix, instead") // 6.2.0
	@:isVar var _useBlitMatrix(get, set):Bool;
	function get__useBlitMatrix()
	{
		if (viewBlit != null)
			this._useBlitMatrix = viewBlit._useBlitMatrix;
		
		return this._useBlitMatrix;
	}
	function set__useBlitMatrix(value:Bool)
	{
		return if (viewBlit != null)
			this._useBlitMatrix = viewBlit._useBlitMatrix = value;
		else
			this._useBlitMatrix = value;
	}
	
	@:noCompletion
	@:deprecated("_flashRect is deprecated, use camera.viewBlit._flashRect, instead") // 6.2.0
	@:isVar var _flashRect(get, set):Rectangle;
	function get__flashRect()
	{
		if (viewBlit != null)
			this._flashRect = viewBlit._flashRect;
		
		return this._flashRect;
	}
	function set__flashRect(value:Rectangle)
	{
		return if (viewBlit != null)
			this._flashRect = viewBlit._flashRect = value;
		else
			this._flashRect = value;
	}
	
	@:noCompletion
	@:deprecated("_flashPoint is deprecated, use viewBlit._flashPoint, instead") // 6.2.0
	@:isVar var _flashPoint(get, set):Point;
	function get__flashPoint()
	{
		if (viewBlit != null)
			this._flashPoint = viewBlit._flashPoint;
		
		return this._flashPoint;
	}
	function set__flashPoint(value:Point)
	{
		return if (viewBlit != null)
			this._flashPoint = viewBlit._flashPoint = value;
		else
			this._flashPoint = value;
	}
	
	@:noCompletion
	@:deprecated("_flashOffset is deprecated, use camera.view._flashOffset, instead") // 6.2.0
	@:isVar var _flashOffset(get, set):Null<FlxPoint>;
	function get__flashOffset()
	{
		if (viewBlit != null)
			this._flashOffset = viewBlit._flashOffset;
		else if (viewQuad != null)
			this._flashOffset = viewQuad._flashOffset;
		
		return this._flashOffset;
	}
	function set__flashOffset(value:FlxPoint)
	{
		return if (viewBlit != null)
			this._flashOffset = viewBlit._flashOffset = value;
		else if (viewQuad != null)
			this._flashOffset = viewQuad._flashOffset = value;
		else
			this._flashOffset = value;
	}
	
	@:noCompletion
	@:deprecated("_fill is deprecated, use camera.viewBlit._fill, instead") // 6.2.0
	@:isVar var _fill(get, set):BitmapData;
	function get__fill():BitmapData
	{
		if (viewBlit != null)
			this._fill = viewBlit._fill;
		
		return this._fill;
	}
	function set__fill(value:BitmapData):BitmapData
	{
		return if (viewBlit != null)
			this._fill = viewBlit._fill = value;
		else
			this._fill = value;
	}
	
	@:noCompletion
	@:deprecated("_flashBitmap is deprecated, use camera.viewBlit._flashBitmap, instead") // 6.2.0
	@:isVar var _flashBitmap(get, set):Bitmap;
	function get__flashBitmap():Bitmap
	{
		if (viewBlit != null)
			this._flashBitmap = viewBlit._flashBitmap;
		
		return this._flashBitmap;
	}
	inline function set__flashBitmap(value:Bitmap):Bitmap
	{
		return if (viewBlit != null)
			this._flashBitmap = viewBlit._flashBitmap = value;
		else
			this._flashBitmap = value;
	}
	
	@:noCompletion
	@:deprecated("_scrollRect is deprecated, use camera.viewQuad._scrollRect/camera.viewBlit._scrollRect, instead") // 6.2.0
	@:isVar var _scrollRect(get, set):Sprite;
	function get__scrollRect():Sprite
	{
		if (viewBlit != null)
			this._scrollRect = viewBlit._scrollRect;
		else if (viewQuad != null)
			this._scrollRect = viewQuad._scrollRect;
		
		return this._scrollRect;
	}
	function set__scrollRect(value:Sprite):Sprite
	{
		return if (viewBlit != null)
			this._scrollRect = viewBlit._scrollRect = value;
		else if (viewQuad != null)
			this._scrollRect = viewQuad._scrollRect = value;
		else
			this._scrollRect = value;
	}
	
	@:noCompletion
	@:deprecated("_bounds is deprecated, use FlxBlitRenderer/FlxQuadRender._bounds, instead") // 6.2.0
	@:isVar var _bounds(get, set):FlxRect;
	function get__bounds():FlxRect
	{
		switch FlxG.renderer.method
		{
			case BLITTING:
				this._bounds = cast(FlxG.renderer, FlxBlitRenderer)._bounds;
			case DRAW_TILES:
				this._bounds = cast(FlxG.renderer, FlxQuadRenderer)._bounds;
			default:
		}
		
		return this._bounds;
	}
	function set__bounds(value:FlxRect):FlxRect 
	{
		return this._bounds = switch FlxG.renderer.method
		{
			case BLITTING:
				cast(FlxG.renderer, FlxBlitRenderer)._bounds = value;
			case DRAW_TILES:
				cast(FlxG.renderer, FlxQuadRenderer)._bounds = value;
			default:
				value;
		}
	}
	
	@:noCompletion
	@:deprecated("canvas is deprecated, use camera.viewQuad.canvas, instead") // 6.2.0
	@:isVar public var canvas(get, set):Null<Sprite>;
	function get_canvas()
	{
		if (viewQuad != null)
			this.canvas = viewQuad.canvas;
		
		return this.canvas;
	}
	function set_canvas(value:Null<Sprite>)
	{
		return if (viewQuad != null)
			this.canvas = viewQuad.canvas = value;
		else
			this.canvas = value;
	}

	#if FLX_DEBUG
	@:noCompletion
	@:deprecated("debugLayer is deprecated, use camera.viewQuad.debugLayer, instead") // 6.2.0
	@:isVar public var debugLayer(get, set):Null<Sprite>;
	function get_debugLayer()
	{
		if (viewQuad != null)
			this.debugLayer = viewQuad.debugLayer;
		
		return this.debugLayer;
	}
	function set_debugLayer(value:Null<Sprite>)
	{
		return if (viewQuad != null)
			this.debugLayer = viewQuad.debugLayer = value;
		else
			this.debugLayer = value;
	}
	#end
	
	@:noCompletion
	@:deprecated("_helperMatrix is deprecated, use FlxBlitRenderer/FlxQuadRenderer._helperMatrix, instead") // 6.2.0
	@:isVar var _helperMatrix(get, set):FlxMatrix;
	function get__helperMatrix()
	{
		switch FlxG.renderer.method
		{
			case BLITTING:
				this._helperMatrix = cast(FlxG.renderer, FlxBlitRenderer)._helperMatrix;
			case DRAW_TILES:
				this._helperMatrix = cast(FlxG.renderer, FlxQuadRenderer)._helperMatrix;
			default:
		}
		
		return this._helperMatrix;
	}
	function set__helperMatrix(value:FlxMatrix):FlxMatrix
	{
		return this._helperMatrix = switch FlxG.renderer.method
		{
			case BLITTING:
				cast(FlxG.renderer, FlxBlitRenderer)._helperMatrix = value;
			case DRAW_TILES:
				cast(FlxG.renderer, FlxQuadRenderer)._helperMatrix = value;
			default:
				value;
		}
	}
	
	@:noCompletion
	@:deprecated("_helperPoint is deprecated, use FlxBlitRenderer._helperPoint, instead") // 6.2.0
	@:isVar var _helperPoint(get, set):Point;
	function get__helperPoint()
	{
		switch FlxG.renderer.method
		{
			case BLITTING:
				this._helperPoint = cast(FlxG.renderer, FlxBlitRenderer)._helperPoint;
			default:
		}
		
		return this._helperPoint;
	}
	function set__helperPoint(value:Point):Point
	{
		return switch FlxG.renderer.method
		{
			case BLITTING:
				this._helperPoint = cast(FlxG.renderer, FlxBlitRenderer)._helperPoint = value;
			default:
				this._helperPoint = value;
		}
	}
	
	@:noCompletion
	@:deprecated("_currentDrawItem is deprecated, use camera.viewQuad._currentDrawItem, instead") // 6.2.0
	@:isVar var _currentDrawItem(get, set):Null<FlxDrawBaseItem<Dynamic>>;
	function get__currentDrawItem()
	{
		if (viewQuad != null)
			this._currentDrawItem = viewQuad._currentDrawItem;
		
		return this._currentDrawItem;
	}
	function set__currentDrawItem(value:Null<FlxDrawBaseItem<Dynamic>>)
	{
		return if (viewQuad != null)
			this._currentDrawItem = viewQuad._currentDrawItem = value;
		else
			this._currentDrawItem = value;
	}
	
	@:noCompletion
	@:deprecated("_headOfDrawStack is deprecated, use camera.viewQuad._headOfDrawStack, instead") // 6.2.0
	@:isVar var _headOfDrawStack(get, set):Null<FlxDrawBaseItem<Dynamic>>;
	function get__headOfDrawStack()
	{
		if (viewQuad != null)
			this._headOfDrawStack = viewQuad._headOfDrawStack;
		
		return this._headOfDrawStack;
	}
	function set__headOfDrawStack(value:Null<FlxDrawBaseItem<Dynamic>>)
	{
		return if (viewQuad != null)
			this._headOfDrawStack = viewQuad._headOfDrawStack = value;
		else
			this._headOfDrawStack = value;
	}
	
	@:noCompletion
	@:deprecated("_headTiles is deprecated, use camera.viewQuad._headTiles, instead") // 6.2.0
	@:isVar var _headTiles(get, set):Null<FlxDrawQuadsItem>;
	function get__headTiles()
	{
		if (viewQuad != null)
			this._headTiles = viewQuad._headTiles;
		
		return this._headTiles;
	}
	function set__headTiles(value:Null<FlxDrawQuadsItem>)
	{
		return if (viewQuad != null)
			this._headTiles = viewQuad._headTiles = value;
		else
			this._headTiles = value;
	}
	
	@:noCompletion
	@:deprecated("_headTriangles is deprecated, use camera.viewQuad._headTriangles, instead") // 6.2.0
	@:isVar var _headTriangles(get, set):Null<FlxDrawTrianglesItem>;
	function get__headTriangles()
	{
		if (viewQuad != null)
			this._headTriangles = viewQuad._headTriangles;
		
		return this._headTriangles;
	}
	function set__headTriangles(value:Null<FlxDrawTrianglesItem>)
	{
		return if (viewQuad != null)
			this._headTriangles = viewQuad._headTriangles = value;
		else
			this._headTriangles = value;
	}
	
	@:noCompletion
	@:deprecated("_storageTilesHead is deprecated, use FlxQuadView._storageTilesHead, instead") // 6.2.0
	static var _storageTilesHead(get, set):Null<FlxDrawQuadsItem>;
	static inline function get__storageTilesHead():Null<FlxDrawQuadsItem> return FlxQuadView._storageTilesHead;
	static inline function set__storageTilesHead(value:Null<FlxDrawQuadsItem>):FlxDrawQuadsItem return FlxQuadView._storageTilesHead = value;
	
	@:noCompletion
	@:deprecated("_storageTrianglesHead is deprecated, use FlxQuadView._storageTrianglesHead, instead") // 6.2.0
	static var _storageTrianglesHead(get, set):FlxDrawTrianglesItem;
	static inline function get__storageTrianglesHead():FlxDrawTrianglesItem return FlxQuadView._storageTrianglesHead;
	static inline function set__storageTrianglesHead(value:FlxDrawTrianglesItem):FlxDrawTrianglesItem return FlxQuadView._storageTrianglesHead = value;
	
	@:noCompletion
	@:deprecated("drawVertices is deprecated, use FlxBlitRenderer.drawVertices, instead") // 6.2.0
	static var drawVertices(get, set):Vector<Float>;
	static inline function get_drawVertices():Vector<Float> return FlxBlitRenderer.drawVertices;
	static inline function set_drawVertices(value:Vector<Float>):Vector<Float> return FlxBlitRenderer.drawVertices = value;
	
	@:noCompletion
	@:deprecated("trianglesSprite is deprecated, use FlxBlitRenderer.trianglesSprite, instead") // 6.2.0
	static var trianglesSprite(get, set):Sprite;
	static inline function get_trianglesSprite():Sprite return FlxBlitRenderer.trianglesSprite;
	static inline function set_trianglesSprite(value:Sprite):Sprite return FlxBlitRenderer.trianglesSprite = value;
	
	@:noCompletion
	@:deprecated("renderPoint is deprecated, use FlxBlitRenderer.renderPoint, instead") // 6.2.0
	static var renderPoint(get, set):FlxPoint;
	static inline function get_renderPoint():FlxPoint return FlxBlitRenderer.renderPoint;
	static inline function set_renderPoint(value:FlxPoint):FlxPoint return FlxBlitRenderer.renderPoint = value;
	
	@:noCompletion
	@:deprecated("renderRect is deprecated, use FlxBlitRenderer.renderRect, instead") // 6.2.0
	static var renderRect(get, set):FlxRect;
	static inline function get_renderRect():FlxRect return FlxBlitRenderer.renderRect;
	static inline function set_renderRect(value:FlxRect):FlxRect return FlxBlitRenderer.renderRect = value;
	
	// @:bypassAccess doesn't work from external classes in haxe 4. So call this when needed
	@:noCompletion inline function setColorBypass       (value:FlxColor):FlxColor return @:bypassAccessor this.color = value;
	@:noCompletion inline function setAlphaBypass       (value:Float   ):Float    return @:bypassAccessor this.alpha = value;
	@:noCompletion inline function setAngleBypass       (value:Float   ):Float    return @:bypassAccessor this.angle = value;
	@:noCompletion inline function setVisibleBypass     (value:Bool    ):Bool     return @:bypassAccessor this.visible = value;
	@:haxe.warning("-WDeprecated")
	@:noCompletion inline function setAntialiasingBypass(value:Bool    ):Bool     return @:bypassAccessor this.antialiasing = value;
	
	
	//{ endregion --- DEPRECATED VIEW FIELDS ------
}

enum FlxCameraFollowStyle
{
	/**
	 * Camera has no deadzone, just tracks the focus object directly.
	 */
	LOCKON;

	/**
	 * Camera's deadzone is narrow but tall.
	 */
	PLATFORMER;

	/**
	 * Camera's deadzone is a medium-size square around the focus object.
	 */
	TOPDOWN;

	/**
	 * Camera's deadzone is a small square around the focus object.
	 */
	TOPDOWN_TIGHT;

	/**
	 * Camera will move screenwise.
	 */
	SCREEN_BY_SCREEN;

	/**
	 * Camera has no deadzone, just tracks the focus object directly and centers it.
	 */
	NO_DEAD_ZONE;
}