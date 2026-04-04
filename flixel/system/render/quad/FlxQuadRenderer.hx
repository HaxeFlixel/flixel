package flixel.system.render.quad;

import flixel.system.render.FlxRenderer;

using flixel.util.FlxColorTransformUtil;
#if FLX_OPENGL_AVAILABLE
import lime.graphics.opengl.GL;
#end

@:access(flixel.FlxCamera)
@:access(flixel.system.render.quad)
class FlxQuadRenderer extends FlxTypedRenderer<FlxQuadView>
{
	public function new()
	{
		super();
		method = DRAW_TILES;
		
		#if FLX_OPENGL_AVAILBLE
		if (isGL)
			maxTextureSize = cast GL.getParameter(GL.MAX_TEXTURE_SIZE);
		#end
	}
	
	public function createCameraView(camera:FlxCamera)
	{
		return new FlxQuadView(camera);
	}

	public inline function startFrame():Void
	{
		FlxG.renderer.totalDrawCalls = 0;
		FlxG.cameras.clear();
	}

	public inline function endFrame():Void
	{
		FlxG.cameras.render();
	}
}
