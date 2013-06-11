package org.flixel.util;

import flash.Lib;
import flash.net.URLRequest;
import org.flixel.FlxGame;

/**
 * A class containing random functions that didn't 
 * fit in any other class of the util package.
 */
class FlxMisc 
{
	/**
	 * Opens a web page in a new tab or window.
	 * 
	 * @param	URL		The address of the web page.
	 */
	inline public static function openURL(URL:String):Void
	{
		Lib.getURL(new URLRequest(URL), "_blank");
	}
	
	/**
	 * Just grabs the current "ticks" or time in milliseconds that has passed since Flash Player started up.
	 * Useful for finding out how long it takes to execute specific blocks of code.
	 * @return	Time in milliseconds that has passed since Flash Player started up.
	 */
	inline static public function getTicks():Int
	{
		return FlxGame._mark;
	}
	
	/**
	 * Check to see if two objects have the same class name.
	 * @param	Object1		The first object you want to check.
	 * @param	Object2		The second object you want to check.
	 * @return	Whether they have the same class name or not.
	 */
	@:extern inline static public function compareClassNames(Object1:Dynamic, Object2:Dynamic):Bool
	{
		return Type.getClassName(Object1) == Type.getClassName(Object2);
	}
	
	/**
	 * Function to search for a specified element in an array.
	 * @param	array		The array.
	 * @param	whatToFind	The element you're looking for.
	 * @param 	fromIndex	The index to start the search from (optional, for optimization).
	 * @return	The index of the element within the array. -1 if it wasn't found.
	 */
	inline static public function arrayIndexOf(array:Array<Dynamic>, whatToFind:Dynamic, fromIndex:Int = 0):Int
	{
		#if flash
		return untyped array.indexOf(whatToFind, fromIndex);
		#else
		var len:Int = array.length;
		var index:Int = -1;
		for (i in fromIndex...len)
		{
			if (array[i] == whatToFind) 
			{
				index = i;
				break;
			}
		}
		return index;
		#end
	}
	
	/**
	 * Sets the length of an array.
	 * @param	array		The array.
	 * @param	newLength	The length you want the array to have.
	 */
	static public function setArrayLength(array:Array<Dynamic>, newLength:Int):Void
	{
		#if flash
		untyped array.length = newLength;
		#else
		if (newLength < 0) return;
		var oldLength:Int = array.length;
		var diff:Int = newLength - oldLength;
		if (diff < 0)
		{
			diff = -diff;
			for (i in 0...diff)
			{
				array.pop();
			}
		}
		#end
	}
}