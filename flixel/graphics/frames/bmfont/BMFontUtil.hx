package flixel.graphics.frames.bmfont;

import UnicodeString;

using StringTools;

@:dox(hide)
@:noCompletion
class BMFontUtil
{
	public static var ATTRIBUTE_REG = ~/(\w+?)=((".*?")|.*?)(\s|$)/g;
	public static var QUOTES_REG = ~/^"(.+)"$/;
	public static function forEachAttribute(text:UnicodeString, callback:(key:String, value:UnicodeString)->Void)
	{
		while (ATTRIBUTE_REG.match(text))
		{
			final key = ATTRIBUTE_REG.matched(1);
			final value = ATTRIBUTE_REG.matched(2);
			callback(key, value);
			text = ATTRIBUTE_REG.matchedRight();
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