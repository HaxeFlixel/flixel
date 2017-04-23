package flixel.system.render.hardware.gl;

import flixel.graphics.FlxMaterial;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import lime.graphics.GLRenderContext;
import lime.math.Matrix4;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.gl.GL;
import openfl.utils.Float32Array;

import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;

/**
 * ...
 * @author Zaphod
 */
class GLDebugRenderer extends DisplayObjectContainer implements IFlxDestroyable
{
	#if FLX_RENDER_GL
	public var buffer(default, null):RenderTexture;
	
	private static var DefaultColorMaterial:FlxMaterial = new FlxMaterial();
	
	/**
	 * Projection matrix used for render passes (excluding last render pass, which uses global projection matrix from GLRenderer)
	 */
	public var projection(default, null):Matrix4;
	
	public var projectionFlipped(default, null):Matrix4;
	
	private var __height:Int;
	private var __width:Int;
	
	private var context:GLContextHelper;
	
	private var drawCommands:FlxDrawQuadsCommand = new FlxDrawQuadsCommand(false);
	
	public function new(width:Int, height:Int, context:GLContextHelper)
	{
		super();
		
		this.context = context;
		resize(width, height);
	}
	
	public function destroy():Void
	{
		buffer = FlxDestroyUtil.destroy(buffer);
		drawCommands = FlxDestroyUtil.destroy(drawCommands);
		
		projection = null;
		projectionFlipped = null;
		context = null;
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
		var gl = context.gl;
		context.checkRenderTarget(buffer);
		buffer.clear(0.0, 0, 0, 0.0, gl.DEPTH_BUFFER_BIT | gl.COLOR_BUFFER_BIT);
	}
	
	public function prepare():Void
	{
		drawCommands.prepare(projection, context, buffer);
		drawCommands.set(null, true, false, DefaultColorMaterial);
	}
	
	public function finish():Void
	{
		drawCommands.flush();
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
		
		// code from GLBitmap
		renderSession.blendModeManager.setBlendMode(blendMode);
	//	renderSession.maskManager.pushObject(this);
		
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
	
	/**
	 * Draws a single pixel to the screen
	 * @param x      the x-axis value of the pixel
	 * @param y      the y-axis value of the pixel
	 * @param color  the color of the pixel
	 * @param size   the overall size of the pixel square
	 */
	public function pixel(x:Float, y:Float, color:FlxColor, size:Float = 1):Void
	{
		var hs = size / 2;
		fillRect(x - hs, y - hs, size, size, color);
	}
	
	/**
	 * Draws a circle to the screen
	 * @param x       the x-axis value of the circle
	 * @param y       the y-axis value of the circle
	 * @param radius  the radius of the circle
	 * @param color   the color of the circle
	 */
	public function circle(x:Float, y:Float, radius:Float, color:FlxColor, numSides:Int = 40):Void
	{
		var sides = numSides,
			angle = 0.0,
			angleStep = (Math.PI * 2) / sides,
			lastX = x + Math.cos(angle) * radius,
			lastY = y + Math.sin(angle) * radius,
			pointX:Float,
			pointY:Float;
		
		for (i in 0...sides)
		{
			angle += angleStep;
			pointX = x + Math.cos(angle) * radius;
			pointY = y + Math.sin(angle) * radius;
			line(lastX, lastY, pointX, pointY, color);
			lastX = pointX;
			lastY = pointY;
		}
	}

	/**
	 * Draws a non-filled rectangle to the screen
	 * @param x          the x-axis value of the rectangle
	 * @param y          the y-axis value of the rectangle
	 * @param width      the width of the rectangle
	 * @param height     the height of the rectangle
	 * @param color      the color of the rectangle
	 * @param thickness  the line thickness of the rectangle
	 */
	public function rect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1):Void
	{
		var ht = thickness / 2,
			x2 = x + width,
			y2 = y + height;
		// offset values to create an inline border
		line(x, y + ht, x2, y + ht, color, thickness);
		line(x2 - ht, y, x2 - ht, y2, color, thickness);
		line(x2, y2 - ht, x, y2 - ht, color, thickness);
		line(x + ht, y2, x + ht, y, color, thickness);
	}

	/**
	 * Draws a filled rectangle to the screen
	 * @param x       the x-axis value of the rectangle
	 * @param y       the y-axis value of the rectangle
	 * @param width   the width of the rectangle
	 * @param height  the height of the rectangle
	 * @param color   the color of the rectangle
	 */
	public function fillRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void
	{
		drawCommands.startQuad(null, DefaultColorMaterial);
		drawCommands.addColoredVertex(x, y, color);
		drawCommands.addColoredVertex(x + width, y, color);
		drawCommands.addColoredVertex(x + width, y + height, color);
		drawCommands.addColoredVertex(x, y + height, color);
	}

	/**
	 * Draws a line to the screen
	 * @param x1         the first x-axis value of the line
	 * @param y1         the first y-axis value of the line
	 * @param x2         the second x-axis value of the line
	 * @param y2         the second y-axis value of the line
	 * @param color      the color of the line
	 * @param thickness  the thickness of the line
	 */
	public function line(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1):Void
	{
		// create perpendicular delta vector
		var dx = -(x2 - x1);
		var dy = y2 - y1;
		var len = Math.sqrt(dx * dx + dy * dy);
		if (len == 0) return;
		// normalize line and set delta to half thickness
		var ht = thickness / 2;
		var tx = dx;
		dx = (dy / len) * ht;
		dy = (tx / len) * ht;
		
		drawCommands.startQuad(null, DefaultColorMaterial);
		drawCommands.addColoredVertex(x1 + dx, y1 + dy, color);
		drawCommands.addColoredVertex(x1 - dx, y1 - dy, color);
		drawCommands.addColoredVertex(x2 - dx, y2 - dy, color);
		drawCommands.addColoredVertex(x2 + dx, y2 + dy, color);
	}
	
	/**
	 * Draws a grid to the screen
	 * @param gx     x-axis value of the grid
	 * @param gy     y-axis value of the grid
	 * @param gw     width of the grid
	 * @param gh     height of the grid
	 * @param color  the color of the grid lines
	 */
	public function grid(gx:Float, gy:Float, gw:Float, gh:Float, cellX:Int, cellY:Int, color:FlxColor):Void
    {
        var offset = gx,
            step = gw / cellX; // horizontal offset
        for (i in 0...cellX+1)
        {
            line(offset, gy, offset, gy + gh, color);
            offset += step;
        }
        offset = gy; // vertical offset
        step = gh / cellY;
        for (i in 0...cellY+1)
        {
            line(gx, offset, gx + gw, offset, color);
            offset += step;
        }
    }
	
	#else
	
	public function destroy():Void {}
	
	#end
}