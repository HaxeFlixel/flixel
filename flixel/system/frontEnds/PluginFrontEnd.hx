package flixel.system.frontEnds;

import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

/**
 * Accessed via `FlxG.plugins`.
 */
class PluginFrontEnd
{
	/**
	 * An array container for plugins.
	 */
	public var list(default, null):Array<FlxBasic> = [];

	/**
	 * Adds a new plugin to the global plugin array.
	 * **DEPRECATED:** In a later version this will be changed to behave like `addPlugin`.
	 *
	 * @param   plugin  Any object that extends FlxBasic. Useful for managers and other things.
	 * @return  The same plugin you passed in.
	 */
	@:generic
	@:deprecated("FlxG.plugins.add is deprecated, use `addIfUniqueType` or `addPlugin`, instead.\nNote: In a later version `add` will be changed to behave like `addPlugin`")
	public inline function add<T:FlxBasic>(plugin:T):T
	{
		return addIfUniqueType(plugin);
	}
	
	/**
	 * Adds a new plugin to the global plugin array, does not check for existing instances of this type.
	 * **Note:** This is a temporary function. Eventually `add` will allow duplicates
	 *
	 * @param   plugin  Any object that extends FlxBasic. Useful for managers and other things.
	 * @return  The same plugin you passed in.
	 */
	public function addPlugin<T:FlxBasic>(plugin:T):T
	{
		// No repeats found
		list.push(plugin);
		return plugin;
	}
	
	/**
	 * Adds a new plugin to the global plugin array.
	 * **Note:** If there is already a plugin of this type, it will not be added
	 *
	 * @param   plugin  Any object that extends FlxBasic. Useful for managers and other things.
	 * @return  The same plugin you passed in.
	 */
	public function addIfUniqueType<T:FlxBasic>(plugin:T):T
	{
		// Check for repeats
		for (p in list)
		{
			if (FlxStringUtil.sameClassName(plugin, p))
				return plugin;
		}
		
		// No repeats found
		list.push(plugin);
		return plugin;
	}

	/**
	 * Retrieves the first plugin found that matches the specified type.
	 *
	 * @param   type  The class name of the plugin you want to retrieve.
	 *                See the `FlxPath` or `FlxTimer` constructors for example usage.
	 * @return  The plugin object, or null if no matching plugin was found.
	 */
	public function get<T:FlxBasic>(type:Class<T>):T
	{
		for (plugin in list)
		{
			if (Std.isOfType(plugin, type))
			{
				return cast plugin;
			}
		}

		return null;
	}

	/**
	 * Removes an instance of a plugin from the global plugin array.
	 *
	 * @param   plugin  The plugin instance you want to remove.
	 * @return  The same plugin you passed in.
	 */
	public inline function remove<T:FlxBasic>(plugin:T):T
	{
		list.remove(plugin);
		return plugin;
	}

	/**
	 * Removes all instances of a plugin from the global plugin array.
	 *
	 * @param   type  The class name of the plugin type you want removed from the array.
	 * @return  Whether or not at least one instance of this plugin type was removed.
	 */
	@:deprecated("FlxG.plugin.removeType is deprecated, use `removeAllByType` instead")
	public inline function removeType(type:Class<FlxBasic>):Bool
	{
		return removeAllByType(type);
	}
	
	public function removeAllByType(type:Class<FlxBasic>):Bool
	{
		var results:Bool = false;

		var i = list.length;
		while (i-- > 0)
		{
			if (Std.isOfType(list[i], type))
			{
				list.splice(i, 1);
				results = true;
			}
		}

		return results;
	}

	@:allow(flixel.FlxG)
	function new()
	{
		addPlugin(FlxTimer.globalManager = new FlxTimerManager());
		addPlugin(FlxTween.globalManager = new FlxTweenManager());
		addPlugin(FlxMouseEvent.globalManager = new FlxMouseEventManager());
	}

	/**
	 * Used by the game object to call update() on all the plugins.
	 */
	@:allow(flixel.FlxGame)
	inline function update(elapsed:Float):Void
	{
		for (plugin in list)
		{
			if (plugin.exists && plugin.active)
			{
				plugin.update(elapsed);
			}
		}
	}

	/**
	 * Used by the game object to call draw() on all the plugins.
	 */
	@:allow(flixel.FlxGame)
	inline function draw():Void
	{
		for (plugin in list)
		{
			if (plugin.exists && plugin.visible)
			{
				plugin.draw();
			}
		}
	}
}
