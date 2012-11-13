/**
 * FlxSpecialFX
 * -- Part of the Flixel Power Tools set
 * 
 * @version 1.6 - September 19th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm;

import nme.ObjectHash;
import org.flixel.FlxBasic;
import org.flixel.FlxG;
import org.flixel.FlxU;
import org.flixel.plugin.photonstorm.fx.BaseFX;
//import org.flixel.plugin.photonstorm.fx.GlitchFX;
import org.flixel.plugin.photonstorm.fx.StarfieldFX;

/**
 * FlxSpecialFX is a single point of access to all of the FX Plugins available in the Flixel Power Tools
 */
class FlxSpecialFX extends FlxBasic
{
	private static var members:ObjectHash<BaseFX, BaseFX> = new ObjectHash<BaseFX, BaseFX>();
	
	public function new() 
	{
		super();
	}
	
	//	THE SPECIAL FX PLUGINS AVAILABLE
	
	/**
	 * Creates a Glitch Effect
	 * 
	 * @return	GlitchFX
	 */
	/*public static function glitch():GlitchFX
	{
		var temp:GlitchFX = new GlitchFX();
		members.set(temp, temp);
		return temp;
	}*/
	
	/**
	 * Creates a 2D or 3D Starfield Effect
	 * 
	 * @return	StarfieldFX
	 */
	public static function starfield():StarfieldFX
	{
		var temp:StarfieldFX = new StarfieldFX();
		members.set(temp, temp);
		return temp;
	}
	
	//	GLOBAL FUNCTIONS
	
	/**
	 * Starts the given FX Plugin running
	 * 
	 * @param	source	A reference to the FX Plugin you wish to run. If null it will start all currently added FX Plugins
	 */
	public static function startFX(source:BaseFX = null):Void
	{
		if (source != null)
		{
			members.get(source).active = true;
		}
		else
		{
			for (obj in members)
			{
				obj.active = true;
			}
		}
	}
	
	/**
	 * Stops the given FX Plugin running
	 * 
	 * @param	source	A reference to the FX Plugin you wish to stop. If null it will stop all currently added FX Plugins
	 */
	public static function stopFX(source:BaseFX = null):Void
	{
		if (source != null)
		{
			members.get(source).active = false;
		}
		else
		{
			for (obj in members)
			{
				obj.active = false;
			}
		}
	}
	
	/**
	 * Returns the active state of the given FX Plugin running
	 * 
	 * @param	source	A reference to the FX Plugin you wish to run. If null it will start all currently added FX Plugins
	 * @return	Boolean	true if the FX Plugin is active, false if not
	 */
	public static function isActive(source:BaseFX):Bool
	{
		if (members.exists(source))
		{
			return members.get(source).active;
		}
		
		return false;
	}
	
	/**
	 * Called automatically by Flixels Plugin handler
	 */
	override public function draw():Void
	{
		if (FlxG.paused)
		{
			return;
		}
		
		for (obj in members)
		{
			if (obj.active)
			{
				obj.draw();
			}
		}
	}
	
	/**
	 * Removes a FX Plugin from the Special FX Handler
	 * 
	 * @param	source	The FX Plugin to remove
	 * @return	Boolean	true if the plugin was removed, otherwise false.
	 */
	public static function remove(source:BaseFX):Bool
	{
		if (members.exists(source))
		{
			members.get(source).destroy();
			members.remove(source);
			return true;
		}
		
		return false;
	}
	
	/**
	 * Removes all FX Plugins<br>
	 * This is called automatically if the plugin is destroyed, but should be called manually by you if you change States
	 */
	public static function clear():Void
	{
		for (obj in members)
		{
			remove(obj);
		}
	}
	
	/**
	 * Destroys all FX Plugins currently added and then destroys this instance of the FlxSpecialFX Plugin
	 */
	override public function destroy():Void
	{
		clear();
	}
	
}