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
	 * @param   alias   The name with which you want to access the object.
	 * @param   object  The object to register.
	 */
	public inline function registerObject(alias:String, object:Dynamic):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerObject(alias, object);
		#end
	}

	/**
	 * Removes an object from the command registry.
	 *
	 * Note: `removeByAlias` is more performant, as this method searches the list for the object.
	 *
	 * @param   object  The object to remove.
	 * @since 5.4.0
	 */
	public inline function removeObject(object:Dynamic)
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.removeObject(object);
		#end
	}

	/**
	 * Removes a function from the command registry.
	 *
	 * Note: `removeByAlias` is more performant, as this method searches the list for the function.
	 *
	 * @param   func  The object to remove.
	 * @since 5.4.0
	 */
	public inline function removeFunction(func:Dynamic)
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.removeFunction(func);
		#end
	}
	
	/**
	 * Removes an alias from the command registry.
	 *
	 * @param   alias  The alias to remove.
	 * @since 5.4.0
	 */
	public inline function removeByAlias(alias:String)
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.removeByAlias(alias);
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
	 * Removes a class from the command registry.
	 *
	 * @param   c  The class to remove.
	 * @since 5.4.0
	 */
	public inline function removeClass(c:Class<Dynamic>):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.removeClass(c);
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

	/**
	 * Removes an enum from the command registry.
	 *
	 * @param   e  The enum to remove.
	 * @since 5.4.0
	 */
	public inline function removeEnum(e:Enum<Dynamic>):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.removeEnum(e);
		#end
	}

	@:allow(flixel.FlxG)
	function new() {}
}
