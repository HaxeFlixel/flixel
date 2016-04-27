package flixel.system.scaleModes.shaders;

import openfl.filters.ShaderFilter;
import openfl.geom.Rectangle;


class ScaleShaderFilter extends ShaderFilter
{
	
	public var scaleX:Float;
	public var scaleY:Float;
	public var strength:Float;
	public var resolution:Array<Float>;
	
	public function postDraw():Void
	{
		var ts = cast(shader, IScaleShader);
		ts.uScaleX = this.scaleX;
		ts.uScaleY = this.scaleY;
		ts.uStrength = this.strength;
		ts.uResolution = this.resolution;
	}
}