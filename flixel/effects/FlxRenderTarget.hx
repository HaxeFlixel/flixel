package flixel.effects;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.system.render.common.FlxRenderTexture;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * Special case of FlxSprite which can be used as a render target for other sprites.
 * You can achieve multi-render pass effects by using this class.
 */
class FlxRenderTarget extends FlxSprite
{
	/**
	 * Render texture of this sprite. All sprites which have `renderTarget` equal to this sprite, 
	 * will be rendered on this texture. 
	 */
	public var renderTexture(default, null):FlxRenderTexture;
	
	/**
	 * Camera used for calculations required for rendering (as if sprites were rendered on this camera).
	 * Default value is `FlxG.camera`
	 */
	public var renderCamera(get, set):FlxCamera;
	
	/**
	 * Whether render texture of this sprite should be cleared before next rendering iteration.
	 */
	public var clearBeforeRender:Bool = true;
	
	/**
	 * Color, used for clearing (filling with) render texture.
	 */
	public var clearColor(get, set):FlxColor;
	
	/**
	 * An array of cameras used for rendering of sprites.
	 * Always contain only one camera object - `renderCamera`.
	 */
	@:allow(flixel.FlxSprite)
	private var renderCameras(default, null):Array<FlxCamera>;
	
	/**
	 * Render target constructor
	 * 
	 * @param	Width			width of render target
	 * @param	Height			height of render target
	 * @param	Smoothing		smoothing of  render texture
	 * @param	PowerOfTwo		whether size of render texture should be multiple of two.
	 */
	public function new(Width:Int, Height:Int, Smoothing:Bool = true, PowerOfTwo:Bool = false) 
	{
		super(0, 0);
		
		renderTexture = new FlxRenderTexture(Width, Height, Smoothing, PowerOfTwo);
		frames = renderTexture.graphic.imageFrame;
		renderCameras = [FlxG.camera];
	}
	
	override public function destroy():Void 
	{
		renderTexture = FlxDestroyUtil.destroy(renderTexture);
		renderCameras = null;
		
		super.destroy();
	}
	
	/**
	 * Forces clearing of render texture. 
	 * Usually you won't need this method.
	 */
	public function clear():Void
	{
		renderTexture.clearBeforeRender = true; // force cleaning.
		renderCamera.setRenderTarget(this);
		renderCamera.setRenderTarget(null);
	}
	
	/**
	 * Renders object on this sprite's texture one time.
	 * To constantly render sprite you'll need just to set `sprite.renderTarget = this;`
	 * 
	 * @param	object Object to draw on this sprite's texture.
	 */
	public function drawObject(object:FlxSprite):Void
	{
		var temp:FlxRenderTarget = object.renderTarget;
		object.renderTarget = this;
		renderCamera.setRenderTarget(this);
		object.draw();
		renderCamera.setRenderTarget(null);
		object.renderTarget = temp;
	}
	
	override public function draw():Void 
	{
		super.draw();
		renderTexture.clearBeforeRender = clearBeforeRender;
	}
	
	private function set_renderCamera(value:FlxCamera):FlxCamera
	{
		return renderCameras[0] = value;
	}
	
	private function get_renderCamera():FlxCamera
	{
		return renderCameras[0];
	}
	
	private function get_clearColor():FlxColor
	{
		return renderTexture.clearColor;
	}
	
	private function set_clearColor(value:FlxColor):FlxColor
	{
		return renderTexture.clearColor = value;
	}
}