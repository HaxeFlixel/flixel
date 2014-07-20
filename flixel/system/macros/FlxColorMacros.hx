package flixel.system.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;

class FlxColorMacros
{
	/**
	 * Macro
	 * @return	An array of {name:String, color:Int} values with the static inline vars of FlxColor
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
									case TCast(_.expr => expr, _):
										switch(expr)
										{
											case TConst(TInt(_ => v)):
												color = v;
											default:
										}
									default:
								}
								values.push({name:f.name, color:color});
							default:
						}
					}
				}
			default:
		}
		
		return macro $v{values};
	}
}