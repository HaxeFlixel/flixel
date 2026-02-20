package flixel.util;

import flixel.util.FlxNullChecker;
import haxe.PosInfos;
import haxe.macro.Expr;

@:access(flixel.util.FlxNullChecker)
class FlxNullUtil
{
	/**
	 * Handles any runtime null-safety check failure from `ought`, `assert`, and `require` calls,
	 * set this to a custom handler to change its behavior. By default, `OUGHT` will call
	 * `FlxG.log.warn`, `ASSERT` will call `FlxG.log.error`, and `REQUIRE` will throw an exception.
	 * 
	 * **NOTE:** Any `OUGHT`, or `ASSERT` failures before `FlxG` is initialized will trace rather than log
	 * 
	 * **NOTE:** It is highly recommended that all custom handlers throw exceptions on `REQUIRE` fails
	 */
	public static dynamic function onFail(level:FlxNullSafetyFailLevel, logId:String, ?pos:PosInfos):Void
	{
		switch level
		{
			case OUGHT: haxe.Log.trace('Null-safety OUGHT fail: $logId is null', pos);
			case ASSERT: haxe.Log.trace('Null-safety ASSERT fail: $logId is null', pos);
			case REQUIRE: throw 'Null-safety REQUIRE fail: $logId is null';
		}
	}
	
	static var checker = new FlxNullChecker((level, logId, ?pos)->onFail(level, logId, pos));
	
	public static inline function sure<T>(obj:Null<T>):T return checker.sure(obj);

	public static inline function or<T>(obj:Null<T>, backup:T):T return checker.sure(obj);
	
	public static inline function orGet<T>(obj:Null<T>, backup:()->T):T return checker.orGet(obj, backup);
	
	public static inline function check<T>(level, logId, obj:Null<T>, ?pos):T return checker.check(level, logId, obj, pos);
	
	/** Throws an exception if the object is null */
	macro public static function require(obj:Expr):Expr return FlxNullChecker.buildCheck(macro flixel.util.FlxNullUtil, obj, macro REQUIRE);
	
	/** Logs an error if the object is null */
	macro public static function assert (obj:Expr):Expr return FlxNullChecker.buildCheck(macro flixel.util.FlxNullUtil, obj, macro ASSERT);
	
	/** Logs a warning if the object is null */
	macro public static function ought  (obj:Expr):Expr return FlxNullChecker.buildCheck(macro flixel.util.FlxNullUtil, obj, macro OUGHT);
}