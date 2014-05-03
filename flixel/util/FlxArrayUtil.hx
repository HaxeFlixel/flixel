package flixel.util;

/**
 * A set of functions for array manipulation.
 */
class FlxArrayUtil
{	
	@:generic
	public static inline function indexOf<T>(array:Array<T>, whatToFind:T, fromIndex:Int = 0):Int
	{
		return array.indexOf(whatToFind, fromIndex);
	}
	
	/**
	 * Sets the length of an array.
	 * 
	 * @param	array		The array.
	 * @param	newLength	The length you want the array to have.
	 */
	@:generic
	public static function setLength<T>(array:Array<T>, newLength:Int):Void
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
	@:generic
	public static inline function shuffle<T>(Objects:Array<T>, HowManyTimes:Int):Array<T>
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
	@:generic
	public static inline function getRandom<T>(Objects:Array<T>, StartIndex:Int = 0, EndIndex:Int = 0):T
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
	@:generic
	public static inline function fastSplice<T>(array:Array<T>, element:T):Array<T>
	{
		var index = array.indexOf(element);
		if (index != -1)
		{
			return swapAndPop(array, index);
		}
		return array;
	}
	
	/**
	 * Removes an element from an array by swapping it with the last element and calling pop().
	 * This is a lot faster than regular splice(), but it can only be used on arrays where order doesn't matter.
	 * 
	 * IMPORTANT: always count down from length to zero if removing elements from whithin a loop
	 * 
	 * var i = array.length;
	 * while (i-- > 0)
	 * {
	 *      if (array[i].shouldRemove)
	 *      {
	 *           FlxArrayUtil.swapAndPop(array, i);
	 *      }
	 * }
	 * 
	 * @param	array	The array to remove the element from
	 * @param 	index	The index of the element to be removed from the array
	 * @return	The array
	 */
	@:generic
	public static inline function swapAndPop<T>(array:Array<T>, index:Int):Array<T>
	{
		array[index] = array[array.length - 1]; // swap element to remove and last element
		array.pop();
		return array;
	}
	
	/**
	 * Clears an array structure, but leaves the object data untouched
	 * Useful for cleaning up temporary references to data you want to preserve
	 * WARNING: Can lead to memory leaks. Use destroyArray() instead for data you truly want GONE.
	 *
	 * @param	array		The array to clear out
	 * @param	Recursive	Whether to search for arrays inside of arr and clear them out, too (false by default)
	 */
	@:generic
	public static function clearArray<T>(array:Array<T>, recursive:Bool = false):Void
	{
		if (array != null)
		{
			if (!recursive)
			{
				while (array.length > 0)
				{
					array.pop();
				}
			}
			else
			{
				while (array.length > 0)
				{
					var thing:Dynamic = array.pop();
					if (Std.is(thing, Array))
					{
						clearArray(array, recursive);
					}
				}
			}
		}
	}
}
