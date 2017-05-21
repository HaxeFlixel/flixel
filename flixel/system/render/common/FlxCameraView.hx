package flixel.system.render.common;

import flixel.FlxCamera;
import flixel.effects.FlxRenderTarget;
import flixel.graphics.FlxMaterial;
import flixel.graphics.FlxTrianglesData;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

// TODO: add pure opengl version of camera view, so it will work on nme...
// TODO: add stage3d version of camera view...

/**
 * ...
 * @author Zaphod
 */
class FlxCameraView implements IFlxDestroyable
{
	// Batching related static variables and constants:
	public static inline var MAX_INDICES_PER_BUFFER:Int = 98298;
	public static inline var MAX_VERTEX_PER_BUFFER:Int = 65532;		// (MAX_INDICES_PER_BUFFER * 4 / 6)
	public static inline var MAX_QUADS_PER_BUFFER:Int = 16383;		// (MAX_VERTEX_PER_BUFFER / 4)
	public static inline var MAX_TRIANGLES_PER_BUFFER:Int = 21844;	// (MAX_VERTEX_PER_BUFFER / 3)
	
	public static inline var VERTICES_PER_QUAD:Int = 4;
	
	public static inline var TRIANGLES_PER_QUAD:Int = 2;
	
	public static inline var INDICES_PER_TRIANGLE:Int = 3;
	
	public static inline var INDICES_PER_QUAD:Int = 6;
	
	/**
	 * Max size of the batch. Used for quad render items. If you'll try to add one more tile to the full batch, then new batch will be started.
	 */
	public static var QUADS_PER_BATCH(default, set):Int = 2000;
	
	private static function set_QUADS_PER_BATCH(value:Int):Int
	{
		QUADS_PER_BATCH = (value > MAX_QUADS_PER_BUFFER) ? MAX_QUADS_PER_BUFFER : value;
		return QUADS_PER_BATCH;
	}
	
	public static var TRIANGLES_PER_BATCH(default, set):Int = 2600;
	
	private static function set_TRIANGLES_PER_BATCH(value:Int):Int
	{
		TRIANGLES_PER_BATCH = (value > MAX_TRIANGLES_PER_BUFFER) ? MAX_TRIANGLES_PER_BUFFER : value;
		return TRIANGLES_PER_BATCH;
	}
	
	/**
	 * Whether to batch drawTriangles() calls or not.
	 * Default value is true.
	 */
	public static var BATCH_TRIANGLES:Bool = #if FLX_RENDER_GL false #else true #end;
	
	/**
	 * Tracks total number of `drawTiles()` calls made each frame.
	 */
	public static var drawCalls:Int = 0;
	
	/**
	 * Display object which is used as a container for all the camera's graphic.
	 * This object is added to display tree.
	 */
	public var display(get, never):DisplayObjectContainer;
	/**
	 * Parent camera for this view.
	 */
	public var camera(default, null):FlxCamera;
	/**
	 * Camera's smoothing.
	 */
	public var smoothing(get, set):Bool;
	/**
	 * Camera's tint factor
	 */
	public var color(get, set):FlxColor;
	
	public var alpha(get, set):Float;
	
	public var visible(get, set):Bool;
	
	public var angle(get, set):Float;
	
	/**
	 * Sometimes it's easier to just work with a `FlxSprite` than it is to work directly with the `BitmapData` buffer.
	 * This sprite reference will allow you to do exactly that.
	 * Basically this sprite's `pixels` property is camera's `BitmapData` buffer.
	 * NOTE: This varible is used only in blit render mode.
	 * 
	 * The FlxBloom demo shows how you can use this variable in blit render mode.
	 * @see http://haxeflixel.com/demos/FlxBloom/
	 */
	public var screen:FlxSprite;
	
	/**
	 * The actual `BitmapData` of the camera display itself.
	 * Used in blit render mode, where you can manipulate its pixels for achieving some visual effects.
	 */
	public var buffer(get, null):BitmapData;
	
