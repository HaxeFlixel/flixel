package flixel.system.render.hardware.gl;

import flixel.system.render.hardware.gl.GLUtils;
import flixel.system.render.hardware.gl.RenderTexture;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.gl.GL;
import openfl.utils.Float32Array;

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

/**
 * Display object for actual rendering for openfl 4 in tile render mode.
 * Huge part of it is taken from HaxePunk fork by @Yanrishatum. 
 * Original class can be found here https://github.com/Yanrishatum/HaxePunk/blob/ofl4/com/haxepunk/graphics/atlas/HardwareRenderer.hx
 * @author Pavel Alexandrov aka Yanrishatum https://github.com/Yanrishatum
 * @author Zaphod
 */
class CanvasGL extends DisplayObjectContainer implements IFlxDestroyable
{
	#if FLX_RENDER_GL
	public var buffer(default, null):RenderTexture;
	
	/**
	 * Projection matrix used for render passes (excluding last render pass, which uses global projection matrix from GLRenderer)
	 */
	public var projection(default, null):Matrix4;
	
	public var projectionFlipped(default, null):Matrix4;
	
	private var __height:Int;
	private var __width:Int;
	
	private var colorFilter:ColorTransformFilter;
	private var filtersArray:Array<BitmapFilter>;
	
	public function new(width:Int, height:Int)
	{
		super();
		
		resize(width, height);
		
		colorFilter = new ColorTransformFilter();
		filtersArray = [colorFilter];
	}
	
	public function destroy():Void
	{
		buffer = FlxDestroyUtil.destroy(buffer);
		
		projection = null;
		projectionFlipped = null;
		
		colorFilter = null;
		filtersArray = null;
	}
	
	public function resize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		
		FlxDestroyUtil.destroy(buffer);
		buffer = new RenderTexture(width, height, false);
		
		projection = Matrix4.createOrtho(0, width, 0, height, -1000, 1000);
		projectionFlipped = Matrix4.createOrtho(0, width, height, 0, -1000, 1000);
	}
	
	public function clear():Void
	{
		var gl = GL.context;
		gl.bindFramebuffer(gl.FRAMEBUFFER, buffer.frameBuffer);
		gl.viewport(0, 0, buffer.width, buffer.height);
		buffer.clear(0, 0, 0, 1.0, gl.DEPTH_BUFFER_BIT | gl.COLOR_BUFFER_BIT);
		FlxDrawHardwareCommand.currentBuffer = buffer;
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
		// TODO: sprites might have renderTarget property
		
		var gl:GLRenderContext = renderSession.gl;
		var renderer:GLRenderer = cast renderSession.renderer;
		
		var useColorTransform:Bool = false;
		var hasNoFilters:Bool = (__filters == null);
		
		var color:ColorTransform = __worldColorTransform;
		colorFilter.transform = color;
		
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
		
		// code from GLBitmap
		renderSession.blendModeManager.setBlendMode(blendMode);
	//	renderSession.maskManager.pushObject(this);
		
	//	GL.enable(GL.SCISSOR_TEST);
	//	GL.scissor(0, 0, Std.int(FlxG.stage.stageWidth * 0.5), Std.int(FlxG.stage.stageHeight * 0.5));
		
		var shader = renderSession.filterManager.pushObject(this);
		shader.data.uMatrix.value = renderer.getMatrix(__renderTransform);
		renderSession.shaderManager.setShader(shader);
		
		gl.bindTexture(GL.TEXTURE_2D, buffer.texture);
		GLUtils.setTextureSmoothing(false); // TODO: set texture smoothing...
		GLUtils.setTextureWrapping(false);
		
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer.buffer);
		
		gl.vertexAttribPointer(shader.data.aPosition.index, 3, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
		gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aAlpha.index, 1, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
		
		gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
		
		renderSession.filterManager.popObject(this);
	//	renderSession.maskManager.popObject(this);
		// end of code from GLBitmap
		
	//	GL.disable(GL.SCISSOR_TEST);
		
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