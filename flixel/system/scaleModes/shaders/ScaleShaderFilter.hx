package flixel.system.scaleModes.shaders;

import openfl.display.Shader;
import openfl.filters.BitmapFilter;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl._internal.renderer.RenderSession;


class ScaleShaderFilter extends openfl.filters.ShaderFilter {
	
	public var scaleX:Float;
	public var scaleY:Float;
	public var resolution:Array<Float>;

	public function new(shader:Shader) {
		super(shader);
	}
	
	override public function clone():BitmapFilter {
		return super.clone();
	}
	
	override function __growBounds (rect:Rectangle) {
		
		rect.x = 0;
		rect.y = 0;
		rect.width = 400;
		rect.height = 400;
		
	}
	
	override function __preparePass(pass:Int):Shader {
		var ts = cast(shader, IScaleShader);
		ts.uScaleX = this.scaleX;
		ts.uScaleY = this.scaleY;
		ts.uResolution = this.resolution;
		return shader;
	}

	
}