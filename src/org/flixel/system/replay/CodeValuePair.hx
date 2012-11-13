package org.flixel.system.replay;

/**
 * ...
 * @author Zaphod
 */

class CodeValuePair
{
	public var code:Int;
	public var value:Int;
	
	public function new(code:Int = 0, value:Int = 0)
	{
		this.code = code;
		this.value = value;
	}
	
	inline public static function convertFromFlashToCpp(pair:CodeValuePair):CodeValuePair
	{
		var convertedCode:Int = pair.code;
		if (pair.code >= 65 && pair.code <= 90) 
		{
			convertedCode = pair.code + 32;
		}
		pair.code = convertedCode;
		return pair;
	}
	
}