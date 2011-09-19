/**
 * RainbowLineFX - A Special FX Plugin
 * -- Part of the Flixel Power Tools set
 * 
 * v1.0 Built into the new FlxSpecialFX system
 * 
 * @version 1.0 - May 9th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 * @see Requires FlxGradient, FlxMath
*/

package org.flixel.plugin.photonstorm.FX 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	/**
	 * Creates a Rainbow Line Effect - typically a rainbow sequence of color values passing through a 1px high line
	 */
	public class RainbowLineFX extends BaseFX
	{
		private var lineColors:Array;
		private var maxColor:uint;
		private var currentColor:uint;
		private var fillRect:Rectangle;
		private var speed:uint;
		private var chunk:uint;
		private var direction:uint;
		private var setPixel:Boolean;
		
		public function RainbowLineFX() 
		{
		}
		
		/**
		 * Creates a Color Line FlxSprite.
		 * 
		 * @param	x			The x coordinate of the FlxSprite in game world pixels
		 * @param	y			The y coordinate of the FlxSprite in game world pixels
		 * @param	width		The width of the FlxSprite in pixels
		 * @param	height		The height of the FlxSprite in pixels
		 * @param	colors		An Array of color values used to create the line. If null (default) the HSV Color Wheel is used, giving a full spectrum rainbow effect
		 * @param	colorWidth	The width of the color range controls how much interpolation occurs between each color in the colors array (default 360)
		 * @param	colorSpeed	The speed at which the Rainbow Line cycles through its colors (default 1)
		 * @param	stepSize	The size of each "chunk" of the Rainbow Line - use a higher value for a more retro look (default 1)
		 * @param	fadeWidth	If you want the Line to fade from fadeColor to the first color in the colors array, and then out again, set this value to the amount of transition you want (128 looks good)
		 * @param	fadeColor	The default fade color is black, but if you need to alpha it, or change for a different color, set it here
		 * 
		 * @return	An FlxSprite which automatically updates each draw() to cycle the colors through it
		 */
		public function create(x:int, y:int, width:uint, height:uint = 1, colors:Array = null, colorWidth:uint = 360, colorSpeed:uint = 1, stepSize:uint = 1, fadeWidth:uint = 128, fadeColor:uint = 0xff000000):FlxSprite
		{
			sprite = new FlxSprite(x, y).makeGraphic(width, height, 0x0);
			
			canvas = new BitmapData(width, height, true, 0x0);
			
			if (colors is Array)
			{
				lineColors = FlxGradient.createGradientArray(1, colorWidth, colors);
			}
			else
			{
				lineColors = FlxColor.getHSVColorWheel();
			}
			
			currentColor = 0;
			maxColor = lineColors.length - 1;
			
			if (fadeWidth != 0)
			{
				var blackToFirst:Array = FlxGradient.createGradientArray(1, fadeWidth, [ fadeColor, fadeColor, fadeColor, lineColors[0] ]);
				var lastToBlack:Array = FlxGradient.createGradientArray(1, fadeWidth, [ lineColors[maxColor], fadeColor, fadeColor, fadeColor, fadeColor ]);
				
				var fadingColours:Array = blackToFirst.concat(lineColors);
				fadingColours = fadingColours.concat(lastToBlack);
				
				lineColors = fadingColours;
			
				maxColor = lineColors.length - 1;
			}
			
			direction = 0;
			setPixel = false;
			speed = colorSpeed;
			chunk = stepSize;
			fillRect = new Rectangle(0, 0, chunk, height);
			
			if (height == 1 && chunk == 1)
			{
				setPixel = true;
			}
			
			active = true;
			
			return sprite;
		}
		
		/**
		 * Change the colors cycling through the line by passing in a new array of color values
		 * 
		 * @param	colors				An Array of color values used to create the line. If null (default) the HSV Color Wheel is used, giving a full spectrum rainbow effect
		 * @param	colorWidth			The width of the color range controls how much interpolation occurs between each color in the colors array (default 360)
		 * @param	resetCurrentColor	If true the color pointer is returned to the start of the new color array, otherwise remains where it is
		 * @param	fadeWidth			If you want the Rainbow Line to fade from black to the first color in the colors array, and then out again, set this value to the amount of transition you want (128 looks good)
		 * @param	fadeColor			The default fade color is black, but if you need to alpha it, or change for a different color, set it here
		 */
		public function updateColors(colors:Array, colorWidth:uint = 360, resetCurrentColor:Boolean = false, fadeWidth:uint = 128, fadeColor:uint = 0xff000000):void
		{
			if (colors is Array)
			{
				lineColors = FlxGradient.createGradientArray(1, colorWidth, colors);
			}
			else
			{
				lineColors = FlxColor.getHSVColorWheel();
			}
			
			maxColor = lineColors.length - 1;
			
			if (fadeWidth != 0)
			{
				var blackToFirst:Array = FlxGradient.createGradientArray(1, fadeWidth, [ 0xff000000, 0xff000000, 0xff000000, lineColors[0] ]);
				var lastToBlack:Array = FlxGradient.createGradientArray(1, fadeWidth, [ lineColors[maxColor], 0xff000000, 0xff000000, 0xff000000, 0xff000000 ]);
				
				var fadingColours:Array = blackToFirst.concat(lineColors);
				fadingColours = fadingColours.concat(lastToBlack);
				
				lineColors = fadingColours;
			
				maxColor = lineColors.length - 1;
			}
			
			if (currentColor > maxColor || resetCurrentColor)
			{
				currentColor = 0;
			}
		}
		
		/**
		 * Doesn't need to be called directly as it's called by the FlxSpecialFX Plugin.<br>
		 * Set active to false if you wish to disable the effect.<br>
		 * Pass the effect to FlxSpecialFX.erase() if you wish to destroy this effect.
		 */
		public function draw():void
		{
			canvas.lock();
		
			fillRect.x = 0;
			
			for (var x:int = 0; x < canvas.width; x = x + chunk)
			{
				var c:int = FlxMath.wrapValue(currentColor + x, 1, maxColor);
				
				if (setPixel)
				{
					canvas.setPixel32(x, 0, lineColors[c]);
				}
				else
				{
					canvas.fillRect(fillRect, lineColors[c]);
					fillRect.x += chunk;
				}
			}
			
			canvas.unlock();
			
			if (direction == 0)
			{
				currentColor += speed;
				
				if (currentColor >= maxColor)
				{
					currentColor = 0;
				}
			}
			else
			{
				currentColor -= speed;
				
				if (currentColor < 0)
				{
					currentColor = maxColor;
				}
			}
			
			sprite.pixels = canvas;
			sprite.dirty = true;
		}
		
		/**
		 * Set the speed at which the Line cycles through its colors
		 */
		public function set colorSpeed(value:uint):void 
		{
			if (value < maxColor)
			{
				speed = value;
			}
		}
		
		/**
		 * The speed at which the Line cycles through its colors
		 */
		public function get colorSpeed():uint
		{
			return speed;
		}
		
		/**
		 * Set the size of each "chunk" of the Line. Use a higher value for a more retro look
		 */
		public function set stepSize(value:uint):void 
		{
			if (value < canvas.width && value > 0)
			{
				canvas.fillRect(new Rectangle(0, 0, canvas.width, canvas.height), 0x0);
				chunk = value;
				
				fillRect.x = 0;
				fillRect.width = chunk;
				
				if (value > 1)
				{
					setPixel = false;
				}
				else
				{
					setPixel = true;
				}
			}
		}
		
		/**
		 * The size of each "chunk" of the Line
		 */
		public function get stepSize():uint
		{
			return chunk;
		}
		
		/**
		 * Changes the color cycle direction.
		 * 
		 * @param	newDirection	0 = Colors cycle incrementally (line looks like it is moving to the left), 1 = Colors decrement (line moves to the right)
		 */
		public function setDirection(newDirection:uint):void
		{
			if (newDirection == 0 || newDirection == 1)
			{
				direction = newDirection;
			}
		}
		
	}

}