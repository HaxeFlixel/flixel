package flixel.system.render;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
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
typedef FlxRenderer = FlxTypedRenderer<FlxCameraView>;

/**
 * Typed Renderer, override this to handle specific backends that require specific cavera views
 */
abstract class FlxTypedRenderer<TView:FlxCameraView> implements IFlxDestroyable
{
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
			return cast new flixel.system.render.blit.FlxBlitRenderer();
		}
		else
		{
			return cast new flixel.system.render.quad.FlxQuadRenderer();
		}
	}
	
	/**
	 * The number of total draw calls in the current frame.
	 */
	public var totalDrawCalls:Int = 0;
	
	/**
	 * Returns the current render method as an enum.
	 */
	public var method(default, null):FlxRenderMethod;
	
	public var blit(get, never):Bool;
	inline function get_blit() return method.match(BLITTING);
	
	public var tile(get, never):Bool;
	inline function get_tile() return method.match(DRAW_TILES);
	
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
	public var maxTextureSize(default, null):Int = -1;
	
	function new() {}
	
	/**
	 * Initializes and global fields that are dependant on the global rendering method.
	 * Called automatically by `FlxG.init`
	 */
	public function initGlobals() {}
	
	public function destroy():Void {}
	
	abstract function createCameraView(camera:FlxCamera):TView;
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
	
	/**
	 * A custom backend
	 */
	CUSTOM;
}
