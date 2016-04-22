package flixel.system.scaleModes.shaders;

import openfl.display.Shader;

interface IScaleShader
{
	
  public var uScaleX(get, set):Float;
  public var uScaleY(get, set):Float;
  public var uResolution(get, set):Array<Float>;
	
}