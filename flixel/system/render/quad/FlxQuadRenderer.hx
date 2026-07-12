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
		
		#if FLX_OPENGL_AVAILABLE
		if (hasGL)
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

	public function addCameraView(view:FlxQuadView):Void
	{
		FlxG.game.addChildAt(view.flashSprite, FlxG.game.getChildIndex(FlxG.game._inputContainer));
	}

	public function addCameraViewAt(view:FlxQuadView, index:Int):Void
	{
		final childIndex = FlxG.game.getChildIndex(FlxG.cameras.list[index].viewQuad.flashSprite);
        FlxG.game.addChildAt(view.flashSprite, childIndex);
	}

	public function removeCameraView(view:FlxQuadView):Void
	{
		FlxG.game.removeChild(view.flashSprite);
	}
}
