package flixel.system.frontEnds;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.plugin.DebugPathDisplay;
import flixel.plugin.TimerManager;

class PluginFrontEnd
{
	/**
	 * An array container for plugins.
	 * By default flixel uses a couple of plugins:
	 * DebugPathDisplay, and TimerManager.
	 */
	public var list:Array<FlxBasic>;
	
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
		//Don't add repeats
		var pluginList:Array<FlxBasic> = list;
		var l:Int = pluginList.length;
		for (i in 0...l)
		{
			if (pluginList[i].toString() == Plugin.toString())
			{
				return Plugin;
			}
		}
		
		//no repeats! safe to add a new instance of this plugin
		pluginList.push(Plugin);
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
		var pluginList:Array<FlxBasic> = list;
		var i:Int = 0;
		var l:Int = pluginList.length;
		while(i < l)
		{
			if (Std.is(pluginList[i], ClassType))
			{
				return list[i];
			}
			i++;
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
		//Don't add repeats
		var pluginList:Array<FlxBasic> = list;
		var i:Int = pluginList.length-1;
		while(i >= 0)
		{
			if (pluginList[i] == Plugin)
			{
				pluginList.splice(i, 1);
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
		//Don't add repeats
		var results:Bool = false;
		var pluginList:Array<FlxBasic> = list;
		var i:Int = pluginList.length - 1;
		while(i >= 0)
		{
			if (Std.is(pluginList[i], ClassType))
			{
				pluginList.splice(i,1);
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
		var plugin:FlxBasic;
		var pluginList:Array<FlxBasic> = list;
		var i:Int = 0;
		var l:Int = pluginList.length;
		while(i < l)
		{
			plugin = pluginList[i++];
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
		var plugin:FlxBasic;
		var pluginList:Array<FlxBasic> = list;
		var i:Int = 0;
		var l:Int = pluginList.length;
		while(i < l)
		{
			plugin = pluginList[i++];
			if (plugin.exists && plugin.visible)
			{
				plugin.draw();
			}
		}
	}
}