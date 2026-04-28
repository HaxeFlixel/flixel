package flixel.system.debug.console;

/**
 * Interface for making custom console behavior, used by `FlxG.console` and the Console debug window
 * 
 * @since 6.2.0
 */
interface IFlxConsoleHandler
{
	/**
	 * Converts a string into a runnable command and executes it
	 * 
	 * @param   input  A string of code
	 * @return  The result of running the command
	 */
	function evaluate(input:String):Any;
	
	/**
	 * Registers the field to be used in commands
	 * 
	 * @param   alias  The name used to access the field
	 * @param   value  The value of the field
	 */
	function register(alias:String, value:Any):Void;
	
	/**
	 * Removes the registered field by its alias
	 * 
	 * @param   alias  The name used to access the field
	 */
	function remove(alias:String):Void;
	
	/**
	 * Creates a list of all fields of the given object
	 */
	function getFields(object:Any):Array<String>;
	
	/**
	 * Creates a list of all fields available at the top-level
	 */
	function getGlobals():Array<String>;
}