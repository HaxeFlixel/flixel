package flixel.plugin;

import flixel.FlxBasic;

/**
 * A base class for all flixel plugins that use the flixel plugin system (see <code>FlxG.plugins</code>).
 * Plugins are basically <code>FlxBasic</code>s, but they provide some additional features, like 
 * notifications for certain events like switchting the state or resizing the window.
 */
class FlxPlugin extends FlxBasic
{
	/**
	 * This function is called whenever the state is switched or reset 
	 * (<code>FlxG.switchState()</code> and <code>FlxG.resetState()</code>).
	 */  
	public function onStateSwitch():Void { }
	
	/**
	 * This function is called whenever the window size has been changed.
	 * @param 	Width	The new window width
	 * @param 	Height	The new window Height
	 */  
	public function onResize(Width:Int, Height:Int):Void { }
}