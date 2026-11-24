package flixel.util;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.typeLimit.OneOfTwo;
import openfl.display.BitmapData;

using StringTools;

#if flash
import openfl.geom.Matrix;
#end

/**
 * A class primarily containing functions related
 * to formatting different data types to strings.
 */
class FlxStringUtil
{
	/**
	 * Takes two "ticks" timestamps and formats them into the number of seconds that passed as a String.
	 * Useful for logging, debugging, the watch window, or whatever else.
	 *
	 * @param	StartTicks	The first timestamp from the system.
	 * @param	EndTicks	The second timestamp from the system.
	 * @return	A String containing the formatted time elapsed information.
	 */
	public static inline function formatTicks(StartTicks:Int, EndTicks:Int):String
	{
		return (Math.abs(EndTicks - StartTicks) / 1000) + "s";
	}

	/**
	 * Format seconds as minutes with a colon, an optionally with milliseconds too.
	 *
	 * @param	Seconds		The number of seconds (for example, time remaining, time spent, etc).
	 * @param	ShowMS		Whether to show milliseconds after a "." as well.  Default value is false.
	 * @return	A nicely formatted String, like "1:03".
	 */
	public static function formatTime(Seconds:Float, ShowMS:Bool = false):String
	{
		var timeString:String = Std.int(Seconds / 60) + ":";
		var timeStringHelper:Int = Std.int(Seconds) % 60;
		if (timeStringHelper < 10)
		{
			timeString += "0";
		}
		timeString += timeStringHelper;
		if (ShowMS)
		{
			timeString += ".";
			timeStringHelper = Std.int((Seconds - Std.int(Seconds)) * 100);
			if (timeStringHelper < 10)
			{
				timeString += "0";
			}
			timeString += timeStringHelper;
		}

		return timeString;
	}

	/**
	 * Generate a comma-separated string from an array.
	 * Especially useful for tracing or other debug output.
	 *
	 * @param	AnyArray	Any Array object.
	 * @return	A comma-separated String containing the .toString() output of each element in the array.
	 */
	public static function formatArray(AnyArray:Array<Dynamic>):String
	{
		var string:String = "";
		if ((AnyArray != null) && (AnyArray.length > 0))
		{
			string = Std.string(AnyArray[0]);
			var i:Int = 1;
			var l:Int = AnyArray.length;
			while (i < l)
			{
				string += ", " + Std.string(AnyArray[i++]);
			}
		}
		return string;
	}

	/**
	 * Generate a comma-separated string representation of the keys of a StringMap.
	 *
	 * @param  AnyMap    A StringMap object.
	 * @return  A String formatted like this: key1, key2, ..., keyX
	 */
	public static function formatStringMap(AnyMap:Map<String, Dynamic>):String
	{
		var string:String = "";
		for (key in AnyMap.keys())
		{
			string += Std.string(key);
			string += ", ";
		}

		return string.substring(0, string.length - 2);
	}

	/**
	 * Automatically commas and decimals in the right places for displaying money amounts.
	 * Does not include a dollar sign or anything, so doesn't really do much
	 * if you call say `FlxString.formatMoney(10, false)`.
	 * However, very handy for displaying large sums or decimal money values.
	 *
	 * @param	Amount			How much moneys (in dollars, or the equivalent "main" currency - i.e. not cents).
	 * @param	ShowDecimal		Whether to show the decimals/cents component.
	 * @param	EnglishStyle	Major quantities (thousands, millions, etc) separated by commas, and decimal by a period.
	 * @return	A nicely formatted String. Does not include a dollar sign or anything!
	 */
	public static function formatMoney(Amount:Float, ShowDecimal:Bool = true, EnglishStyle:Bool = true):String
	{
		var isNegative = Amount < 0;
		Amount = Math.abs(Amount);

		var string:String = "";
		var comma:String = "";
		var amount:Float = Math.ffloor(Amount);
		while (amount > 0)
		{
			if (string.length > 0 && comma.length <= 0)
				comma = (EnglishStyle ? "," : ".");

			var zeroes = "";
			var helper = amount - Math.ffloor(amount / 1000) * 1000;
			amount = Math.ffloor(amount / 1000);
			if (amount > 0)
			{
				if (helper < 100)
					zeroes += "0";
				if (helper < 10)
					zeroes += "0";
			}
			string = zeroes + helper + comma + string;
		}

		if (string == "")
			string = "0";

		if (ShowDecimal)
		{
			amount = Math.ffloor(Amount * 100) - (Math.ffloor(Amount) * 100);
			string += (EnglishStyle ? "." : ",");
			if (amount < 10)
				string += "0";
			string += amount;
		}

		if (isNegative)
			string = "-" + string;
		return string;
	}

