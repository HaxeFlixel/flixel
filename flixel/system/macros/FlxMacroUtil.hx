package flixel.system.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;

class FlxMacroUtil
{
	/**
	 * Builds a map from static uppercase inline variables in an abstract type.
	 */
	public static macro function buildMap(typePath:String, reverse:Bool = false, ?exclude:Array<String>):Expr
	{
		var type = Context.getType(typePath);
		var values = [];
		
		if (exclude == null)
			exclude = ["NONE"];
		
		switch (type.follow()) 
		{
			case TAbstract(_.get() => ab, _):
				for (f in ab.impl.get().statics.get())
				{
					switch (f.kind)
					{
						case FVar(AccInline, _):
							var value = 0;
							switch (f.expr().expr)
							{
								case TCast(Context.getTypedExpr(_) => expr, _):
									value = expr.getValue();
								default:
							}
							if (f.name.toUpperCase() == f.name && exclude.indexOf(f.name) == -1) // uppercase?
							{
								values.push({name: f.name, value: value});
							}
						default:
					}
				}
			default:
		}
		
		var finalExpr;
		if (!reverse)
			finalExpr = values.map(function(v) return macro $v{v.name} => $v{v.value});
		else
			finalExpr = values.map(function(v) return macro $v{v.value} => $v{v.name});
			
		return macro $a{finalExpr};
	}
    
    /**
	 * Generate a sine and cosine table during compilation
	 * 
	 * The parameters allow you to specify the length, amplitude and frequency of the wave. 
	 * You have to call this function with constant parameters and either use it on your own or assign it to FlxAngle.sincos
	 * 
	 * @param length 		The length of the wave
	 * @param sinAmplitude 	The amplitude to apply to the sine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param cosAmplitude 	The amplitude to apply to the cosine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param frequency 	The frequency of the sine and cosine table data
	 * @return	Returns the cosine/sine table in a Dynamic
	 * @see getSinTable
	 * @see getCosTable
	 */
	public static macro function sinCosGenerator(length:Int, sinAmplitude:Float = 1.0, cosAmplitude:Float = 1.0, frequency:Float = 1.0):Expr
	{
		var sincos = {
			cos: new Array<Float>(),
			sin: new Array<Float>()
		};
		
		for (c in 0...length) {
            var radian = c * frequency * Math.PI / 180;
			sincos.cos.push(Math.cos(radian) * cosAmplitude);
			sincos.sin.push(Math.sin(radian) * sinAmplitude);
		}

		return Context.makeExpr(sincos, Context.currentPos());
	}

}