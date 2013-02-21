/**
 * ...
 * @author Zaphod
 */
package org.flixel;

import nme.display.BitmapInt32;
import nme.Lib;
import nme.net.URLRequest;
import org.flixel.FlxPoint;

class FlxU 
{
	public function new() { }
	
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
	 * Calculate the absolute value of a number.
	 * @param	Value	Any number.
	 * @return	The absolute value of that number.
	 */
	inline static public function abs(Value:Float):Float
	{
		return (Value > 0) ? Value : -Value;
	}
	
	/**
	 * Round down to the next whole number. E.g. floor(1.7) == 1, and floor(-2.7) == -2.
	 * @param	Value	Any number.
	 * @return	The rounded value of that number.
	 */
	inline static public function floor(Value:Float):Int
	{
		var number:Int = Std.int(Value);
		return (Value > 0) ? (number) : ((number != Value) ? (number - 1) : (number));
	}
	
	/**
	 * Round up to the next whole number.  E.g. ceil(1.3) == 2, and ceil(-2.3) == -3.
	 * @param	Value	Any number.
	 * @return	The rounded value of that number.
	 */
	inline static public function ceil(Value:Float):Int
	{
		var number:Int = Std.int(Value);
		return (Value > 0) ? ((number != Value) ? (number + 1) : (number)) : (number);
	}
	
	/**
	 * Round to the closest whole number. E.g. round(1.7) == 2, and round(-2.3) == -2.
	 * @param	Value	Any number.
	 * @return	The rounded value of that number.
	 */
	inline static public function round(Value:Float):Int
	{
		return Std.int(Value + ((Value > 0) ? 0.5 : -0.5));
	}
	
	/**
	 * Round a decimal number to have reduced precision (less decimal numbers).
	 * Ex: roundDecimal(1.2485, 2) -> 1.25
	 * 
	 * @param	Value		Any number.
	 * @param	Precision	Number of decimal points to leave in float.
	 * @return	The rounded value of that number.
	 */
	inline static public function roundDecimal(Value:Float, Precision:Int):Float
	{
		var num = Value * Math.pow(10, Precision);
		return Math.round( num ) / Math.pow(10, Precision);
	}
	
	/**
	 * Figure out which number is smaller.
	 * @param	Number1		Any number.
	 * @param	Number2		Any number.
	 * @return	The smaller of the two numbers.
	 */
	inline static public function min(Number1:Float, Number2:Float):Float
	{
		return (Number1 <= Number2) ? Number1 : Number2;
	}
	
	/**
	 * Figure out which number is larger.
	 * @param	Number1		Any number.
	 * @param	Number2		Any number.
	 * @return	The larger of the two numbers.
	 */
	inline static public function max(Number1:Float, Number2:Float):Float
	{
		return (Number1 >= Number2) ? Number1 : Number2;
	}
	
	/**
	 * Bound a number by a minimum and maximum.
	 * Ensures that this number is no smaller than the minimum,
	 * and no larger than the maximum.
	 * @param	Value	Any number.
	 * @param	Min		Any number.
	 * @param	Max		Any number.
	 * @return	The bounded value of the number.
	 */
	inline static public function bound(Value:Float, Min:Float, Max:Float):Float
	{
		var lowerBound:Float = (Value < Min) ? Min : Value;
		return (lowerBound > Max) ? Max : lowerBound;
	}
	
	/**
	 * Generates a random number based on the seed provided.
	 * @param	Seed	A number between 0 and 1, used to generate a predictable random number (very optional).
	 * @return	A <code>Number</code> between 0 and 1.
	 */
	inline static public function srand(Seed:Float):Float
	{
		#if !neko
		return ((69621 * Std.int(Seed * 0x7FFFFFFF)) % 0x7FFFFFFF) / 0x7FFFFFFF;
		#else
		return Math.random();
		#end
	}
	
