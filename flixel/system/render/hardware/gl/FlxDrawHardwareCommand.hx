package flixel.system.render.hardware.gl;

import flixel.graphics.shaders.FlxShader;
import flixel.system.render.hardware.FlxHardwareView;
import flixel.system.render.common.FlxDrawBaseCommand;

#if FLX_RENDER_GL
import openfl._internal.renderer.RenderSession;
import lime.math.Matrix4;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawHardwareCommand<T> extends FlxDrawBaseCommand<T>
{
	public static var currentShader:FlxShader = null;
	
	public function new() 
	{
		super();
	}
	
	override public function render(view:FlxHardwareView):Void 
	{
		view.drawItem(this);
	}
	
	public function renderGL(uniformMatrix:Matrix4, renderSession:RenderSession):Void {}
}
#else
class FlxDrawHardwareCommand<T> extends FlxDrawBaseCommand<T>
{
	public static var currentShader:FlxShader = null;
	
	public function new() 
	{
		super();
	}
	
	public function renderGL(uniformMatrix:Dynamic, renderSession:Dynamic):Void {}
}
#end