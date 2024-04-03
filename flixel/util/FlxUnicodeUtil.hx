package flixel.util;

/**
 * Just an internal helper to deal with the deprecation of `haxe.Utf8` - not considered public API.
 */
@:dox(hide)
@:noCompletion
@:deprecated("Use UnicodeString")
class FlxUnicodeUtil
{
	@:deprecated("Use UnicodeString")
	public static inline function uLength(s:String):Int
	{
		return (s : UnicodeString).length;
	}
	
	@:deprecated("Use UnicodeString")
	public static inline function uEquals(a:String, b:String):Bool
	{
		return (a : UnicodeString) == (b : UnicodeString);
	}
	
	@:deprecated("Use UnicodeString")
	public static inline function uSub(s:String, pos:Int, len:Int):String
	{
		return (s : UnicodeString).substr(pos, len);
	}
	
	@:deprecated("Use UnicodeString")
	public static inline function uCharCodeAt(s:String, index:Int):Null<Int>
	{
		return (s : UnicodeString).charCodeAt(index);
	}
}

@:dox(hide)
@:noCompletion
@:deprecated("Use UnicodeString")
abstract UnicodeBuffer(UnicodeString)
{
	@:deprecated("Use UnicodeString")
	public inline function new(s:String = "")
	{
		this = s;
	}

	@:deprecated("Use UnicodeString")
	public inline function addChar(c:Int):UnicodeBuffer
	{
		return new UnicodeBuffer(this + String.fromCharCode(c));
	}

	public inline function toString():String
	{
		return this;
	}
}
