/**
 * CenterSlideFX - Special FX Plugin
 * -- Part of the Flixel Power Tools set
 * 
 * v1.1 Refactored main loop a little and added reverse function
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
	 * Makes an image expand or collapse from its center
	 */
	public class CenterSlideFX extends BaseFX
	{
		/**
		 * True when the effect has completed. False while the effect is running.
		 */
		public var complete:Boolean;
		
		/**
		 * A function that is called once the effect is has finished running and is complete
		 */
		public var completeCallback:Function;
		
		private var pixels:uint;
		private var direction:uint;
		
		private var sideA:Rectangle;
		private var sideB:Rectangle;
		private var pointA:Point;
		private var pointB:Point;
		
		public static const REVEAL_VERTICAL:uint = 0;
		public static const REVEAL_HORIZONTAL:uint = 1;
		public static const HIDE_VERTICAL:uint = 2;
		public static const HIDE_HORIZONTAL:uint = 3;
		
		public function CenterSlideFX() 
		{
		}
		
		/**
		 * Creates a new CenterSlide effect from the given FlxSprite. The original sprite remains unmodified.<br>
		 * The resulting FlxSprite will take on the same width / height and x/y coordinates of the source FlxSprite.
		 * 
		 * @param	source				The FlxSprite providing the image data for this effect. The resulting FlxSprite takes on the source width, height and x/y position.
		 * @param	direction			REVEAL_VERTICAL, REVEAL_HORIZONTAL, HIDE_VERTICAL or HIDE_HORIZONTAL
		 * @param	pixels				How many pixels to slide update (default 1)
		 * @param	backgroundColor		The background colour of the FlxSprite the effect is drawn in to (default 0x0 = transparent)
		 * 
		 * @return	An FlxSprite with the effect running through it, which should be started with a call to CenterSlideFX.start()
		 */
		public function createFromFlxSprite(source:FlxSprite, direction:uint = 0, pixels:uint = 1, backgroundColor:uint = 0x0):FlxSprite
		{
			return create(source.pixels, source.x, source.y, direction, pixels, backgroundColor);
		}
		
		/**
		 * Creates a new CenterSlide effect from the given Class (which must contain a Bitmap) usually from an Embedded bitmap.
		 * 
		 * @param	source				The Class providing the bitmapData for this effect, usually from an Embedded bitmap.
		 * @param	x					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	y					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	direction			REVEAL_VERTICAL, REVEAL_HORIZONTAL, HIDE_VERTICAL or HIDE_HORIZONTAL
		 * @param	pixels				How many pixels to slide update (default 1)
		 * @param	backgroundColor		The background colour of the FlxSprite the effect is drawn in to (default 0x0 = transparent)
		 * 
		 * @return	An FlxSprite with the effect running through it, which should be started with a call to CenterSlideFX.start()
		 */
		public function createFromClass(source:Class, x:int, y:int, direction:uint = 0, pixels:uint = 1, backgroundColor:uint = 0x0):FlxSprite
		{
			return create((new source).bitmapData, x, y, direction, pixels, backgroundColor);
		}
		
		/**
		 * Creates a new CenterSlide effect from the given bitmapData.
		 * 
		 * @param	source				The bitmapData image to use for this effect.
		 * @param	x					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	y					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	direction			REVEAL_VERTICAL, REVEAL_HORIZONTAL, HIDE_VERTICAL or HIDE_HORIZONTAL
		 * @param	pixels				How many pixels to slide update (default 1)
		 * @param	backgroundColor		The background colour of the FlxSprite the effect is drawn in to (default 0x0 = transparent)
		 * 
		 * @return	An FlxSprite with the effect running through it, which should be started with a call to CenterSlideFX.start()
		 */
		public function createFromBitmapData(source:BitmapData, x:int, y:int, direction:uint = 0, pixels:uint = 1, backgroundColor:uint = 0x0):FlxSprite
		{
			return create(source, x, y, direction, pixels, backgroundColor);
		}
		
		private function create(source:BitmapData, x:int, y:int, direction:uint = 0, pixels:uint = 1, backgroundColor:uint = 0x0):FlxSprite
		{
			sprite = new FlxSprite(x, y).makeGraphic(source.width, source.height, backgroundColor);
			
			canvas = new BitmapData(source.width, source.height, true, backgroundColor);
			
			image = source.clone();
			
			clsRect = new Rectangle(0, 0, canvas.width, canvas.height);
			clsColor = backgroundColor;
			
			this.direction = direction;
			this.pixels = pixels;
			
			var midway:int = int(source.height / 2);
			
			switch (direction)
			{
				case REVEAL_VERTICAL:
					sideA = new Rectangle(0, 0, source.width, pixels);
					sideB = new Rectangle(0, source.height - pixels, source.width, pixels);
					pointA = new Point(0, midway);
					pointB = new Point(0, midway);
					break;
					
				case REVEAL_HORIZONTAL:
					midway = int(source.width / 2);
					sideA = new Rectangle(0, 0, pixels, source.height);
					sideB = new Rectangle(source.width - pixels, 0, pixels, source.height);
					pointA = new Point(midway, 0);
					pointB = new Point(midway, 0);
					break;
					
				case HIDE_VERTICAL:
					canvas = image.clone();
					sprite.pixels = canvas;
					sprite.dirty = true;
					sideA = new Rectangle(0, 0, source.width, midway);
					sideB = new Rectangle(0, midway, source.width, source.height - midway);
					pointA = new Point(0, 0);
					pointB = new Point(0, midway);
					break;
					
				case HIDE_HORIZONTAL:
					canvas = image.clone();
					sprite.pixels = canvas;
					sprite.dirty = true;
					midway = int(source.width / 2);
					sideA = new Rectangle(0, 0, midway, source.height);
					sideB = new Rectangle(midway, 0, source.width - midway, source.height);
					pointA = new Point(0, 0);
					pointB = new Point(midway, 0);
					break;
			}
			
			active = true;
			complete = false;
			
			return sprite;
		}
		
		public function reverse():void
		{
			if (direction == REVEAL_VERTICAL)
			{
				direction = HIDE_VERTICAL;
				complete = false;
			}
			else if (direction == REVEAL_HORIZONTAL)
			{
				direction = HIDE_HORIZONTAL;
				complete = false;
			}
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
				
				canvas.fillRect(clsRect, clsColor);
				canvas.copyPixels(image, sideA, pointA, null, null, true);
				canvas.copyPixels(image, sideB, pointB, null, null, true);
				
				switch (direction)
				{
					case REVEAL_VERTICAL:
						sideA.height += pixels;
						pointA.y -= pixels;
						sideB.height += pixels;
						sideB.y -= pixels;
						break;
						
					case REVEAL_HORIZONTAL:
						sideA.width += pixels;
						pointA.x -= pixels;
						sideB.width += pixels;
						sideB.x -= pixels;
						break;
						
					case HIDE_VERTICAL:
						sideA.height -= pixels;
						pointA.y += pixels;
						sideB.height -= pixels;
						sideB.y += pixels;
						break;
						
					case HIDE_HORIZONTAL:
						sideA.width -= pixels;
						pointA.x += pixels;
						sideB.width -= pixels;
						sideB.x += pixels;
						break;
				}
				
				//	Are we finished?
				if ((direction == REVEAL_VERTICAL && pointA.y < 0) || (direction == REVEAL_HORIZONTAL && pointA.x < 0))
				{
					canvas = image.clone();
					complete = true;
				}
				else if ((direction == HIDE_VERTICAL && sideA.height <= 0) || (direction == HIDE_HORIZONTAL && sideA.width <= 0))
				{
					canvas.fillRect(clsRect, clsColor);
					complete = true;
				}
				
				lastUpdate = 0;
				
				sprite.pixels = canvas;
				sprite.dirty = true;
				
				if (complete && completeCallback is Function)
				{
					completeCallback.call();
				}
			}
		}
		
	}

}