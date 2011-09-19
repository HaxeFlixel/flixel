/**
 * FloodFillFX - Special FX Plugin
 * -- Part of the Flixel Power Tools set
 * 
 * v1.1 Renamed - was "DropDown", but now a more accurate "flood fill"
 * v1.0 First release
 * 
 * @version 1.1 - May 31st 2011
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
	 * Creates a flood fill effect FlxSprite, useful for bringing in images in cool ways
	 */
	public class FloodFillFX extends BaseFX
	{
		private var complete:Boolean;
		private var chunk:uint;
		private var offset:uint;
		private var dropDirection:uint;
		private var dropRect:Rectangle;
		private var dropPoint:Point;
		private var dropY:uint;
		
		public function FloodFillFX() 
		{
		}
		
		/**
		 * Creates a new Flood Fill effect from the given image
		 * 
		 * @param	source				The source image bitmapData to use for the drop
		 * @param	x					The x coordinate to place the resulting effect sprite
		 * @param	y					The y coordinate to place the resulting effect sprite
		 * @param	width				The width of the resulting effet sprite. Doesn't have to match the source image
		 * @param	height				The height of the resulting effet sprite. Doesn't have to match the source image
		 * @param	direction			0 = Top to bottom. 1 = Bottom to top. 2 = Left to Right. 3 = Right to Left.
		 * @param	pixels				How many pixels to drop per update (default 1)
		 * @param	split				Boolean (default false) - if split it will drop from opposite sides at the same time
		 * @param	backgroundColor		The background colour of the FlxSprite the effect is drawn in to (default 0x0 = transparent)
		 * 
		 * @return	An FlxSprite with the effect ready to run in it
		 */
		public function create(source:FlxSprite, x:int, y:int, width:uint, height:uint, direction:uint = 0, pixels:uint = 1, split:Boolean = false, backgroundColor:uint = 0x0):FlxSprite
		{
			sprite = new FlxSprite(x, y).makeGraphic(width, height, backgroundColor);
			
			canvas = new BitmapData(width, height, true, backgroundColor);
			
			if (source.pixels.width != width || source.pixels.height != height)
			{
				image = new BitmapData(width, height, true, backgroundColor);
				image.copyPixels(source.pixels, new Rectangle(0, 0, source.pixels.width, source.pixels.height), new Point(0, height - source.pixels.height));
			}
			else
			{
				image = source.pixels;
			}
			
			offset = pixels;
			
			dropDirection = direction;
			dropRect = new Rectangle(0, canvas.height - offset, canvas.width, offset);
			dropPoint = new Point(0, 0);
			dropY = canvas.height;
			
			active = true;
			
			return sprite;
		}
		
		public function draw():void
		{
			if (ready && complete == false)
			{
				if (lastUpdate != updateLimit)
				{
					lastUpdate++;
					
					return;
				}
				
				canvas.lock();
				
				switch (dropDirection)
				{
					//	Dropping Down
					case 0:
					
						//	Get a pixel strip from the picture (starting at the bottom and working way up)
						for (var y:int = 0; y < dropY; y += offset)
						{
							dropPoint.y = y;
							canvas.copyPixels(image, dropRect, dropPoint);
						}
						
						dropY -= offset;
						
						dropRect.y -= offset;
						
						if (dropY <= 0)
						{
							complete = true;
						}
					
						break;
				}
				
				lastUpdate = 0;
				
				canvas.unlock();
				
				sprite.pixels = canvas;
				sprite.dirty = true;
			}
		}
		
	}

}