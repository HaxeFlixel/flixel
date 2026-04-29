package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.debug.console.Console;
import flixel.system.debug.console.IFlxConsoleHandler;
import flixel.util.FlxSignal;
import flixel.util.FlxStringUtil;

/**
 * Accessed via `FlxG.console`.
 */
@:access(flixel.system.debug.console.Console)
class ConsoleFrontEnd
{
	@:haxe.warning("-WDeprecated")
	static function getDefaultHandler():IFlxConsoleHandler
	{
		#if (hscript && FLX_DEBUG)
		flixel.system.debug.console.ConsoleUtil.init();
		@:privateAccess
		return flixel.system.debug.console.ConsoleUtil.handler;
		#else
		return new flixel.system.debug.console.EmptyConsoleHandler();
		#end
	}
	
	/**
	 * The manager for the evaluation of expressions and console commands
	 */
	public var handler(default, null) = getDefaultHandler();
	
	/**
	 * Called whenever the handler changes
	 * 
	 * @since 6.2.0
	 */
	public final onHandlerChange = new FlxTypedSignal<(IFlxConsoleHandler)->Void>();
	
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
	
	#if FLX_DEBUG
	/**
	 * The console window in the FlxDebugger
	 */
	public var window(get, never):Console;
	
	inline function get_window()
	{
		return FlxG.game.debugger.console;
	}
	#end
	
	/**
	 * Changes the current handler, useful for overriding the evaluation of expressions used by
	 * various debugging features. Will automatically register any objects registered to
	 * the previous handler
	 * 
	 * @since 6.2.0
	 */
	public function setHandler(handler:IFlxConsoleHandler)
	{
		this.handler = handler;
		#if FLX_DEBUG
		@:privateAccess
		FlxG.game.debugger.console.onHandlerChange();
		#end
		onHandlerChange.dispatch(handler);
	}
	
	/**
	 * Register a new function to use in any command.
	 *
	 * @param   alias     The name with which you want to access the function.
	 * @param   func      The function to register.
	 * @param   helpText  An optional string to trace to the console using the "help" command.
	 */
	public inline function registerFunction(alias:String, func:Dynamic, ?helpText:String):Void
	{
		#if FLX_DEBUG
		if (Reflect.isFunction(func))
			handler.register(alias, func);
		
		window.registerFunctionHelper(alias, func, helpText);
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
		if (object == null || Reflect.isObject(object))
			handler.register(alias, object);
		
		window.registerObjectHelper(alias, object);
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
		final alias = handler.findAlias(object);
		if (alias == null)
			handler.remove(alias);
		
		window.removeObjectHelper(object);
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
		final alias = handler.findAlias(func);
		if (alias == null)
			handler.remove(alias);
		
		window.removeFunctionHelper(func);
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
		handler.remove(alias);
		window.removeByAliasHelper(alias);
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
		registerObject(FlxStringUtil.getClassName(c, true), c);
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
		removeByAlias(FlxStringUtil.getClassName(c, true));
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
		registerObject(FlxStringUtil.getEnumName(e, true), e);
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
		removeByAlias(FlxStringUtil.getEnumName(e, true));
		#end
	}

	@:allow(flixel.FlxG)
	function new() {}
}
