/**
 * GlitchFX - Special FX Plugin
 * -- Part of the Flixel Power Tools set
 * 
 * v1.1 Added changeGlitchValues support
 * v1.0 First release
 * 
 * @version 1.1 - June 13th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.FX 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	/**
	 * Creates a static / glitch / monitor-corruption style effect on an FlxSprite
	 * 
	 * TODO:
	 * 
	 * Add reduction from really high glitch value down to zero, will smooth the image into place and look cool :)
	 * Add option to glitch vertically?
	 * 
	 */
	public class GlitchFX extends BaseFX
	{
		private var glitchSize:uint;
		private var glitchSkip:uint;
		
		public function GlitchFX() 
		{
		}
		
		public function createFromFlxSprite(source:FlxSprite, maxGlitch:uint, maxSkip:uint, autoUpdate:Boolean = false, backgroundColor:uint = 0x0):FlxSprite
		{
			sprite = new FlxSprite(source.x, source.y).makeGraphic(source.width + maxGlitch, source.height, backgroundColor);
			
			canvas = new BitmapData(sprite.width, sprite.height, true, backgroundColor);
			
			image = source.pixels;
			
			updateFromSource = autoUpdate;
			
			glitchSize = maxGlitch;
			glitchSkip = maxSkip;
			
			clsColor = backgroundColor;
			clsRect = new Rectangle(0, 0, canvas.width, canvas.height);
			
			copyPoint = new Point(0, 0);
			copyRect = new Rectangle(0, 0, image.width, 1);
			
			active = true;
			
			return sprite;
		}
		
		public function changeGlitchValues(maxGlitch:uint, maxSkip:uint):void
		{
			glitchSize = maxGlitch;
			glitchSkip = maxSkip;
		}
		
		public function draw():void
		{
			if (ready)
			{
				if (lastUpdate != updateLimit)
				{
					lastUpdate++;
					
					return;
				}
				
				if (updateFromSource && sourceRef.exists)
				{
					image = sourceRef.framePixels;
				}
				
				canvas.lock();
				canvas.fillRect(clsRect, clsColor);
				
				var rndSkip:uint = 1 + int(Math.random() * glitchSkip);
				
				copyRect.y = 0;
				copyPoint.y = 0;
				copyRect.height = rndSkip;
				
				for (var y:int = 0; y < sprite.height; y += rndSkip)
				{
					copyPoint.x = int(Math.random() * glitchSize);
					canvas.copyPixels(image, copyRect, copyPoint);
					
					copyRect.y += rndSkip;
					copyPoint.y += rndSkip;
				}
						
				canvas.unlock();
				
				lastUpdate = 0;
				
				sprite.pixels = canvas;
				sprite.dirty = true;
			}
		}
		
	}

}