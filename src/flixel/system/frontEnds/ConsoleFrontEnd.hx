package flixel.system.frontEnds;

import flixel.FlxG;

class ConsoleFrontEnd
{
	/**
	 * Just needed to create an instance.
	 */
	public function new() { }
	
	/**
	 * Register a new function to use for the call command.
	 * 
	 * @param 	FunctionAlias		The name with which you want to access the function.
	 * @param 	Function			The function to register.
	 */
	inline public function registerFunction(FunctionAlias:String, Function:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
		if (FlxG._game != null && FlxG._game.debugger.console != null)
		{
			FlxG._game.debugger.console.registerFunction(FunctionAlias, Function);
		}
		#end
	}
	
	/**
	 * Register a new object to use for the set command.
	 * 
	 * @param 	ObjectAlias		The name with which you want to access the object.
	 * @param 	AnyObject		The object to register.
	 */
	inline public function registerObject(ObjectAlias:String, AnyObject:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
		if (FlxG._game != null && FlxG._game.debugger.console != null)
		{
			FlxG._game.debugger.console.registerObject(ObjectAlias, AnyObject);
		}
		#end
	}
	
	/**
	 * Add a custom command to the console on the debugging screen.
	 * 
	 * @param 	Command		The command's name.
	 * @param 	AnyObject 	Object containing the function (<code>this</code> if function is within the class you're calling this from).
	 * @param 	Function	Function to be called with params when the command is entered.
	 * @param 	Alt			Alternative name for the command, useful as a shortcut.
	 */
	inline public function addCommand(Command:String, AnyObject:Dynamic, Function:Dynamic, Alt:String = ""):Void
	{
		#if !FLX_NO_DEBUG
		if (FlxG._game != null && FlxG._game.debugger.console != null)
		{
			FlxG._game.debugger.console.addCommand(Command, AnyObject, Function, Alt);
		}
		#end
	}
}