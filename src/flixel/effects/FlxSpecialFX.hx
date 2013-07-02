package flixel.effects;

import flixel.effects.fx.BaseFX;
import flixel.effects.fx.StarfieldFX;
import flixel.FlxBasic;
import flixel.FlxG;
import haxe.ds.ObjectMap;

/**
 * FlxSpecialFX is a single point of access to all of the FX Plugins available in the Flixel Power Tools
 * 
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class FlxSpecialFX extends FlxBasic
{
	static private var members:ObjectMap<BaseFX, BaseFX> = new ObjectMap<BaseFX, BaseFX>();
	
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
	 * @param	Effect	A reference to the FX Plugin you wish to run. If null it will start all currently added FX Plugins
	 */
	public static function startFX(?Effect:BaseFX):Void
	{
		if (Effect != null)
		{
			members.get(Effect).active = true;
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
	 * @param	Effect	A reference to the FX Plugin you wish to stop. If null it will stop all currently added FX Plugins
	 */
	public static function stopFX(?Effect:BaseFX):Void
	{
		if (Effect != null)
		{
			members.get(Effect).active = false;
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
	 * @param	Effect	A reference to the FX Plugin you wish to run. If null it will start all currently added FX Plugins
	 * @return	Boolean	true if the FX Plugin is active, false if not
	 */
	public static function isActive(Effect:BaseFX):Bool
	{
		if (members.exists(Effect))
		{
			return members.get(Effect).active;
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
	 * @param	Effect	The FX Plugin to remove
	 * @return	Boolean	true if the plugin was removed, otherwise false.
	 */
	public static function remove(Effect:BaseFX):Bool
	{
		if (members.exists(Effect))
		{
			members.get(Effect).destroy();
			members.remove(Effect);
			
			return true;
		}
		
		return false;
	}
	
	/**
	 * Removes all FX Plugins. This is called automatically if the plugin is destroyed, 
	 * but should be called manually by you if you change states.
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