package flixel.util;

/**
 * Null safety tools. Add `using flixel.util.FlxNullUtil;` to a module for static extension.
 * @since 6.3.0
 * 
 * Example:
 * ```haxe
 * someFunction(someNullableValue.sure());
 * ```
 * 
 * Copied from https://github.com/RealyUniqueName/Safety/blob/master/src/Safety.hx
 */
@:nullSafety(Strict)
class FlxNullUtil
{
	/**
	 * Returns `value` if it is not `null`. Otherwise throws an exception.
	 */
	static public inline function sure<T>(value:Null<T>):T
	{
		return value == null ? throw 'Null pointer in .sure() call' : value;
	}
	
	/**
	 * Just returns `value` without any checks, but typed as not-nullable. Use at your own risk.
	 */
	static public inline function unsafe<T>(value:Null<T>):T
	{
		return @:nullSafety(Off) (value:T);
	}
}