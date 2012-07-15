/**
 * GlitchFX - Special FX Plugin
 * -- Part of the Flixel Power Tools set
 * 
 * v1.2 Fixed updateFromSource github issue #8 (thanks CoderBrandon)
 * v1.1 Added changeGlitchValues support
 * v1.0 First release
 * 
 * @version 1.2 - August 8th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.fx;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import nme.display.BitmapInt32;
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
class GlitchFX extends BaseFX
{
	private var glitchSize:Int;
	private var glitchSkip:Int;
	
	public function new() 
	{
		super();
	}
	
	#if flash
	public function createFromFlxSprite(source:FlxSprite, maxGlitch:Int, maxSkip:Int, ?autoUpdate:Bool = false, ?backgroundColor:UInt = 0x0):FlxSprite
	#else
	public function createFromFlxSprite(source:FlxSprite, maxGlitch:Int, maxSkip:Int, ?autoUpdate:Bool = false, ?backgroundColor:BitmapInt32 = null):FlxSprite
	#end
	{
		#if (cpp || neko)
		if (backgroundColor == null)
		{
			#if neko
			backgroundColor = { rgb: 0x000000, a: 0x00);
			#else
			backgroundColor = 0x00000000;
			#end
		}
		#end
		
		#if flash
		sprite = new FlxSprite(source.x, source.y).makeGraphic(Math.floor(source.width + maxGlitch), Math.floor(source.height), backgroundColor);
		canvas = new BitmapData(Math.floor(sprite.width), Math.floor(sprite.height), true, backgroundColor);
		image = source.pixels;
		#else
		sprite = new GlitchSprite();
		// TODO: initialize glitch sprite
		
		#end
		
		updateFromSource = autoUpdate;
		
		glitchSize = maxGlitch;
		glitchSkip = maxSkip;
		
		clsColor = backgroundColor;
		
		copyPoint = new Point(0, 0);
		
		#if flash
		clsRect = new Rectangle(0, 0, canvas.width, canvas.height);
		copyRect = new Rectangle(0, 0, image.width, 1);
		#end
		
		active = true;
		return sprite;
	}
	
	public function changeGlitchValues(maxGlitch:Int, maxSkip:Int):Void
	{
		glitchSize = maxGlitch;
		glitchSkip = maxSkip;
	}
	
	override public function draw():Void
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
				#if flash
				image = sourceRef.framePixels;
				#else
				// TODO: update glitch sprite graphics
				
				#end
			}
			
			#if flash
			canvas.lock();
			canvas.fillRect(clsRect, clsColor);
			#end
			
			var rndSkip:Int = 1 + Std.int(Math.random() * glitchSkip);
			
			copyRect.y = 0;
			copyPoint.y = 0;
			copyRect.height = rndSkip;
			
			var y:Int = 0;
			
			#if flash
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
			#else
			// TODO: implement drawing for cpp and neko targets
			
			#end
		}
	}
	
}

#if (cpp || neko)
class GlitchSprite extends FlxSprite
{
	/**
	 * Information about each line in glitched sprite
	 */
	public var imageLines:Array<ImageLine>;
	
	// TODO: make all necessary properties
	
	public function new()
	{
		super();
		
		imageLines = new Array<ImageLine>();
		// TODO: initialize all additional properties
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		imageLines = null;
		// TODO: destroy all additional properties
	}
	
	override public function draw():Void
	{
		// TODO: implement sprite drawing
		
	}
	
	override public function updateTileSheet():Void 
	{
		// TODO: implement adding frames to tilesheet
		
	}
	
}

typedef ImageLine = {
	var x:Float;
	var y:Float;
	var tileID:Int;
}
#end