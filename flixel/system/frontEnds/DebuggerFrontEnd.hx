package flixel.system.frontEnds;

import flixel.FlxBasic;
import flixel.FlxG;

class DebuggerFrontEnd
{	
	#if !FLX_NO_DEBUG
	/**
	 * Whether to show visual debug displays or not. Doesn't exist in <code>FLX_NO_DEBUG</code> mode.
	 * @default false
	 */
	public var visualDebug:Bool = false;
	#end
	
	#if !FLX_NO_KEYBOARD
	/**
	 * The key codes used to open the debugger (via <code>flash.ui.Keyboard</code>). 
	 * Doesn't exist in <code>FLX_NO_KEYBOARD</code> mode.
	 * @default [192, 220]
	 */
	public var toggleKeys:Array<Int>;
	#end
	
	/**
	 * Used to instantiate this class and assign a value to <code>toggleKeys</code>
	 */
	public function new() 
	{
		#if !FLX_NO_KEYBOARD
		toggleKeys = [192, 220];
		#end
	}
	
	/**
	 * Change the way the debugger's windows are laid out.
	 * 
	 * @param	Layout	The layout codes can be found in <code>FlxDebugger</code>, for example <code>FlxDebugger.MICRO</code>
	 */
	inline public function setLayout(Layout:Int):Void
	{
		#if !FLX_NO_DEBUG
		FlxG._game._debugger.setLayout(Layout);
		#end
	}
	
	/**
	 * Just resets the debugger windows to whatever the last selected layout was (<code>STANDARD</code> by default).
	 */
	inline public function resetLayout():Void
	{
		#if !FLX_NO_DEBUG
		FlxG._game._debugger.resetLayout();
		#end
	}
	
	/**
	 * Whether the debugger is visible or not.
	 * @default false
	 */
	public var visible(default, set):Bool = false;
	
	private function set_visible(Visible:Bool):Bool
	{
		#if !FLX_NO_DEBUG
		FlxG._game._debuggerUp = Visible;
		FlxG._game.debugger.visible = Visible;
		#end
		
		return visible = Visible;
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * You shouldn't need to call this. Used to Draw the debug graphics for any installed plugins.
	 */
	public function drawDebugPlugins():Void
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
}