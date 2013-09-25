package flixel.util;

/**
 * A set of functions for array manipulation.
 */
class FlxArrayUtil
{
	/**
	 * Function to search for a specified element in an array. This is faster than <code>Lambda.indexOf()</code>
	 * on the flash target because it uses the the native array <code>indexOf()</code> method.
	 * 
	 * @param	array		The array.
	 * @param	whatToFind	The element you're looking for.
	 * @param 	fromIndex	The index to start the search from (optional, for optimization).
	 * @return	The index of the element within the array. -1 if it wasn't found.
	 */
	@:generic static public function indexOf<T>(array:Array<T>, whatToFind:T, fromIndex:Int = 0):Int
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
	@:generic static public function setLength<T>(array:Array<T>, newLength:Int):Void
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
	 * Shuffles the entries in an array into a new random order.
	 * Deterministic and safe for use with replays/recordings.
	 * 
	 * @param	A				A Flash <code>Array</code> object containing...stuff.
	 * @param	HowManyTimes	How many swaps to perform during the shuffle operation.  Good rule of thumb is 2-4 times as many objects are in the list.
	 * @return	The same Flash <code>Array</code> object that you passed in in the first place.
	 */
	@:generic static public function shuffle<T>(Objects:Array<T>, HowManyTimes:Int):Array<T>
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
	@:generic static public function getRandom<T>(Objects:Array<T>, StartIndex:Int = 0, Length:Int = 0):T
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
	
	/**
	 * Split a comma-separated string into an array of ints
	 * @param	data string formatted like this: "1,2,5,-10,120,27"
	 * @return	an array of ints
	 */
	
	static public function intFromString(data:String):Array<Int>
	{
		if (data != null && data != "") 
		{
			var strArray:Array<String> = data.split(",");
			var iArray:Array<Int> = new Array<Int>();
			for (str in strArray) {
				iArray.push(Std.parseInt(str));
			}
			return iArray;
		}
		return null;
	}
	
	/**
	 * Split a comma-separated string into an array of floats
	 * @param	data string formatted like this: "1.0,2.1,5.6,1245587.9,-0.00354"
	 * @return
	 */	
	static public function floatFromString(data:String):Array<Float>
	{
		if (data != null && data != "") 
		{
			var strArray:Array<String> = data.split(",");
			var fArray:Array<Float> = new Array<Float>();
			for (str in strArray) {
				fArray.push(Std.parseFloat(str));
			}
			return fArray;
		}
		return null;
	}
}
