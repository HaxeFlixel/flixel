package flixel.graphics;

import flixel.graphics.shaders.FlxShader;
import flixel.system.render.hardware.gl.GLUtils;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.GLRenderContext;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.gl.GLProgram;
import openfl.utils.Float32Array;

#if (openfl >= "4.0.0")
import openfl.display.ShaderData;
import openfl.display.ShaderInput;
import openfl.display.ShaderParameter;
import openfl.display.ShaderParameterType;
#end

@:access(openfl.display.ShaderInput)
@:access(openfl.display.ShaderParameter)
@:access(openfl.display.Shader)

// TODO: single quad draw element...

class FlxMaterial implements IFlxDestroyable
{
	/**
	 * Name of the default texture for all the shaders.
	 */
	public static inline var DEFAULT_TEXTURE:String = "uImage0";
	
	private static var uniformMatrix2:Float32Array = new Float32Array(4);
	private static var uniformMatrix3:Float32Array = new Float32Array(9);
	private static var uniformMatrix4:Float32Array = new Float32Array(16);
	
	/**
	 * Shader of the material. Different shaders could have the same shader, 
	 * but material stores different data (uniforms, textures).
	 */
	public var shader(default, set):FlxShader;
	
	/**
	 * Data of the material, stores values for shader uniforms.
	 * Use this property only after setting shader of the material, or you could get null pointer access error.
	 */
	#if (openfl >= "4.0.0")
	public var data(default, null):ShaderData;
	#else
	public var data(default, null):Dynamic;
	#end
	
	/**
	 * Blend mode for the material
	 */
	public var blendMode:BlendMode = null;
	
	/**
	 * Tells if textures of the material should be smoothed or not.
	 */
	public var smoothing:Bool = false;
	
	/**
	 * Tells if textures of the material should be repeated or not.
	 */
	public var repeat:Bool = true;
	
	/**
	 * Tells if this material should be batched.
	 */
	public var batchable:Bool = false; // TODO: use this property...
	
	#if (openfl >= "4.0.0")
	private var inputTextures:Array<ShaderInput<BitmapData>>;
	private var paramBool:Array<ShaderParameter<Bool>>;
	private var paramFloat:Array<ShaderParameter<Float>>;
	private var paramInt:Array<ShaderParameter<Int>>;
	
	private var isUniform:Map<String, Bool>;
	#end
	
	private var gl:GLRenderContext;
	
	private var isShaderInit:Bool = false;
	
	public function new() 
	{
		#if (openfl >= "4.0.0")
		inputTextures = [];
		paramBool = [];
		paramFloat = [];
		paramInt = [];
		#end
	}
	
	public function destroy():Void
	{
		shader = null;
		data = null;
		
		gl = null;
		
		#if (openfl >= "4.0.0")
		inputTextures = null;
		paramBool = null;
		paramFloat = null;
		paramInt = null;
		#end
	}
	
