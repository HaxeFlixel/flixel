/**
* FlxSpecialFX
* -- Part of the Flixel Power Tools set
* 
* v1.5 Added RevealFX
* v1.4 Added BlurFX and CenterSlideFX
* v1.3 Renamed DropDown to FloodFill
* v1.2 Added GlitchFX and StarfieldFX
* v1.1 Added SineWaveFX
* v1.0 First release of the new FlxSpecialFX system
* 
* @version 1.4 - June 12th 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm;

import flash.utils.TypedDictionary;
import org.flixel.FlxBasic;
import org.flixel.FlxG;
import org.flixel.plugin.photonstorm.fx.BaseFX;
import org.flixel.plugin.photonstorm.fx.BlurFX;
import org.flixel.plugin.photonstorm.fx.CenterSlideFX;
import org.flixel.plugin.photonstorm.fx.FloodFillFX;
import org.flixel.plugin.photonstorm.fx.GlitchFX;
import org.flixel.plugin.photonstorm.fx.PlasmaFX;
import org.flixel.plugin.photonstorm.fx.RainbowLineFX;
import org.flixel.plugin.photonstorm.fx.RevealFX;
import org.flixel.plugin.photonstorm.fx.SineWaveFX;
import org.flixel.plugin.photonstorm.fx.StarfieldFX;

/**
 * FlxSpecialFX is a single point of access to all of the FX Plugins available in the Flixel Power Tools
 */
class FlxSpecialFX extends FlxBasic
{
	private static var members:TypedDictionary<BaseFX, BaseFX> = new TypedDictionary(true);
	
	public function new() 
	{
		super();
	}
	
	//	THE SPECIAL FX PLUGINS AVAILABLE
	
	/**
	 * Creates a Plama field Effect
	 * 
	 * @return	PlasmaFX
	 */
	public static function plasma():PlasmaFX
	{
		var temp:PlasmaFX = new PlasmaFX();
		
		members.set(temp, temp);
		
		return temp;
	}
	
	/**
	 * Creates a Rainbow Line Effect
	 * 
	 * @return	RainbowLineFX
	 */
	public static function rainbowLine():RainbowLineFX
	{
		var temp:RainbowLineFX = new RainbowLineFX();
		
		members.set(temp, temp);
		
		return temp;
	}
	
	/**
	 * Creates a Flood Fill Effect
	 * 
	 * @return	FloodFillFX
	 */
	public static function floodFill():FloodFillFX
	{
		var temp:FloodFillFX = new FloodFillFX();
		
		members.set(temp, temp);
		
		return temp;
	}
	
	/**
	 * Creates a Sine Wave Down Effect
	 * 
	 * @return	SineWaveFX
	 */
	public static function sineWave():SineWaveFX
	{
		var temp:SineWaveFX = new SineWaveFX();
		
		members.set(temp, temp);
		
		return temp;
	}
	
	/**
	 * Creates a Glitch Effect
	 * 
	 * @return	GlitchFX
	 */
	public static function glitch():GlitchFX
	{
		var temp:GlitchFX = new GlitchFX();
		
		members.set(temp, temp);
		
		return temp;
	}
	
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
	
	/**
	 * Creates a Blur Effect
	 * 
	 * @return	BlurFX
	 */
	public static function blur():BlurFX
	{
		var temp:BlurFX = new BlurFX();
		
		members.set(temp, temp);
		
		return temp;
	}
	
	/**
	 * Creates a Center Slide Effect
	 * 
	 * @return	CenterSlideFX
	 */
	public static function centerSlide():CenterSlideFX
	{
		var temp:CenterSlideFX = new CenterSlideFX();
		
		members.set(temp, temp);
		
		return temp;
	}
	
	/**
	 * Creates a Reveal Effect
	 * 
	 * @return	RevealFX
	 */
	public static function reveal():RevealFX
	{
		var temp:RevealFX = new RevealFX();
		
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
		if (members.get(source) != null)
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
				//obj.draw();
				Reflect.callMethod(obj, Reflect.field(obj, "draw"), []);
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
		if (members.get(source) != null)
		{
			members.get(source).destroy();
			
			members.delete(source);
			
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