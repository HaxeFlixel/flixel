package flixel.system.render;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * `FlxRenderer` is the base class for all rendering functionality.
 * It does not contain any rendering logic by itself, rather it is extended by the various renderer implementations.
 * 
 * You can access a global renderer instance via `FlxG.renderer`.
 * 
 * The `FlxRenderer` API replaces the previous renderer implementation in `FlxCamera`.
 * Because it's not tied to a camera, it also works slightly differently.
 * Before any drawing commands are executed, `FlxG.renderer.begin(camera);` is called to use the camera as a render target.
 * This is called internally by Flixel during a sprite's draw phase, so you shouldn't worry about calling it yourself unless
 * you have a reason to.
 */
class FlxRenderer implements IFlxDestroyable
{
    /**
	 * The number of total draw calls in the current frame.
	 */
    public static var totalDrawCalls:Int = 0;

    /**
     * Creates a renderer instance, based on the used rendering backend.
     * This function is dynamic, which means that you can change the return value yourself.
     * 
     * @return A `FlxRenderer` instance.
     */
    public static dynamic function create():FlxRenderer 
    {
        if (!FlxG.renderer.isHardware)
        {
            return new flixel.system.render.blit.FlxBlitRenderer();
        }
        else
        {
            return new flixel.system.render.quad.FlxQuadRenderer();
        }
    }

    /**
     * Returns the current render method as an enum.
     */
    public var method(default, null):FlxRenderMethod;

    /**
     * Returns whether the current renderer is hardware accelerated.
     */
    public var isHardware(get, never):Bool;
    @:noCompletion inline function get_isHardware():Bool
    {
        return FlxG.stage.window.context.attributes.hardware;
    }

    /**
     * Returns whether OpenGL access is available for the current renderer.
     */
    public var isGL(get, never):Bool;
    @:noCompletion inline function get_isGL():Bool
    {
        #if FLX_OPENGL_AVAILABLE
		return FlxG.stage.window.context.type == OPENGL
			|| FlxG.stage.window.context.type == OPENGLES
			|| FlxG.stage.window.context.type == WEBGL;
        #else
        return false;
        #end
    }

    /**
	 * Returns the maximum allowed width and height (in pixels) for a texture.
	 * This value is only available on hardware-accelerated targets that use OpenGL.
	 * On unsupported targets, the returned value will always be -1.
	 * 
	 * @see https://opengl.gpuinfo.org/displaycapability.php?name=GL_MAX_TEXTURE_SIZE
	 */
    public var maxTextureSize(default, null):Int;

    /**
     * The current camera in use.
     */
    public var camera(default, null):FlxCamera;

    public function new() 
    {
        maxTextureSize = -1;
    }

    public function destroy():Void 
    {
        camera = null;
    }

    // ------------------------ RENDERING ------------------------

    /**
     * Sets `camera` as the current render target.
     * Any drawing commands will be executed on the camera.
     * 
     * **NOTE:** Manually calling this during the draw phase could mess things up.
     * If you must, please remember to reset the state back to where it was
     * 
     * @param   camera   The camera to draw to.
     */
    public function begin(camera:FlxCamera):Void 
    {
        this.camera = camera;
    }

    /**
	 * Called before a new rendering frame, clears all previously drawn graphics.
	 */
    public function clear():Void {}

    /**
	 * Flushes any remaining graphics and renders everything to the screen.
	 */
    public function render():Void {}

