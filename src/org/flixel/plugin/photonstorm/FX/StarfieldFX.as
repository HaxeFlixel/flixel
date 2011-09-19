/**
 * StarfieldFX - Special FX Plugin
 * -- Part of the Flixel Power Tools set
 * 
 * v1.1 StarField moved to the FX Plugin system
 * v1.0 First release
 * 
 * @version 1.1 - May 21st 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.FX 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	/**
	 * Creates a 2D or 3D Star Field effect on an FlxSprite for use in your game.
	 */
	public class StarfieldFX extends BaseFX
	{
		/**
		 * In a 3D starfield this controls the X coordinate the stars emit from, can be updated in real-time!
		 */
		public var centerX:int;
		
		/**
		 * In a 3D starfield this controls the Y coordinate the stars emit from, can be updated in real-time!
		 */
		public var centerY:int;
		
		/**
		 * How much to shift on the X axis every update. Negative values move towards the left, positiive to the right. 2D Starfield only. Can also be set via setStarSpeed()
		 */
		public var starXOffset:Number = -1;
		
		/**
		 * How much to shift on the Y axis every update. Negative values move up, positiive values move down. 2D Starfield only. Can also be set via setStarSpeed()
		 */
		public var starYOffset:Number = 0;
		
		private var stars:Array;
		private var starfieldType:int;
		
		private var backgroundColor:uint = 0xff000000;
		
		private var updateSpeed:int;
		private var tick:int;
		
		private var depthColours:Array;
		
		public static const STARFIELD_TYPE_2D:int = 1;
		public static const STARFIELD_TYPE_3D:int = 2;
		
		public function StarfieldFX() 
		{
		}
		
		/**
		 * Create a new StarField
		 * 
		 * @param	x				X coordinate of the starfield sprite
		 * @param	y				Y coordinate of the starfield sprite
		 * @param	width			The width of the starfield
		 * @param	height			The height of the starfield
		 * @param	quantity		The number of stars in the starfield (default 200)
		 * @param	type			Type of starfield. Either STARFIELD_TYPE_2D (default, stars move horizontally) or STARFIELD_TYPE_3D (stars flow out from the center)
		 * @param	updateInterval	How many ms should pass before the next starfield update (default 20)
		 */
		public function create(x:int, y:int, width:uint, height:uint, quantity:uint = 200, type:int = 1, updateInterval:int = 20):FlxSprite
		{
			sprite = new FlxSprite(x, y).makeGraphic(width, height, backgroundColor);
			
			canvas = new BitmapData(sprite.width, sprite.height, true, backgroundColor);
			
			starfieldType = type;
			
			updateSpeed = speed;
			
			//	Stars come from the middle of the starfield in 3D mode
			centerX = width >> 1;
			centerY = height >> 1;
				
			clsRect = new Rectangle(0, 0, width, height);
			clsPoint = new Point;
			clsColor = backgroundColor;
			
			stars = new Array();
			
			for (var i:uint = 0; i < quantity; i++)
			{
				var star:Object = new Object;
				
				star.index = i;
				star.x = int(Math.random() * width);
				star.y = int(Math.random() * height);
				star.d = 1;
				
				if (type == STARFIELD_TYPE_2D)
				{
					star.speed = 1 + int(Math.random() * 5);
				}
				else
				{
					star.speed = Math.random();
				}
				
				star.r = Math.random() * Math.PI * 2;
				star.alpha = 0;
				
				stars.push(star);
			}
			
			//	Colours array
			if (type == STARFIELD_TYPE_2D)
			{
				depthColours = FlxGradient.createGradientArray(1, 5, [0xff585858, 0xffF4F4F4]);
			}
			else
			{
				depthColours = FlxGradient.createGradientArray(1, 300, [0xff292929, 0xffffffff]);
			}
			
			active = true;
			
			return sprite;
		}
		
		/**
		 * Change the background color in the format 0xAARRGGBB of the starfield.<br />
		 * Supports alpha, so if you want a transparent background just pass 0x00 as the color.
		 * 
		 * @param	backgroundColor
		 */
		public function setBackgroundColor(backgroundColor:uint):void
		{
			clsColor = backgroundColor;
		}
		
		/**
		 * Change the number of layers (depth) and colors used for each layer of the starfield. Change happens immediately.
		 * 
		 * @param	depth			Number of depths (for a 2D starfield the default is 5)
		 * @param	lowestColor		The color given to the stars furthest away from the camera (i.e. the slowest stars), typically the darker colour
		 * @param	highestColor	The color given to the stars cloest to the camera (i.e. the fastest stars), typically the brighter colour
		 */
		public function setStarDepthColors(depth:int, lowestColor:uint = 0xff585858, highestColor:uint = 0xffF4F4F4):void
		{
			//	Depth is the same, we just need to update the gradient then
			depthColours = FlxGradient.createGradientArray(1, depth, [lowestColor, highestColor]);
			
			//	Run through the stars array, making sure the depths are all within range
			for each (var star:Object in stars)
			{
				star.speed = 1 + int(Math.random() * depth);
			}
		}
		
		/**
		 * Sets the direction and speed of the 2D starfield (doesn't apply to 3D)<br />
		 * You can combine both X and Y together to make the stars move on a diagnol
		 * 
		 * @param	xShift	How much to shift on the X axis every update. Negative values move towards the left, positiive to the right
		 * @param	yShift	How much to shift on the Y axis every update. Negative values move up, positiive values move down
		 */
		public function setStarSpeed(xShift:Number, yShift:Number):void
		{
			starXOffset = xShift;
			starYOffset = yShift;
		}
		
		/**
		 * The current update speed
		 */
		public function get speed():int
		{
			return updateSpeed;
		}
		
		/**
		 * Change the tick interval on which the update runs. By default the starfield updates once every 20ms. Set to zero to disable totally.
		 */
		public function set speed(newSpeed:int):void
		{
			updateSpeed = newSpeed;
		}
		
		private function update2DStarfield():void
		{
			for each (var star:Object in stars)
			{
				star.x += (starXOffset * star.speed);
				star.y += (starYOffset * star.speed);
				
				canvas.setPixel32(star.x, star.y, depthColours[star.speed - 1]);
				
				if (star.x > sprite.width)
				{
					star.x = 0;
				}
				else if (star.x < 0)
				{
					star.x = sprite.width;
				}
				
				if (star.y > sprite.height)
				{
					star.y = 0;
				}
				else if (star.y < 0)
				{
					star.y = sprite.height;
				}
			}
		}
		
		private function update3DStarfield():void
		{
			for each (var star:Object in stars)
			{
				star.d *= 1.1;
				star.x = centerX + ((Math.cos(star.r) * star.d) * star.speed);
				star.y = centerY + ((Math.sin(star.r) * star.d) * star.speed);
				
				star.alpha = star.d * 2;
				
				if (star.alpha > 255)
				{
					star.alpha = 255;
				}
				
				canvas.setPixel32(star.x, star.y, 0xffffffff);
				//canvas.setPixel32(star.x, star.y, FlxColor.getColor32(255, star.alpha, star.alpha, star.alpha));
				
				if (star.x < 0 || star.x > sprite.width || star.y < 0 || star.y > sprite.height)
				{
					star.d = 1;
					star.r = Math.random() * Math.PI * 2;
					star.x = 0;
					star.y = 0;
					star.speed = Math.random();
					star.alpha = 0;
					
					stars[star.index] = star;
				}
			}
		}
		
		public function draw():void
		{
			if (getTimer() > tick)
			{
				canvas.lock();
				canvas.fillRect(clsRect, clsColor);
				
				if (starfieldType == STARFIELD_TYPE_2D)
				{
					update2DStarfield();
				}
				else
				{
					update3DStarfield();
				}
				
				canvas.unlock();
				
				sprite.pixels = canvas;
				
				if (updateSpeed > 0)
				{
					tick = getTimer() + updateSpeed;
				}
			}
		}
		
	}

}