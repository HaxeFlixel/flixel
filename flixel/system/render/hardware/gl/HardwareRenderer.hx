package flixel.system.render.hardware.gl;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

#if FLX_RENDER_GL
import lime.math.Matrix4;
import lime.graphics.GLRenderContext;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;
#end

import openfl.display.DisplayObject;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

using flixel.util.FlxColorTransformUtil;

// TODO: multitexture batching...
// TODO: sprite materials with multiple textures...

/**
 * Display object for actual rendering for openfl 4 in tile render mode.
 * Huge part of it is taken from HaxePunk fork by @Yanrishatum. 
 * Original class can be found here https://github.com/Yanrishatum/HaxePunk/blob/ofl4/com/haxepunk/graphics/atlas/HardwareRenderer.hx
 * @author Pavel Alexandrov aka Yanrishatum https://github.com/Yanrishatum
 * @author Zaphod
 */
class HardwareRenderer extends DisplayObject implements IFlxDestroyable
{
	#if FLX_RENDER_GL
	private var states:Array<FlxDrawHardwareCommand<Dynamic>>;
	private var stateNum:Int;
	
	private var __height:Int;
	private var __width:Int;
	
	private var renderHelper(get, null):GLRenderHelper;
	
	private var _renderHelper:GLRenderHelper;
	
	public function new(width:Int, height:Int)
	{
		super();
		
		__width = width;
		__height = height;
		
		states = [];
		stateNum = 0;
	}
	
	public function destroy():Void
	{
		states = null;
		_renderHelper = FlxDestroyUtil.destroy(_renderHelper);
	}
	
	public function resize(witdh:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		
		if (_renderHelper != null)
			_renderHelper.resize(__width, __height);
	}
	
	public function clear():Void
	{
		stateNum = 0;
	}

	public function drawItem(item:FlxDrawHardwareCommand<Dynamic>):Void
	{
		states[stateNum++] = item;
	}
	
	@:access(openfl.geom.Rectangle)
	override private function __getBounds(rect:Rectangle, matrix:Matrix):Void 
	{
		var bounds = Rectangle.__temp;
		bounds.setTo(0, 0, __width, __height);
		bounds.__transform(bounds, matrix);
		rect.__expand(bounds.x, bounds.y, bounds.width, bounds.height);	
	}
	
	override private function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool 
	{
		if (!hitObject.visible || __isMask) 
			return false;
		
		if (mask != null && !mask.__hitTestMask(x, y))
			return false;
		
		__getWorldTransform();
		
		var px = __worldTransform.__transformInverseX(x, y);
		var py = __worldTransform.__transformInverseY(x, y);
		
		if (px > 0 && py > 0 && px <= __width && py <= __height) 
		{
			if (stack != null && !interactiveOnly) 
			{
				stack.push(hitObject);	
			}
			
			return true;
		}
		
		return false;
	}
	
	override private function get_height():Float 
	{	
		return __height;	
	}
	
	override private function set_height(value:Float):Float 
	{	
		return __height = Std.int(value);	
	}
	
	override private function get_width():Float 
	{	
		return __width;	
	}
	
	override private function set_width(value:Float):Float 
	{	
		return __width = Std.int(value);	
	}
	
	override public function __renderGL(renderSession:RenderSession):Void 
	{
		// TODO: call FlxGame's draw() method from here
		// TODO: every camera will have its own render texture where i will draw everthing onto and only then draw this texture on the screen
		// TODO: sprites might have renderTarget property
		
	//	FlxG.game.draw();
	
		var gl:GLRenderContext = renderSession.gl;
		var renderer:GLRenderer = cast renderSession.renderer;
		
		var numPasses:Int = GLUtils.getObjectNumPasses(this);
		
		var needRenderHelper:Bool = (numPasses > 0);
		var transform:Matrix = this.__worldTransform;
		var uMatrix:Array<Float> = null;
		
		if (needRenderHelper)
		{
			renderHelper.capture();
			uMatrix = renderHelper.getMatrix(transform, renderer, numPasses);
		}
		else
		{
			uMatrix = renderer.getMatrix(transform);
		}
		
		var uniformMatrix:Matrix4 = GLUtils.arrayToMatrix(uMatrix);
		
		for (i in 0...stateNum)
			states[i].renderGL(uniformMatrix, renderSession);
		
		if (needRenderHelper)
			renderHelper.render(renderSession);
	}
	
	private function get_renderHelper():GLRenderHelper
	{
		if (_renderHelper == null)
		{
			_renderHelper = new GLRenderHelper(this, __width, __height, false, false);
			_renderHelper.fullscreen = false;
		}
		
		return _renderHelper;
	}
	
	#else
	
	public function destroy():Void {}
	
	#end
	
}