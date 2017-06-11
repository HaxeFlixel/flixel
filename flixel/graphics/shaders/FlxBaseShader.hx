package flixel.graphics.shaders;

#if (openfl >= "4.0.0")
class FlxBaseShader extends FlxShader
{
	public function new(vertexSource:String, fragmentSource:String) 
	{
		super();
		
		#if FLX_RENDER_GL
		glVertexSource = vertexSource;
		glFragmentSource = fragmentSource;
		
		data = null;
		__init();
		#end
	}
}
#else
class FlxBaseShader 
{
	public function new(vertexSource:String, fragmentSource:String) {}
}
#end