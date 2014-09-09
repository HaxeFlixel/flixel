package flixel.input.android;

#if android
/**
 * Maps enum values and strings to integer keycodes.
 */
@:enum
abstract FlxAndroidKey(FlxBaseKey) from Int to Int
{
	public static var keyNameMap:Map<String, FlxAndroidKey> = [
		"ANY" =>  ANY,
		"MENU" => MENU,
		"BACK" => BACK
	];
	
	var ANY  = -2;
	var NONE = -1;
	var MENU = 16777234;
	var BACK = 27;
	
	@:from
	public static inline function fromString(s:String):FlxAndroidKey
	{
		s = s.toUpperCase();
		return keyNameMap.exists(s) ? keyNameMap.get(s) : NONE;
	}
	
	@:to
	public static function toString(i:Int):String
	{
		for (key in keyNameMap.keys())
		{
			if (i == keyNameMap.get(key))
			{
				return key;
			}
		}
		return "NONE";
	}
}
#end