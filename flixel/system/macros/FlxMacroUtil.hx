package flixel.system.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

class FlxMacroUtil
{
	/**
	 * Builds a map from static uppercase inline variables in an abstract type.
	 *
	 * @param	invert	Use the field value as the key and the name as the value
	 */
	public static macro function buildMap(typePath:String, invert:Bool = false, ?exclude:Array<String>):Expr
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
		if (invert)
			finalExpr = values.map(function(v) return macro $v{v.value} => $v{v.name});
		else
			finalExpr = values.map(function(v) return macro $v{v.name} => $v{v.value});

		return macro $a{finalExpr};
	}
}