	/**
	 * Shuffles the entries in an array into a new random order.
	 * <code>FlxG.shuffle()</code> is deterministic and safe for use with replays/recordings.
	 * HOWEVER, <code>FlxU.shuffle()</code> is NOT deterministic and unsafe for use with replays/recordings.
	 * @param	A				A Flash <code>Array</code> object containing...stuff.
	 * @param	HowManyTimes	How many swaps to perform during the shuffle operation.  Good rule of thumb is 2-4 times as many objects are in the list.
	 * @return	The same Flash <code>Array</code> object that you passed in in the first place.
	 */
	inline static public function shuffle(Objects:Array<Dynamic>, HowManyTimes:Int):Array<Dynamic>
	{
		var i:Int = 0;
		var index1:Int;
		var index2:Int;
		var object:Dynamic;
		while(i < HowManyTimes)
		{
			index1 = Std.int(Math.random() * Objects.length);
			index2 = Std.int(Math.random() * Objects.length);
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
	 * <code>FlxG.getRandom()</code> is deterministic and safe for use with replays/recordings.
	 * HOWEVER, <code>FlxU.getRandom()</code> is NOT deterministic and unsafe for use with replays/recordings.
	 * @param	Objects		A Flash array of objects.
	 * @param	StartIndex	Optional offset off the front of the array. Default value is 0, or the beginning of the array.
	 * @param	Length		Optional restriction on the number of values you want to randomly select from.
	 * @return	The random object that was selected.
	 */
	inline static public function getRandom(Objects:Array<Dynamic>, StartIndex:Int = 0, Length:Int = 0):Dynamic
	{
		var res:Dynamic = null;
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
				res = Objects[StartIndex + Std.int(Math.random() * l)];
			}
		}
		return res;
	}
	
	/**
	 * Just grabs the current "ticks" or time in milliseconds that has passed since Flash Player started up.
	 * Useful for finding out how long it takes to execute specific blocks of code.
	 * @return	A <code>uint</code> to be passed to <code>FlxU.endProfile()</code>.
	 */
	inline static public function getTicks():Int
	{
		return FlxGame._mark;
	}
	
	/**
	 * Takes two "ticks" timestamps and formats them into the number of seconds that passed as a String.
	 * Useful for logging, debugging, the watch window, or whatever else.
	 * @param	StartTicks	The first timestamp from the system.
	 * @param	EndTicks	The second timestamp from the system.
	 * @return	A <code>String</code> containing the formatted time elapsed information.
	 */
	inline static public function formatTicks(StartTicks:Int, EndTicks:Int):String
	{
		return (Math.abs(EndTicks - StartTicks) / 1000) + "s";
	}
	
	/**
	 * Generate a Flash <code>uint</code> color from RGBA components.
	 * 
	 * @param   Red     The red component, between 0 and 255.
	 * @param   Green   The green component, between 0 and 255.
	 * @param   Blue    The blue component, between 0 and 255.
	 * @param   Alpha   How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * 
	 * @return  The color as a <code>uint</code>.
	 */
	#if flash
	inline static public function makeColor(Red:UInt, Green:UInt, Blue:UInt, Alpha:Float = 1.0):UInt
	#else
	inline static public function makeColor(Red:Int, Green:Int, Blue:Int, Alpha:Float = 1.0):BitmapInt32
	#end
	{
		#if !neko
		return (Std.int((Alpha > 1) ? Alpha : (Alpha * 255)) & 0xFF) << 24 | (Red & 0xFF) << 16 | (Green & 0xFF) << 8 | (Blue & 0xFF);
		#else
		return {rgb: (Red & 0xFF) << 16 | (Green & 0xFF) << 8 | (Blue & 0xFF), a: Std.int((Alpha > 1) ? Alpha : (Alpha * 255)) & 0xFF << 24 };
		#end
	}
	
