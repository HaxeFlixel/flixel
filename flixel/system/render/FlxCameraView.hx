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
@:access(flixel.FlxCamera)
abstract class FlxCameraView implements IFlxDestroyable
{
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
	 * Whether the camera display is smooth and filtered, or chunky and pixelated.
	 * Default behavior is chunky-style.
	 */
	public var antialiasing(default, set):Bool;

	/**
	 * A shortcut for `camera.angle`. Used so implementations can listen to changes.
	 */
	public var angle(default, set):Float;

	/**
	 * A shortcut for `camera.alpha`. Used so implementations can listen to changes.
	 */
	public var alpha(default, set):Float;

	/**
	 * A shortcut for `camera.color`. Used so implementations can listen to changes.
	 */
	public var color(default, set):FlxColor;

	/**
	 * A shortcut for `camera.visible`. Used so implementations can listen to changes.
	 */
	public var visible(default, set):Bool;
	
	function new(camera:FlxCamera)
	{
		this.camera = camera;
	}
	
	public function destroy():Void {}
	
	// =============================================================================
	//{ region                             REDNERING
	// =============================================================================
	
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
	
	
	// =============================================================================
	//} endregion                          REDNERING
	// =============================================================================
	
	public function offsetView(x:Float, y:Float):Void {}
	
	function updateScale():Void {}
	
	function updatePosition():Void {}
	
	function updateInternals():Void {}
	
	function updateOffset():Void {}
	
	function updateScrollRect():Void {}
	
	// =============================================================================
	//{ region                             DEBUG DRAW
	// =============================================================================
	
	/**
	 * Begins debug draw on the current (or optionally specified) camera.
	 * Any debug drawing commands will be executed on the camera.
	 * 
	 * @param camera Optional, the camera to draw to.
	 */
	abstract public function beginDrawDebug():Void;
	
	/**
	 * Cleans up and finalizes the debug draw.
	 */
	abstract public function endDrawDebug():Void;
	
	#if FLX_DEBUG
	
	abstract public function getDebugBuffer():FlxVertexBuffer;
	
	abstract function worldToDebugX(worldX:Float):Float;//TODO: find out what "debug space" actually is, rename and make public
	abstract function worldToDebugY(worldY:Float):Float;//TODO: find out what "debug space" actually is, rename and make public
	
	#end
	
	// =============================================================================
	//} endregion                          DEBUG DRAW
	// =============================================================================
	
	// =============================================================================
	//{ region                             HELPERS
	// =============================================================================
	
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
	
	// =============================================================================
	//} endregion                          HELPERS
	// =============================================================================
	
	// =============================================================================
	//{ region                             GETTERS
	// =============================================================================
	
	abstract function get_display():DisplayObjectContainer;
	
	@:haxe.warning("-WDeprecated")
	function set_antialiasing(value:Bool):Bool
	{
		camera.setAntialiasingBypass(value);
		return this.antialiasing = value;
	}
	
	function set_color(value:FlxColor):FlxColor
	{
		camera.setColorBypass(value);
		return this.color = value;
	}
	
	function set_angle(value:Float):Float
	{
		camera.setAngleBypass(value);
		return this.angle = value;
	}
	
	function set_visible(value:Bool):Bool
	{
		camera.setVisibleBypass(value);
		return this.visible = value;
	}
	
	function set_alpha(value:Float):Float
	{
		camera.setAlphaBypass(value);
		return this.alpha = value;
	}
	
	// @:bypassAccess doesn't work from external classes in haxe 4. So call this when needed
	@:noCompletion inline function setColorBypass       (value:FlxColor):FlxColor return @:bypassAccessor this.color = value;
	@:noCompletion inline function setAlphaBypass       (value:Float   ):Float    return @:bypassAccessor this.alpha = value;
	@:noCompletion inline function setAngleBypass       (value:Float   ):Float    return @:bypassAccessor this.angle = value;
	@:noCompletion inline function setAntialiasingBypass(value:Bool    ):Bool     return @:bypassAccessor this.antialiasing = value;
	@:noCompletion inline function setVisibleBypass     (value:Bool    ):Bool     return @:bypassAccessor this.visible = value;
	
	// =============================================================================
	//} endregion                          GETTERS
	// =============================================================================
}
