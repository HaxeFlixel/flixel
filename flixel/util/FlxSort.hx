package flixel.util;

import flixel.FlxBasic;
import flixel.FlxObject;

/**
 * Helper class for sort() in FlxTypedGroup, but could theoretically be used on regular arrays as well.
 */
class FlxSort
{
	public static inline var ASCENDING:Int = -1;
	public static inline var DESCENDING:Int = 1;
	
	/**
	 * You can use this function in FlxTypedGroup.sort() to sort FlxObjects by their y values.
	 */
 	public static inline function byY(Order:Int, Obj1:FlxObject, Obj2:FlxObject):Int
	{
		return byValues(Order, Obj1.y, Obj2.y);
	}
	
	/**
	 * You can use this function in FlxTypedGroup.sort() to sort FlxObjects by their x values.
	 */
	public static inline function byX(Order:Int, Obj1:FlxObject, Obj2:FlxObject):Int
	{
		return byValues(Order, Obj1.x, Obj2.x);
	}
	
	/**
	 * You can use this function as a backend to write a custom sorting function (see byX() and byY()).
	 */
	public static inline function byValues(Order:Int, Value1:Float, Value2:Float):Int
	{
		if (Value1 < Value2)
		{
			return Order;
		}
		else if (Value1 > Value2)
		{
			return - Order;
		}
		
		return 0;
	}
}