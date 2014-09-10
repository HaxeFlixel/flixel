package flixel.system.debug;

import flash.errors.ArgumentError;
import flixel.FlxG;
import flixel.system.debug.Console.Command;
import flixel.system.debug.ConsoleUtil.PathToVariable;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxStringUtil;
using StringTools;

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
			if (Commands[i].aliases.indexOf(Alias) != -1) 
			{
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
	@:generic
	public static function attemptToCreateInstance<T>(ClassName:String, type:Class<T>, ?Params:Array<String>):Dynamic
	{
		if (ClassName == null)
			return null;
		
		if (Params == null)
			Params = [];
		
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
	 * Attempts to find the object which contains the variable to set  from the String 
	 * path, like "FlxG.state.sprite.x" so it can be accessed via Reflection.
	 * 
	 * @param	ObjectAndVariable	The path to the variable as a String, for example array.length
	 * @param	Object	Starting point for the search, has to contain the first object / variable of the first param
	 * @return	A PathToVarible typedef, or null.
	 */
	public static function resolveObjectAndVariable(ObjectAndVariable:String, Object:Dynamic):PathToVariable
	{
		var searchArr:Array<String> = ObjectAndVariable.split(".");
		
		if (searchArr.length == 1)
		{
			return { object: Object, variableName: ObjectAndVariable };
		}
		
		var variableName:String = searchArr.join(".");
		
		if (!Reflect.isObject(Object)) 
		{
			FlxG.log.error("'" + FlxStringUtil.getClassName(Object, true) + "' is not a valid Object");
			return null;
		}

		// Searching for property...
		var l:Int = searchArr.length;
		var tempObj:Dynamic = Object;
		var tempVarName:String = "";
		for (i in 0...l)
		{
			tempVarName = searchArr[i];			

			
			if (i < (l - 1))
			{
				tempObj = resolveProperty(tempObj, tempVarName);

				if (tempObj == null)
					return null;
			}
		}
		
		return { object: tempObj, variableName: tempVarName };
	}

	/**
	 * Resolve properties taking array indices into account.
	 * @param	obj Any object containing the property
	 * @param	propName Name of the property you want to resolve
	 * @return The property value, or null.
	 */
	public static function resolveProperty(obj:Dynamic, propName:String):Dynamic
	{
		//If array, get indice
		var arrayIndices = new Array<Int>();
		var arrayIndicesStr = propName.split("[");
		propName = arrayIndicesStr.shift(); //Remove the leftmost element which the current prop
		for (indice in arrayIndicesStr)
		{
			//Verify format
			if (indice.charAt(indice.length - 1) != "]")
			{
				FlxG.log.error("'" + FlxStringUtil.getClassName(obj, true) + "' does not have a field '" + propName + "'");
				return null;
			}
			//Extract indice
			var index = Std.parseInt(indice.substr(0, indice.length - 1));
			if (index == null)
			{
				FlxG.log.error("'" + FlxStringUtil.getClassName(obj, true) + "' does not have a field '" + propName + "'");
				return null;
			}
			arrayIndices.push(index);
		}

		try 
		{
			obj = Reflect.getProperty(obj, propName);
			//Loop through array indice, if any
			for (index in arrayIndices)
			{
				if (!Std.is(obj, Array) || obj.length <= index)
				{
					FlxG.log.error("'" + FlxStringUtil.getClassName(obj, true) + "' does not have index '" + index + "' or is not an Array");
				}
				obj = obj[index];
			}
		}
		catch (e:Dynamic) 
		{
			FlxG.log.error("'" + FlxStringUtil.getClassName(obj, true) + "' does not have a field '" + propName + "'");
			return null;
		}
		return obj;
	}
	
	/**
	 * Helper function for the set command. Attempts to find the object which contains the variable to set
	 * from the String path, like "FlxG.state.sprite.x" so it can be set via Reflection.
	 * 
	 * @param	ObjectAndVariable	The path to the variable as a String, for example array.length
	 * @param	ObjectMap			A Map of registered objects to start the search from
	 * @return	A PathToVarible typedef, or null.
	 */
	public static inline function resolveObjectAndVariableFromMap(ObjectAndVariable:String, ObjectMap:Map<String, Dynamic>):PathToVariable
	{
		var splitString:Array<String> = ObjectAndVariable.split(".");
		var object:Dynamic = ObjectMap.get(splitString[0]);
		splitString.shift();
		ObjectAndVariable = splitString.join(".");
		return resolveObjectAndVariable(ObjectAndVariable, object);
	}
	
	/**
	 * Type.getInstanceFields() returns all fields, including all those from super classes. This function allows
	 * controlling the number of super classes whose fields should still be included in the list using Type.getSuperClass().
	 * 
	 * Example:
	 * 	For a class PlayState with the following inheritance:
	 * 	FlxBasic -> FlxTypedGroup -> FlxGroup -> FlxState -> PlayState 
	 * 		numSuperClassesToInclude == 0 would only return the fields of PlayState itself	
	 * 		numSuperClassesToInclude == 1 would only return the fields of PlayState and FlxState etc...
	 */
	public static function getInstanceFieldsAdvanced(cl:Class<Dynamic>, numSuperClassesToInclude:Int = 0):Array<String>
	{
		var fields:Array<String> = Type.getInstanceFields(cl);
		if (numSuperClassesToInclude >= 0)
		{
			var curClass = Type.getSuperClass(cl);
			var superClasses:Array<Class<Dynamic>> = [];
			while (curClass != null) // no more super classes if null
			{
				superClasses.push(curClass);
				curClass = Type.getSuperClass(curClass);
			}
			
			superClasses.reverse();
			
			if (numSuperClassesToInclude > superClasses.length)
				numSuperClassesToInclude = superClasses.length;
				
			for (i in 0...(superClasses.length - numSuperClassesToInclude))
			{
				var superFields:Array<String> = Type.getInstanceFields(superClasses[i]);
				for (superField in superFields)
				{
					if (fields.indexOf(superField) != -1)
						fields.remove(superField);
				}
			}
		}
		
		return fields;
	}
	
	public static function getTypeName(v:Dynamic):String
	{
		var type = Type.typeof(v);
		
		return switch (type)
		{
			case TClass(c):
				FlxStringUtil.getClassName(c, true);
			case TEnum(e):
				var name = Type.getEnumName(e);
				name.substr(name.lastIndexOf(".") + 1);
			case _:
				Std.string(type).substr(1);
		}
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
			return true;
		else if (s == "false") 
			return false;
		else
			return null;
	}
	
	/**
	 * Attempts to parse a String into a Array<Dynamic>,
	 * returns an array if succeed, null otherwise.
	 * 
	 * @param	s	The String to parse
	 * @return	The parsed Array<Dynamic>
	 */
	public static function parseArray(s:String):Array<Dynamic>
	{
		var returnArray = new Array<Dynamic>();
		//Verify if enclosed with brackets
		if (s.charAt(0) == "[" && s.charAt(s.length - 1) == "]")
		{
			//Manual substr because of nested arrays
			var values = new Array<String>();
			s = s.substr(1, s.length - 2); //Remove brackets
			var value = "";
			var skipComma = false;
			for (i in 0...s.length)
			{
				var c = s.charAt(i);
				if (c == "," && !skipComma)
				{
					values.push(value);
					value = "";
				}
				else
					value += c;
				if (c == "[")
					skipComma = true;
				else if (c == "]")
					skipComma = false;
			}
			values.push(value);
			//Parse values
			for (value in values)
			{
				var parsedValue:Null<Dynamic> = null;
				value = value.trim();
				if (parseBool(value) != null)
					parsedValue = parseBool(value);
				else if (!Math.isNaN(Std.parseFloat(value)))
					parsedValue = Std.parseFloat(value);
				else
				{
					//try to parse a string
					var start = value.indexOf("\"");
					var end = value.lastIndexOf("\"");
					if (start != end && start != -1)
						parsedValue = value.substr(start + 1, end);

					//Try to parse another array
					if (parsedValue == null)
						parsedValue = parseArray(value);
				}

				if (parsedValue != null)
					returnArray.push(parsedValue);
				else
					return null;
			}
			return returnArray;
		}
		return null;
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