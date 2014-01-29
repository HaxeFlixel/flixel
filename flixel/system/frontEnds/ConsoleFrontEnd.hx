package flixel.system.frontEnds;

import flixel.FlxG;

class ConsoleFrontEnd
{
	/**
	 * Whether the console should auto-pause or not when it's focused. Only works for flash atm.
	 * @default true
	 */
	public var autoPause:Bool = true;
	
	/**
	 * Register a new function to use for the call command.
	 * 
	 * @param 	FunctionAlias		The name with which you want to access the function.
	 * @param 	Function			The function to register.
	 */
	public inline function registerFunction(FunctionAlias:String, Function:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.console.registerFunction(FunctionAlias, Function);
		#end
	}
	
	/**
	 * Register a new object to use for the set command.
	 * 
	 * @param 	ObjectAlias		The name with which you want to access the object.
	 * @param 	AnyObject		The object to register.
	 */
	public inline function registerObject(ObjectAlias:String, AnyObject:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.console.registerObject(ObjectAlias, AnyObject);
		#end
	}
	
	/**
	 * Add a custom command to the console on the debugging screen.
	 * 
	 * @param 	Aliases			An array of accepted aliases for this command.
	 * @param 	ProcessFunction	Function to be called with params when the command is entered.
	 * @param	Help			The description of this command shown in the help command.
	 * @param	ParamHelp		The description of this command's processFunction's params.
	 * @param 	NumParams		The amount of parameters a function has. Require to prevent crashes on Neko.
	 * @param	ParamCutoff		At which parameter to put all remaining params into an array
	 */
	public inline function addCommand(Aliases:Array<String>, ProcessFunction:Dynamic, ?Help:String, ?ParamHelp:String, NumParams:Int = 0, ParamCutoff:Int = -1):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.console.addCommand(Aliases, ProcessFunction, Help, ParamHelp, NumParams, ParamCutoff);
		#end
	}
	
	/**
	 * Just needed to create an instance.
	 */
	@:allow(flixel.FlxG)
	private function new() { }
}