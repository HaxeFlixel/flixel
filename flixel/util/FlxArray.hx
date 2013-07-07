package flixel.util;

/**
 * A set of functions for array manipulation.
 */
class FlxArray
{
	/**
	 * Function to search for a specified element in an array.
	 * 
	 * @param	array		The array.
	 * @param	whatToFind	The element you're looking for.
	 * @param 	fromIndex	The index to start the search from (optional, for optimization).
	 * @return	The index of the element within the array. -1 if it wasn't found.
	 */
	inline static public function indexOf(array:Array<Dynamic>, whatToFind:Dynamic, fromIndex:Int = 0):Int
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
	 * 
	 * @param	array		The array.
	 * @param	newLength	The length you want the array to have.
	 */
	static public function setLength(array:Array<Dynamic>, newLength:Int):Void
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
	
	/**
	 * Shuffles the entries in an array into a new random order.
	 * Deterministic and safe for use with replays/recordings.
	 * 
	 * @param	A				A Flash <code>Array</code> object containing...stuff.
	 * @param	HowManyTimes	How many swaps to perform during the shuffle operation.  Good rule of thumb is 2-4 times as many objects are in the list.
	 * @return	The same Flash <code>Array</code> object that you passed in in the first place.
	 */
	inline static public function shuffle(Objects:Array<Dynamic>, HowManyTimes:Int):Array<Dynamic>
	{
		HowManyTimes = Std.int(Math.max(HowManyTimes, 0));
		var i:Int = 0;
		var index1:Int;
		var index2:Int;
		var object:Dynamic;
		while (i < HowManyTimes)
		{
			index1 = Std.int(FlxRandom.float() * Objects.length);
			index2 = Std.int(FlxRandom.float() * Objects.length);
			object = Objects[index2];
			Objects[index2] = Objects[index1];
			Objects[index1] = object;
			i++;
		}
		return Objects;
	}
		
	/**
	 * Fetch a random entry from the given array.
	 * Will return null if random selection is missing, or array has no entries.
	 * Deterministic and safe for use with replays/recordings.
	 * 
	 * @param	Objects		A Flash array of objects.
	 * @param	StartIndex	Optional offset off the front of the array. Default value is 0, or the beginning of the array.
	 * @param	Length		Optional restriction on the number of values you want to randomly select from.
	 * @return	The random object that was selected.
	 */
	static public function getRandom(Objects:Array<Dynamic>, StartIndex:Int = 0, Length:Int = 0):Dynamic
	{
		if (Objects != null)
		{
			if (StartIndex < 0) StartIndex = 0;
			if (Length < 0) Length = 0;
			
			var l:Int = Length;
			if ((l == 0) || (l > Objects.length - StartIndex))
			{
				l = Objects.length - StartIndex;
			}
			if (l > 0)
			{
				return Objects[StartIndex + Std.int(FlxRandom.float() * l)];
			}
		}
		return null;
	}
}
