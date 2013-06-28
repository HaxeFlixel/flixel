package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.FlxBasic;
import flash.display.Sprite;
import flash.display.Graphics;

class DebuggerFrontEnd
{	
	#if !FLX_NO_DEBUG
	/**
	 * Whether to show visual debug displays or not.
	 * @default false
	 */
	public var visualDebug:Bool;
	#end
	
	#if !FLX_NO_KEYBOARD
	/**
	 * The key codes used to open the debugger. (via flash.ui.Keyboard)
	 * @default [192, 220]
	 */
	public var toggleKeys:Array<Int>;
	#end
	
	public function new() 
	{
		#if !FLX_NO_KEYBOARD
		toggleKeys = [192, 220];
		#end
		
		#if !FLX_NO_DEBUG
		visualDebug = false;
		#end
	}
	
	#if !FLX_NO_DEBUG
	inline public function drawDebugPlugins():Void
	{
		var plugin:FlxBasic;
		var pluginList:Array<FlxBasic> = FlxG.plugins.list;
		var i:Int = 0;
		var l:Int = pluginList.length;
		while(i < l)
		{
			plugin = pluginList[i++];
			if (plugin.exists && plugin.visible && !plugin.ignoreDrawDebug)
			{
				plugin.drawDebug();
			}
		}
	}
	#end
	
	/**
	 * Toggles the flixel debugger, if it exists.
	 */
	public function toggle():Void
	{
		#if !FLX_NO_DEBUG
		if ((FlxG._game != null) && (FlxG._game.debugger != null))
		{
			FlxG._game._debuggerUp = !FlxG._game.debugger.visible;
			FlxG._game.debugger.visible = !FlxG._game.debugger.visible;
		}
		#end
	}
	
	/**
	 * Shows the flixel debugger, if it exists.
	 */
	public function show():Void
	{
		#if !FLX_NO_DEBUG
		if ((FlxG._game != null) && (FlxG._game.debugger != null))
		{
			FlxG._game._debuggerUp = true;
			FlxG._game.debugger.visible = true;
		}
		#end
	}
	
	/**
	 * Hides the flixel debugger, if it exists.
	 */
	public function hide():Void
	{
		#if !FLX_NO_DEBUG
		if ((FlxG._game != null) && (FlxG._game.debugger != null))
		{
			FlxG._game._debuggerUp = false;
			FlxG._game.debugger.visible = false;
		}
		#end
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Change the way the debugger's windows are laid out.
	 * 
	 * @param	Layout		See the presets above (e.g. <code>DEBUGGER_MICRO</code>, etc).
	 */
	public function setLayout(Layout:Int):Void
	{
		FlxG._game._debugger.setLayout(Layout);
	}
	
	/**
	 * Just resets the debugger windows to whatever the last selected layout was (<code>DEBUGGER_STANDARD</code> by default).
	 */
	public function resetLayout():Void
	{
		FlxG._game._debugger.resetLayout();
	}
	#end
}