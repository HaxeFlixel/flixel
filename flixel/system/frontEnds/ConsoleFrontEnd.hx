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
	 * @param   alias  The name with which you want to access the function.
	 * @param   func   The function to register.
	 */
	public inline function registerFunction(alias:String, func:Dynamic):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerFunction(alias, func);
		#end
	}

	/**
	 * Register a new object to use in any command.
	 *
	 * @param  alias   The name with which you want to access the object.
	 * @param  object  The object to register.
	 */
	public inline function registerObject(alias:String, object:Dynamic):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerObject(alias, object);
		#end
	}

	/**
	 * Register a new class to use in any command.
	 *
	 * @param   c  The class to register.
	 */
	public inline function registerClass(c:Class<Dynamic>):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerClass(c);
		#end
	}

	/**
	 * Register a new enum to use in any command.
	 *
	 * @param   e  The enum to register.
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
