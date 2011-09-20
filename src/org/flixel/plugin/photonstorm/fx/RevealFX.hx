/**
* RevealFX - Special FX Plugin
* -- Part of the Flixel Power Tools set
* 
* v1.1 Added changeGlitchValues support
* v1.0 First release
* 
* @version 1.1 - June 13th 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.fx;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import org.flixel.FlxSprite;


/**
 * Creates a static / glitch / monitor-corruption style effect on an FlxSprite
 * 
 * TODO:
 * 
 * Add reduction from really high glitch value down to zero, will smooth the image into place and look cool :)
 * Add option to glitch vertically?
 * 
 */
class RevealFX extends BaseFX
{
	#if flash
	private var glitchSize:UInt;
	private var glitchSkip:UInt;
	#else
	private var glitchSize:Int;
	private var glitchSkip:Int;
	#end
	
	public function new() 
	{
		super();
	}
	
	#if flash
	public function createFromFlxSprite(source:FlxSprite, maxGlitch:UInt, maxSkip:UInt, ?autoUpdate:Bool = false, ?backgroundColor:UInt = 0x0):FlxSprite
	#else
	public function createFromFlxSprite(source:FlxSprite, maxGlitch:Int, maxSkip:Int, ?autoUpdate:Bool = false, ?backgroundColor:Int = 0x0):FlxSprite
	#end
	{
		sprite = new FlxSprite(source.x, source.y).makeGraphic(Math.floor(source.width + maxGlitch), Math.floor(source.height), backgroundColor);
		
		canvas = new BitmapData(Math.floor(sprite.width), Math.floor(sprite.height), true, backgroundColor);
		
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
	
	#if flash
	public function changeGlitchValues(maxGlitch:UInt, maxSkip:UInt):Void
	#else
	public function changeGlitchValues(maxGlitch:Int, maxSkip:Int):Void
	#end
	{
		glitchSize = maxGlitch;
		glitchSkip = maxSkip;
	}
	
	public function draw():Void
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
			
			#if flash
			var rndSkip:UInt = 1 + Std.int(Math.random() * glitchSkip);
			#else
			var rndSkip:Int = 1 + Std.int(Math.random() * glitchSkip);
			#end
			
			copyRect.y = 0;
			copyPoint.y = 0;
			copyRect.height = rndSkip;
			
			var y:Int = 0;
			while (y < sprite.height)
			{
				copyPoint.x = Std.int(Math.random() * glitchSize);
				canvas.copyPixels(image, copyRect, copyPoint);
				
				copyRect.y += rndSkip;
				copyPoint.y += rndSkip;
				y += rndSkip;
			}
					
			canvas.unlock();
			
			lastUpdate = 0;
			
			sprite.pixels = canvas;
			sprite.dirty = true;
		}
	}
	
}