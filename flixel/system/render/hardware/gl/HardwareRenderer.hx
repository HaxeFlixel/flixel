package flixel.system.render.hardware.gl;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;

#if FLX_RENDER_GL
import lime.math.Matrix4;
import lime.graphics.GLRenderContext;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;
import flixel.graphics.shaders.FlxCameraColorTransform.ColorTransformFilter;
#end

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
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
class HardwareRenderer extends DisplayObjectContainer implements IFlxDestroyable
{
	#if FLX_RENDER_GL
	private var states:Array<FlxDrawHardwareCommand<Dynamic>>;
	private var stateNum:Int;
	
	private var __height:Int;
	private var __width:Int;
	
	private var colorFilter:ColorTransformFilter;
	private var filtersArray:Array<BitmapFilter>;
	
	public function new(width:Int, height:Int)
	{
		super();
		
		__width = width;
		__height = height;
		
		states = [];
		stateNum = 0;
		
		colorFilter = new ColorTransformFilter();
		filtersArray = [colorFilter];
	}
	
	public function destroy():Void
	{
		states = null;
		colorFilter = null;
		filtersArray = null;
	}
	
	public function resize(witdh:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
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
				stack.push(hitObject);
			
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
		// TODO: every camera will have its own render texture where i will draw everthing onto and only then draw this texture on the screen
		// TODO: sprites might have renderTarget property
		
		var gl:GLRenderContext = renderSession.gl;
		var renderer:GLRenderer = cast renderSession.renderer;
		
		var useColorTransform:Bool = false;
		var hasNoFilters:Bool = (__filters == null);
		var color:ColorTransform = __worldColorTransform;
		
		if (color != null)
			useColorTransform = color.hasAnyTransformation();
		
		if (useColorTransform)
		{
			colorFilter.transform = color;
			
			if (hasNoFilters)
				__filters = filtersArray;
			else
				__filters.unshift(colorFilter);
		}
		
		renderSession.filterManager.pushObject(this);
		
		var transform:Matrix = this.__worldTransform;
		var uMatrix:Array<Float> = renderer.getMatrix(transform);
		var uniformMatrix:Matrix4 = GLUtils.arrayToMatrix(uMatrix);
		
		for (i in 0...stateNum)
			states[i].renderGL(uniformMatrix, renderSession);
		
		FlxDrawHardwareCommand.currentShader = null;
		
		for (child in __children) 
			child.__renderGL(renderSession);
		
		for (orphan in __removedChildren) 
		{	
			if (orphan.stage == null)
				orphan.__cleanup();
		}
		
		__removedChildren.length = 0;
		
		renderSession.filterManager.popObject(this);
		
		if (useColorTransform)
		{
			if (hasNoFilters)
				__filters = null;
			else
				__filters.shift();
		}
	}
	
	#else
	
	public function destroy():Void {}
	
	#end
	
}