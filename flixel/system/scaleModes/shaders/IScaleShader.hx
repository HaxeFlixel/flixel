package flixel.system.scaleModes.shaders;

interface IScaleShader
{
	#if !flash
  		public var uScaleX(get, set):Float;
  		public var uScaleY(get, set):Float;
  		public var uStrength(get, set):Float;
  		public var uResolution(get, set):Array<Float>;
	#else
		public var uScaleX:Float;
  		public var uScaleY:Float;
  		public var uStrength:Float;
  		public var uResolution:Array<Float>;
  	#end
}