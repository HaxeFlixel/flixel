package flixel.system.input.keyboard;

/**
 * A helper class for keyboard input.
 */
class FlxKey
{
	inline static public var JUST_RELEASED:Int = -1;
	inline static public var RELEASED:Int = 0;
	inline static public var PRESSED:Int = 1;
	inline static public var JUST_PRESSED:Int = 2;

	/**
	 * The name of this key.
	 */
	public var name:String;
	/**
	 * The current state of this key.
	 */
	public var current:Int;
	/**
	 * The last state of this key.
	 */
	public var last:Int;
	
	public function new(Name:String, Current:Int = RELEASED, Last:Int = RELEASED)
	{
		name = Name;
		current = Current;
		last = Last;
	}
}