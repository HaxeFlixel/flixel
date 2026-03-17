package flixel.system.render;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * A `FlxCameraView` is a helper added to cameras, that holds some rendering-related objects
 * @since 6.2.0
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
	//{ region                             RENDERING
	// =============================================================================
	
	/**
	 * Flushes any remaining graphics and renders everything to the screen.
	 */
	public function render()
	{
		throw "Not implemented";
		// Note: Abstract methods with default values are broken on cpp in haxe 4.3. https://github.com/HaxeFoundation/haxe/issues/11666
	}
	
	/**
	 * Called before a new rendering frame, clears all previously drawn graphics.
	 */
	public function clear()
	{
		throw "Not implemented";
		// Note: Abstract methods with default values are broken on cpp in haxe 4.3. https://github.com/HaxeFoundation/haxe/issues/11666
	}
	
	/**
	 * Fills the current render target with `color`.
	 * 
	 * @param   color        The color (in 0xAARRGGBB format) to fill the screen with.
	 * @param   blendAlpha   Whether to blend the alpha value or just wipe the previous contents.
	 */
	public function fill(color:FlxColor, blendAlpha:Bool = true)
	{
		throw "Not implemented";
		// Note: Abstract methods with default values are broken on cpp in haxe 4.3. https://github.com/HaxeFoundation/haxe/issues/11666
	}
	
	/**
	 * Draws the pixels onto the current render target.
	 * 
	 * @param   pixels      The pixels to draw.
	 * @param   transform   The color transform to use.
	 * @param   blend       The blend mode to use.
	 * @param   smoothing   Whether to use smoothing (anti-aliasing) when drawing.
	 * @param   shader      The shader to use.
	 */
	public function drawPixels(pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader:FlxShader)
	{
		throw "Not implemented";
		// Note: Abstract methods with default values are broken on cpp in haxe 4.3. https://github.com/HaxeFoundation/haxe/issues/11666
	}
	
	/**
	 * Draws the pixels onto the current render target.
	 * 
	 * Unlike `drawPixels()`, this method does not use a matrix. This means that complex transformations
	 * are not supported with this method. The `destPoint` argument is used to determine the position to draw to.
	 * 
	 * @param   pixels      The pixels to draw.
	 * @param   sourceRect  A rectangle that defines the area of the pixels to use.
	 * @param   destPoint   A point representing the top-left position to draw to.
	 * @param   transform   The color transform to use.
	 * @param   blend       The blend mode to use.
	 * @param   smoothing   Whether to use smoothing (anti-aliasing) when drawing.
	 * @param   shader      The shader to use.
	 */
	public function copyPixels(pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
		smoothing:Bool = false, ?shader:FlxShader)
	{
		throw "Not implemented";
		// Note: Abstract methods with default values are broken on cpp in haxe 4.3. https://github.com/HaxeFoundation/haxe/issues/11666
	}
	
	/**
	 * Draws the frame onto the current render target.
	 * 
	 * @param   frame       The frame to draw.
	 * @param   matrix      The transformation matrix to use.
	 * @param   transform   The color transform to use.
	 * @param   blend       The blend mode to use.
	 * @param   smoothing   Whether to use smoothing (anti-aliasing) when drawing.
	 * @param   shader      The shader to use.
	 */
	public function drawFrame(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false, ?shader:FlxShader)
	{
		throw "Not implemented";
		// Note: Abstract methods with default values are broken on cpp in haxe 4.3. https://github.com/HaxeFoundation/haxe/issues/11666
	}
	
	/**
	 * Draws the frame onto the current render target.
	 * 
	 * Unlike `drawFrame()`, this method does not use a matrix. This means that complex transformations
	 * are not supported with this method. The `destPoint` argument is used to determine the position to draw to.
	 * 
	 * @param   frame       The frame to draw
	 * @param   destPoint   A point representing the top-left position to draw to.
	 * @param   transform   The color transform to use.
	 * @param   blend       The blend mode to use.
	 * @param   smoothing   Whether to use smoothing (anti-aliasing) when drawing.
	 * @param   shader      The shader to use
	 */
	public function copyFrame(frame:FlxFrame, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader:FlxShader)
	{
		throw "Not implemented";
		// Note: Abstract methods with default values are broken on cpp in haxe 4.3. https://github.com/HaxeFoundation/haxe/issues/11666
	}
	
	/**
	 * Draws a set of triangles onto the current render target.
	 * 
	 * @param   graphic    The graphic to use for the triangles.
	 * @param   vertices   A vector where each element is a coordinate location. 2 elements make up an (x, y) pair.
	 * @param   indices    A vector where each element is an index to a vertex (x, y) pair. 3 indices make up a triangle.
	 * @param   uvtData    A vector where each element is a normalized coordinate (from 0.0 to 1.0), per vertex, used to apply texture mapping.
	 * @param   colors     A vector containing the colors to use per vertex. Currently does not work with any renderer.
	 * @param   position   A point representing the top-left position to draw to.
	 * @param   blend      The blend mode to use, optional.
	 * @param   repeat     Whether the graphic should repeat.
	 * @param   smoothing  Whether to use smoothing (anti-aliasing) when drawing.
	 * @param   transform  The color transform to use, optional.
	 * @param   shader     The shader to use, optional (used only with the DRAW_TILES renderer).
	 */
	public function drawTriangles(graphic:FlxGraphic, vertices:FlxVector2d<Float>, indices:FlxVector2d<Int>, uvtData:FlxVector2d<Float>, ?colors:FlxVector2d<Int>,
		?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader)
	{
		throw "Not implemented";
		// Note: Abstract methods with default values are broken on cpp in haxe 4.3. https://github.com/HaxeFoundation/haxe/issues/11666
	}
	
	// =============================================================================
	//} endregion                          RENDERING
	// =============================================================================
	
	abstract public function offsetView(x:Float, y:Float):Void;
	
	abstract function updateScale():Void;
	
	abstract function updatePosition():Void;
	
	abstract function updateInternals():Void;
	
	abstract function updateOffset():Void;
	
	abstract function updateScrollRect():Void;
	
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
