package flixel.system.debug.watch;

enum WatchEntryData
{
	/**
	 * `object.field` resolved via `Reflect.getProperty()`.
	 */
	FIELD(object:Dynamic, field:String);

	/**
	 * Manually updated values.
	 */
	QUICK(value:String);

	/**
	 * Haxe expression evaluated with hscript.
	 */
	EXPRESSION(expression:String, parsedExpr:#if hscript hscript.Expr #else String #end);
	
	/**
	 * An expression evaluated `by FlxG.console`
	 */
	EXPR(expression:String, func:()->Any);
	
	/**
	 * A function that returns the value to display.
	 */
	FUNCTION(func:()->Dynamic);
}
