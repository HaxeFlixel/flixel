package flixel.system.debug.console;

import flixel.FlxG;
import flixel.system.debug.log.LogStyle;

using flixel.util.FlxStringUtil;
using flixel.util.FlxArrayUtil;
using StringTools;

#if hscript
import hscript.Expr;
import hscript.Parser;
#end

/** 
 * A set of helper functions used by the console.
 */
class ConsoleUtil
{
	#if hscript
	/**
	 * The hscript parser to make strings into haxe code.
	 */
	static var parser:Parser;

	/**
	 * The custom hscript interpreter to run the haxe code from the parser.
	 */
	public static var interp:Interp;

	/**
	 * Sets up the hscript parser and interpreter.
	 */
	public static function init():Void
	{
		parser = new Parser();
		parser.allowJSON = true;
		parser.allowTypes = true;

		interp = new Interp();
	}

	/**
	 * Converts the input string into its AST form to be executed.
	 *
	 * @param   input  The user's input command.
	 * @return  The parsed out AST.
	 */
	public static function parseCommand(input:String):Expr
	{
		if (StringTools.endsWith(input, ";"))
			input = input.substr(0, -1);
		return parser.parseString(input);
	}

	/**
	 * Parses and runs the input command.
	 *
	 * @param   input  The user's input command.
	 * @return  Whatever the input code evaluates to.
	 */
	public static function runCommand(input:String):Dynamic
	{
		return interp.expr(parseCommand(input));
	}

	/**
	 * Runs the input expression.
	 * @param   expr  The expression to run
	 * @return  Whatever the input code evaluates to.
	 */
	public static function runExpr(expr:Expr):Dynamic
	{
		return interp.expr(expr);
	}

	/**
	 * Register a new object to use in any command.
	 *
	 * @param   alias   The name with which you want to access the object.
	 * @param   object  The object to register.
	 */
	public static function registerObject(alias:String, object:Dynamic):Void
	{
		if (object == null || Reflect.isObject(object))
			interp.variables.set(alias, object);
	}

	/**
	 * Register a new function to use in any command.
	 *
	 * @param   alias  The name with which you want to access the function.
	 * @param   func   The function to register.
	 */
	public static function registerFunction(alias:String, func:Dynamic):Void
	{
		if (Reflect.isFunction(func))
			interp.variables.set(alias, func);
	}

	/**
	 * Removes an alias from the command registry.
	 *
	 * @param   alias  The alias to remove.
	 * @since 5.4.0
	 */
	public static function removeByAlias(alias:String):Void
	{
		interp.variables.remove(alias);
	}
	#end

	public static function getFields(Object:Dynamic):Array<String>
	{
		var fields = [];
		if ((Object is Class)) // passed a class -> get static fields
			fields = Type.getClassFields(Object);
		else if ((Object is Enum))
			fields = Type.getEnumConstructs(Object);
		else if (Reflect.isObject(Object)) // get instance fields
			fields = Type.getInstanceFields(Type.getClass(Object));

		// on Flash, enums are classes, so Std.is(_, Enum) fails
		fields.remove("__constructs__");

		var filteredFields = [];
		for (field in fields)
		{
			// don't add property getters / setters
			if (field.startsWith("get_") || field.startsWith("set_"))
			{
				var name = field.substr(4);
				// property without a backing field, needs to be added
				if (!fields.contains(name) && !filteredFields.contains(name))
					filteredFields.push(name);
			}
			else
				filteredFields.push(field);
		}

		return sortFields(filteredFields);
	}

	static function sortFields(fields:Array<String>):Array<String>
	{
		var underscoreList = [];

		fields = fields.filter(function(field)
		{
			if (field.startsWith("_"))
			{
				underscoreList.push(field);
				return false;
			}
			return true;
		});

		fields.sortAlphabetically();
		underscoreList.sortAlphabetically();

		return fields.concat(underscoreList);
	}

	/**
	 * Shortcut to log a text with the Console LogStyle.
	 *
	 * @param   text  The text to log.
	 */
	public static inline function log(text:Dynamic):Void
	{
		FlxG.log.advanced([text], LogStyle.CONSOLE);
	}
}

/**
 * hscript doesn't use property access by default... have to make our own.
 */
#if hscript
private class Interp extends hscript.Interp
{
	public function getGlobals():Array<String>
	{
		return toArray(locals.keys()).concat(toArray(variables.keys()));
	}

	function toArray<T>(iterator:Iterator<T>):Array<T>
	{
		var array = [];
		for (element in iterator)
			array.push(element);
		return array;
	}

	override function get(o:Dynamic, f:String):Dynamic
	{
		if (o == null)
			error(EInvalidAccess(f));
		return Reflect.getProperty(o, f);
	}

	override function set(o:Dynamic, f:String, v:Dynamic):Dynamic
	{
		if (o == null)
			error(EInvalidAccess(f));
		Reflect.setProperty(o, f, v);
		return v;
	}
}
#end
