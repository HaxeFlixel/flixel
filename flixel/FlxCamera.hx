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
import flixel.system.render.quad.FlxQuadView;
import flixel.system.render.blit.FlxBlitView;
import flixel.system.render.blit.FlxBlitRenderer;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Vector;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.DisplayObjectContainer;
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
@:allow(flixel.system.render)
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
	public var viewQuad(default, null):Null<FlxQuadView>;

	/**
	 * This camera's `view`, typed as a `FlxBlitView`.
	 * 
	 * **NOTE**: May be null depending on the render implementation used.
	 */
	public var viewBlit(default, null):Null<FlxBlitView>;

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
	 * The actual `BitmapData` of the camera display itself.
	 * Used in blit render mode, where you can manipulate its pixels for achieving some visual effects.
	 */
	@:deprecated("buffer is deprecated, use camera.viewBlit.buffer, instead")
	public var buffer(get, set):BitmapData;
	inline function set_buffer(value:BitmapData):BitmapData return viewBlit.buffer = value;
	inline function get_buffer():BitmapData return viewBlit.buffer;

	/**
	 * The natural background color of the camera, in `AARRGGBB` format. Defaults to `FlxG.cameras.bgColor`.
	 * On Flash, transparent backgrounds can be used in conjunction with `useBgAlphaBlending`.
	 */
	public var bgColor:FlxColor;

	/**
	 * Sometimes it's easier to just work with a `FlxSprite`, than it is to work directly with the `BitmapData` buffer.
	 * This sprite reference will allow you to do exactly that.
	 * Basically, this sprite's `pixels` property is the camera's `BitmapData` buffer.
	 *
	 * **NOTE:** This field is only used in blit render mode.
	 */
	@:deprecated("screen is deprecated, use camera.viewBlit.screen, instead")
	public var screen(get, set):FlxSprite;
	inline function set_screen(value:FlxSprite):FlxSprite return viewBlit.screen = value;
	inline function get_screen():FlxSprite return viewBlit.screen;

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
	 * Used to render buffer to screen space.
	 * NOTE: We don't recommend modifying this directly unless you are fairly experienced.
	 * Uses include 3D projection, advanced display list modification, and more.
	 * This is container for everything else that is used by camera and rendered to the camera.
	 *
	 * Its position is modified by `updateFlashSpritePosition()` which is called every frame.
	 */
	@:deprecated("flashSprite is deprecated, use camera.display, instead")
	public var flashSprite(get, set):Sprite;
	inline function set_flashSprite(value:Sprite):Sprite 
	{
		var sprite = FlxG.renderTile ? viewQuad.flashSprite : viewBlit.flashSprite;
		return sprite = value;
	}

	inline function get_flashSprite():Sprite return cast view.display;

	/**
	 * Whether the positions of the objects rendered on this camera are rounded.
	 * If set on individual objects, they ignore the global camera setting.
	 * Defaults to `false` with `FlxG.renderTile` and to `true` with `FlxG.renderBlit`.
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
	 * Reference to camera's `view.display`.
	 */
	public var display(get, never):DisplayObjectContainer;

	/**
	 * Helper matrix object. Used in blit render mode when camera's zoom is less than initialZoom
	 * (it is applied to all objects rendered on the camera at such circumstances).
	 */
	@:deprecated("_blitMatrix is deprecated, use camera.viewBlit.blitMatrix, instead")
	var _blitMatrix(get, set):FlxMatrix;
	inline function get__blitMatrix():FlxMatrix return viewBlit._blitMatrix;
	inline function set__blitMatrix(value:FlxMatrix) return viewBlit._blitMatrix = value;

	/**
	 * Logical flag for tracking whether to apply _blitMatrix transformation to objects or not.
	 */
	@:deprecated("_useBlitMatrix is deprecated, use camera.viewBlit._useBlitMatrix, instead")
	var _useBlitMatrix(get, set):Bool;
	inline function get__useBlitMatrix():Bool return viewBlit._useBlitMatrix;
	inline function set__useBlitMatrix(value:Bool) return viewBlit._useBlitMatrix = value;

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
	 * Internal, used in blit render mode in camera's `fill()` method for less garbage creation.
	 * It represents the size of buffer `BitmapData`
	 * (the area of camera's buffer which should be filled with `bgColor`).
	 * Do not modify it unless you know what are you doing.
	 */
	@:deprecated("_flashRect is deprecated, use camera.viewBlit._flashRect, instead")
	var _flashRect:Rectangle;
	inline function get__flashRect():Rectangle return viewBlit._flashRect;
	inline function set__flashRect(value:Rectangle) return viewBlit._flashRect = value;

	/**
	 * Internal, used in blit render mode in camera's `fill()` method for less garbage creation:
	 * Its coordinates are always `(0,0)`, where camera's buffer filling should start.
	 * Do not modify it unless you know what are you doing.
	 */
	@:deprecated("_flashPoint is deprecated, use FlxBlitRenderer._flashPoint, instead")
	var _flashPoint:Point = new Point();
	inline function get__flashPoint():Point return cast (FlxG.renderer, FlxBlitRenderer)._flashPoint;
	inline function set__flashPoint(value:Point) return cast (FlxG.renderer, FlxBlitRenderer)._flashPoint = value;

	/**
	 * Internal, used for positioning camera's `flashSprite` on screen.
	 * Basically it represents position of camera's center point in game sprite.
	 * It's recalculated every time you resize game or camera.
	 * Its value depends on camera's size (`width` and `height`), game's `scale` and camera's initial zoom factor.
	 * Do not modify it unless you know what are you doing.
	 */
	@:deprecated("_flashOffset is deprecated, use camera.view._flashOffset, instead")
	var _flashOffset(get, set):FlxPoint;
	inline function get__flashOffset():FlxPoint return view._flashOffset;
	inline function set__flashOffset(value:FlxPoint) return view._flashOffset = value;

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
	 * Internal helper variable for doing better wipes/fills between renders.
	 * Used it blit render mode only (in `fill()` method).
	 */
	@:deprecated("_fill is deprecated, use camera.viewBlit._fill, instead")
	var _fill(get, set):BitmapData;
	inline function get__fill():BitmapData return viewBlit._fill;
	inline function set__fill(value:BitmapData):BitmapData return viewBlit._fill = value;

	/**
	 * Internal, used to render buffer to screen space. Used it blit render mode only.
	 * This Bitmap used for rendering camera's buffer (`_flashBitmap.bitmapData = buffer;`)
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 * It is a child of the `_scrollRect` `Sprite`.
	 */
	@:deprecated("_flashBitmap is deprecated, use camera.viewBlit._flashBitmap, instead")
	var _flashBitmap(get, set):Bitmap;
	inline function get__flashBitmap():Bitmap return viewBlit._flashBitmap;
	inline function set__flashBitmap(value:Bitmap):Bitmap return viewBlit._flashBitmap = value;

	/**
	 * Internal sprite, used for correct trimming of camera viewport.
	 * It is a child of `flashSprite`.
	 * Its position is modified by `updateScrollRect()` method, which is called on camera's resize and scale events.
	 */
	@:deprecated("_scrollRect is deprecated, use camera.viewQuad._scrollRect/camera.viewBlit._scrollRect, instead")
	var _scrollRect(get, set):Sprite;
	inline function get__scrollRect():Sprite
	{
		return FlxG.renderTile ? viewQuad._scrollRect : viewBlit._scrollRect;
	}
	inline function set__scrollRect(value:Sprite):Sprite 
	{
		var scrollRect = FlxG.renderTile ? viewQuad._scrollRect : viewBlit._scrollRect;
		return scrollRect = value;
	}

	/**
	 * Helper rect for `drawTriangles()` visibility checks
	 */
	@:deprecated("_bounds is deprecated, use FlxBlitRenderer/FlxQuadRender._bounds, instead")
	var _bounds(get, set):FlxRect;
	inline function get__bounds():FlxRect 
	{
		return untyped FlxG.renderer._bounds;
	}
	inline function set__bounds(value:FlxRect):FlxRect 
	{
		return untyped FlxG.renderer._bounds = value;
	}

	/**
	 * Sprite used for actual rendering in tile render mode (instead of `_flashBitmap` for blitting).
	 * Its graphics is used as a drawing surface for `drawTriangles()` and `drawTiles()` methods.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	@:deprecated("canvas is deprecated, use camera.viewQuad.canvas, instead")
	public var canvas(get, set):Sprite;
	inline function set_canvas(value:Sprite):Sprite return viewQuad.canvas = value;
	inline function get_canvas():Sprite return viewQuad.canvas;

	#if FLX_DEBUG
	/**
	 * Sprite for visual effects (flash and fade) and drawDebug information
	 * (bounding boxes are drawn on it) for tile render mode.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	@:deprecated("debugLayer is deprecated, use camera.viewQuad.debugLayer, instead")
	public var debugLayer(get, set):Sprite;
	inline function set_debugLayer(value:Sprite):Sprite return viewQuad.debugLayer;
	inline function get_debugLayer():Sprite return viewQuad.debugLayer;
	#end

	@:deprecated("_helperMatrix is deprecated, use FlxBlitRenderer/FlxQuadRenderer._helperMatrix, instead")
	var _helperMatrix(get, set):FlxMatrix;
	inline function get__helperMatrix():FlxMatrix
	{
		return untyped FlxG.renderer._helperMatrix;
	}
	inline function set__helperMatrix(value:FlxMatrix):FlxMatrix 
	{
		return untyped FlxG.renderer._helperMatrix = value;
	}

	@:deprecated("_helperPoint is deprecated, use FlxBlitRenderer._helperPoint, instead")
	var _helperPoint(get, set):Point;
	inline function get__helperPoint():Point 
	{ 
		return cast(FlxG.renderer, FlxBlitRenderer)._helperPoint;
	}
	inline function set__helperPoint(value:Point):Point 
	{
		return cast(FlxG.renderer, FlxBlitRenderer)._helperPoint = value;
	}

	/**
	 * Currently used draw stack item
	 */
	@:deprecated("_currentDrawItem is deprecated, use camera.viewQuad._currentDrawItem, instead")
	var _currentDrawItem(get, set):FlxDrawBaseItem<Dynamic>;
	inline function get__currentDrawItem():FlxDrawBaseItem<Dynamic> return viewQuad._currentDrawItem;
	inline function set__currentDrawItem(value:FlxDrawBaseItem<Dynamic>):FlxDrawBaseItem<Dynamic> return viewQuad._currentDrawItem = value;

	/**
	 * Pointer to head of stack with draw items
	 */
	@:deprecated("_headOfDrawStack is deprecated, use camera.viewQuad._headOfDrawStack, instead")
	var _headOfDrawStack(get, set):FlxDrawBaseItem<Dynamic>;
	inline function get__headOfDrawStack():FlxDrawBaseItem<Dynamic> return viewQuad._headOfDrawStack;
	inline function set__headOfDrawStack(value:FlxDrawBaseItem<Dynamic>):FlxDrawBaseItem<Dynamic> return viewQuad._headOfDrawStack = value;

	/**
	 * Last draw tiles item
	 */
	@:deprecated("_headTiles is deprecated, use camera.viewQuad._headTiles, instead")
	var _headTiles(get, set):FlxDrawQuadsItem;
	inline function get__headTiles():FlxDrawQuadsItem return viewQuad._headTiles;
	inline function set__headTiles(value:FlxDrawQuadsItem):FlxDrawQuadsItem return viewQuad._headTiles = value;

	/**
	 * Last draw triangles item
	 */
	@:deprecated("_headTriangles is deprecated, use camera.viewQuad._headTriangles, instead")
	var _headTriangles(get, set):FlxDrawTrianglesItem;
	inline function get__headTriangles():FlxDrawTrianglesItem return viewQuad._headTriangles;
	inline function set__headTriangles(value:FlxDrawTrianglesItem):FlxDrawTrianglesItem return viewQuad._headTriangles = value;

	/**
	 * Draw tiles stack items that can be reused
	 */
	@:deprecated("_storageTilesHead is deprecated, use FlxQuadView._storageTilesHead, instead")
	static var _storageTilesHead(get, set):FlxDrawQuadsItem;
	static inline function get__storageTilesHead():FlxDrawQuadsItem return FlxQuadView._storageTilesHead;
	static inline function set__storageTilesHead(value:FlxDrawQuadsItem):FlxDrawQuadsItem return FlxQuadView._storageTilesHead = value;

	/**
	 * Draw triangles stack items that can be reused
	 */
	@:deprecated("_storageTrianglesHead is deprecated, use FlxQuadView._storageTrianglesHead, instead")
	static var _storageTrianglesHead(get, set):FlxDrawTrianglesItem;
	static inline function get__storageTrianglesHead():FlxDrawTrianglesItem return FlxQuadView._storageTrianglesHead;
	static inline function set__storageTrianglesHead(value:FlxDrawTrianglesItem):FlxDrawTrianglesItem return FlxQuadView._storageTrianglesHead = value;

	/**
	 * Internal variable, used for visibility checks to minimize `drawTriangles()` calls.
	 */
	@:deprecated("drawVertices is deprecated, use FlxBlitRenderer.drawVertices, instead")
	static var drawVertices(get, set):Vector<Float>;
	static inline function get_drawVertices():Vector<Float> return FlxBlitRenderer.drawVertices;
	static inline function set_drawVertices(value:Vector<Float>):Vector<Float> return FlxBlitRenderer.drawVertices = value;

	/**
	 * Internal variable, used in blit render mode to render triangles (`drawTriangles()`) on camera's buffer.
	 */
	@:deprecated("trianglesSprite is deprecated, use FlxBlitRenderer.trianglesSprite, instead")
	static var trianglesSprite(get, set):Sprite;
	static inline function get_trianglesSprite():Sprite return FlxBlitRenderer.trianglesSprite;
	static inline function set_trianglesSprite(value:Sprite):Sprite return FlxBlitRenderer.trianglesSprite = value;

	/**
	 * Internal variables, used in blit render mode to draw trianglesSprite on camera's buffer.
	 * Added for less garbage creation.
	 */
	@:deprecated("renderPoint is deprecated, use FlxBlitRenderer.renderPoint, instead")
	static var renderPoint(get, set):FlxPoint;
	static inline function get_renderPoint():FlxPoint return FlxBlitRenderer.renderPoint;
	static inline function set_renderPoint(value:FlxPoint):FlxPoint return FlxBlitRenderer.renderPoint = value;

	@:deprecated("renderRect is deprecated, use FlxBlitRenderer.renderRect, instead")
	static var renderRect(get, set):FlxRect;
	static inline function get_renderRect():FlxRect return FlxBlitRenderer.renderRect;
	static inline function set_renderRect(value:FlxRect):FlxRect return FlxBlitRenderer.renderRect = value;

	@:noCompletion
	public function startQuadBatch(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false, ?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader)
	{
		return viewQuad.startQuadBatch(graphic, colored, hasColorOffsets, blend, smooth, shader);
	}

	@:noCompletion
	public function startTrianglesBatch(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, ?blend:BlendMode, ?hasColorOffsets:Bool, ?shader:FlxShader):FlxDrawTrianglesItem
	{
		return viewQuad.startTrianglesBatch(graphic, smoothing, isColored, blend, hasColorOffsets, shader);
	}

	@:noCompletion
	public function getNewDrawTrianglesItem(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, ?blend:BlendMode, ?hasColorOffsets:Bool, ?shader:FlxShader):FlxDrawTrianglesItem
	{
		return viewQuad.getNewDrawTrianglesItem(graphic, smoothing, isColored, blend, hasColorOffsets, shader);
	}

	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	function clearDrawStack():Void
	{
		viewQuad.clearDrawStack();
	}

	@:deprecated("camera.drawPixels() is deprecated, use FlxG.renderer.drawPixels() instead.")
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false,
			?shader:FlxShader):Void
	{
		FlxG.renderer.begin(this);
		FlxG.renderer.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
	}

	@:deprecated("camera.copyPixels() is deprecated, use FlxG.renderer.copyPixels() instead.")
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
			?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		FlxG.renderer.begin(this);
		FlxG.renderer.copyPixels(frame, pixels, sourceRect, destPoint, transform, blend, smoothing, shader);
	}

	@:deprecated("camera.drawTriangles() is deprecated, use FlxG.renderer.drawTriangles() instead.")
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
			?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader):Void
	{
		FlxG.renderer.begin(this);
		FlxG.renderer.drawTriangles(graphic, vertices, indices, uvtData, colors, position, blend, repeat, smoothing, transform, shader);
	}

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
	 * Helper method for applying transformations (scaling and offsets)
	 * to specified display objects which has been added to the camera display list.
	 * For example, debug sprite for nape debug rendering.
	 * @param	object	display object to apply transformations to.
	 * @return	transformed object.
	 */
	inline function transformObject(object:DisplayObject):DisplayObject
	{
		return view.transformObject(object);
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

		view = FlxCameraView.create(this);
		if (view is FlxQuadView)
			viewQuad = cast view;
		else if (view is FlxBlitView)
			viewBlit = cast view;

		pixelPerfectRender = FlxG.renderBlit;

		set_color(FlxColor.WHITE);
		
		// sets the scale of flash sprite, which in turn loads flashOffset values
		this.zoom = initialZoom = zoom;
		
		updateScrollRect();
		updateFlashOffset();
		updateFlashSpritePosition();
		updateInternalSpritePositions();

		bgColor = FlxG.cameras.bgColor;
	}

	/**
	 * Clean up memory.
	 */
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
	 * Fill the camera with the specified color.
	 *
	 * @param   color        The color to fill with in `0xAARRGGBB` hex format.
	 * @param   blendAlpha   Whether to blend the alpha value or just wipe the previous contents. Default is `true`.
	 */
	@:deprecated("camera.fill() is deprecated, use FlxG.renderer.fill() instead.")
	public function fill(color:FlxColor, blendAlpha:Bool = true, fxAlpha:Float = 1.0, ?graphics:Graphics):Void
	{
		color.alphaFloat = fxAlpha;

		FlxG.renderer.begin(this);

		if (viewQuad != null && graphics != null)
			viewQuad.targetGraphics = graphics;

		FlxG.renderer.fill(color, blendAlpha);
	}

	/**
	 * Internal helper function, handles the actual drawing of all the special effects.
	 */
	@:allow(flixel.system.render.FlxCameraView)
	function drawFX():Void
	{
		FlxG.renderer.begin(this);

		// Draw the "flash" special effect onto the buffer
		if (_fxFlashAlpha > 0.0)
		{
			var color = _fxFlashColor;
			color.alphaFloat *= _fxFlashAlpha;
			FlxG.renderer.fill(color);
		}
		
		// Draw the "fade" special effect onto the buffer
		if (_fxFadeAlpha > 0.0)
		{
			var color = _fxFadeColor;
			color.alphaFloat *= _fxFadeAlpha;
			FlxG.renderer.fill(color);
		}
	}

	@:deprecated("checkResize() is deprecated")
	function checkResize():Void
	{
		if (FlxG.renderBlit)
			viewBlit.checkResize();
	}

	@:deprecated("updateBlitMatrix() is deprecated, use camera.viewBlit.updateBlitMatrix(), instead")
	inline function updateBlitMatrix():Void
	{
		viewBlit.updateBlitMatrix();
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

	function set_alpha(alpha:Float):Float
	{
		this.alpha = FlxMath.bound(alpha, 0, 1);
		view.alpha = alpha;
		return alpha;
	}

	function set_angle(angle:Float):Float
	{
		this.angle = angle;
		view.angle = angle;
		return angle;
	}

	function set_color(color:FlxColor):FlxColor
	{
		this.color = color;
		view.color = color;
		return color;
	}

	function set_antialiasing(antialiasing:Bool):Bool
	{
		this.antialiasing = antialiasing;
		view.antialiasing = antialiasing;
		return antialiasing;
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

	override function set_visible(visible:Bool):Bool
	{
		view.visible = visible;
		return this.visible = visible;
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

	inline function get_display():DisplayObjectContainer
	{
		return view.display;
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
