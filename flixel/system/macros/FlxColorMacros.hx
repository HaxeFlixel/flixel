package flixel.system.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;

class FlxColorMacros
{
	/**
	 * Macro
	 * @return	Returns the the static inline vars of FlxColor as an Array<Expr> for a map.
	 */
	public static macro function staticColors():Expr
	{
		var type = Context.getType("flixel.util.FlxColor");
		
		var values = [];
		
		switch(type.follow()) 
		{
			case TAbstract(_.get() => ab, _):
				for (f in ab.impl.get().statics.get())
				{
					if (f.isPublic)
					{
						switch(f.kind)
						{
							case FVar(AccInline, _):
								var color = 0;
								switch(f.expr().expr)
								{
									case TCast(Context.getTypedExpr(_) => expr, _):
										color = expr.getValue();
									default:
								}
								values.push({name:f.name, color:color});
							default:
						}
					}
				}
			default:
		}
		
		var finalExpr = values.map(function(v) return macro $v{v.name} => $v{v.color});
		
		return macro $a{finalExpr};
	}
}