	/**
	 * Uploads all the stored uniforms to the GPU.
	 * @param	gl	Render context.
	 */
	public function apply(gl:GLRenderContext/*, bitmap:BitmapData = null*/):Void
	{
		#if FLX_RENDER_GL
		if (shader == null)
		{
			return;
		}
		
		updateDataIndices(gl);
		
	//	var textureCount:Int = 0;
		var textureCount:Int = 1;
		
		for (input in inputTextures) 
		{
			if (input.name == DEFAULT_TEXTURE/* && bitmap != null*/)
			{
				/*
				gl.activeTexture(gl.TEXTURE0 + textureCount);
				gl.bindTexture(gl.TEXTURE_2D, bitmap.getTexture(gl));
				
				gl.uniform1i(input.index, textureCount);
				
				GLUtils.setTextureSmoothing(smoothing);
				GLUtils.setTextureWrapping(repeat);
				*/
				continue;
			}
			else if (input.input != null)
			{
				gl.activeTexture(gl.TEXTURE0 + textureCount);
				gl.bindTexture(gl.TEXTURE_2D, input.input.getTexture(gl));
				
				gl.uniform1i(input.index, textureCount);
				
				GLUtils.setTextureSmoothing(smoothing);
				GLUtils.setTextureWrapping(repeat);
			}
			
			textureCount++;
		}
		
		for (parameter in paramBool) 
		{
			var value:Array<Bool> = parameter.value;
			var index = parameter.index;
			
			if (value != null) 
			{
				switch (parameter.type) 
				{	
					case BOOL:
						gl.uniform1i(index, value[0] ? 1 : 0);
					
					case BOOL2:
						gl.uniform2i(index, value[0] ? 1 : 0, value[1] ? 1 : 0);
					
					case BOOL3:
						gl.uniform3i(index, value[0] ? 1 : 0, value[1] ? 1 : 0, value[2] ? 1 : 0);
					
					case BOOL4:
						gl.uniform4i(index, value[0] ? 1 : 0, value[1] ? 1 : 0, value[2] ? 1 : 0, value[3] ? 1 : 0);
					
					default:
						
				}
			} 
		}
		
		for (parameter in paramFloat) 
		{
			var value:Array<Float> = parameter.value;
			var index = parameter.index;
			
			if (value != null) 
			{
				switch (parameter.type)
				{
					case FLOAT:
						gl.uniform1f(index, value[0]);
					
					case FLOAT2:
						gl.uniform2f(index, value[0], value[1]);
					
					case FLOAT3:
						gl.uniform3f(index, value[0], value[1], value[2]);
					
					case FLOAT4:
						gl.uniform4f(index, value[0], value[1], value[2], value[3]);
					
					case MATRIX2X2:
						for (i in 0...4) 
							uniformMatrix2[i] = value[i];
						
						#if (openfl >= "4.9.0")
						gl.uniformMatrix2fv(index, 1, false, uniformMatrix2);
						#else
						gl.uniformMatrix2fv(index, false, uniformMatrix2);
						#end
					
					case MATRIX3X3:
						for (i in 0...9)
							uniformMatrix3[i] = value[i];
						
						#if (openfl >= "4.9.0")
						gl.uniformMatrix3fv(index, 1, false, uniformMatrix3);
						#else
						gl.uniformMatrix3fv(index, false, uniformMatrix3);
						#end
					
					case MATRIX4X4:
						for (i in 0...16)
							uniformMatrix4[i] = value[i];
						
						#if (openfl >= "4.9.0")
						gl.uniformMatrix4fv(index, 1, false, uniformMatrix4);
						#else
						gl.uniformMatrix4fv(index, false, uniformMatrix4);
						#end
					
					default:
						
				}	
			}
		}
		
		for (parameter in paramInt) 
		{
			var value:Array<Int> = parameter.value;
			var index = parameter.index;
			
			if (value != null) 
			{
				switch (parameter.type) 
				{
					case INT:
						gl.uniform1i(index, value[0]);
					
					case INT2:
						gl.uniform2i(index, value[0], value[1]);
					
					case INT3:
						gl.uniform3i(index, value[0], value[1], value[2]);
					
					case INT4:
						gl.uniform4i(index, value[0], value[1], value[2], value[3]);
					
					default:
						
				}
			} 
		}
		#end
	}
	
	/**
	 * Sets the texture by its name.
	 * Don't set "uImage0" texture with this method (it just will be ignored).
	 * 
	 * @param	name		name of the texture uniform
	 * @param	texture		texture to set.
	 */
	public function setTexture(name:String, texture:BitmapData):Void
	{
		#if (openfl >= "4.0.0")
		for (input in inputTextures)
		{
			if (input.name == name)
			{
				input.input = texture;
				return;
			}
		}
		#end
	}
	
	private function set_shader(value:FlxShader):FlxShader
	{
		#if FLX_RENDER_GL
		if (shader != value)
		{
			shader = value;
			isShaderInit = false;
			
			if (shader != null)
				initData();
		}
		#end
		
		return shader = value;
	}
	
