package flixel.system.frontEnds;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.plugin.DebugPathDisplay;
import flixel.plugin.TimerManager;

class PluginFrontEnd
{
	/**
	 * An array container for plugins.
	 */
	public var list(default, null):Array<FlxBasic>;
	
	/**
	 * Sets up two plugins: <code>DebugPathDisplay</code> 
	 * in debugging mode and <code>TimerManager</code>
	 */
	public function new() 
	{
		list = new Array<FlxBasic>();
		
		#if !FLX_NO_DEBUG
		add(new DebugPathDisplay());
		#end
		
		add(new TimerManager());
	}
	
	/**
	 * Adds a new plugin to the global plugin array.
	 * 
	 * @param	Plugin	Any object that extends FlxBasic. Useful for managers and other things.  See flixel.plugin for some examples!
	 * @return	The same <code>FlxBasic</code>-based plugin you passed in.
	 */
	public function add(Plugin:FlxBasic):FlxBasic
	{
		// Don't add repeats
		for (plugin in list)
		{
			if (plugin.toString() == Plugin.toString())
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
	 * @param	ClassType	The class name of the plugin you want to retrieve. See the <code>FlxPath</code> or <code>FlxTimer</code> constructors for example usage.
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
	 * @return	The same <code>FlxBasic</code>-based plugin you passed in.
	 */
	public function remove(Plugin:FlxBasic):FlxBasic
	{
		// Don't add repeats
		var i:Int = list.length - 1;
		
		while(i >= 0)
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
		
		while(i >= 0)
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
	
	/**
	 * Used by the game object to call <code>update()</code> on all the plugins.
	 */
	inline public function update():Void
	{
		for (plugin in list)
		{
			if (plugin.exists && plugin.active)
			{
				plugin.update();
			}
		}
	}
	
	/**
	 * Used by the game object to call <code>draw()</code> on all the plugins.
	 */
	inline public function draw():Void
	{
		for (plugin in list)
		{
			if (plugin.exists && plugin.visible)
			{
				plugin.draw();
			}
		}
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * You shouldn't need to call this. Used to Draw the debug graphics for any installed plugins.
	 */
	public function drawDebug():Void
	{
		for (plugin in list)
		{
			if (plugin.exists && plugin.visible && !plugin.ignoreDrawDebug)
			{
				plugin.drawDebug();
			}
		}
	}
	#end
}