package flixel.graphics.frames.bmfont;

import UnicodeString;

using StringTools;

@:dox(hide)
@:noCompletion
class BMFontUtil
{
	static var attFinder = ~/(\w+?)=("?)(.*?)\2(?=\s|$)/;
	
	public static function forEachAttribute(text:UnicodeString, callback:(key:String, value:UnicodeString)->Void)
	{
		var index = 0;
		while (attFinder.match(text.substr(index)))
		{
			final key = attFinder.matched(1);
			final value = attFinder.matched(3);
			callback(key, value);
			
			final nextIndex = text.length - attFinder.matchedRight().length;
			if (nextIndex == index)
				throw 'Error parsing text: $text';
			index = nextIndex;
		}
	}
}