	/**
	 * Takes an amount of bytes and finds the fitting unit. Makes sure that the
	 * value is below 1024. Example: formatBytes(123456789); -> 117.74MB
	 */
	public static function formatBytes(Bytes:Float, Precision:Int = 2):String
	{
		var units:Array<String> = ["Bytes", "kB", "MB", "GB", "TB", "PB"];
		var curUnit = 0;
		while (Bytes >= 1024 && curUnit < units.length - 1)
		{
			Bytes /= 1024;
			curUnit++;
		}
		return FlxMath.roundDecimal(Bytes, Precision) + units[curUnit];
	}

	/** 
	 * Takes a string and filters out everything but the digits.
	 *
	 * @param 	Input	The input string
	 * @return 	The output string, digits-only
	 */
	public static function filterDigits(Input:String):String
	{
		var output = new StringBuf();
		for (i in 0...Input.length)
		{
			var c = Input.charCodeAt(i);
			if (c >= '0'.code && c <= '9'.code)
			{
				output.addChar(c);
			}
		}
		return output.toString();
	}

	/**
	 * Format a text with html tags - useful for TextField.htmlText.
	 * Used by the log window of the debugger.
	 *
	 * @param	Text		The text to format
	 * @param	Size		The text size, using the font-size-tag
	 * @param	Color		The text color, using font-color-tag
	 * @param	Bold		Whether the text should be bold (b-tag)
	 * @param	Italic		Whether the text should be italic (i-tag)
	 * @param	Underlined 	Whether the text should be underlined (u-tag)
	 * @return	The html-formatted text.
	 */
	public static function htmlFormat(Text:String, Size:Int = 12, Color:String = "FFFFFF", Bold:Bool = false, Italic:Bool = false,
			Underlined:Bool = false):String
	{
		var prefix:String = "<font size='" + Size + "' color='#" + Color + "'>";
		var suffix:String = "</font>";

		if (Bold)
		{
			prefix = "<b>" + prefix;
			suffix = suffix + "</b>";
		}
		if (Italic)
		{
			prefix = "<i>" + prefix;
			suffix = suffix + "</i>";
		}
		if (Underlined)
		{
			prefix = "<u>" + prefix;
			suffix = suffix + "</u>";
		}

		return prefix + Text + suffix;
	}

	/**
	 * Get the string name of any class or class instance. Wraps `Type.getClassName()`.
	 *
	 * @param	objectOrClass	The class or class instance in question.
	 * @param	simple	Returns only the type name, without package(s).
	 * @return	The name of the class as a string.
	 */
	public static function getClassName(objectOrClass:Dynamic, simple:Bool = false):String
	{
		var cl:Class<Dynamic>;
		if ((objectOrClass is Class))
			cl = cast objectOrClass;
		else
			cl = Type.getClass(objectOrClass);

		return formatPackage(Type.getClassName(cl), simple);
	}

	/**
	 * Get the string name of any enum or enum value. Wraps `Type.getEnumName()`.
	 *
	 * @param	enumValueOrEnum	The enum value or enum in question.
	 * @param	simple	Returns only the type name, without package(s).
	 * @return	The name of the enum as a string.
	 * @since 4.4.0
	 */
	public static function getEnumName(enumValueOrEnum:OneOfTwo<EnumValue, Enum<Dynamic>>, simple:Bool = false):String
	{
		var e:Enum<Dynamic>;
		if ((enumValueOrEnum is Enum))
			e = cast enumValueOrEnum;
		else
			e = Type.getEnum(enumValueOrEnum);

		return formatPackage(Type.getEnumName(e), simple);
	}

