package flixel.util;

/**
 * A set of functions for array manipulation.
 */
class FlxArrayUtil
{
	/**
	 * Function to search for a specified element in an array. This is faster than Lambda.indexOf()
	 * on the flash target because it uses the the native array indexOf() method.
	 * 
	 * @param	array		The array.
	 * @param	whatToFind	The element you're looking for.
	 * @param 	fromIndex	The index to start the search from (optional, for optimization).
	 * @return	The index of the element within the array. -1 if it wasn't found.
	 */
	@:generic public static function indexOf<T>(array:Array<T>, whatToFind:T, fromIndex:Int = 0):Int
	{
		#if flash
		return untyped array.indexOf(whatToFind, fromIndex);
		#else
		var index:Int = -1;
		var len:Int = array.length;
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
	 * 
	 * @param	array		The array.
	 * @param	newLength	The length you want the array to have.
	 */
	@:generic public static function setLength<T>(array:Array<T>, newLength:Int):Void
	{
		if (newLength < 0) return;
		var oldLength:Int = array.length;
		var diff:Int = newLength - oldLength;
		if (diff < 0)
		{
			#if flash
			untyped array.length = newLength;
			#else
			diff = -diff;
			for (i in 0...diff)
			{
				array.pop();
			}
			#end
		}
	}
	
	/**
	 * Deprecated; please use FlxRandom.shuffleArray() instead.
	 * Shuffles the entries in an array into a new random order.
	 * 
	 * @param	Objects			An array to shuffle.
	 * @param	HowManyTimes	How many swaps to perform during the shuffle operation.  A good rule of thumb is 2-4 times the number of objects in the list.
	 * @return	The newly shuffled array.
	 */
	@:generic public static inline function shuffle<T>(Objects:Array<T>, HowManyTimes:Int):Array<T>
	{
		return FlxRandom.shuffleArray(Objects, HowManyTimes);
	}
	
	/**
	 * Deprecated; please use FlxRandom.getObject() instead.
	 * Fetch a random entry from the given array from StartIndex to EndIndex.
	 * 
	 * @param	Objects			An array from which to select a random entry.
	 * @param	StartIndex		Optional index from which to restrict selection. Default value is 0, or the beginning of the array.
	 * @param	EndIndex		Optional index at which to restrict selection. Ignored if 0, which is the default value.
	 * @return	The random object that was selected.
	 */
	@:generic public static inline function getRandom<T>(Objects:Array<T>, StartIndex:Int = 0, EndIndex:Int = 0):T
	{
		return FlxRandom.getObject(Objects, StartIndex, EndIndex);
	}
	
	/**
	 * Safely removes an element from an array by swapping it with the last element and calling pop()
	 * (won't do anything if the element is not in the array). This is a lot faster than regular splice(), 
	 * but it can only be used on arrays where order doesn't matter.
	 * 
	 * @param	array	The array to remove the element from
	 * @param 	element	The element to remove from the array
	 * @return	The array
	 */
	@:generic public static function fastSplice<T>(array:Array<T>, element:T):Array<T>
	{
		var index = indexOf(array, element);
		if (index >= 0)
		{
			array[index] = array[array.length - 1]; // swap element to remove and last element
			array.pop();
		}
		return array;
	}
}
