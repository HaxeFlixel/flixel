package flixel.system.debug.console;

using StringTools;

#if hscript
import hscript.Expr;
import hscript.Parser;

using flixel.util.FlxArrayUtil;
#end

/**
 * The default debug console manager used by `FlxG.console` and the Console debug window
 * 
 * @since 6.2.0
 */
class LegacyConsoleHandler implements IFlxConsoleHandler
{
	#if hscript
	var parser:Parser;

	/**
	 * The custom hscript interpreter to run the haxe code from the parser.
	 */
	public var interp:Interp;

	/**
	 * Sets up the hscript parser and interpreter.
	 */
	public function new() {}
	
	public function init()
	{
		parser = new Parser();
		parser.allowJSON = true;
		parser.allowTypes = true;

		interp = new Interp();
	}
	
	/**
	 * Converts a string into a runnable command
	 * 
	 * @param   input  A string of code
	 * @return  An exectutable expression
	 */
	public function parse(input:String):Expr
	{
		if (StringTools.endsWith(input, ";"))
			input = input.substr(0, -1);
		return parser.parseString(input);
	}
	
	/**
	 * Converts a string into a runnable command and executes it
	 * 
	 * @param   input  A string of code
	 * @return  The result of running the command
	 */
	public function evaluate(input:String):Any
	{
		return evaluateExpr(parse(input));
	}

	/**
	 * Runs the input expression.
	 * @param   expr  The expression to run
	 * @return  Whatever the input code evaluates to.
	 */
	public function evaluateExpr(expr:Expr):Dynamic
	{
		return interp.expr(expr);
	}
	
	/**
	 * Registers the field to be used in commands
	 * 
	 * @param   alias  The name used to access the field
	 * @param   value  The value of the field
	 */
	public function register(alias:String, object:Dynamic):Void
	{
		interp.variables.set(alias, object);
	}
	
	/**
	 * Removes the registered field by its alias
	 * 
	 * @param   alias  The name used to access the field
	 */
	public function remove(alias:String):Void
	{
		interp.variables.remove(alias);
	}
	#end
	
	/**
	 * Creates a list of all fields of the given object
	 */
	public function getFields(Object:Dynamic):Array<String>
	{
		var fields = [];
		if ((Object is Class)) // passed a class -> get static fields
			fields = Type.getClassFields(Object);
		else if ((Object is Enum))
			fields = Type.getEnumConstructs(Object);
		else if (Reflect.isObject(Object)) // get instance fields
		{
			try
			{
				fields = Type.getInstanceFields(Type.getClass(Object));
			}
			catch(e)
			{
				fields = [for (field in Reflect.fields(Object)) field];
			}
		}
		
		// on Flash, enums are classes, so Std.isOfType(_, Enum) fails
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
	
	/**
	 * Creates a list of all fields available at the top-level
	 */
	public function getGlobals():Array<String>
	{
		return sortAlphabetically(interp.getGlobals());
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
		
		sortAlphabetically(fields);
		sortAlphabetically(underscoreList);
		
		return fields.concat(underscoreList);
	}
	
	static function sortAlphabetically(list:Array<String>):Array<String>
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
}

/** 
 * A set of helper functions used by the console
 */
@:deprecated("ConsoleUtil is deprecated, use FlxG.console, instead")
class ConsoleUtil
{
	#if hscript
	static var handler:LegacyConsoleHandler;
	
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
		handler = new LegacyConsoleHandler();
		handler.init();
		@:privateAccess
		parser = handler.parser;
		interp = handler.interp;
	}
	
	/**
	 * Converts the input string into its AST form to be executed.
	 *
	 * @param   input  The user's input command.
	 * @return  The parsed out AST.
	 */
	public static function parse(input:String):Expr
	{
		return handler.parse(input);
	}
	
	/**
	 * Parses and runs the input command.
	 *
	 * @param   input  The user's input command.
	 * @return  Whatever the input code evaluates to.
	 */
	public static function evaluate(input:String):Dynamic
	{
		return handler.evaluate(input);
	}
	
	/**
	 * Runs the input expression.
	 * @param   expr  The expression to run
	 * @return  Whatever the input code evaluates to.
	 */
	public static function evaluateExpr(expr:Expr):Dynamic
	{
		return handler.evaluateExpr(expr);
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
			handler.register(alias, object);
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
			handler.register(alias, func);
	}
	
	/**
	 * Removes an alias from the command registry.
	 *
	 * @param   alias  The alias to remove.
	 * @since 5.4.0
	 */
	public static function removeByAlias(alias:String):Void
	{
		handler.remove(alias);
	}
	#end
	
	public static function getFields(object:Dynamic):Array<String>
	{
		return handler.getFields(object);
	}
	
	/**
	 * Shortcut to log a text with the Console LogStyle.
	 *
	 * @param   text  The text to log.
	 */
	@:deprecated("ConsoleUtil.log no longer logs and will be removed")
	public static inline function log(text:Dynamic):Void {}
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
