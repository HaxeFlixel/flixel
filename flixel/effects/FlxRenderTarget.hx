package flixel.effects;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.system.render.gl.RenderTexture;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.gl.GL;

/**
 * ...
 * @author ...
 */
class FlxRenderTarget extends FlxSprite
{
	public var renderTexture(default, null):RenderTexture;
	
	public var renderCamera(get, set):FlxCamera;
	
	public var clearBeforeRender:Bool = true;
	
	public var clearColor(get, set):FlxColor;
	
	@:allow(flixel.FlxSprite)
	private var renderCameras(default, null):Array<FlxCamera>;
	
	public function new(Width:Int, Height:Int, Smoothing:Bool = true, PowerOfTwo:Bool = false) 
	{
		super(0, 0);
		
		renderTexture = new RenderTexture(Width, Height, Smoothing, PowerOfTwo);
		frames = renderTexture.graphic.imageFrame;
		renderCameras = [FlxG.camera];
	}
	
	override public function destroy():Void 
	{
		renderTexture = FlxDestroyUtil.destroy(renderTexture);
		renderCameras = null;
		
		super.destroy();
	}
	
	public function clear():Void
	{
		renderTexture.clearBeforeRender = true; // force cleaning.
		renderCamera.setRenderTarget(this);
		renderCamera.setRenderTarget(null);
	}
	
	public function drawObject(object:FlxSprite):Void
	{
		renderCamera.setRenderTarget(this);
		object.draw();
		renderCamera.setRenderTarget(null);
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
		return FlxColor.fromRGBFloat(renderTexture.clearRed, renderTexture.clearGreen, renderTexture.clearBlue, renderTexture.clearAlpha);
	}
	
	private function set_clearColor(value:FlxColor):FlxColor
	{
		renderTexture.clearRed = value.redFloat;
		renderTexture.clearGreen = value.greenFloat;
		renderTexture.clearBlue = value.blueFloat;
		renderTexture.clearAlpha = value.alphaFloat;
		return value;
	}
}