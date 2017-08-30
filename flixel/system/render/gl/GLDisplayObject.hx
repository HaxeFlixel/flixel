package flixel.system.render.gl;

import flixel.math.FlxMatrix;
import flixel.util.FlxDestroyUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

#if FLX_RENDER_GL
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.GLRenderContext;
import lime.utils.Float32Array;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;

@:access(openfl.geom.ColorTransform)

#end

/**
 * Display object used by flixel for rendering cameras (buffer and debug layer) in gl render mode
 * @author Zaphod
 */
class GLDisplayObject extends DisplayObjectContainer implements IFlxDestroyable
{
	#if FLX_RENDER_GL
	/**
	 * Render texture of this display object.
	 * All flixel's commands are drawn on this texture.
	 * And then this texture will be drawn on the screen.
	 */
	public var buffer(default, null):FlxRenderTexture;
	
	public var smoothing:Bool = true;
	
	/**
	 * Internal variables for tracking object's dimensions.
	 */
	private var _width:Int;
	private var _height:Int;
	
	/**
	 * Render context helper, which is used for managing blendmodes, shaders, filters, etc.
	 */
	private var context:GLContextHelper;
	
	public function new(width:Int, height:Int, context:GLContextHelper)
	{
		super();
		
		this.context = context;
		resize(width, height);
	}
	
	public function destroy():Void
	{
		buffer = FlxDestroyUtil.destroy(buffer);
		context = null;
	}
	
	public function resize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		
		FlxDestroyUtil.destroy(buffer);
		buffer = new FlxRenderTexture(width, height, false);
	}
	
	public function clear():Void
	{
		var gl = context.gl;
		context.checkRenderTarget(buffer);
		buffer.clear(gl.DEPTH_BUFFER_BIT | gl.COLOR_BUFFER_BIT);
	}
	
	public function prepare(?renderTarget:FlxRenderTexture, ?transform:FlxMatrix):Void {}
	
	public function finish():Void {}
	
	@:access(openfl.geom.Rectangle)
	override private function __getBounds(rect:Rectangle, matrix:Matrix):Void 
	{
		var bounds = Rectangle.__pool.get();
		bounds.setTo(0, 0, _width, _height);
		bounds.__transform(bounds, matrix);
		rect.__expand(bounds.x, bounds.y, bounds.width, bounds.height);
		Rectangle.__pool.release(bounds);
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
		
		if (px > 0 && py > 0 && px <= _width && py <= _height) 
		{
			if (stack != null && !interactiveOnly) 
				stack.push(hitObject);
			
			return true;
		}
		
		return false;
	}
	
	override private function get_height():Float 
	{	
		return _height;	
	}
	
	override private function set_height(value:Float):Float 
	{	
		return _height = Std.int(value);	
	}
	
	override private function get_width():Float 
	{	
		return _width;	
	}
	
	override private function set_width(value:Float):Float 
	{	
		return _width = Std.int(value);	
	}
	
	/**
	 * Actual rendering on the screen is handled here.
	 */
	override public function __renderGL(renderSession:RenderSession):Void 
	{
		/*
		gl.bindTexture(gl.TEXTURE_2D, buffer.texture);
		GLUtils.setTextureSmoothing(false);
	//	GLUtils.setTextureSmoothing(smoothing);
		GLUtils.setTextureWrapping(false);
		*/
		
		context.setShader(null);
		
		var renderer:GLRenderer = cast renderSession.renderer;
		var gl = renderSession.gl;
		
		renderSession.blendModeManager.setBlendMode(__worldBlendMode);
		renderSession.maskManager.pushObject(this);
		
		var shader = renderSession.filterManager.pushObject(this);
		renderSession.shaderManager.setShader(shader);
		
		shader.data.uImage0.input = buffer.bitmap;
		shader.data.uImage0.smoothing = false;
		shader.data.uMatrix.value = renderer.getMatrix(__renderTransform);
		
		var useColorTransform = !__worldColorTransform.__isDefault();
		
		if (shader.data.uColorTransform.value == null) 
			shader.data.uColorTransform.value = [];
		
		shader.data.uColorTransform.value[0] = useColorTransform;
		
		renderSession.shaderManager.updateShader(shader);
		
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer.bitmap.getBuffer(gl, __worldAlpha, __worldColorTransform));
		
		gl.vertexAttribPointer(shader.data.aPosition.index,	3, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 0);
		gl.vertexAttribPointer(shader.data.aTexCoord.index,	2, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aAlpha.index,	1, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
		
		if (true || useColorTransform) 
		{
			gl.vertexAttribPointer(shader.data.aColorMultipliers.index,		4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 6 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.data.aColorMultipliers.index + 1,	4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 10 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.data.aColorMultipliers.index + 2,	4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 14 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.data.aColorMultipliers.index + 3,	4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 18 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.data.aColorOffsets.index,			4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 22 * Float32Array.BYTES_PER_ELEMENT);	
		}
		
		gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
		
		for (child in __children) 
			child.__renderGL(renderSession);
		
		for (orphan in __removedChildren) 
		{	
			if (orphan.stage == null)
				orphan.__cleanup();
		}
		
		__removedChildren.length = 0;
		
		renderSession.filterManager.popObject(this);
		renderSession.maskManager.popObject(this);
	}
	
	#else
	public function destroy():Void {}
	#end
}