	static function formatPackage(s:String, simple:Bool):String
	{
		if (s == null)
			return null;

		s = s.replace("::", ".");
		if (simple)
			s = s.substr(s.lastIndexOf(".") + 1);
		return s;
	}

	/**
	 * Returns the host from the specified URL.
	 * The host is one of three parts that comprise the authority.  (User and port are the other two parts.)
	 * For example, the host for "ftp://anonymous@ftp.domain.test:990/" is "ftp.domain.test".
	 *
	 * @return	The host from the URL; or the empty string ("") upon failure.
	 * @since 4.3.0
	 */
	public static function getHost(url:String):String
	{
		var hostFromURL:EReg = ~/^(?:[a-z][a-z0-9+\-.]*:\/\/)?(?:[a-z0-9\-._~%!$&'()*+,;=]+@)?([a-z0-9\-._~%]{3,}|\[[a-f0-9:.]+\])?(?::[0-9]+)?/i;
		if (hostFromURL.match(url))
		{
			var host = hostFromURL.matched(1);
			return (host != null) ? host.urlDecode().toLowerCase() : "";
		}

		return "";
	}

	/**
	 * Returns the domain from the specified URL.
	 * The domain, in this case, refers specifically to the first and second levels only.
	 * For example, the domain for "api.haxe.org" is "haxe.org".
	 *
	 * @return	The domain from the URL; or the empty string ("") upon failure.
	 */
	public static function getDomain(url:String):String
	{
		var host:String = getHost(url);

		var isLocalhostOrIpAddress:EReg = ~/^(localhost|[0-9.]+|\[[a-f0-9:.]+\])$/i;
		var domainFromHost:EReg = ~/^(?:[a-z0-9\-]+\.)*([a-z0-9\-]+\.[a-z0-9\-]+)$/i;
		if (!isLocalhostOrIpAddress.match(host) && domainFromHost.match(host))
		{
			var domain = domainFromHost.matched(1);
			return (domain != null) ? domain.toLowerCase() : "";
		}

		return "";
	}

	/**
	 * Helper function that uses getClassName to compare two objects' class names.
	 *
	 * @param	Obj1	The first object
	 * @param	Obj2	The second object
	 * @param	Simple 	Only uses the class name, not the package or packages.
	 * @return	Whether they have the same class name or not
	 */
	public static inline function sameClassName(Obj1:Dynamic, Obj2:Dynamic, Simple:Bool = true):Bool
	{
		return (getClassName(Obj1, Simple) == getClassName(Obj2, Simple));
	}

	/**
	 * Split a comma-separated string into an array of ints
	 *
	 * @param	Data 	String formatted like this: "1, 2, 5, -10, 120, 27"
	 * @return	An array of ints
	 */
	public static function toIntArray(Data:String):Array<Int>
	{
		if ((Data != null) && (Data != ""))
		{
			var strArray:Array<String> = Data.split(",");
			var iArray:Array<Int> = new Array<Int>();
			for (str in strArray)
			{
				iArray.push(Std.parseInt(str));
			}
			return iArray;
		}
		return null;
	}

	/**
	 * Split a comma-separated string into an array of floats
	 *
	 * @param	Data string formatted like this: "1.0,2.1,5.6,1245587.9, -0.00354"
	 * @return	An array of floats
	 */
	public static function toFloatArray(Data:String):Array<Float>
	{
		if ((Data != null) && (Data != ""))
		{
			var strArray:Array<String> = Data.split(",");
			var fArray:Array<Float> = new Array<Float>();
			for (str in strArray)
			{
				fArray.push(Std.parseFloat(str));
			}
			return fArray;
		}
		return null;
	}

	/**
	 * Converts a one-dimensional array of tile data to a comma-separated string.
	 *
	 * @param   data    An array full of integer tile references.
	 * @param   width   The number of tiles in each row.
	 * @param   invert  Recommended only for 1-bit arrays - changes 0s to 1s and vice versa.
	 * @return  A comma-separated string containing the level data in a FlxTilemap-friendly format.
	 */
	public static function arrayToCSV(data:Array<Int>, width:Int, invert = false):String
	{
		return arrayToCSVHelper(invert ? data.map(t->t == 0 ? 1 : 0) : data, width);
	}
	
	static function arrayToCSVHelper<T>(data:Array<T>, width:Int):String
	{
		final rows = Std.int(data.length / width);
		return [ for (row in 0...rows)
			data.slice(width * row, (1 + row) * width).join(", ")
		].join("\n");
	}
	
	/**
	 * Converts a BitmapData object to a comma-separated string. Black pixels are flagged as 'solid' by default,
	 * non-black pixels are set as non-colliding. Black pixels must be PURE BLACK.
	 *
	 * @param   bitmap        A Flash BitmapData object, preferably black and white.
	 * @param   whiteIsSolid  Whether to load white pixels as solid and black and empty
	 * @param   scale         Default is 1. Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * @param	colorMap  	  An array of color values (ignores alpha) in the order they're intended to be assigned as indices
	 * @return  A comma-separated string containing the level data in a FlxTilemap-friendly format.
	 */
	@:deprecated("bitmapToCSV with both bitmap and colorMap is deprecated, use a different overload of bitmapToCSV")
	overload public static inline extern function bitmapToCSV(bitmap:BitmapData, whiteIsSolid:Bool, scale:Int, colorMap:Null<Array<FlxColor>>):String
	{
		if (colorMap == null)
			colorMap = whiteIsSolid ? invertColorMap : defaultColorMap;
		
		return bitmapToCSVHelper(bitmap, scale, colorMap, true);
	}
	
	/**
	 * Converts a BitmapData object to a comma-separated string. Black pixels are flagged as
	 * 'solid' by default, non-black pixels are set as non-colliding. Black pixels must be PURE BLACK
	 *
	 * @param   bitmap        A Flash BitmapData object, preferably black and white
	 * @param   whiteIsSolid  Whether to load white pixels as solid and black and empty
	 * @param   scale         Default is 1. Scale of 2 means each pixel forms a 2x2 block of tiles
	 * @return  A comma-separated string containing the level data in a FlxTilemap-friendly format
	 */
	overload public static inline extern function bitmapToCSV(bitmap:BitmapData, whiteIsSolid = false, scale = 1):String
	{
		return bitmapToCSVHelper(bitmap, scale, whiteIsSolid ? invertColorMap : defaultColorMap, true);
	}
	
	static final defaultColorMap = [FlxColor.WHITE, FlxColor.BLACK];
	static final invertColorMap = [FlxColor.BLACK, FlxColor.WHITE];

	/**
	 * Converts a BitmapData object to a comma-separated string.
	 *
	 * @param	bitmap   A Flash BitmapData object, preferably black and white.
	 * @param	scale    Default is 1. Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * @param	colorMap An array of rgb color values in the order, they're intended to be assigned as indices
	 * @return	A comma-separated string containing the level data in a FlxTilemap-friendly format.
	 */
	overload public static inline extern function bitmapToCSV(bitmap:BitmapData, scale = 1, colorMap:Array<FlxColor>):String
	{
		return bitmapToCSVHelper(bitmap, scale, colorMap, true);
	}

	/**
	 * Converts a BitmapData object to a comma-separated string.
	 * 
	 * **NOTE:** Due to OpenFL premultiplying all pixel colors on set,
	 * any pixel with a 0 alpha and non-zero color components will be treated as 0x00000000
	 * 
	 * @param	bitmap   A Flash BitmapData object, preferably black and white.
	 * @param	scale    Default is 1. Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * @param	colorMap An array of rgba color values in the order they're intended to be assigned as indices
	 * @return	A comma-separated string containing the level data in a FlxTilemap-friendly format.
	 */
	public static inline function bitmap32ToCSV(bitmap:BitmapData, scale = 1, colorMap:Array<FlxColor>):String
	{
		return bitmapToCSVHelper(bitmap, scale, colorMap, false);
	}
	
	static function bitmapToCSVHelper(bitmap:BitmapData, scale:Int, colors:Array<FlxColor>, ignoreAlpha:Bool):String
	{
		final colorMap = generateColorMapFromArray(colors, ignoreAlpha);
		final array = bitmapToArray2d(bitmap, colorMap, ignoreAlpha, 0);
		final scaledArray = FlxArrayUtil.scale(array, scale);
		return scaledArray.map(row->row.join(", ")).join("\n");
	}
	
	static function bitmapToArray2d<T>(bitmap:BitmapData, colorMap:Map<FlxColor, T>, ignoreAlpha:Bool, backupValue:T):Array<Array<T>>
	{
		final bitmapColors = bitmap.getVector(bitmap.rect);
		final columns = bitmap.width;
		return [ for (row in 0...bitmap.height)
		{
			[ for (column in 0...columns)
			{
				final rgba:FlxColor = bitmapColors[row * columns + column];
				final color = ignoreAlpha ? rgba.rgb : rgba;
				final value = if (colorMap.exists(color))
				{
					colorMap[color];
				}
				else if (isBrowserManipulatingImages)
				{
					final nearestColor = color.nearest(colorMap.keys());
					colorMap[color] = colorMap[nearestColor];
					FlxG.log.notice('Bitmap contains unexpected color ${color.toHexString()}, '
						+ 'likely due to your browser\'s privacy settings. Using nearest color $nearestColor.toHexString()}');
					colorMap[nearestColor];
				}
				else
				{
					colorMap[color] = backupValue;
					FlxG.log.error('Bitmap contains unexpected color ${color.toHexString()}. Defaulting to $backupValue');
					backupValue;
				}
				value;
			}];
		}];
	}
	
	#if FLX_UNIT_TEST
	public static var isBrowserManipulatingImages = false;
	#elseif html5 
	static var _isBrowserManipulatingImages:Null<Bool> = null;
	static var isBrowserManipulatingImages(get, null):Bool;
	static function get_isBrowserManipulatingImages()
	{
		if (_isBrowserManipulatingImages == null)
		{
			final width = 100;
			final height = 100;
			final bmd = new openfl.display.BitmapData(width, height, true);
			final pixels = width * height;
			for (color in [FlxColor.WHITE, FlxColor.BLACK, FlxColor.MAGENTA])
			{
				bmd.fillRect(bmd.rect, color);
				final pixels = bmd.getVector(bmd.rect);
				for (i in 0...pixels.length)
				{
					final pixelColor:FlxColor = pixels[i];
					if (pixelColor != color)
					{
						_isBrowserManipulatingImages = true;
						return true;
					}
				}
			}
		}
		
		return _isBrowserManipulatingImages;
	}
	#else
	static inline var isBrowserManipulatingImages = false;
	#end
	
	static function generateColorMapFromArray(colors:Array<FlxColor>, ignoreAlpha:Bool)
	{
		final colorMap = new Map<FlxColor, Int>();
		for (index => color in colors)
		{
			final mappedColor = ignoreAlpha ? color.rgb : color;
			if (colorMap.exists(mappedColor))
			{
				if (color == mappedColor) // argb matches
					FlxG.log.error('Color map contains duplicates of ${color.toHexString()}');
				else
					FlxG.log.error('Color map contains duplicate rgb for ${color.toHexString()} and ${mappedColor.toHexString()}');
			}
			else
				colorMap[mappedColor] = index;
		}
		
		#if html5
		if (!isBrowserManipulatingImages)
			return colorMap;
		
		// check for farbling, try to account
		final width = 100;
		final height = 100;
		final bmd = new openfl.display.BitmapData(width, height, true);
		final pixels = width * height;
		var mapModified = false;
		for (color => index in colorMap)
		{
			bmd.fillRect(bmd.rect, color);
			var errorFound = false;
			final newColors = new Array<FlxColor>();
			final pixels = bmd.getVector(bmd.rect);
			for (i in 0...pixels.length)
			{
				// final pixelColor:FlxColor = bmd.getPixel32(i % width, Std.int(i / width));
				final pixelColor:FlxColor = pixels[i];
				if (pixelColor != color && !newColors.contains(pixelColor))
				{
					if (colorMap.exists(pixelColor))
					{
						FlxG.log.error('Cannot reliably read bitmaps, due to your brower\'s privacy settings. '
							+ 'Source pixels ${color.toHexString()}, may become ${pixelColor.toHexString()}');
						
						errorFound = true;
					}
					else
					{
						FlxG.log.notice('Browser image manipulation detected. '
							+ 'Source pixels [$index]${color.toHexString()}, may become ${pixelColor.toHexString()}');
						newColors.push(pixelColor);
						mapModified = true;
					}
				}
			}
			
			// Make the modifed colors point to the same index
			for (color in newColors)
				colorMap[color] = index;
		}
		
		if (mapModified)
			FlxG.log.add('Color map adjusted to compensate for your browser\'s privacy settings'
				+ '${[for (color=>index in colorMap) '${color.toHexString()} => $index']}');
		#end
		
		return colorMap;
	}

	/**
	 * Converts a resource image file to a comma-separated string. Black pixels are flagged as 'solid' by default,
	 * non-black pixels are set as non-colliding. Black pixels must be PURE BLACK.
	 *
	 * @param   graphic       An embedded graphic, preferably black and white.
	 * @param   whiteIsSolid  Whether to load white pixels as solid and black and empty.
	 * @param   scale         Default is 1.  Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * @param   colorMap      An array of color values (ingoring alpha) in the order they're intended to be assigned as indices.
	 * @return  A comma-separated string containing the level data in a FlxTilemap-friendly format.
	 */
	@:deprecated("imageToCSV with both whiteIsSolid and colorMap is deprecated, use a different overload of imageToCSV")
	overload public static inline extern function imageToCSV(graphic:FlxGraphicAsset, whiteIsSolid:Bool, scale:Int, colorMap:Null<Array<FlxColor>>):String
	{
		if (colorMap != null)
			colorMap = whiteIsSolid ? invertColorMap : defaultColorMap;
		
		return bitmapToCSVHelper(graphic.resolveBitmapData(), scale, colorMap, true);
	}
	
	/**
	 * Converts a resource image file to a comma-separated string. Black pixels are flagged as 'solid' by default,
	 * non-black pixels are set as non-colliding. Black pixels must be PURE BLACK.
	 *
	 * @param   graphic       An embedded graphic, preferably black and white.
	 * @param   whiteIsSolid  Whether to load white pixels as solid and black and empty
	 * @param   scale         Default is 1.  Scale of 2 means each pixel forms a 2x2 block of tiles, and so on
	 * @return  A comma-separated string containing the level data in a FlxTilemap-friendly format
	 * @since 6.2.0
	 */
	overload public static inline extern function imageToCSV(graphic:FlxGraphicAsset, whiteIsSolid = false, scale = 1):String
	{
		return bitmapToCSVHelper(graphic.assertBitmapData(), scale, whiteIsSolid ? invertColorMap : defaultColorMap, true);
	}
	
	/**
	 * Converts a resource image file to a comma-separated string
	 *
	 * @param   graphic   An embedded graphic, preferably black and white.
	 * @param   scale     Default is 1.  Scale of 2 means each pixel forms a 2x2 block of tiles, and so on
	 * @param   colorMap  An array of color values (ingoring alpha) in the order they're intended to be assigned as indices
	 * @return  A comma-separated string containing the level data in a FlxTilemap-friendly format
	 * @since 6.2.0
	 */
	overload public static inline extern function imageToCSV(graphic:FlxGraphicAsset, scale = 1, colorMap:Array<FlxColor>):String
	{
		return bitmapToCSVHelper(graphic.assertBitmapData(), scale, colorMap, true);
	}
	
	/**
	 * Converts a resource image file to a comma-separated string
	 *
	 * @param   graphic   An embedded graphic, preferably black and white.
	 * @param   scale     Default is 1.  Scale of 2 means each pixel forms a 2x2 block of tiles, and so on
	 * @param   colorMap  An array of color values in the order they're intended to be assigned as indices
	 * @return  A comma-separated string containing the level data in a FlxTilemap-friendly format
	 * @since 6.2.0
	 */
	overload public static inline extern function image32ToCSV(graphic:FlxGraphicAsset, scale = 1, colorMap:Array<FlxColor>):String
	{
		return bitmapToCSVHelper(graphic.assertBitmapData(), scale, colorMap, false);
	}

	/**
	 * Helper function to create a string for toString() functions. Automatically rounds values according to FlxG.debugger.precision.
	 * Strings are formatted in the format: (x: 50 | y: 60 | visible: false)
	 *
	 * @param	LabelValuePairs		Array with the data for the string
	 */
	public static function getDebugString(LabelValuePairs:Array<LabelValuePair>):String
	{
		var output:String = "(";
		for (pair in LabelValuePairs)
		{
			output += (pair.label + ": ");
			var value:Dynamic = pair.value;
			if ((value is Float))
			{
				value = FlxMath.roundDecimal(cast value, FlxG.debugger.precision);
			}
			output += (value + " | ");
			pair.put(); // free for recycling
		}
		// remove the | of the last item, we don't want that at the end
		output = output.substr(0, output.length - 2).trim();
		return (output + ")");
	}

	public static inline function contains(s:String, str:String):Bool
	{
		return s.indexOf(str) != -1;
	}

	/**
	 * Removes occurrences of a substring by calling `StringTools.replace(s, sub, "")`.
	 */
	public static inline function remove(s:String, sub:String):String
	{
		return s.replace(sub, "");
	}

	/**
	 * Inserts `insertion` into `s` at index `pos`.
	 */
	public static inline function insert(s:String, pos:Int, insertion:String):String
	{
		return s.substring(0, pos) + insertion + s.substr(pos);
	}

	public static function sortAlphabetically(list:Array<String>):Array<String>
	{
		list.sort(function(a, b)
		{
			a = a.toLowerCase();
			b = b.toLowerCase();
			if (a < b)
				return -1;
			if (a > b)
				return 1;
			return 0;
		});
		return list;
	}

	/**
	 * Returns true if `s` equals `null` or is empty.
	 * @since 4.1.0
	 */
	public static inline function isNullOrEmpty(s:String):Bool
	{
		return s == null || s.length == 0;
	}
	
	/**
	 * Returns an Underscored, or "slugified" string
	 * Example: `"A Tale of Two Cities, Part II"` becomes `"a_tale_of_two_cities__part_ii"`
	 */
	public static function toUnderscoreCase(str:String):String 
	{
		var regex = ~/[^a-z0-9]+/g;
		return regex.replace(str.toLowerCase(), '_');
	}
	
	/**
	 * Returns a string formatted to 'Title Case'. 
	 * Example: `"a tale of two cities, pt ii" returns `"A Tale of Two Cities, Part II"`
	 */
	public static function toTitleCase(str:String):String 
	{
		var exempt:Array<String> = ["a", "an", "the", "at", "by", "for", "in", "of", "on", "to", "up", "and", "as", "but", "or", "nor"];
		var words:Array<String> = str.toLowerCase().split(" ");
		
		for (i in 0...words.length) 
		{
			if (isRomanNumeral(words[i]))
				words[i] = words[i].toUpperCase();
			else if (i == 0 || exempt.indexOf(words[i]) == -1)
				words[i] = words[i].charAt(0).toUpperCase() + words[i].substr(1);
		}

		return words.join(" ");
		
	}
	
	/**
	 * Capitalizes the first letter of every word, does not change the others to lower
	 */
	static final whitespace = ~/(?<=\r|\s|^)([a-z])/g;
	public static function capitalizeFirstLetters(str:String):String
	{
		// TODO: Unit test
		return whitespace.map(str, (r)->r.matched(0).toUpperCase());
	}
	
	/**
	 * Wether the string contains a valid roman numeral
	 */
	static final roman = ~/^(?=[MDCLXVI])M*(C[MD]|D?C*)(X[CL]|L?X*)(I[XV]|V?I*)$/i;
	public static function isRomanNumeral(str:String):Bool
	{
		return roman.match(str);
	}
}

class LabelValuePair implements IFlxDestroyable
{
	static var _pool = new FlxPool(LabelValuePair.new);
	
	public static inline function weak(label:String, value:Dynamic):LabelValuePair
	{
		return _pool.get().create(label, value);
	}

	public var label:String;
	public var value:Dynamic;

	public inline function create(label:String, value:Dynamic):LabelValuePair
	{
		this.label = label;
		this.value = value;
		return this;
	}

	public inline function put():Void
	{
		_pool.put(this);
	}

	public inline function destroy():Void
	{
		label = null;
		value = null;
	}

	@:keep
	function new() {}
}
