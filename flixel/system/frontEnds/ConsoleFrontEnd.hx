package flixel.system.frontEnds;

import flixel.FlxG;

class ConsoleFrontEnd
{
	/**
	 * Whether the console should auto-pause or not when it's focused. Only works for flash atm.
	 */
	public var autoPause:Bool = true;
	
	/**
	 * Register a new function to use in any command.
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
	 * Register a new object to use in any command.
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
	 * Register a new class to use in any command.
	 * 
	 * @param 	cl			The class to register.
	 */
	public inline function registerClass(cl:Class<Dynamic>):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.console.registerClass(cl);
		#end
	}
	
	/**
	 * Just needed to create an instance.
	 */
	@:allow(flixel.FlxG)
	private function new() {}
}