	/**
	 * Sprite used for actual rendering in tile render mode (instead of `_flashBitmap` for blitting).
	 * Its graphics is used as a drawing surface for `drawTriangles()` and `drawTiles()` methods.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	public var canvas(get, null):DisplayObjectContainer;
	
	/**
	 * Difference between native size of camera and zoomed size, divided in half
	 * Needed to do occlusion of objects when zoom != initialZoom
	 */
	public var viewOffsetX(default, null):Float = 0;
	public var viewOffsetY(default, null):Float = 0;
	
	/**
	 * The size of the camera plus view offset.
	 * These variables are used for object visibility checks.
	 */
	public var viewOffsetWidth(default, null):Float = 0;
	public var viewOffsetHeight(default, null):Float = 0;
	
	/**
	 * Dimensions of area visible at current camera zoom.
	 */
	public var viewWidth(default, null):Float = 0;
	public var viewHeight(default, null):Float = 0;
	
	/**
	 * Internal, used for positioning camera's `flashSprite` on screen.
	 * Basically it represents position of camera's center point in game sprite.
	 * It's recalculated every time you resize game or camera.
	 * Its value dependes on camera's size (`width` and `height`), game's `scale` and camera's initial zoom factor.
	 * Do not modify it unless you know what are you doing.
	 */
	private var _flashOffset:FlxPoint = FlxPoint.get();
	
	/**
	 * Internal, the filters array to be applied to the camera.
	 */
	private var _filters:Array<BitmapFilter>;
	
	/**
	 * Helper rect for drawTriangles visibility checks
	 */
	@:allow(flixel.system.render)
	private var _bounds:FlxRect = FlxRect.get();
	
	public var bounds(get, null):FlxRect;
	
	public function new(camera:FlxCamera) 
	{
		this.camera = camera;
		
		screen = new FlxSprite();
	}
	
	public function destroy():Void
	{
		_filters = null;
		_bounds = null;
		camera = null;
		screen = FlxDestroyUtil.destroy(screen);
		_flashOffset = FlxDestroyUtil.put(_flashOffset);
	}
	
	public function updateOffset():Void
	{
		_flashOffset.x = camera.width * 0.5 * FlxG.scaleMode.scale.x * camera.initialZoom;
		_flashOffset.y = camera.height * 0.5 * FlxG.scaleMode.scale.y * camera.initialZoom;
	}
	
	public function updatePosition():Void {}
	
	public function updateScrollRect():Void {}
	
	public function updateInternals():Void {}
	
	public function updateFilters():Void {}
	
	public function updateScale():Void 
	{
		calcOffsetX();
		calcOffsetY();
	}
	
	public function checkResize():Void {}
	
	public function fill(Color:FlxColor, BlendAlpha:Bool = true, Alpha:Float = 1.0):Void {}
	
	public function drawFX(FxColor:FlxColor, FxAlpha:Float = 1.0):Void {}
	
	public function lock(useBufferLocking:Bool):Void {}
	
	public function unlock(useBufferLocking:Bool):Void {}
	
	public function clear():Void {}
	
	public function offsetView(X:Float, Y:Float):Void {}
	
	public function setFilters(filters:Array<BitmapFilter>):Void 
	{ 
		_filters = filters;
	}
	
	@:allow(flixel.FlxCamera)
	private function render():Void {}
	
	public function beginDrawDebug():Void {}
	
	public function endDrawDebug(?matrix:FlxMatrix):Void {}
	
	public function drawDebugRect(x:Float, y:Float, width:Float, height:Float, color:Int, thickness:Float = 1.0, alpha:Float = 1.0):Void {}
	
	public function drawDebugFilledRect(x:Float, y:Float, width:Float, height:Float, color:Int, alpha:Float = 1.0):Void {}
	
