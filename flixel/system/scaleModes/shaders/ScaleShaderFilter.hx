package flixel.system.scaleModes.shaders;

import openfl.display.Shader;
import openfl.filters.BitmapFilter;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl._internal.renderer.RenderSession;


class ScaleShaderFilter extends openfl.filters.ShaderFilter
{
	
	public var scaleX:Float;
	public var scaleY:Float;
	public var strength:Float;
	public var resolution:Array<Float>;

	override function __growBounds (rect:Rectangle):Void
	{
		
		rect.x = 0;
		rect.y = 0;
		rect.width = 400;
		rect.height = 400;
		
	}
	
	public function postDraw():Void
	{
		var ts = cast(shader, IScaleShader);
		ts.uScaleX = this.scaleX;
		ts.uScaleY = this.scaleY;
		ts.uStrength = this.strength;
		ts.uResolution = this.resolution;
	}
}