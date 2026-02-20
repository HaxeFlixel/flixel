package flixel.util;

import haxe.PosInfos;
import haxe.macro.Expr;

typedef FlxNullSafetyFailHandler = (level:FlxNullSafetyFailLevel, logId:String, ?pos:PosInfos)->Void;

abstract FlxNullChecker(FlxNullSafetyFailHandler) from FlxNullSafetyFailHandler
{
	public function new (onFail)
	{
		this = onFail;
	}
	
	/**
	 * An unsafe cast to a non-nullable type, useful to avoid null-safety compiler checks on
	 * objects you've already verified to be non-null.
	 */
	public inline function sure<T>(obj:Null<T>):T
	{
		return cast obj;
	}
	
	/**
	 * Null checks the object, returns it if it is not null, otherwise returns the backup.
	 */
	public inline function or<T>(obj:Null<T>, backup:T):T
	{
		return obj != null ? obj : backup;
	}
	
	/**
	 * Null checks the object, returns it if it is not null, otherwise returns the result of
	 * calling the backup. Useful if retrieving the backup is a costly operation.
	 */
	public inline function orGet<T>(obj:Null<T>, backup:()->T):T
	{
		return obj != null ? obj : backup();
	}
	
	public inline function check<T>(level, logId, obj:Null<T>, ?pos):T
	{
		if (obj == null)
			this(level, logId, pos);
		
		return sure(obj);
	}
	
	macro public function require(inst:Expr, obj:Expr):Expr return buildCheck(inst, obj, macro REQUIRE);
	
	macro public function assert (inst:Expr, obj:Expr):Expr return buildCheck(inst, obj, macro ASSERT);
	
	macro public function ought  (inst:Expr, obj:Expr):Expr return buildCheck(inst, obj, macro OUGHT);
	
	#if macro
	static public function buildCheck(inst:Null<Expr>, obj:Expr, level:ExprOf<FlxNullSafetyFailLevel>):Expr
	{
		final str = haxe.macro.MacroStringTools.formatString;
		final id = str('${haxe.macro.ExprTools.toString(obj)}', obj.pos);
		
		return macro
		{
			@:pos(obj.pos)
			$inst.check($level, $id, $obj);
		};
	}
	#end
}

enum abstract FlxNullSafetyFailLevel(Int)
{
	/** Lowest null-safety fail level, for non-problematic, yet still unexpected nulls */
	var OUGHT = 0;
	
	/** Mid-level null-safety fail, when a null could cause problems but code should continue */
	var ASSERT = 1;
	
	/** An unacceptable null-safety fail, when a program may not continue with a null value */
	var REQUIRE = 2;
}