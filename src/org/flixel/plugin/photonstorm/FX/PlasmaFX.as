/**
 * PlasmaFX - Special FX Plugin
 * -- Part of the Flixel Power Tools set
 * 
 * v1.4 Moved to the new Special FX Plugins
 * v1.3 Colours updated to include alpha values
 * v1.2 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.4 - May 8th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.FX 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	/**
	 * Creates a plasma effect FlxSprite
	 */
	
	public class PlasmaFX extends BaseFX
	{
		//private var pos1:uint;
		//private var pos2:uint;
		//private var pos3:uint;
		//private var pos4:uint;
		
		public var pos1:uint;
		public var pos2:uint;
		public var pos3:uint;
		public var pos4:uint;
		public var depth:uint = 128;
		
		private var tpos1:uint;
		private var tpos2:uint;
		private var tpos3:uint;
		private var tpos4:uint;
		
		private var aSin:Array;
		//private var previousColour:uint;
		private var colours:Array;
		private var step:uint = 0;
		private var span:uint;
		
		public function PlasmaFX():void
		{
		}
		
		public function create(x:int, y:int, width:uint, height:uint, scaleX:uint = 1, scaleY:uint = 1):FlxSprite
		{
			sprite = new FlxSprite(x, y).makeGraphic(width, height, 0x0);
			
			if (scaleX != 1 || scaleY != 1)
			{
				sprite.scale = new FlxPoint(scaleX, scaleY);
				sprite.x += width / scaleX;
				sprite.y += height / scaleY;
			}
			
			canvas = new BitmapData(width, height, true, 0x0);
			
			colours = FlxColor.getHSVColorWheel();
			
			//colours = FlxColor.getHSVColorWheel(140);	// now supports alpha :)
			//colours = FlxGradient.createGradientArray(1, 360, [0xff000000, 0xff000000, 0xff000000, 0x00000000, 0xff000000], 2);	//	Lovely black reveal for over an image
			//colours = FlxGradient.createGradientArray(1, 360, [0xff0000FF, 0xff000000, 0xff8F107C, 0xff00FFFF, 0xff0000FF], 1); // lovely purple black blue thingy
			
			span = colours.length - 1;
			
			aSin = new Array(512);
			
			for (var i:int = 0; i < 512; i++)
			{
				//var rad:Number = (i * 0.703125) * 0.0174532;
				var rad:Number = (i * 0.703125) * 0.0174532;
				
				//	Any power of 2!
				//	http://www.vaughns-1-pagers.com/computer/powers-of-2.htm
				//	256, 512, 1024, 2048, 4096, 8192, 16384
				aSin[i] = Math.sin(rad) * 1024;
				
				//aSin[i] = Math.cos(rad) * 1024;
			}
			
			active = true;
			
			tpos1 = 293;
			tpos2 = 483;
			tpos3 = 120;
			tpos4 = 360;
			
			pos1 = 0;
			pos2 = 5;
			pos3 = 0;
			pos4 = 0;
			
			return sprite;
		}
		
		public function draw():void
		{
			if (step < 10)
			{
				//trace(step, tpos1, tpos2, tpos3, tpos4, pos1, pos2, pos3, pos4, index);
				step++;
			}
			
			tpos4 = pos4;
			tpos3 = pos3;
			
			canvas.lock();
			
			for (var y:int = 0; y < canvas.height; y++)
			{
				tpos1 = pos1 + 5;
				tpos2 = pos2 + 3;
				
				//tpos1 = pos1;
				//tpos2 = pos2;
				
				tpos2 &= 511;
				tpos3 &= 511;
				
				for (var x:int = 0; x < canvas.width; x++)
				{
					tpos1 &= 511;
					tpos2 &= 511;
					
					var x2:int = aSin[tpos1] + aSin[tpos2] + aSin[tpos3] + aSin[tpos4];
				
					//var index:int = depth + (x2 >> 4);
					var index:int = depth + (x2 >> 4);
					//p = (128 + (p >> 4)) & 255;

					
					if (index <= 0)
					{
						index += span;
					}
					
					if (index >= span)
					{
						index -= span;
					}
						
					canvas.setPixel32(x, y, colours[index]);
					
					tpos1 += 5;
					tpos2 += 3;
				}
				
				tpos3 += 1;
				tpos4 += 3;
			}
			
			canvas.unlock();
			
			sprite.pixels = canvas;
			sprite.dirty = true;
			
			pos1 += 4;	// horizontal shift
			pos3 += 2;	// vertical shift
		}
		
	}

}