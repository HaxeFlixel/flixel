package flixel.system.debug;

import flash.errors.ArgumentError;
import flixel.FlxG;
import flixel.system.debug.Console.Command;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxStringUtil;

/** 
 * A set of helper functions used by the console.
 */
class ConsoleUtil
{
	/**
	 * Safely calls a function via Reflection with an array of dynamic arguments. Prevents a crash from happening
	 * if there are too many Arguments (the additional ones are removed and the function is called anyway) or too few
	 * 
	 * @param	Function	The reference to the function to call.
	 * @param	Args		An array of arguments.
	 * @return	Whether or not it was possible to safely call the function.
	 */
	public static function callFunction(Function:Dynamic, Args:Array<Dynamic>):Bool
	{
		try
		{
			Reflect.callMethod(null, Function, Args);
			return true;
		}
		catch (e:ArgumentError)
		{
			if (e.errorID == 1063)
			{
				/* Retrieve the number of expected arguments from the error message
				The first 4 digits in the message are the error-type (1063), 5th is 
				the one we are looking for */
				var expected:Int = Std.parseInt(FlxStringUtil.filterDigits(e.message).charAt(4));
				
				// We can deal with too many parameters...
				if (expected < Args.length) 
				{
					// Shorten args accordingly
					var shortenedArgs:Array<Dynamic> = Args.slice(0, expected);
					// Try again
					Reflect.callMethod(null, Function, shortenedArgs);
				}
				// ...but not with too few
				else 
				{
					FlxG.log.error("Invalid number or parameters: " + expected + " expected, " + Args.length + " passed");
					return false;
				}
				
				return true;
			}
			
			return false;
		}
	}
	
	/**
	 * Searches for the Command typedef for a given Alias within a Command Array.
	 * 
	 * @param	Alias		The Alias to search for.
	 * @param	Commands	The array of commands to search through
	 * @return	The Command typdef - null if none was found.
	 */
	public static function findCommand(Alias:String, Commands:Array<Command>):Command
	{
		for (i in 0...Commands.length)
		{
			if (FlxArrayUtil.indexOf(Commands[i].aliases, Alias) != -1) {
				return Commands[i];
			}
		}
		return null;
	}
	
	/**
	 * Helper function for the create and switchState commands. Attempts to create a  instance of a given class name 
	 * using the given params via Type.createInstance(). Also makes sure the created object is of a certain class.
	 * 
	 * @param	ClassName	The Class name 
	 * @param	type		Which class the created instance has to have
	 * @param	Params		An optional array of constructor params
	 * @return	The created instance, or null
	 */
	@:generic public static function attemptToCreateInstance<T>(ClassName:String, type:Class<T>, ?Params:Array<String>):Dynamic
	{
		if (Params == null) {
			Params = [];
		}
		
		var obj:Dynamic = Type.resolveClass(ClassName);
		if (!Reflect.isObject(obj)) 
		{
			FlxG.log.error(ClassName + "' is not a valid class name. Try passing the full class path. Also make sure the class is being compiled.");
			return null;
		}
		
		var instance:Dynamic = Type.createInstance(obj, Params);
		
		if (!Std.is(instance, type)) 
		{
			FlxG.log.error(ClassName + "' is not a " + Type.getClassName(type));
			return null;
		}
		
		return instance;
	}
	
	/**
	 * Helper function for the set command. Attempts to find the object which contains the variable to set
	 * from the String path, like "FlxG.state.sprite.x" so it can be set via Reflection.
	 * 
	 * @param	ObjectAndVariable	The path to the variable as a String
	 * @param	ObjectMap			A Map of registered objects to start the search from
	 * @return	A PathToVarible typedef, or null.
	 */
	public static function resolveObjectAndVariable(ObjectAndVariable:String, ObjectMap:Map<String, Dynamic>):PathToVariable
	{
		var searchArr:Array<String> = ObjectAndVariable.split(".");
		
		// In case there's no dot in the string
		if (searchArr[0].length == ObjectAndVariable.length) 
		{
			FlxG.log.error("'" + ObjectAndVariable + "' does not refer to an object's field");
			return null;
		}
		
		var object:Dynamic = ObjectMap.get(searchArr.shift());
		var variableName:String = searchArr.join(".");
		
		if (!Reflect.isObject(object)) 
		{
			FlxG.log.error("'" + FlxStringUtil.getClassName(object, true) + "' is not a valid Object");
			return null;
		}
		
		// Searching for property...
		var l:Int = searchArr.length;
		var tempObj:Dynamic = object;
		var tempVarName:String = "";
		for (i in 0...l)
		{
			tempVarName = searchArr[i];
			
			try 
			{
				if (i < (l - 1))
				{
					tempObj = Reflect.getProperty(tempObj, tempVarName);
				}
			}
			catch (e:Dynamic) 
			{
				FlxG.log.error("'" + FlxStringUtil.getClassName(tempObj, true) + "' does not have a field '" + tempVarName + "'");
				return null;
			}
		}
		
		return { object:tempObj, variableName:tempVarName };
	}
	
	/**
	 * Attempts to parse a String into a Boolean, returns 
	 * true for "true", false for "false", and null otherwise.
	 * 
	 * @param	s	The String to parse
	 * @return	The parsed Bool
	 */
	public static function parseBool(s:String):Null<Bool>
	{
		if (s == "true") 
		{
			return true;
		}
		else if (s == "false") 
		{
			return false;
		}
		else
		{
			return null;
		}
	}
	
	/**
	 * Shortcut to log a text with the Console LogStyle.
	 * 
	 * @param	Text	The text to log.
	 */
	public static inline function log(Text:Dynamic):Void
	{
		FlxG.log.advanced([Text], LogStyle.CONSOLE);
	}
}

/**
 * Data necessary to set a variable via Reflection. Used by the set command / resolveObjectAndVariable().
 */
typedef PathToVariable = {
	object:Dynamic,
	variableName:String
}