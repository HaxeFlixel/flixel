package flixel.graphics.shaders;

#if (openfl >= "4.0.0")
class FlxBaseShader extends FlxShader
{
	public function new(vertexSource:String, fragmentSource:String) 
	{
		#if flash
		super(vertexSource, fragmentSource);
		#else
		super();
		#end
		
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