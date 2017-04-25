package flixel.system.render.hardware.gl;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLTexture;

class PingPongTexture implements IFlxDestroyable
{
	public var renderTexture(get, set):RenderTexture;
	public var oldRenderTexture(get, set):RenderTexture;
	public var framebuffer(get, never):GLFramebuffer;
	public var texture(get, never):GLTexture;
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var powerOfTwo(default, null):Bool = true;
	public var smoothing:Bool;
	
	private var _swapped:Bool = false;
	private var _texture0:RenderTexture;
	private var _texture1:RenderTexture;
	
	public function new(width:Int, height:Int, smoothing:Bool = true, powerOfTwo:Bool = false) 
	{
		this.width = width;
		this.height = height;
		this.powerOfTwo = powerOfTwo;
		this.smoothing = smoothing;
		
		renderTexture = new RenderTexture(width, height, smoothing, powerOfTwo);
	}
	
	public function destroy():Void
	{
		if (_texture0 != null) 
		{
			_texture0.destroy();
			_texture0 = null;
		}
		
		if (_texture1 != null) 
		{
			_texture1.destroy();
			_texture1 = null;
		}
		
		_swapped = false;
	}
	
	public function swap():Void
	{
		_swapped = !_swapped;
		
		if (renderTexture == null) 
		{
			renderTexture = new RenderTexture(width, height, powerOfTwo);
		}
	}
	
	public inline function clear(?r:Float = 0, ?g:Float = 0, ?b:Float = 0, ?a:Float = 0, ?mask:Null<Int>):Void 
	{
		renderTexture.clear(r, g, b, a, mask);	
	}
	
	public function resize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		renderTexture.resize(width, height);
		
		if (oldRenderTexture != null)
			oldRenderTexture.resize(width, height);
	}
	
	private inline function get_renderTexture():RenderTexture
	{
		return _swapped ? _texture1 : _texture0;
	}
	
	private inline function set_renderTexture(v:RenderTexture):RenderTexture
	{
		return {
			if (_swapped) 
				_texture1 = v;
			else 
				_texture0 = v;
		};
	}
	
	private inline function get_oldRenderTexture():RenderTexture
	{
		return _swapped ? _texture0 : _texture1;
	}
	
	private inline function set_oldRenderTexture(v:RenderTexture):RenderTexture
	{
		return {
			if (_swapped) 
				_texture0 = v;
			else 
				_texture1 = v;
		};
	}
	
	private inline function get_framebuffer():GLFramebuffer 
	{
		return renderTexture.frameBuffer;
	}
	
	private inline function get_texture():GLTexture
	{
		return renderTexture.texture;
	}
	
}