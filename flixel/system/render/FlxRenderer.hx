package flixel.system.render;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.display.BlendMode;
import flixel.math.FlxMatrix;
import flixel.util.FlxColor;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.FlxGraphic;

/**
 * A `FlxRenderer` is the base class for all rendering functionality.
 * It does not contain any rendering logic by itself, rather it is extended by the various renderer implementations.
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
     * @return FlxRenderer
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
        return isHardware && method == DRAW_TILES;
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

    /**
     * Shortcut to `currentCamera.view`.
     * Renderer implementations may override this to cast the return value to the
     * corresponding type for the implementation.
     */
    // public var currentView(get, never):FlxCameraView;
    // @:noCompletion function get_currentView<T:FlxCameraView>():T
    // {
    //     return currentCamera.view;
    // }
     

    public function new() {}

    public function destroy():Void 
    {
        camera = null;
    }

    /**
     * Called internally when it's safe to initialize rendering related properties.
     */
    @:allow(flixel.FlxG)
    function init():Void {}

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
        if (this.camera == camera)
            return;

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

    public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false,
		?shader:FlxShader):Void {}
		
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
		smoothing:Bool = false, ?shader:FlxShader):Void {}
		
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
		?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader):Void {}

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
            if (this.camera == camera) 
                return;

            this.camera = camera;
        }
    }

    public function endDrawDebug():Void {}

    public function drawDebugRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1.0):Void {}
	
	public function drawDebugFilledRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void {}
	
	public function drawDebugFilledCircle(x:Float, y:Float, radius:Float, color:FlxColor):Void {}
	
	public function drawDebugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1.0):Void {}
}

enum FlxRenderMethod
{
    DRAW_TILES;
    BLITTING;
}
