package flixel.system.render;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;

/**
 * A `FlxCameraView` is a helper added to cameras, that holds some rendering-related objects
 */
@:allow(flixel.FlxCamera)
abstract class FlxCameraView implements IFlxDestroyable
{	
	/**
	 * Creates a `FlxCameraView` object tied to a camera, based on the target and project configuration.
	 * This function is dynamic, which means that you can change the return value yourself.
	 * 
	 * @param   camera   The camera to create the view for
	 */
	public static dynamic function create(camera:FlxCamera):FlxCameraView
	{
		if (!FlxG.renderer.isHardware)
		{
			return cast new flixel.system.render.blit.FlxBlitView(camera);
		}
		else
		{
			return cast new flixel.system.render.quad.FlxQuadView(camera);
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
	 * Flushes any remaining graphics and renders everything to the screen.
	 */
	abstract public function render():Void;
	
	/**
	 * Called before a new rendering frame, clears all previously drawn graphics.
	 */
	abstract public function clear():Void;
	
	/**
	 * Fills the current render target with `color`.
	 * 
	 * @param   color        The color (in 0xAARRGGBB format) to fill the screen with.
	 * @param   blendAlpha   Whether to blend the alpha value or just wipe the previous contents.
	 */
	abstract public function fill(color:FlxColor, blendAlpha:Bool = true):Void;
	
	public function offsetView(x:Float, y:Float):Void {}

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
	
	function updateScrollRect():Void {}
	
	//{ region ------------------------ DEBUG DRAW ------------------------
	
	/**
	 * Begins debug draw on the current (or optionally specified) camera.
	 * Any debug drawing commands will be executed on the camera.
	 * 
	 * @param camera Optional, the camera to draw to.
	 */
	abstract public function beginDrawDebug():Graphics;
	
	abstract public function getDebugGraphics():Graphics;
	
	/**
	 * Cleans up and finalizes the debug draw.
	 */
	abstract public function endDrawDebug():Void;
	
	/**
	 * Draws a rectangle with an outline.
	 * 
	 * @param   x           The x position of the rectangle.
	 * @param   y           The y position of the rectangle.
	 * @param   width       The width of the rectangle (in pixels).
	 * @param   height      The height of the rectangle (in pixels).
	 * @param   color       The color (in 0xAARRGGBB hex format) of the rectangle's outline.
	 * @param   thickness   The thickness of the rectangle's outline.
	 */
	abstract public function drawDebugRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1.0):Void;
	
	/**
	 * Draws a filled rectangle.
	 * 
	 * @param   x       The x position of the rectangle.
	 * @param   y       The y position of the rectangle.
	 * @param   width   The width of the rectangle (in pixels).
	 * @param   height  The height of the rectangle (in pixels).
	 * @param   color   The color (in 0xAARRGGBB hex format) of the rectangle's fill.
	 */
	abstract public function drawDebugFilledRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void;
	
	/**
	 * Draws a filled circle.
	 * 
	 * @param   x       The x position of the circle.
	 * @param   y       The y position of the circle.
	 * @param   radius  The radius of the circle.
	 * @param   color   The color (in 0xAARRGGBB hex format) of the circle's fill.
	 */
	abstract public function drawDebugFilledCircle(x:Float, y:Float, radius:Float, color:FlxColor):Void;
	
	/**
	 * Draws a line.
	 * 
	 * @param   x1         The start x position of the line.
	 * @param   y1         The start y position of the line.
	 * @param   x2         The end x position of the line.
	 * @param   y2         The end y position of the line.
	 * @param   color      The color (in 0xAARRGGBB hex format) of the line.
	 * @param   thickness  The thickness of the line.
	 */
	abstract public function drawDebugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1.0):Void;
	
	//} endregion --------------------- DEBUG DRAW ------------------------
	
	//{ region ------------------------ HELPERS ---------------------------
	
	abstract function worldToDebugX(worldX:Float):Float;//TODO: find out what "debug space" actually is, rename and make public
	abstract function worldToDebugY(worldY:Float):Float;//TODO: find out what "debug space" actually is, rename and make public
	
	/**
	 * Helper method preparing debug rectangle for rendering in blit render mode
	 * @param   rect  Rectangle to prepare for rendering
	 * @return  Transformed rectangle with respect to camera's zoom factor
	 */
	function transformRect(rect:FlxRect):FlxRect
	{
		return rect;
	}
	
	/**
	 * Helper method preparing debug point for rendering in blit render mode (for debug path rendering, for example)
	 * @param   point  Point to prepare for rendering
	 * @return  Transformed point with respect to camera's zoom factor
	 */
	function transformPoint(point:FlxPoint):FlxPoint
	{
		return point;
	}
	
	/**
	 * Helper method preparing debug vectors (relative positions) for rendering in blit render mode
	 * @param   vector  Relative position to prepare for rendering
	 * @return  Transformed vector with respect to camera's zoom factor
	 */
	function transformVector(vector:FlxPoint):FlxPoint
	{
		return vector;
	}
	
	//} endregion --------------------- HELPERS ------------------------
	
	//{ region ------------------------ GETTERS ------------------------
	
	abstract function get_display():DisplayObjectContainer;
	
	function get_color():FlxColor
	{
		return camera.color;
	}
	
	function set_color(value:FlxColor):FlxColor
	{
		return camera.color = value;
	}
	
	function get_antialiasing():Bool
	{
		return camera.antialiasing;
	}
	
	function set_antialiasing(value:Bool):Bool
	{
		return camera.antialiasing = value;
	}
	
	function get_angle():Float
	{
		return camera.angle;
	}
	
	function set_angle(value:Float):Float
	{
		return camera.angle = value;
	}
	
	function get_visible():Bool
	{
		return camera.visible;
	}
	
	function set_visible(value:Bool):Bool
	{
		return camera.visible = value;
	}
	
	function get_alpha():Float
	{
		return camera.alpha;
	}
	
	function set_alpha(value:Float):Float
	{
		return camera.alpha = value;
	}
	
	//} endregion --------------------- GETTERS ------------------------
}
