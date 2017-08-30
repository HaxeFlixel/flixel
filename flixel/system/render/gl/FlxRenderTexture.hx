package flixel.system.render.gl;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLTexture;
import lime.math.Matrix4;
import lime.utils.ArrayBufferView;
import openfl.display.BitmapData;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import openfl.geom.Rectangle;

@:access(openfl.display.BitmapData)
class FlxRenderTexture implements IFlxDestroyable
{
	public static var defaultFramebuffer:GLFramebuffer = null;
	
	public var frameBuffer(default, null):GLFramebuffer;
	public var renderBuffer(default, null):GLRenderbuffer;
	public var texture(default, null):GLTexture;
	public var bitmap(default, null):BitmapData;
	public var graphic(default, null):FlxGraphic;
	
	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;
	public var powerOfTwo(default, null):Bool = false;
	public var smoothing:Bool;
	
	public var actualWidth(default, null):Int = 0;
	public var actualHeight(default, null):Int = 0;
	
	public var clearBeforeRender:Bool = true;
	
	/**
	 * Projection matrix used for render passes (excluding last render pass, which uses global projection matrix from GLRenderer)
	 */
	public var projection(default, null):Matrix4;
	
	public var projectionFlipped(default, null):Matrix4;
	
	public var clearRed:Float = 0.0;
	public var clearGreen:Float = 0.0;
	public var clearBlue:Float = 0.0;
	public var clearAlpha:Float = 0.0;
	
	public var clearColor(get, set):FlxColor;
	
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
		
		this.width = width;
		this.height = height;
		
		projection = Matrix4.createOrtho(0, width, 0, height, -1000, 1000);
		projectionFlipped = Matrix4.createOrtho(0, width, height, 0, -1000, 1000);
		
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
		var gl = GL.context;
		texture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, texture);
		
		var data:ArrayBufferView = null;
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, actualWidth, actualHeight, 0, gl.RGBA, gl.UNSIGNED_BYTE, data);
		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		
		bitmap = new BitmapData(0, 0, true, 0);
		bitmap.width = width;
		bitmap.height = height;
		bitmap.rect = new Rectangle(0, 0, width, height);
		
		bitmap.__texture = texture;
		bitmap.__textureContext = gl;
		bitmap.__isValid = true;
		bitmap.image = null;
		bitmap.readable = false;
		
		graphic = FlxGraphic.fromBitmapData(bitmap, false, null, false);
		
		// specify texture as color attachment
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);
	}
	
	private inline function createRenderbuffer(width:Int, height:Int)
	{
		// Bind the renderbuffer and create a depth buffer
		renderBuffer = GL.createRenderbuffer();
		
		GL.bindRenderbuffer(GL.RENDERBUFFER, renderBuffer);
		GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, actualWidth, actualHeight);
		
		// Specify renderbuffer as depth attachement
		GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderBuffer);
	}
	
	public function destroy():Void
	{
		if (frameBuffer != null) GL.deleteFramebuffer(frameBuffer);
		if (texture != null) GL.deleteTexture(texture);
		if (renderBuffer != null) GL.deleteRenderbuffer(renderBuffer);
		
		frameBuffer = null;
		texture = null;
		renderBuffer = null;
		bitmap = FlxDestroyUtil.dispose(bitmap);
		graphic = FlxDestroyUtil.destroy(graphic);
		
		projection = null;
		projectionFlipped = null;
	}
	
	public function clear(?mask:Null<Int>):Void
	{	
		GL.clearColor(clearRed, clearGreen, clearBlue, clearAlpha);
		GL.clear(mask == null ? GL.COLOR_BUFFER_BIT : mask);
	}
	
	private inline function powOfTwo(value:Int):Int
	{
		var n = 1;
		while (n < value) n <<= 1;
		return n;
	}
	
	private inline function get_clearColor():FlxColor
	{
		return FlxColor.fromRGBFloat(clearRed, clearGreen, clearBlue, clearAlpha);
	}
	
	private inline function set_clearColor(value:FlxColor):FlxColor
	{
		clearRed = value.redFloat;
		clearGreen = value.greenFloat;
		clearBlue = value.blueFloat;
		clearAlpha = value.alphaFloat;
		return value;
	}
}