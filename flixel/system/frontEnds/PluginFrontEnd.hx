package flixel.system.frontEnds;

import flixel.tweens.FlxTween;
import flixel.util.FlxPath;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

@:allow(flixel.FlxGame)
class PluginFrontEnd
{
	/**
	 * An array container for plugins.
	 */
	public var list(default, null):Array<FlxBasic> = [];
	
	/**
	 * Adds a new plugin to the global plugin array.
	 * 
	 * @param	Plugin	Any object that extends FlxPlugin. Useful for managers and other things. See flixel.plugin for some examples!
	 * @return	The same FlxPlugin-based plugin you passed in.
	 */
	@:generic
	public function add<T:FlxBasic>(Plugin:T):T
	{
		// Don't add repeats
		for (plugin in list)
		{
			if (FlxStringUtil.sameClassName(Plugin, plugin))
			{
				return Plugin;
			}
		}
		
		// No repeats! safe to add a new instance of this plugin
		list.push(Plugin);
		return Plugin;
	}
	
	/**
	 * Retrieves a plugin based on its class name from the global plugin array.
	 * 
	 * @param	ClassType	The class name of the plugin you want to retrieve. See the FlxPath or FlxTimer constructors for example usage.
	 * @return	The plugin object, or null if no matching plugin was found.
	 */
	public function get(ClassType:Class<FlxBasic>):FlxBasic
	{
		for (plugin in list)
		{
			if (Std.is(plugin, ClassType))
			{
				return plugin;
			}
		}
		
		return null;
	}
	
	/**
	 * Removes an instance of a plugin from the global plugin array.
	 * 
	 * @param	Plugin	The plugin instance you want to remove.
	 * @return	The same FlxPlugin-based plugin you passed in.
	 */
	public function remove(Plugin:FlxBasic):FlxBasic
	{
		// Don't add repeats
		var i:Int = list.length - 1;
		
		while (i >= 0)
		{
			if (list[i] == Plugin)
			{
				list.splice(i, 1);
				return Plugin;
			}
			i--;
		}
		
		return Plugin;
	}
	
	/**
	 * Removes all instances of a plugin from the global plugin array.
	 * 
	 * @param	ClassType	The class name of the plugin type you want removed from the array.
	 * @return	Whether or not at least one instance of this plugin type was removed.
	 */
	public function removeType(ClassType:Class<FlxBasic>):Bool
	{
		// Don't add repeats
		var results:Bool = false;
		var i:Int = list.length - 1;
		
		while (i >= 0)
		{
			if (Std.is(list[i], ClassType))
			{
				list.splice(i,1);
				results = true;
			}
			i--;
		}
		
		return results;
	}
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		add(FlxTimer.manager = new FlxTimerManager());
		add(FlxTween.manager = new FlxTweenManager());
	}
	
	/**
	 * Used by the game object to call update() on all the plugins.
	 */
	private inline function update(elapsed:Float):Void
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
	private inline function draw():Void
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