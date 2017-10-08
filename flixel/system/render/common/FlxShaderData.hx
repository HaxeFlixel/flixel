package flixel.system.render.common;

import openfl.utils.ByteArray;

#if ((openfl < "4.0.0") || flash)
class FlxShaderData implements Dynamic 
{
	public function new (?byteArray:ByteArray) 
	{
		
	}
}
#else
typedef FlxShaderData = openfl.display.ShaderData;
#end