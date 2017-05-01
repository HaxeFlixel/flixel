package flixel.system.render.gl;

import flixel.util.FlxDestroyUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

#if FLX_RENDER_GL
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.GLRenderContext;
import lime.math.Matrix4;
import openfl.utils.Float32Array;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;
#end

// TODO: document this class...

/**
 * Display object used by flixel for rendering cameras (buffer and debug layer) in gl render mode
 * @author Zaphod
 */
class GLDisplayObject extends DisplayObjectContainer implements IFlxDestroyable
{
	#if FLX_RENDER_GL
	public var buffer(default, null):RenderTexture;
	
	private var __height:Int;
	private var __width:Int;
	
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
		buffer = new RenderTexture(width, height, false);
	}
	
	public function clear():Void
	{
		var gl = context.gl;
		context.checkRenderTarget(buffer);
		buffer.clear(gl.DEPTH_BUFFER_BIT | gl.COLOR_BUFFER_BIT);
	}
	
	public function prepare(?renderTarget:RenderTexture):Void {}
	
	public function finish():Void {}
	
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
		var gl:GLRenderContext = renderSession.gl;
		var renderer:GLRenderer = cast renderSession.renderer;
		
		// code from GLBitmap
		renderSession.blendModeManager.setBlendMode(blendMode);
	//	renderSession.maskManager.pushObject(this);
		
		var shader = renderSession.filterManager.pushObject(this);
		shader.data.uMatrix.value = renderer.getMatrix(__renderTransform);
		renderSession.shaderManager.setShader(shader);
		
		gl.bindTexture(gl.TEXTURE_2D, buffer.texture);
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
		
		context.currentShader = null;
		
		for (child in __children) 
			child.__renderGL(renderSession);
		
		for (orphan in __removedChildren) 
		{	
			if (orphan.stage == null)
				orphan.__cleanup();
		}
		
		__removedChildren.length = 0;
		
		renderSession.filterManager.popObject(this);
	}
	
	#else
	public function destroy():Void {}
	#end
}