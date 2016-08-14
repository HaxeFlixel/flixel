package flixel.system.render.gl;

import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.FlxCameraView;
import openfl.display.BlendMode;
import openfl.geom.Matrix;

/**
 * ...
 * @author Zaphod
 */
class FlxGlView extends FlxCameraView
{
	
	public function new(camera:FlxCamera) 
	{
		super(camera);
		
		
	}
	
	@:noCompletion
	public function startQuadBatch(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader)
	{
		return new FlxDrawQuadsItem();
	}
	
}