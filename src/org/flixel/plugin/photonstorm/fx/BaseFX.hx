/**
* BaseFX - Special FX Plugin
* -- Part of the Flixel Power Tools set
* 
* v1.1 Fixed some documentation
* v1.0 First release
* 
* @version 1.1 - June 10th 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.fx; 

import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BitmapInt32;
import org.flixel.FlxSprite;
import nme.display.BitmapData;

class BaseFX 
{
	/**
	 * Set to false to stop this effect being updated by the FlxSpecialFX Plugin. Set to true to enable.
	 */
	public var active:Bool;
	
	/**
	 * The FlxSprite into which the effect is drawn. Add this to your FlxState / FlxGroup to display the effect.
	 */
	public var sprite:FlxSprite;
	
	#if flash
	/**
	 * A scratch bitmapData used to build-up the effect before passing to sprite.pixels
	 */
	var canvas:BitmapData;
	
	/**
	 * TODO A snapshot of the sprite background before the effect is applied
	 */
	var back:BitmapData;
	#end
	
	var image:BitmapData;
	var sourceRef:FlxSprite;
	var updateFromSource:Bool;
	var clsRect:Rectangle;
	var clsPoint:Point;
	#if flash
	var clsColor:UInt;
	#else
	var clsColor:BitmapInt32;
	#end
	
	//	For staggered drawing updates
	var updateLimit:Int;
	var lastUpdate:Int;
	var ready:Bool;
	
	var copyRect:Rectangle;
	var copyPoint:Point;
	
	public function new() 
	{
		updateLimit = 0;
		lastUpdate = 0;
		ready = false;
		active = false;
	}
	
	/**
	 * Starts the effect runnning
	 * 
	 * @param	delay	How many "game updates" should pass between each update? If your game runs at 30fps a value of 0 means it will do 30 updates per second. A value of 1 means it will do 15 updates per second, etc.
	 */
	public function start(delay:Int = 0):Void
	{
		updateLimit = delay;
		lastUpdate = 0;
		ready = true;
	}
	
	/**
	 * Pauses the effect from running. The draw function is still called each loop, but the pixel data is stopped from updating.<br>
	 * To disable the SpecialFX Plugin from calling the FX at all set the "active" parameter to false.
	 */
	public function stop():Void
	{
		ready = false;
	}
	
	public function draw():Void
	{
		
	}
	
	public function destroy():Void
	{
		if (sprite != null)
		{
			sprite.kill();
		}
		
		#if flash
		if (canvas != null)
		{
			canvas.dispose();
		}
		
		if (back != null)
		{
			back.dispose();
		}
		#end
		
		if (image != null)
		{
			image.dispose();
		}
		
		sourceRef = null;
		active = false;
	}
	
}