	#if FLX_RENDER_GL
	private function updateDataIndices(gl:GLRenderContext):Void
	{
		if (this.gl != gl && gl != null && shader != null)
		{
			this.gl = gl;
			
			var glProgram:GLProgram = shader.glProgram;
			
			for (input in inputTextures)
				input.index = gl.getUniformLocation(glProgram, input.name);
			
			for (parameter in paramBool) 
				parameter.index = gl.getUniformLocation(glProgram, parameter.name);
			
			for (parameter in paramFloat) 
				parameter.index = gl.getUniformLocation(glProgram, parameter.name);
			
			for (parameter in paramInt) 
				parameter.index = gl.getUniformLocation(glProgram, parameter.name);
			
		}
	}
	
	private function initData():Void
	{
		if (shader != null && !isShaderInit)
		{
			data = new ShaderData(null);
			
			inputTextures.splice(0, inputTextures.length);
			paramBool.splice(0, paramBool.length);
			paramFloat.splice(0, paramFloat.length);
			paramInt.splice(0, paramInt.length);
			
			isUniform = new Map();
			
			var glProgram:GLProgram = shader.glProgram;
			var glVertexSource:String = shader.glVertexSource;
			var glFragmentSource:String = shader.glFragmentSource;
			
		//	processGLData(glVertexSource, "attribute"); // Don't add attributes (we don't need them, for now...)
			processGLData(glVertexSource, "uniform");
			processGLData(glFragmentSource, "uniform");
			
			if (glProgram != null)
			{	
				trace(glFragmentSource);
				
				for (input in inputTextures) 
				{	
					trace(input.name);
					
					input.index = Reflect.field(shader.data, input.name).index;
					/*
					if (isUniform.get(input.name))
						input.index = gl.getUniformLocation(glProgram, input.name);
					else
						input.index = gl.getAttribLocation(glProgram, input.name);
					*/
				}
				
				for (parameter in paramBool) 
				{
					parameter.index = Reflect.field(shader.data, parameter.name).index;
					
					/*
					if (isUniform.get(parameter.name))
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					*/
				}
				
				for (parameter in paramFloat) 
				{
					parameter.index = Reflect.field(shader.data, parameter.name).index;
					
					/*
					if (isUniform.get(parameter.name))
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					*/
				}
				
				for (parameter in paramInt)
				{
					parameter.index = Reflect.field(shader.data, parameter.name).index;
					
					/*
					if (isUniform.get(parameter.name)) 
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					*/
				}	
			}
			
			isShaderInit = true;
		}
	}
	
	private function processGLData(source:String, storageType:String):Void
	{
		var lastMatch = 0, position, regex, name, type;
		
		if (storageType == "uniform") 	
			regex = ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9]+)/;	
		else 
			regex = ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9]+)/;
		
		while (regex.matchSub(source, lastMatch)) 
		{	
			type = regex.matched(1);
			name = regex.matched(2);
			
			if (StringTools.startsWith(type, "sampler"))
			{	
				var input = new ShaderInput<BitmapData>();
				input.name = name;
				inputTextures.push(input);
				Reflect.setField(data, name, input);
			} 
			else 
			{	
				var parameterType:ShaderParameterType = switch (type) 
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
				
				switch (parameterType) 
				{	
					case BOOL, BOOL2, BOOL3, BOOL4:
						var parameter = new ShaderParameter<Bool>();
						parameter.name = name;
						parameter.type = parameterType;
						paramBool.push(parameter);
						Reflect.setField(data, name, parameter);
					
					case INT, INT2, INT3, INT4:
						var parameter = new ShaderParameter<Int>();
						parameter.name = name;
						parameter.type = parameterType;
						paramInt.push(parameter);
						Reflect.setField(data, name, parameter);
					
					default:
						var parameter = new ShaderParameter<Float>();
						parameter.name = name;
						parameter.type = parameterType;
						paramFloat.push(parameter);
						Reflect.setField(data, name, parameter);
				}
			}
			
			isUniform.set(name, storageType == "uniform");
			
			position = regex.matchedPos();
			lastMatch = position.pos + position.len;
		}	
	}
	#end
}