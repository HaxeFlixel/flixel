package flixel.graphics.frames.bmfont;

import UnicodeString;

using StringTools;

@:noCompletion
class BMFontUtil
{
	public static var SPACE_REG = ~/ +/g;
	public static var QUOTES_REG = ~/^"(.+)"$/;
	public static function forEachAttribute(text:UnicodeString, callback:(key:String, value:UnicodeString)->Void)
	{
		for (s in SPACE_REG.split(text))
		{
			final split = s.split('=');
			final key = parseKey(split[0]);
			final value = parseValue(split[1]);
			callback(key, value);
		}
	}
	
	static inline function parseKey(text:String)
	{
		// return removeQuotes(text);// not needed
		return text;
	}
	
	static inline function parseValue(text:String)
	{
		return removeQuotes(text);
	}
	
	/**
	 * Removes surrounding quotes from text
	 */
	static inline function removeQuotes(text:String)
	{
		return QUOTES_REG.match(text) ? QUOTES_REG.matched(1) : text;
	}
}