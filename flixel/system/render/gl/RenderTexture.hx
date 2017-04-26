package flixel.system.render.gl;

import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLTexture;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;

@:access(openfl.display.BitmapData)
class RenderTexture implements IFlxDestroyable
{
	public static var defaultFramebuffer:GLFramebuffer = null;
	
	public var frameBuffer:GLFramebuffer;
	public var renderBuffer:GLRenderbuffer;
	public var texture:GLTexture;
	
	public var buffer:GLBuffer;
	
	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;
	public var powerOfTwo(default, null):Bool = false;
	public var smoothing:Bool;
	
	public var actualWidth(default, null):Int = 0;
	public var actualHeight(default, null):Int = 0;
	
	public var uvData(default, null):FlxRect;
	
	public var gl(default, null):GLRenderContext;
	
	public function new(width:Int, height:Int, smoothing:Bool = true, powerOfTwo:Bool = false) 
	{
		this.powerOfTwo = powerOfTwo;
		this.smoothing = smoothing;
		
		frameBuffer = GL.createFramebuffer();
		resize(width, height);
		
	#if (ios || tvos)
		if (defaultFramebuffer == null)
			defaultFramebuffer = new GLFramebuffer(GL.version, 1); // faked framebuffer
	#else
		var status = GL.checkFramebufferStatus(GL.FRAMEBUFFER);
		
		switch (status)
		{
			case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
				trace("FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
			case GL.FRAMEBUFFER_UNSUPPORTED:
				trace("GL_FRAMEBUFFER_UNSUPPORTED");
			case GL.FRAMEBUFFER_COMPLETE:
			default:
				trace("Check frame buffer: " + status);
		}
	#end
	}
	
	public function resize(width:Int, height:Int) 
	{
		if (this.width == width && this.height == height) return;
		
		gl = GL.context;
		
		this.width = width;
		this.height = height;
		
		var pow2W = width;
		var pow2H = height;
		
		if (powerOfTwo) 
		{
			pow2W = powOfTwo(width);
			pow2H = powOfTwo(height);
		}
		
		var lastW = actualWidth;
		var lastH = actualHeight;
		
		actualWidth = pow2W;
		actualHeight = pow2H;
		
		createUVs();
		createBuffer();
		
		if (lastW == pow2W && lastH == pow2H) return;
		
		GL.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
		
		if (texture != null) GL.deleteTexture(texture);
		if (renderBuffer != null) GL.deleteRenderbuffer(renderBuffer);
		
		createTexture(width, height);
		createRenderbuffer(width, height);
		
		GL.bindTexture(GL.TEXTURE_2D, null);
		GL.bindRenderbuffer(GL.RENDERBUFFER, null);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}
	
	private inline function createTexture(width:Int, height:Int)
	{
		#if ((openfl >= "4.9.0") && !flash)
		// code from GLRenderer's resize() method
		var renderBitmap:BitmapData = BitmapData.fromTexture(Lib.current.stage.stage3Ds[0].context3D.createRectangleTexture(actualWidth, actualHeight, BGRA, true));
		texture = renderBitmap.getTexture(gl);
		gl.bindTexture(gl.TEXTURE_2D, texture);
		#else
		texture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, actualWidth, actualHeight, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
		#end
		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		
		// specify texture as color attachment
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);
	}
	
	private inline function createRenderbuffer(width:Int, height:Int)
	{
		// Bind the renderbuffer and create a depth buffer
		renderBuffer = gl.createRenderbuffer();
		
		gl.bindRenderbuffer(gl.RENDERBUFFER, renderBuffer);
		gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT16, actualWidth, actualHeight);
		
		// Specify renderbuffer as depth attachement
		gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, renderBuffer);
	}
	
	public function destroy():Void
	{
		if (frameBuffer != null) GL.deleteFramebuffer(frameBuffer);
		if (texture != null) GL.deleteTexture(texture);
		if (renderBuffer != null) GL.deleteRenderbuffer(renderBuffer);
		
		frameBuffer = null;
		texture = null;
		renderBuffer = null;
		gl = null;
	}
	
	public function clear(?r:Float = 0, ?g:Float = 0, ?b:Float = 0, ?a:Float = 0, ?mask:Null<Int>):Void
	{	
		gl.clearColor(r, g, b, a);
		gl.clear(mask == null ? gl.COLOR_BUFFER_BIT : mask);	
	}
	
	public function createBitmapData():BitmapData
	{
		if (texture == null)
			return null;
		
		var bitmapData = new BitmapData(width, height, true, 0);
		bitmapData.readable = false;
		bitmapData.__texture = texture;
		bitmapData.__textureContext = gl;
		bitmapData.image = null;
		return bitmapData;
	}
	
	private function createUVs():Void
	{	
		if (uvData == null) uvData = FlxRect.get();
		var w = width / actualWidth;
		var h = height / actualHeight;
		uvData.x = 0;
		uvData.y = 0;
		uvData.width = w;
		uvData.height = h;
	}
	
	private function createBuffer():Void
	{
		var alpha:Float = 1.0;
		
		var bufferData:Float32Array = new Float32Array([
				width,	height,	0,	uvData.width,	uvData.height,	alpha,
				0,		height, 0,	0,				uvData.height,	alpha,
				width, 	0, 		0,	uvData.width,	0,				alpha,
				0, 		0, 		0,	0,				0,				alpha
		]);
		
		if (buffer != null)
			gl.deleteBuffer(buffer);
		
		buffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
		gl.bufferData(gl.ARRAY_BUFFER, bufferData.byteLength, bufferData, gl.STATIC_DRAW);
		gl.bindBuffer(gl.ARRAY_BUFFER, null);
	}
	
	private inline function powOfTwo(value:Int):Int
	{
		var n = 1;
		while (n < value) n <<= 1;
		return n;
	}
}