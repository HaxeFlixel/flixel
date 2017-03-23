package flixel.graphics;

import flixel.graphics.shaders.FlxShader;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.GLRenderContext;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.ShaderData;
import openfl.display.ShaderInput;
import openfl.display.ShaderParameter;
import openfl.display.ShaderParameterType;
import openfl.utils.Float32Array;

@:access(openfl.display.ShaderInput)
@:access(openfl.display.ShaderParameter)

// if shader is null, then try to batch material
// of shader isn't null, then look at the material properties to decide if batching is possible (number of textures)
// if batching is impossible, then draw object separately???
// if objects have the same material then we could try to batch them too.

// material property `batchable` ??? !!!!!!!!!!!!!!

// TODO: batch with previous (with material with the same shader)??? !!!!!!

class FlxMaterial implements IFlxDestroyable
{
	private static var uniformMatrix2:Float32Array = new Float32Array(4);
	private static var uniformMatrix3:Float32Array = new Float32Array(9);
	private static var uniformMatrix4:Float32Array = new Float32Array(16);
	
	public var shader(default, set):FlxShader;
	
	public var data(default, null):ShaderData;
	
	@:isVar
	public var texture(get, set):FlxGraphic;
	
	public var numTextures(get, null):Int;
	
	public var blendMode:BlendMode = null;
	
	public var smoothing:Bool = false;
	
	public var repeat:Bool = true;
	
	private var inputTextures:Array<ShaderInput<FlxGraphic>>;
	private var paramBool:Array<ShaderParameter<Bool>>;
	private var paramFloat:Array<ShaderParameter<Float>>;
	private var paramInt:Array<ShaderParameter<Int>>;
	
	private var numUniforms:Int = 0;
	
	public function new() 
	{
		data = new ShaderData(null);
	}
	
	public function destroy():Void
	{
		data = null;
		shader = null;
		
		inputTextures = null;
		paramBool = null;
		paramFloat = null;
		paramInt = null;
	}
	
	// TODO: call this after setting the shader shader...
	public function apply(gl:GLRenderContext):Void
	{
		initData();
		
		var textureCount:Int = 0;
		
		for (input in inputTextures) 
		{
			if (input.input != null) 
			{
				gl.activeTexture(gl.TEXTURE0 + textureCount);
				gl.bindTexture(gl.TEXTURE_2D, input.input.bitmap.getTexture(gl));
				
				// TODO: call this line when number of textures > 1.
				gl.uniform1i(input.index, textureCount); 
				
				if (input.smoothing) 
				{	
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);	
				} 
				else 
				{
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);	
				}
			}
			
			textureCount++;
		}
		
		var index:Dynamic = 0;
		
		for (parameter in paramBool) 
		{
			var value = parameter.value;
			index = parameter.index;
			
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
			var value = parameter.value;
			index = parameter.index;
			
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
			var value = parameter.value;
			
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
		
	}
	
	public function setTexture(name:String, texture:FlxGraphic):Void
	{
		for (input in inputTextures)
		{
			if (input.name == name)
			{
				input.input = texture;
				return;
			}
		}
	}
	
	private function set_shader(value:FlxShader):FlxShader
	{
		if (shader != value)
		{
			inputTextures = [];
			paramBool = [];
			paramFloat = [];
			paramInt = [];
			numUniforms = 0;
		}
		
		return shader = value;
	}
	
	private function initData():Void
	{
		if (shader != null && numUniforms == 0)
		{
			var fields = Reflect.fields(shader.data);
			
			for (fieldName in fields)
			{
				var field = Reflect.field(shader.data, fieldName);
				var name:String = field.name;
				var index:Int = field.index;
				
				if (Std.is(field, ShaderInput))
				{
					var input = new ShaderInput<FlxGraphic>();
					input.name = name;
					input.index = index;
					inputTextures.push(input);
					Reflect.setField(data, name, input);
				}
				else
				{
					var parameterType:ShaderParameterType = cast field.type;
					
					switch (parameterType) 
					{
						case BOOL, BOOL2, BOOL3, BOOL4:
							var parameter = new ShaderParameter<Bool>();
							parameter.name = field.name;
							parameter.type = parameterType;
							parameter.index = index;
							paramBool.push(parameter);
							Reflect.setField(data, name, parameter);
						
						case INT, INT2, INT3, INT4:
							var parameter = new ShaderParameter<Int>();
							parameter.name = name;
							parameter.type = parameterType;
							parameter.index = index;
							paramInt.push(parameter);
							Reflect.setField(data, name, parameter);
						
						default:	
							var parameter = new ShaderParameter<Float>();
							parameter.name = name;
							parameter.type = parameterType;
							parameter.index = index;
							paramFloat.push(parameter);
							Reflect.setField(data, name, parameter);
					}
				}
				
				numUniforms++;
			}
		}
		
	}
	
	// TODO: implement it...
	private function get_texture():FlxGraphic
	{
		return texture;
	}
	
	// TODO: implement it...
	private function set_texture(value:FlxGraphic):FlxGraphic
	{
		return texture = value;
	}
	
	private function get_numTextures():Int
	{
		return inputTextures.length;
	}
}