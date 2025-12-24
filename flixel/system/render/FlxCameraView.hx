package flixel.system.render;

import flixel.math.FlxRect;
import openfl.display.DisplayObjectContainer;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxMatrix;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.util.FlxColor;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.BitmapData;

/**
 * A `FlxCameraView` is the base class for all rendering functionality.
 * It does not contain any rendering logic by itself, rather it is extended by the various renderer implementations.
 */
@:allow(flixel.FlxCamera)
class FlxCameraView implements IFlxDestroyable
{
	/**
	 * The number of total draw calls in a frame.
	 */
	public static var totalDrawCalls:Int = 0;
	
	/**
	 * Creates a `FlxCameraView` object tied to a camera, based on the target and project configuration.
	 * @param camera The camera to create the view for
	 */
	public static inline function create(camera:FlxCamera):FlxCameraView
	{
		if (FlxG.renderTile)
		{
			return cast new flixel.system.render.quad.FlxQuadView(camera);
		}
		else
		{
			return cast new flixel.system.render.blit.FlxBlitView(camera);
		}
	}
	
	/**
	 * Display object which is used as a container for all of the camera's graphics.
	 * This object is added to the display tree.
	 */
	public var display(get, never):DisplayObjectContainer;
	
	/**
	 * The parent camera for this view.
	 */
	public var camera(default, null):FlxCamera;
	
	/**
	 * A shortcut for `camera.antialiasing`. Used so implementations can listen to changes.
	 */
	public var antialiasing(get, set):Bool;

	/**
	 * A shortcut for `camera.angle`. Used so implementations can listen to changes.
	 */
	public var angle(get, set):Float;

	/**
	 * A shortcut for `camera.alpha`. Used so implementations can listen to changes.
	 */
	public var alpha(get, set):Float;

	/**
	 * A shortcut for `camera.color`. Used so implementations can listen to changes.
	 */
	public var color(get, set):FlxColor;

	/**
	 * A shortcut for `camera.visible`. Used so implementations can listen to changes.
	 */
	public var visible(get, set):Bool;
	
	var _flashOffset:FlxPoint = FlxPoint.get();
	
	function new(camera:FlxCamera)
	{
		this.camera = camera;
	}
	
	public function destroy():Void
	{
		_flashOffset = FlxDestroyUtil.put(_flashOffset);
	}

	/**
	 * Called prior to the rendering call, clears the screen and prepares everything needed.
	 */
	public function clear():Void {}

	/**
	 * The actual rendering call where everything gets drawn.
	 */
	public function render():Void {}
	
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false,
		?shader:FlxShader):Void {}
		
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
		smoothing:Bool = false, ?shader:FlxShader):Void {}
		
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
		?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader):Void {}
		
	public function beginDrawDebug():Void {}
	
	public function endDrawDebug(?matrix:FlxMatrix):Void {}
	
	public function drawDebugRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1.0):Void {}
	
	public function drawDebugFilledRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void {}
	
	public function drawDebugFilledCircle(x:Float, y:Float, radius:Float, color:FlxColor):Void {}
	
	public function drawDebugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1.0):Void {}
	
	public function fill(color:FlxColor, blendAlpha:Bool = true):Void {}
	
	function drawFX():Void {}
	
	function updateScale():Void
	{
		camera.calcMarginX();
		camera.calcMarginY();
	}
	
	function updatePosition():Void {}
	
	function updateInternals():Void {}
	
	function updateOffset():Void
	{
		_flashOffset.x = camera.width * 0.5 * FlxG.scaleMode.scale.x * camera.initialZoom;
		_flashOffset.y = camera.height * 0.5 * FlxG.scaleMode.scale.y * camera.initialZoom;
	}
	
	public function offsetView(x:Float, y:Float):Void {}
	
	function updateScrollRect():Void {}
	
	/**
	 * Helper method preparing debug rectangle for rendering in blit render mode
	 * @param	rect	rectangle to prepare for rendering
	 * @return	transformed rectangle with respect to camera's zoom factor
	 */
	function transformRect(rect:FlxRect):FlxRect
	{
		return rect;
	}
	
	/**
	 * Helper method preparing debug point for rendering in blit render mode (for debug path rendering, for example)
	 * @param	point		point to prepare for rendering
	 * @return	transformed point with respect to camera's zoom factor
	 */
	function transformPoint(point:FlxPoint):FlxPoint
	{
		return point;
	}
	
	/**
	 * Helper method preparing debug vectors (relative positions) for rendering in blit render mode
	 * @param	vector	relative position to prepare for rendering
	 * @return	transformed vector with respect to camera's zoom factor
	 */
	function transformVector(vector:FlxPoint):FlxPoint
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
	function transformObject(object:DisplayObject):DisplayObject
	{
		object.scaleX *= camera.totalScaleX;
		object.scaleY *= camera.totalScaleY;
		
		object.x -= camera.scroll.x * camera.totalScaleX;
		object.y -= camera.scroll.y * camera.totalScaleY;
		
		object.x -= 0.5 * camera.width * (camera.scaleX - camera.initialZoom) * FlxG.scaleMode.scale.x;
		object.y -= 0.5 * camera.height * (camera.scaleY - camera.initialZoom) * FlxG.scaleMode.scale.y;
		
		return object;
	}
	
	function checkResize():Void {}
	
	function get_display():DisplayObjectContainer
	{
		return null;
	}
	
	function get_color():FlxColor
	{
		return camera.color;
	}
	
	function set_color(color:FlxColor):FlxColor
	{
		return color;
	}
	
	function get_antialiasing():Bool
	{
		return camera.antialiasing;
	}
	
	function set_antialiasing(antialiasing:Bool):Bool
	{
		return antialiasing;
	}
	
	function get_angle():Float
	{
		return camera.angle;
	}
	
	function set_angle(angle:Float):Float
	{
		return angle;
	}
	
	function get_visible():Bool
	{
		return camera.visible;
	}
	
	function set_visible(visible:Bool):Bool
	{
		return visible;
	}
	
	function get_alpha():Float
	{
		return camera.alpha;
	}
	
	function set_alpha(alpha:Float):Float
	{
		return alpha;
	}
}
