package flixel.graphics.shaders;

import openfl.Assets;
import openfl.display.Shader;

#if FLX_RENDER_GL
import openfl.display.ShaderInput;
import openfl.display.ShaderParameter;
import openfl.display.ShaderParameterType;
import openfl.gl.GL;

/**
 * ...
 * @author Zaphod
 */
class FlxShader extends Shader
{
	public function new(vertexSource:String, fragmentSource:String)
	{
		super();
		
		if (glProgram != null)
		{
			GL.deleteProgram(this.glProgram); // Delete what super created
			this.glProgram = null;
		}
		
		this.data = null;
		
		if (Assets.exists(vertexSource))
		{
			vertexSource = Assets.getText(vertexSource);
		}
		
		if (Assets.exists(fragmentSource))
		{
			fragmentSource = Assets.getText(fragmentSource);
		}
		
		// Then reinit all the data.
		glVertexSource = vertexSource;
		glFragmentSource = fragmentSource;
		
		// And call init again.
		__init();
		initShaderData();
	}
	
	override function __enable():Void 
	{
		super.__enable();
		
		if (glProgram != null) 
		{
			var param:ShaderParameter, value;
			var paramValue:Dynamic;
			
			for (field in Reflect.fields(data))
			{
				value = Reflect.field(data, field);
				
				if (Std.is(value, ShaderParameter)) 
				{
					param = cast value;
					paramValue = param.value;
					
					if (paramValue == null)
					{
						continue;
					}
					
					switch (param.type) 
					{
						case ShaderParameterType.FLOAT:
							gl.uniform1f(param.index, paramValue[0]);
						case ShaderParameterType.FLOAT2:
							gl.uniform2f(param.index, paramValue[0], paramValue[1]);
						case ShaderParameterType.FLOAT3:
							gl.uniform3f(param.index, paramValue[0], paramValue[1], paramValue[2]);
						case ShaderParameterType.FLOAT4:
							gl.uniform4f(param.index, paramValue[0], paramValue[1], paramValue[2], paramValue[3]);
						case ShaderParameterType.INT:
							gl.uniform1i(param.index, paramValue[0]);
						case ShaderParameterType.INT2:
							gl.uniform2i(param.index, paramValue[0], paramValue[1]);
						case ShaderParameterType.INT3:
							gl.uniform3i(param.index, paramValue[0], paramValue[1], paramValue[2]);
						case ShaderParameterType.INT4:
							gl.uniform4i(param.index, paramValue[0], paramValue[1], paramValue[2], paramValue[3]);
						case ShaderParameterType.MATRIX2X2:
							gl.uniformMatrix2fv(param.index, false, paramValue[0]);
						case ShaderParameterType.MATRIX3X3:
							gl.uniformMatrix3fv(param.index, false, paramValue[0]);
						case ShaderParameterType.MATRIX4X4:
							gl.uniformMatrix4fv(param.index, false, paramValue[0]);
						default:
							// nothing to do here. just continue the loop.
					}
				}
			}
		}
	}
	
	private function initShaderData():Void 
	{
		if (glFragmentSource != null && glVertexSource != null) 
		{
			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}
	}
	
	override private function __processGLData(source:String, storageType:String):Void 
	{
		var lastMatch = 0, position, regex, name, type;
		var input:Dynamic;
		var parameter:Dynamic;
		
		if (storageType == "uniform") 
		{
			regex = ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9]+)/;
		} 
		else 
		{	
			regex = ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9]+)/;	
		}
		
		while (regex.matchSub(source, lastMatch)) 
		{
			type = regex.matched(1);
			name = regex.matched(2);
			
			if (StringTools.startsWith(type, "sampler")) 
			{
				input = Reflect.field(data, name);
				
				if (input == null)
				{
					input = new ShaderInput();
					Reflect.setField(data, name, input);
				}
				
				if (gl != null)
				{
					if (storageType == "uniform") 
					{
						input.index = gl.getUniformLocation(glProgram, name);
					} 
					else
					{
						input.index = gl.getAttribLocation(glProgram, name);
					}
				}
			} 
			else 
			{
				parameter = Reflect.field(data, name);
				
				if (parameter == null)
				{
					parameter = new ShaderParameter();
					
					parameter.type = switch(type) 
					{
						case "bool": BOOL;
						case "double", "float": FLOAT;
						case "int", "uint": INT;
						case "bvec2": BOOL2;
						case "bvec3": BOOL3;
						case "bvec4": BOOL4;
						case "ivec2", "uvec2": INT2;
						case "ivec3", "uvec3": INT3;
						case "ivec4", "uvec4": INT4;
						case "vec2", "dvec2": FLOAT2;
						case "vec3", "dvec3": FLOAT3;
						case "vec4", "dvec4": FLOAT4;
						case "mat2", "mat2x2": MATRIX2X2;
						case "mat2x3": MATRIX2X3;
						case "mat2x4": MATRIX2X4;
						case "mat3x2": MATRIX3X2;
						case "mat3", "mat3x3": MATRIX3X3;
						case "mat3x4": MATRIX3X4;
						case "mat4x2": MATRIX4X2;
						case "mat4x3": MATRIX4X3;
						case "mat4", "mat4x4": MATRIX4X4;
						default: null;
						
					}
					
					Reflect.setField(data, name, parameter);
				}
				
				if (gl != null)
				{
					if (storageType == "uniform") 
					{
						parameter.index = gl.getUniformLocation(glProgram, name);	
					} 
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, name);
					}
				}
			}
			
			position = regex.matchedPos();
			lastMatch = position.pos + position.len;
		}
	}
}

#else

class FlxShader implements Dynamic
{
	public function new(vertexSource:String, fragmentSource:String)
	{
		
	}
}

#end