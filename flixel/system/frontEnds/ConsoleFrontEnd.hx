package flixel.system.frontEnds;

import flixel.FlxG;

/**
 * Accessed via `FlxG.console`.
 */
class ConsoleFrontEnd
{
	/**
	 * Whether the console should auto-pause or not when it's focused.
	 */
	public var autoPause:Bool = true;

	/**
	 * Whether the console should `step()` the game after a command is entered.
	 * Setting this to `false` allows inputting multiple console commands within the same frame.
	 * Use the `step()` command to step the game from the console.
	 * @since 4.2.0
	 */
	public var stepAfterCommand:Bool = true;

	/**
	 * Register a new function to use in any command.
	 *
	 * @param 	FunctionAlias		The name with which you want to access the function.
	 * @param 	Function			The function to register.
	 */
	public inline function registerFunction(FunctionAlias:String, Function:Dynamic):Void
	{
		#if FLX_DEBUG
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
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerObject(ObjectAlias, AnyObject);
		#end
	}

	/**
	 * Register a new class to use in any command.
	 *
	 * @param	cl	The class to register.
	 */
	public inline function registerClass(cl:Class<Dynamic>):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerClass(cl);
		#end
	}

	/**
	 * Register a new enum to use in any command.
	 *
	 * @param	e	The enum to register.
	 * @since 4.4.0
	 */
	public inline function registerEnum(e:Enum<Dynamic>):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerEnum(e);
		#end
	}

	@:allow(flixel.FlxG)
	function new() {}
}
