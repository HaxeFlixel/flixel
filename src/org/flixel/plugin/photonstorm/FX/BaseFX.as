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

package org.flixel.plugin.photonstorm.FX 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxSprite;
	import flash.display.BitmapData;
	
	public class BaseFX 
	{
		/**
		 * Set to false to stop this effect being updated by the FlxSpecialFX Plugin. Set to true to enable.
		 */
		public var active:Boolean;
		
		/**
		 * The FlxSprite into which the effect is drawn. Add this to your FlxState / FlxGroup to display the effect.
		 */
		public var sprite:FlxSprite;
		
		/**
		 * A scratch bitmapData used to build-up the effect before passing to sprite.pixels
		 */
		internal var canvas:BitmapData;
		
		/**
		 * TODO A snapshot of the sprite background before the effect is applied
		 */
		internal var back:BitmapData;
		
		internal var image:BitmapData;
		internal var sourceRef:FlxSprite;
		internal var updateFromSource:Boolean;
		internal var clsRect:Rectangle;
		internal var clsPoint:Point;
		internal var clsColor:uint;
		
		//	For staggered drawing updates
		internal var updateLimit:uint = 0;
		internal var lastUpdate:uint = 0;
		internal var ready:Boolean = false;
		
		internal var copyRect:Rectangle;
		internal var copyPoint:Point;
		
		public function BaseFX() 
		{
			active = false;
		}
		
		/**
		 * Starts the effect runnning
		 * 
		 * @param	delay	How many "game updates" should pass between each update? If your game runs at 30fps a value of 0 means it will do 30 updates per second. A value of 1 means it will do 15 updates per second, etc.
		 */
		public function start(delay:uint = 0):void
		{
			updateLimit = delay;
			lastUpdate = 0;
			ready = true;
		}
		
		/**
		 * Pauses the effect from running. The draw function is still called each loop, but the pixel data is stopped from updating.<br>
		 * To disable the SpecialFX Plugin from calling the FX at all set the "active" parameter to false.
		 */
		public function stop():void
		{
			ready = false;
		}
		
		public function destroy():void
		{
			if (sprite)
			{
				sprite.kill();
			}
			
			if (canvas)
			{
				canvas.dispose();
			}
			
			if (back)
			{
				back.dispose();
			}
			
			if (image)
			{
				image.dispose();
			}
			
			sourceRef = null;
			
			active = false;
		}
		
	}

}