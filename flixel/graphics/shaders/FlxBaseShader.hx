package flixel.graphics.shaders;

#if (openfl >= "4.0.0")
class FlxBaseShader extends FlxShader
{
	public function new(vertexSource:String, fragmentSource:String) 
	{
		super();
		
		#if FLX_RENDER_GL
		__glVertexSource = vertexSource;
		__glFragmentSource = fragmentSource;
		__glSourceDirty = true;
		#end
	}
}
#else
class FlxBaseShader 
{
	public function new(vertexSource:String, fragmentSource:String) {}
}
#end