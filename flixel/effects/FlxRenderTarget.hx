package flixel.effects;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
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
	 * The actual group which holds all sprites.
	 */
	public var group:FlxGroup;
	
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
	
	private var renderedGroup:Bool = false;
	
	/**
	 * Render target constructor
	 * 
	 * @param	Width			width of render target
	 * @param	Height			height of render target
	 * @param	Camera			renderCamera for this render target 
	 * @param	Smoothing		smoothing of  render texture
	 * @param	PowerOfTwo		whether size of render texture should be multiple of two.
	 */
	public function new(Width:Int, Height:Int, ?Camera:FlxCamera, Smoothing:Bool = true, PowerOfTwo:Bool = false) 
	{
		super(0, 0);
		
		renderTexture = new FlxRenderTexture(Width, Height, Smoothing, PowerOfTwo);
		frames = renderTexture.graphic.imageFrame;
		Camera = (Camera == null) ? FlxG.camera : Camera;
		renderCameras = [Camera];
		group = new FlxGroup();
	}
	
	override public function destroy():Void 
	{
		renderTexture = FlxDestroyUtil.destroy(renderTexture);
		renderCameras = null;
		group = FlxDestroyUtil.destroy(group);
		
		super.destroy();
	}
	
	/**
	 * Forces clearing of render texture. 
	 * Usually you won't need to call this method.
	 */
	public function clear():Void
	{
		renderTexture.clearBeforeRender = true; // force cleaning.
		var prevTarget = renderCamera.renderTarget;
		renderCamera.renderTarget = this;
		renderCamera.renderTarget = prevTarget;
	}
	
	/**
	 * Renders object on this sprite's texture one time.
	 * To constantly render sprite you'll need just to set `sprite.renderTarget = this;`
	 * 
	 * @param	object Object to draw on this sprite's texture.
	 */
	public function drawObject(object:FlxSprite):Void
	{
		var prevTarget = renderCamera.renderTarget;
		renderCamera.renderTarget = this;
		object.drawTo(renderCamera);
		renderCamera.renderTarget = prevTarget;
	}
	
	override public function update(elapsed:Float):Void 
	{
		group.update(elapsed);
		super.update(elapsed);
		
		renderedGroup = false;
	}
	
	override public function drawTo(Camera:FlxCamera):Void 
	{
		renderGroup();
		
		super.drawTo(Camera);
		renderTexture.clearBeforeRender = clearBeforeRender;
	}
	
	public function add<T:FlxBasic>(Object:T):T
	{
		group.add(Object);
		return Object;
	}
	
	public function remove<T:FlxBasic>(Object:T, Splice:Bool = false):T
	{
		group.remove(Object, Splice);
		return Object;
	}
	
	public function renderGroup(force:Bool = false):Void
	{
		if (!renderedGroup || force)
		{
			var prevTarget = renderCamera.renderTarget;
			renderCamera.renderTarget = this; 
			group.drawTo(renderCamera);
			renderCamera.renderTarget = prevTarget;
			
			if (FlxG.renderBlit)
			{
				dirty = true;
				calcFrame(useFramePixels);
			}
		}
		
		renderedGroup = true;
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