    /**
     * Draws `frame` or `pixels` (depends on the renderer backend) onto the current render target.
     * 
     * @param   frame       The frame to draw (used only with the DRAW_TILES renderer).
     * @param   pixels      The pixels to draw (used only with the BLITTING renderer).
     * @param   matrix      The transformation matrix to use.
     * @param   transform   The color transform to use, optional.
     * @param   blend       The blend mode to use, optional.
     * @param   smoothing   Whether to use smoothing (anti-aliasing) when drawing.
     * @param   shader      The shader to use, optional (used only with the DRAW_TILES renderer).
     */
    public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false,
		?shader:FlxShader):Void {}
	
	/**
	 * Draws `frame` or `pixels` (depends on the renderer backend) onto the current render target.
     * 
     * Unlike `drawPixels()`, this method does not use a matrix. This means that complex transformations
     * are not supported with this method. The `destPoint` argument is used to determine the position to draw to.
     * 
	 * @param   frame        The frame to draw (used only with the DRAW_TILES renderer).
	 * @param   pixels       The pixels to draw (used only with the BLITTING renderer).
	 * @param   sourceRect   A rectangle that defines the area of the pixels to use (used only with the BLITTING renderer).
	 * @param   destPoint    A point representing the top-left position to draw to.
	 * @param   transform    The color transform to use, optional.
	 * @param   blend        The blend mode to use, optional.
	 * @param   smoothing    Whether to use smoothing (anti-aliasing) when drawing.
	 * @param   shader       The shader to use, optional (used only with the DRAW_TILES renderer).
	 */
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
		smoothing:Bool = false, ?shader:FlxShader):Void {}
	
	/**
	 * Draws a set of triangles onto the current render target.
     * 
	 * @param   graphic     The graphic to use for the triangles.
	 * @param   vertices    A vector where each element is a coordinate location. 2 elements make up an (x, y) pair.
	 * @param   indices     A vector where each element is an index to a vertex (x, y) pair. 3 indices make up a triangle.
	 * @param   uvtData     A vector where each element is a normalized coordinate (from 0.0 to 1.0), per vertex, used to apply texture mapping.
	 * @param   colors      A vector containing the colors to use per vertex. Currently does not work with any renderer.
	 * @param   position    A point representing the top-left position to draw to.
	 * @param   blend       The blend mode to use, optional.
	 * @param   repeat      Whether the graphic should repeat.
	 * @param   smoothing   Whether to use smoothing (anti-aliasing) when drawing.
	 * @param   transform   The color transform to use, optional.
	 * @param   shader      The shader to use, optional (used only with the DRAW_TILES renderer).
	 */
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
		?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader):Void {}

    /**
     * Fills the current render target with `color`.
     * 
     * @param   color        The color (in 0xAARRGGBB format) to fill the screen with.
     * @param   blendAlpha   Whether to blend the alpha value or just wipe the previous contents.
     */
    public function fill(color:FlxColor, blendAlpha:Bool = true):Void {}

    // ------------------------ DEBUG DRAW ------------------------

    /**
     * Begins debug draw on the current (or optionally specified) camera.
     * Any debug drawing commands will be executed on the camera.
     * 
     * @param camera Optional, the camera to draw to.
     */
    public function beginDrawDebug(?camera:FlxCamera):Void
    {
        if (camera != null)
        {
            this.camera = camera;
        }
    }

    /**
     * Cleans up and finalizes the debug draw.
     */
    public function endDrawDebug():Void {}

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
    public function drawDebugRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1.0):Void {}
	
    /**
     * Draws a filled rectangle.
     * 
     * @param   x           The x position of the rectangle.
     * @param   y           The y position of the rectangle.
     * @param   width       The width of the rectangle (in pixels).
     * @param   height      The height of the rectangle (in pixels).
     * @param   color       The color (in 0xAARRGGBB hex format) of the rectangle's fill.
     */
	public function drawDebugFilledRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void {}
	
	/**
	 * Draws a filled circle.
     * 
	 * @param   x        The x position of the circle.
	 * @param   y        The y position of the circle.
	 * @param   radius   The radius of the circle.
	 * @param   color    The color (in 0xAARRGGBB hex format) of the circle's fill.
	 */
	public function drawDebugFilledCircle(x:Float, y:Float, radius:Float, color:FlxColor):Void {}
	
	/**
	 * Draws a line.
     * 
	 * @param   x1          The start x position of the line.
	 * @param   y1          The start y position of the line.
	 * @param   x2          The end x position of the line.
	 * @param   y2          The end y position of the line.
	 * @param   color       The color (in 0xAARRGGBB hex format) of the line.
	 * @param   thickness   The thickness of the line.
	 */
	public function drawDebugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1.0):Void {}
}

/**
 * An enum representing the available rendering methods.
 */
enum FlxRenderMethod
{
    /**
     * Uses the `drawQuads()` method from OpenFL's Graphics API to achieve hardware accelerated rendering.
     * 
     * This method is the default and is used on all targets (when hardware acceleration is available), except for Flash.
     */
    DRAW_TILES;

    /**
     * Draws sprites directly onto bitmaps using a software renderer.
     * 
     * This method is mainly used by the Flash target, though other targets will use it too if
     * hardware acceleration is unavailable.
     */
    BLITTING;
}
