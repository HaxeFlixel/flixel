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
	EXPRESSION(expression:String);
}