	public function drawDebugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:Int, thickness:Float = 1.0, alpha:Float = 1.0):Void {}
	
	public function drawDebugTriangles(matrix:FlxMatrix, data:FlxTrianglesData, color:Int, thickness:Float = 1, alpha:Float = 1.0):Void {}
	
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, matrix:FlxMatrix,
		?transform:ColorTransform):Void {}
	
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform):Void {}
	
	public function drawTriangles(bitmap:BitmapData, material:FlxMaterial, data:FlxTrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform):Void {}
	
	public function drawUVQuad(bitmap:BitmapData, material:FlxMaterial, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix,
		?transform:ColorTransform):Void {}
	
	public function drawColorQuad(material:FlxMaterial, rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0):Void {}
	
	public function setRenderTarget(?target:FlxRenderTarget):Void {}
	
	/**
	 * Helper method preparing debug rectangle for rendering in blit render mode
	 * @param	rect	rectangle to prepare for rendering
	 * @return	trasformed rectangle with respect to camera's zoom factor
	 */
	@:noCompletion
	public function transformRect(rect:FlxRect):FlxRect
	{
		return rect;
	}
	
	/**
	 * Helper method preparing debug point for rendering in blit render mode (for debug path rendering, for example)
	 * @param	point		point to prepare for rendering
	 * @return	trasformed point with respect to camera's zoom factor
	 */
	@:noCompletion
	public function transformPoint(point:FlxPoint):FlxPoint
	{
		return point;
	}
	
	/**
	 * Helper method preparing debug vectors (relative positions) for rendering in blit render mode
	 * @param	vector	relative position to prepare for rendering
	 * @return	trasformed vector with respect to camera's zoom factor
	 */
	@:noCompletion
	public function transformVector(vector:FlxPoint):FlxPoint
	{
		return vector;
	}
	
	/**
	 * Helper method for applying transformations (scaling and offsets) 
	 * to specified display objects which has been added to the camera display list.
	 * For example, debug sprite for nape debug rendering.
	 * @param	object	display object to apply transformations to.
	 * @return	transformed object.
	 */
	@:noCompletion
	public function transformObject(object:DisplayObject):DisplayObject
	{
		return object;
	}
	
	private function get_color():FlxColor
	{
		return camera.color;
	}
	
	private function set_color(Color:FlxColor):FlxColor
	{
		return Color;
	}
	
	private function get_alpha():Float
	{
		return camera.alpha;
	}
	
	private function set_alpha(Alpha:Float):Float
	{
		return Alpha;
	}
	
	private function set_smoothing(Smoothing:Bool):Bool
	{
		return Smoothing;
	}
	
	private function get_smoothing():Bool
	{
		return camera.smoothing;
	}
	
	private function get_visible():Bool
	{
		return camera.visible;
	}
	
	private function set_visible(visible:Bool):Bool
	{
		return visible;
	}
		
	private function get_angle():Float
	{
		return camera.angle;
	}
	
	private function set_angle(Angle:Float):Float
	{
		return Angle;
	}
	
	private function get_display():DisplayObjectContainer
	{
		return null;
	}
	
	private function get_bounds():FlxRect
	{
		_bounds.set(0, 0, camera.width, camera.height);
		return _bounds;
	}
	
	private function get_buffer():BitmapData
	{
		return null;
	}
	
	private function get_canvas():DisplayObjectContainer
	{
		return null;
	}
	
	public function calcOffsetX():Void
	{
		viewOffsetX = 0.5 * camera.width * (camera.scaleX - camera.initialZoom) / camera.scaleX;
		viewOffsetWidth = camera.width - viewOffsetX;
		viewWidth = camera.width - 2 * viewOffsetX;
	}
	
	public function calcOffsetY():Void
	{
		viewOffsetY = 0.5 * camera.height * (camera.scaleY - camera.initialZoom) / camera.scaleY;
		viewOffsetHeight = camera.height - viewOffsetY;
		viewHeight = camera.height - 2 * viewOffsetY;
	}
}