	/**
	 * Generate a Flash <code>uint</code> color from HSB components.
	 * 
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param   Alpha   	How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a <code>uint</code>.
	 */
	#if flash
	inline static public function makeColorFromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1.0):UInt
	#else
	inline static public function makeColorFromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1.0):BitmapInt32
	#end
	{
		var red:Float;
		var green:Float;
		var blue:Float;
		if(Saturation == 0.0)
		{
			red   = Brightness;
			green = Brightness;        
			blue  = Brightness;
		}       
		else
		{
			if (Hue == 360)
			{
				Hue = 0;
			}
			var slice:Int = Std.int(Hue / 60);
			var hf:Float = Hue / 60 - slice;
			var aa:Float = Brightness*(1 - Saturation);
			var bb:Float = Brightness * (1 - Saturation * hf);
			var cc:Float = Brightness * (1 - Saturation * (1.0 - hf));
			switch (slice)
			{
				case 0: 
					red = Brightness; 
					green = cc;   
					blue = aa;  
				case 1: 
					red = bb;  
					green = Brightness;  
					blue = aa;
				case 2: 
					red = aa;  
					green = Brightness;  
					blue = cc;
				case 3: 
					red = aa;  
					green = bb;   
					blue = Brightness;
				case 4: 
					red = cc;  
					green = aa;   
					blue = Brightness;
				case 5: 
					red = Brightness; 
					green = aa;   
					blue = bb;
				default: 
					red = 0;  
					green = 0;    
					blue = 0;
			}
		}
		#if !neko
		return (Std.int((Alpha > 1) ? Alpha :( Alpha * 255)) & 0xFF) << 24 | Std.int(red * 255) << 16 | Std.int(green * 255) << 8 | Std.int(blue * 255);
		#else
		return { rgb: Std.int(red * 255) << 16 | Std.int(green * 255) << 8 | Std.int(blue * 255), a: (Std.int((Alpha > 1) ? Alpha :( Alpha * 255)) & 0xFF) << 24 };
		#end
	}
	
	/**
	 * Loads an array with the RGBA values of a Flash <code>uint</code> color.
	 * RGB values are stored 0-255.  Alpha is stored as a floating point number between 0 and 1.
	 * @param	Color	The color you want to break into components.
	 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
	 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
	 */
	#if flash
	inline static public function getRGBA(Color:UInt, Results:Array<Float> = null):Array<Float>
	#else
	inline static public function getRGBA(Color:BitmapInt32, Results:Array<Float> = null):Array<Float>
	#end
	{
		if (Results == null)
		{
			Results = new Array<Float>();
		}
		#if !neko
		Results[0] = (Color >> 16) & 0xFF;
		Results[1] = (Color >> 8) & 0xFF;
		Results[2] = Color & 0xFF;
		Results[3] = ((Color >> 24) & 0xFF) / 255;
		#else
		Results[0] = (Color.rgb >> 16) & 0xFF;
		Results[1] = (Color.rgb >> 8) & 0xFF;
		Results[2] = Color.rgb & 0xFF;
		Results[3] = Color.a / 255;
		#end
		return Results;
	}
	
	/**
	 * Loads an array with the HSB values of a Flash <code>uint</code> color.
	 * Hue is a value between 0 and 360.  Saturation, Brightness and Alpha
	 * are as floating point numbers between 0 and 1.
	 * @param	Color	The color you want to break into components.
	 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
	 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
	 */
	#if flash
	inline static public function getHSB(Color:UInt, Results:Array<Float> = null):Array<Float>
	#else
	inline static public function getHSB(Color:Int, Results:Array<Float> = null):Array<Float>
	#end
	{
		if (Results == null)
		{
			Results = new Array<Float>();
		}
		
		var red:Float = ((Color >> 16) & 0xFF) / 255;
		var green:Float = ((Color >> 8) & 0xFF) / 255;
		var blue:Float = ((Color) & 0xFF) / 255;
		
		var m:Float = (red > green) ? red : green;
		var dmax:Float = (m > blue) ? m : blue;
		m = (red > green) ? green : red;
		var dmin:Float = (m > blue) ? blue : m;
		var range:Float = dmax - dmin;
		
		Results[2] = dmax;
		Results[1] = 0;
		Results[0] = 0;
		
		if (dmax != 0)
		{
			Results[1] = range / dmax;
		}
		if(Results[1] != 0) 
		{
			if (red == dmax)
			{
				Results[0] = (green - blue) / range;
			}
			else if (green == dmax)
			{
				Results[0] = 2 + (blue - red) / range;
			}
			else if (blue == dmax)
			{
				Results[0] = 4 + (red - green) / range;
			}
			Results[0] *= 60;
			if (Results[0] < 0)
			{
				Results[0] += 360;
			}
		}
		
		Results[3] = ((Color >> 24) & 0xFF) / 255;
		return Results;
	}
	
	/**
	 * Format seconds as minutes with a colon, an optionally with milliseconds too.
	 * @param	Seconds		The number of seconds (for example, time remaining, time spent, etc).
	 * @param	ShowMS		Whether to show milliseconds after a "." as well.  Default value is false.
	 * @return	A nicely formatted <code>String</code>, like "1:03".
	 */
	inline static public function formatTime(Seconds:Int, ShowMS:Bool = false):String
	{
		var timeString:String = Std.int(Seconds / 60) + ":";
		var timeStringHelper:Int = Std.int(Seconds) % 60;
		if (timeStringHelper < 10)
		{
			timeString += "0";
		}
		timeString += timeStringHelper;
		if(ShowMS)
		{
			timeString += ".";
			timeStringHelper = (Seconds - Std.int(Seconds)) * 100;
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
	 * @param	AnyArray	Any <code>Array</code> object.
	 * @return	A comma-separated <code>String</code> containing the <code>.toString()</code> output of each element in the array.
	 */
	inline static public function formatArray(AnyArray:Array<Dynamic>):String
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
	 * Automatically commas and decimals in the right places for displaying money amounts.
	 * Does not include a dollar sign or anything, so doesn't really do much
	 * if you call say <code>var results:String = FlxU.formatMoney(10,false);</code>
	 * However, very handy for displaying large sums or decimal money values.
	 * @param	Amount			How much moneys (in dollars, or the equivalent "main" currency - i.e. not cents).
	 * @param	ShowDecimal		Whether to show the decimals/cents component. Default value is true.
	 * @param	EnglishStyle	Major quantities (thousands, millions, etc) separated by commas, and decimal by a period.  Default value is true.
	 * @return	A nicely formatted <code>String</code>.  Does not include a dollar sign or anything!
	 */
	inline static public function formatMoney(Amount:Float, ShowDecimal:Bool = true, EnglishStyle:Bool = true):String
	{
		var helper:Int;
		var amount:Int = Math.floor(Amount);
		var string:String = "";
		var comma:String = "";
		var zeroes:String = "";
		while(amount > 0)
		{
			if((string.length > 0) && comma.length <= 0)
			{
				if (EnglishStyle)
				{
					comma = ",";
				}
				else
				{
					comma = ".";
				}
			}
			zeroes = "";
			helper = amount - Math.floor(amount / 1000) * 1000;
			amount = Math.floor(amount / 1000);
			if(amount > 0)
			{
				if (helper < 100)
				{
					zeroes += "0";
				}
				if (helper < 10)
				{
					zeroes += "0";
				}
			}
			string = zeroes + helper + comma + string;
		}
		if(ShowDecimal)
		{
			amount = Std.int(Amount * 100) - (Std.int(Amount) * 100);
			string += (EnglishStyle ? "." : ",") + amount;
			if (amount < 10)
			{
				string += "0";
			}
		}
		return string;
	}
	
	/**
	 * Get the <code>String</code> name of any <code>Object</code>.
	 * @param	Obj		The <code>Object</code> object in question.
	 * @param	Simple	Returns only the class name, not the package or packages.
	 * @return	The name of the <code>Class</code> as a <code>String</code> object.
	 */
	@:extern inline static public function getClassName(Obj:Dynamic, Simple:Bool = false):String
	{
		var s:String = Type.getClassName(Type.getClass(Obj));
		if (s != null)
		{
			s = StringTools.replace(s, "::", ".");
			if (Simple)
			{
				s = s.substr(s.lastIndexOf(".") + 1);
			}
		}
		return s;
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
	 * Look up a <code>Class</code> object by its string name.
	 * @param	Name	The <code>String</code> name of the <code>Class</code> you are interested in.
	 * @return	A <code>Class</code> object.
	 */
	@:extern inline public static function getClass(Name:String):Class<Dynamic>
	{
		return Type.resolveClass(Name);
	}
	
	/**
	 * A tween-like function that takes a starting velocity
	 * and some other factors and returns an altered velocity.
	 * @param	Velocity		Any component of velocity (e.g. 20).
	 * @param	Acceleration	Rate at which the velocity is changing.
	 * @param	Drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
	 * @param	Max				An absolute value cap for the velocity (0 for no cap).
	 * @return	The altered Velocity value.
	 */
	inline static public function computeVelocity(Velocity:Float, Acceleration:Float, Drag:Float, Max:Float):Float
	{
		if (Acceleration != 0)
		{
			Velocity += Acceleration * FlxG.elapsed;
		}
		else if(Drag != 0)
		{
			var drag:Float = Drag * FlxG.elapsed;
			if (Velocity - drag > 0)
			{
				Velocity = Velocity - drag;
			}
			else if (Velocity + drag < 0)
			{
				Velocity += drag;
			}
			else
			{
				Velocity = 0;
			}
		}
		if((Velocity != 0) && (Max != 0))
		{
			if (Velocity > Max)
			{
				Velocity = Max;
			}
			else if (Velocity < -Max)
			{
				Velocity = -Max;
			}
		}
		return Velocity;
	}
	
	//*** NOTE: THESE LAST THREE FUNCTIONS REQUIRE FLXPOINT ***//
		
	/**
	 * Rotates a point in 2D space around another point by the given angle.
	 * @param	X		The X coordinate of the point you want to rotate.
	 * @param	Y		The Y coordinate of the point you want to rotate.
	 * @param	PivotX	The X coordinate of the point you want to rotate around.
	 * @param	PivotY	The Y coordinate of the point you want to rotate around.
	 * @param	Angle	Rotate the point by this many degrees.
	 * @param	Point	Optional <code>FlxPoint</code> to store the results in.
	 * @return	A <code>FlxPoint</code> containing the coordinates of the rotated point.
	 */
	inline static public function rotatePoint(X:Float, Y:Float, PivotX:Float, PivotY:Float, Angle:Float, point:FlxPoint = null):FlxPoint
	{
		var sin:Float = 0;
		var cos:Float = 0;
		var radians:Float = Angle * -0.017453293;
		while (radians < -3.14159265)
		{
			radians += 6.28318531;
		}
		while (radians >  3.14159265)
		{
			radians = radians - 6.28318531;
		}
		
		if (radians < 0)
		{
			sin = 1.27323954 * radians + .405284735 * radians * radians;
			if (sin < 0)
			{
				sin = .225 * (sin *-sin - sin) + sin;
			}
			else
			{
				sin = .225 * (sin * sin - sin) + sin;
			}
		}
		else
		{
			sin = 1.27323954 * radians - 0.405284735 * radians * radians;
			if (sin < 0)
			{
				sin = .225 * (sin *-sin - sin) + sin;
			}
			else
			{
				sin = .225 * (sin * sin - sin) + sin;
			}
		}
		
		radians += 1.57079632;
		if (radians >  3.14159265)
		{
			radians = radians - 6.28318531;
		}
		if (radians < 0)
		{
			cos = 1.27323954 * radians + 0.405284735 * radians * radians;
			if (cos < 0)
			{
				cos = .225 * (cos *-cos - cos) + cos;
			}
			else
			{
				cos = .225 * (cos * cos - cos) + cos;
			}
		}
		else
		{
			cos = 1.27323954 * radians - 0.405284735 * radians * radians;
			if (cos < 0)
			{
				cos = .225 * (cos *-cos - cos) + cos;
			}
			else
			{
				cos = .225 * (cos * cos - cos) + cos;
			}
		}
		
		var dx:Float = X - PivotX;
		// TODO: Uncomment this line if there will be problems
		//var dy:Float = PivotY + Y; //Y axis is inverted in flash, normally this would be a subtract operation
		var dy:Float = Y - PivotY;
		if (point == null)
		{
			point = new FlxPoint();
		}
		point.x = PivotX + cos * dx - sin * dy;
		point.y = PivotY - sin * dx - cos * dy;
		return point;
	}
	
	/**
	 * Calculates the angle between two points.  0 degrees points straight up.
	 * @param	Point1		The X coordinate of the point.
	 * @param	Point2		The Y coordinate of the point.
	 * @return	The angle in degrees, between -180 and 180.
	 */
	inline static public function getAngle(Point1:FlxPoint, Point2:FlxPoint):Float
	{
		var x:Float = Point2.x - Point1.x;
		var y:Float = Point2.y - Point1.y;
		var angle:Float = 0;
		if ((x != 0) || (y != 0))
		{
			var c1:Float = 3.14159265 * 0.25;
			var c2:Float = 3 * c1;
			var ay:Float = (y < 0) ? -y : y;
			if (x >= 0)
			{
				angle = c1 - c1 * ((x - ay) / (x + ay));
			}
			else
			{
				angle = c2 - c1 * ((x + ay) / (ay - x));
			}
			angle = ((y < 0)? -angle:angle) * 57.2957796;
			if (angle > 90)
			{
				angle = angle - 270;
			}
			else
			{
				angle += 90;
			}
		}
		
		return angle;
	}
	
	/**
	 * Calculate the distance between two points.
	 * @param Point1	A <code>FlxPoint</code> object referring to the first location.
	 * @param Point2	A <code>FlxPoint</code> object referring to the second location.
	 * @return	The distance between the two points as a floating point <code>Number</code> object.
	 */
	inline static public function getDistance(Point1:FlxPoint, Point2:FlxPoint):Float
	{
		var dx:Float = Point1.x - Point2.x;
		var dy:Float = Point1.y - Point2.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	inline static public function ArrayIndexOf(array:Array<Dynamic>, whatToFind:Dynamic, fromIndex:Int = 0):Int
	{
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
	}
	
	static public function SetArrayLength(array:Array<Dynamic>, newLength:Int):Void
	{
		if (newLength < 0) return;
		var oldLength:Int = array.length;
		var diff:Int = newLength - oldLength;
		if (diff > 0)
		{
			/*for (i in 0...diff)
			{
				array.push(null);
			}*/
		}
		else if (diff < 0)
		{
			diff = -diff;
			for (i in 0...diff)
			{
				array.pop();
			}
		}
		
	}
	
	#if (flash || js)
	inline public static var MIN_VALUE:Float = 0.0000000000000001;
	#else
	inline public static var MIN_VALUE:Float = 5e-324;
	#end
	inline public static var MAX_VALUE:Float = 1.79e+308;
	
}