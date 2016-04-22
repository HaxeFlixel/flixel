package flixel.system.scaleModes;

import flixel.FlxG;
import flixel.util.typeLimit.OneOfTwo;

#if !openfl_legacy
import flixel.system.scaleModes.shaders.ScaleShaderFilter;
import flixel.system.scaleModes.shaders.Nearest;
import flixel.system.scaleModes.shaders.Bilinear;

import openfl.filters.BitmapFilter;
import openfl.display.Shader;
#else
import flixel.effects.postprocess.PostProcess;
import flixel.effects.postprocess.Shader;
#end

@:enum
abstract ShaderScaleEnum(Int)
{
	var NEAREST = 0;
	var BILINEAR = 1;
}

class ShaderScaleMode extends flixel.system.scaleModes.BaseScaleMode
{

	#if !openfl_legacy
	private var scaleX:Float;
	private var scaleY:Float;
	private var strength:Float;

	public var filter:ScaleShaderFilter;
	public var filters:Array<BitmapFilter>;

	public function new(shader:OneOfTwo<ShaderScaleEnum, openfl.display.Shader> = ShaderScaleEnum.NEAREST, scaleX:Float = 1, scaleY:Float = 1)
	{
		super();

		if (Std.is(shader, Shader))
		{
			this.filter = new ScaleShaderFilter(cast(shader, Shader));
		}
		else
		{
			switch (cast(shader, ShaderScaleEnum))
			{
				case ShaderScaleEnum.NEAREST:
					this.filter = new ScaleShaderFilter(new Nearest());
				case ShaderScaleEnum.BILINEAR:
					this.filter = new ScaleShaderFilter(new Bilinear());
			}
		}

		this.setScale(scaleX, scaleY);
		this.setStrength(1);

		this.filters = [];

		FlxG.game.setFilters(filters);
		FlxG.game.filtersEnabled = true;

		FlxG.signals.postDraw.add(postDraw);
	}

	public function postDraw():Void
	{
		this.filter.resolution = [FlxG.stage.width, FlxG.stage.height];
		this.filter.postDraw();
	}

	public function setScale(scaleX:Float = 1, scaleY:Float = 1):Void
	{
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.filter.scaleX = scaleX;
		this.filter.scaleY = scaleY;
		this.pointerMultiplier = new flixel.math.FlxPoint(1 / scaleX, 1 / scaleY);
	}

	public function setStrength(strength:Float = 1):Void
	{
		this.strength = strength;
		this.filter.strength = strength;
	}

	public function activate():Void
	{
		filters.push(this.filter);
	}

	public function deactivate():Void
	{
		filters.remove(this.filter);
	}

	override private function updateScaleOffset():Void
	{
		scale.x = 1;
		scale.y = 1;
	}

	override private function updateGameSize(Width:Int, Height:Int):Void 
	{
		gameSize.x = FlxG.width;
		gameSize.y = FlxG.height;
	}

	override private function updateOffsetY():Void
	{
		offset.y = 0;
	}

	override private function updateOffsetX():Void
	{
		offset.x = 0;
	}
	#else
	private var scaleX:Float;
	private var scaleY:Float;
	private var strength:Float;


	private var postProcess:PostProcess;

	private static inline var VERTEX_SHADER:String = "
#ifdef GL_ES
	precision mediump float;
#endif

attribute vec2 aVertex;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
	vTexCoord = aTexCoord;
	gl_Position = vec4(aVertex, 0.0, 1.0);
}";
	private static inline var NEAREST_SHADER:String = "varying vec2 vTexCoord;
//declare uniforms
uniform sampler2D uImage0;
uniform vec2 uResolution;

uniform float scaleX;
uniform float scaleY;
uniform float strength;

void main()
{
    vec2 tc = vec2(vTexCoord.x,vTexCoord.y+scaleY-1.0);
    
    gl_FragColor = texture2D(uImage0, vec2(tc.x/scaleX*strength,tc.y/scaleY*strength));
}";
	private static inline var BILINEAR_SHADER:String = "varying vec2 vTexCoord;
//declare uniforms
uniform sampler2D uImage0;
uniform vec2 uResolution;

uniform float scaleX;
uniform float scaleY;
uniform float strength;

void main()
{
    vec2 tc = vec2(vTexCoord.x,vTexCoord.y+scaleY-1.0);


	float OneTexelX = 1.0/uResolution.x*strength;
	float OneTexelY = 1.0/uResolution.y*strength;

	vec2 coord1 = vec2(tc.x/scaleX,tc.y/scaleY)+vec2(0.0, OneTexelY);
	vec2 coord2 = vec2(tc.x/scaleX,tc.y/scaleY)+vec2(OneTexelX, 0.0 );
	vec2 coord3 = vec2(tc.x/scaleX,tc.y/scaleY)+vec2(OneTexelX, OneTexelY);
	vec2 coord4 = vec2(tc.x/scaleX,tc.y/scaleY);
	
	vec4 s1 = vec4(texture2D(uImage0, coord1));
	vec4 s2 = vec4(texture2D(uImage0, coord2));
	vec4 s3 = vec4(texture2D(uImage0, coord3));
	vec4 s4 = vec4(texture2D(uImage0, coord4));
	
	vec2 Dimensions = vec2(tc) * uResolution;
	
	float fu = fract(Dimensions.x);
	float fv = fract(Dimensions.y);
	
	vec4 tmp1 = mix(s4, s2, fu);
	vec4 tmp2 = mix(s1, s3, fu);
	
	vec4 t0 = mix(tmp1, tmp2, fv);
    
    gl_FragColor = t0;//texture2D(uImage0, vec2(tc.x/scaleX,tc.y/scaleY));
}";

	public function new(shader:OneOfTwo<ShaderScaleEnum, Shader> = ShaderScaleEnum.NEAREST, scaleX:Float = 1, scaleY:Float = 1)
	{
		super();

		if (Std.is(shader, Shader))
		{
			this.postProcess = new PostProcess(cast(shader, Shader));
		}
		else
		{
			switch (cast(shader, ShaderScaleEnum))
			{
				case ShaderScaleEnum.NEAREST:
					this.postProcess = new PostProcess(new Shader([
					{ src: VERTEX_SHADER, fragment: false },
					{ src: NEAREST_SHADER, fragment: true }]));
				case ShaderScaleEnum.BILINEAR:
					this.postProcess = new PostProcess(new Shader([
					{ src: VERTEX_SHADER, fragment: false },
					{ src: BILINEAR_SHADER, fragment: true }]));
			}
		}

		this.setScale(scaleX, scaleY);
		this.setStrength(1);
	}

	public function setScale(scaleX:Float = 1, scaleY:Float = 1):Void
	{
		postProcess.setUniform("scaleX", scaleX);
		postProcess.setUniform("scaleY", scaleY);
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.pointerMultiplier = new flixel.math.FlxPoint(1 / scaleX, 1 / scaleY);
	}

	public function setStrength(strength:Float = 1):Void
	{
		postProcess.setUniform("strength", strength);
		this.strength = strength;
	}

	public function activate():Void
	{
		FlxG.addPostProcess(this.postProcess);
	}

	public function deactivate():Void
	{
		FlxG.removePostProcess(this.postProcess);
	}

	override private function updateScaleOffset():Void
	{
		scale.x = 1;
		scale.y = 1;
	}

	override private function updateGameSize(Width:Int, Height:Int):Void 
	{
		gameSize.x = FlxG.width;
		gameSize.y = FlxG.height;
	}

	override private function updateOffsetY():Void
	{
		offset.y = 0;
	}

	override private function updateOffsetX():Void
	{
		offset.x = 0;
	}
	#end
}