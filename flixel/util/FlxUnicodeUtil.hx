package flixel.util;

/**
 * Just an internal helper to deal with the deprecation of `haxe.Utf8` - not considered public API.
 */
@:dox(hide)
@:noCompletion
class FlxUnicodeUtil
{
	public static inline function uLength(s:String):Int
	{
		#if haxe4
		return (s : UnicodeString).length;
		#else
		return haxe.Utf8.length(s);
		#end
	}

	public static inline function uEquals(a:String, b:String):Bool
	{
		#if haxe4
		return (a : UnicodeString) == (b : UnicodeString);
		#else
		return haxe.Utf8.compare(a, b) == 0;
		#end
	}

	public static inline function uSub(s:String, pos:Int, len:Int):String
	{
		#if haxe4
		return (s : UnicodeString).substr(pos, len);
		#else
		return haxe.Utf8.sub(s, pos, len);
		#end
	}

	public static inline function uCharCodeAt(s:String, index:Int):Null<Int>
	{
		#if haxe4
		return (s : UnicodeString).charCodeAt(index);
		#else
		return haxe.Utf8.charCodeAt(s, index);
		#end
	}
}

@:dox(hide)
@:noCompletion
abstract UnicodeBuffer(#if haxe4 UnicodeString #else haxe.Utf8 #end)
{
	public inline function new(s:String = "")
	{
		this = #if haxe4 s #else new haxe.Utf8() #end;
	}

	public inline function addChar(c:Int):UnicodeBuffer
	{
		#if haxe4
		return new UnicodeBuffer(this + String.fromCharCode(c));
		#else
		this.addChar(c);
		return cast this;
		#end
	}

	public inline function toString():String
	{
		#if haxe4
		return this;
		#else
		return this.toString();
		#end
	}
}
