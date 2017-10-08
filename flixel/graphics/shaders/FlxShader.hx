package flixel.graphics.shaders;

import openfl.utils.ByteArray;

typedef FlxShader = #if (openfl_legacy || nme) 
						Dynamic;
					#elseif flash
						Shader;
					#else 
						openfl.display.Shader; 
					#end
					
class Shader 
{
	public var glVertexSource:String;
	public var glFragmentSource:String;
	
	public function new(vertexSource:String, fragmentSource:String) 
	{
		glVertexSource = vertexSource;
		glFragmentSource = fragmentSource;
	}
}