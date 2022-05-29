package flixel.graphics.tile;

#if FLX_DRAW_QUADS
import openfl.display.GraphicsShader;

class FlxGraphicsShader extends GraphicsShader
{
	@:glVertexSource("
		#pragma header
		
		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;
		
		void main(void)
		{
			#pragma body
			
			openfl_Alphav = openfl_Alpha * alpha;
			
			if (hasColorTransform)
			{
				openfl_ColorOffsetv = colorOffset / 255.0;
				openfl_ColorMultiplierv = colorMultiplier;
			}
		}")
	@:glFragmentHeader("
		uniform bool hasTransform;
		uniform bool hasColorTransform;

		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
		{
			vec4 color = texture2D(bitmap, coord);
			if (!hasTransform)
			{
				return color;
			}

			if (color.a == 0.0)
			{
				return vec4(0.0, 0.0, 0.0, 0.0);
			}

			if (!hasColorTransform)
			{
				return color * openfl_Alphav;
			}

			color = vec4(color.rgb / color.a, color.a);

			mat4 colorMultiplier = mat4(0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

			color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

			if (color.a > 0.0)
			{
				return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}
	")
	@:glFragmentSource("
		#pragma header
		
		void main(void)
		{
			gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
		}")
	public function new()
	{
		super();
	}

	@:noCompletion private override function __initGL():Void
	{
		if (__glSourceDirty || __paramBool == null)
		{
			__glSourceDirty = false;
			program = null;

			__inputBitmapData = new Array();
			__paramBool = new Array();
			__paramFloat = new Array();
			__paramInt = new Array();

			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}

		if (__context != null && program == null)
		{
			initGLforce();
		}
	}

	public function initGLforce()
	{
		initGood(glFragmentSource, glVertexSource);
	}

	public function initGood(glFragmentSource:String, glVertexSource:String) 
	{
		@:privateAccess
		var gl = __context.gl;

		#if android
		var prefix = "#version 300 es\n";
		#else
		var prefix = "#version 120\n";
		#end

		#if (js && html5)
		prefix += (precisionHint == FULL ? "precision mediump float;\n" : "precision lowp float;\n");
		#else
		prefix += "#ifdef GL_ES\n"
		+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH\n"
		+ "precision highp float;\n"
		+ "#else\n"
		+ "precision mediump float;\n"
		+ "#endif\n" : "precision lowp float;\n")
		+ "#endif\n\n";
		#end

		#if android
		prefix += 'out vec4 output_FragColor;\n';
		var vertex = prefix + glVertexSource.replace("attribute", "in").replace("varying", "out").replace("texture2D", "texture").replace("gl_FragColor", "output_FragColor");
		var fragment = prefix + glFragmentSource.replace("varying", "in").replace("texture2D", "texture").replace("gl_FragColor", "output_FragColor");
		#else
		var vertex = prefix + glVertexSource;
		var fragment = prefix + glFragmentSource;
		#end

		var id = vertex + fragment;

		@:privateAccess
		program = __context.createProgram(GLSL);

		@:privateAccess
		program.__glProgram = __createGLProgram(vertex, fragment);

		if (program != null)
		{
			@:privateAccess
			glProgram = program.__glProgram;

			for (input in __inputBitmapData)
			{
				@:privateAccess
				if (input.__isUniform)
				{
					@:privateAccess
					input.index = gl.getUniformLocation(glProgram, input.name);
				}
				else
				{
					@:privateAccess
					input.index = gl.getAttribLocation(glProgram, input.name);
				}
			}

			for (parameter in __paramBool)
			{
				@:privateAccess
				if (parameter.__isUniform)
				{
					@:privateAccess
					parameter.index = gl.getUniformLocation(glProgram, parameter.name);
				}
				else
				{
					@:privateAccess
					parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}
			}

			for (parameter in __paramFloat)
			{
				@:privateAccess
				if (parameter.__isUniform)
				{
					@:privateAccess
					parameter.index = gl.getUniformLocation(glProgram, parameter.name);
				}
				else
				{
					@:privateAccess
					parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}
			}

			for (parameter in __paramInt)
			{
				@:privateAccess
				if (parameter.__isUniform)
				{
					@:privateAccess
					parameter.index = gl.getUniformLocation(glProgram, parameter.name);
				}
				else
				{
					@:privateAccess
					parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}
			}
		}
	}
}
#end
