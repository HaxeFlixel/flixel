/**
 * FlxGradient
 * -- Part of the Flixel Power Tools set
 * 
 * v1.6 Fixed bug where gradients with chunk sizes > 1 would ignore alpha values
 * v1.5 Alpha values used in the gradient map
 * v1.4 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.6 - May 9th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 * @see Requires FlxMath
*/

package org.flixel.plugin.photonstorm 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.GradientType; 
	import flash.display.SpreadMethod;
	import flash.display.InterpolationMethod;
	
	/**
	 * Adds a set of color gradient creation / rendering functions
	 */
	public class FlxGradient
	{
		
		public function FlxGradient() 
		{
		}
		
		public static function createGradientMatrix(width:int, height:int, colors:Array, chunkSize:int = 1, rotation:int = 90):Object
		{
			var gradientMatrix:Matrix = new Matrix();
			
			//	Rotation (in radians) that the gradient is rotated
			var rot:Number = FlxMath.asRadians(rotation);
			
			//	Last 2 values = horizontal and vertical shift (in pixels)
			if (chunkSize == 1)
			{
				gradientMatrix.createGradientBox(width, height, rot, 0, 0);
			}
			else
			{
				gradientMatrix.createGradientBox(width, height / chunkSize, rot, 0, 0);
			}
			
			//	Create the alpha and ratio arrays
			
			var alpha:Array = new Array();
			
			for (var ai:int = 0; ai < colors.length; ai++)
			{
				alpha.push(FlxColor.getAlphaFloat(colors[ai]));
			}
			
			var ratio:Array = new Array();
			
			if (colors.length == 2)
			{
				ratio[0] = 0;
				ratio[1] = 255;
			}
			else
			{
				//	Spread value
				var spread:int = 255 / (colors.length - 1);
				
				ratio.push(0);
				
				for (var ri:int = 1; ri < colors.length - 1; ri++)
				{
					ratio.push(ri * spread);
				}
				
				ratio.push(255);
			}
			
			return { matrix: gradientMatrix, alpha: alpha, ratio: ratio };
		}
		
		public static function createGradientArray(width:int, height:int, colors:Array, chunkSize:int = 1, rotation:int = 90, interpolate:Boolean = true):Array
		{
			var data:BitmapData = createGradientBitmapData(width, height, colors, chunkSize, rotation, interpolate);
			
			var result:Array = new Array();
			
			for (var y:int = 0; y < data.height; y++)
			{
				result.push(data.getPixel32(0, y));
			}
			
			return result;
		}
		
		/**
		 * Creates an FlxSprite of the given width/height with a colour gradient flowing through it.
		 * 
		 * @param	width		The width of the FlxSprite (and therefore gradient)
		 * @param	height		The height of the FlxSprite (and therefore gradient)
		 * @param	colors		An array of colour values for the gradient to cycle through
		 * @param	chunkSize	If you want a more old-skool looking chunky gradient, increase this value!
		 * @param	rotation	Angle of the gradient in degrees. 90 = top to bottom, 180 = left to right. Any angle is valid
		 * @param	interpolate	Interpolate the colours? True uses RGB interpolation, false uses linear RGB
		 * 
		 * @return	An FlxSprite containing your gradient (if valid parameters given!)
		 */
		public static function createGradientFlxSprite(width:int, height:int, colors:Array, chunkSize:int = 1, rotation:int = 90, interpolate:Boolean = true):FlxSprite
		{
			var data:BitmapData = createGradientBitmapData(width, height, colors, chunkSize, rotation, interpolate);
			
			var dest:FlxSprite = new FlxSprite().makeGraphic(width, height);
			
			dest.pixels = data;
			
			return dest;
		}
		
		public static function createGradientBitmapData(width:int, height:int, colors:Array, chunkSize:int = 1, rotation:int = 90, interpolate:Boolean = true):BitmapData
		{
			//	Sanity checks
			if (width < 1)
			{
				width = 1;
			}
			
			if (height < 1)
			{
				height = 1;
			}
			
			var gradient:Object = createGradientMatrix(width, height, colors, chunkSize, rotation);
			
			var s:Shape = new Shape();
			
			if (interpolate)
			{
				s.graphics.beginGradientFill(GradientType.LINEAR, colors, gradient.alpha, gradient.ratio, gradient.matrix, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
			}
			else
			{
				s.graphics.beginGradientFill(GradientType.LINEAR, colors, gradient.alpha, gradient.ratio, gradient.matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB, 0);
			}
			
			if (chunkSize == 1)
			{
				s.graphics.drawRect(0, 0, width, height);
			}
			else
			{
				s.graphics.drawRect(0, 0, width, height / chunkSize);
			}

			var data:BitmapData = new BitmapData(width, height, true, 0x0);
			
			if (chunkSize == 1)
			{
				data.draw(s);
			}
			else
			{
				var tempBitmap:Bitmap = new Bitmap(new BitmapData(width, height / chunkSize, true, 0x0));
				tempBitmap.bitmapData.draw(s);
				tempBitmap.scaleY = chunkSize;
				
				var sM:Matrix = new Matrix();
				sM.scale(tempBitmap.scaleX, tempBitmap.scaleY);
				
				data.draw(tempBitmap, sM);
			}
			
			return data;
		}
		
		/**
		 * Creates a new gradient and overlays that on-top of the given FlxSprite at the destX/destY coordinates (default 0,0)<br />
		 * Use low alpha values in the colours to have the gradient overlay and not destroy the image below
		 * 
		 * @param	dest		The FlxSprite to overlay the gradient onto
		 * @param	width		The width of the FlxSprite (and therefore gradient)
		 * @param	height		The height of the FlxSprite (and therefore gradient)
		 * @param	colors		An array of colour values for the gradient to cycle through
		 * @param	destX		The X offset the gradient is drawn at (default 0)
		 * @param	destY		The Y offset the gradient is drawn at (default 0)
		 * @param	chunkSize	If you want a more old-skool looking chunky gradient, increase this value!
		 * @param	rotation	Angle of the gradient in degrees. 90 = top to bottom, 180 = left to right. Any angle is valid
		 * @param	interpolate	Interpolate the colours? True uses RGB interpolation, false uses linear RGB
		 * @return	The composited FlxSprite (for chaining, if you need)
		 */
		public static function overlayGradientOnFlxSprite(dest:FlxSprite, width:int, height:int, colors:Array, destX:int = 0, destY:int = 0, chunkSize:int = 1, rotation:int = 90, interpolate:Boolean = true):FlxSprite
		{
			if (width > dest.width)
			{
				width = dest.width;
			}
			
			if (height > dest.height)
			{
				height = dest.height;
			}
			
			var source:FlxSprite = createGradientFlxSprite(width, height, colors, chunkSize, rotation, interpolate);
			
			dest.stamp(source, destX, destY);
			
			return dest;
		}
		
		/**
		 * Creates a new gradient and overlays that on-top of the given BitmapData at the destX/destY coordinates (default 0,0)<br />
		 * Use low alpha values in the colours to have the gradient overlay and not destroy the image below
		 * 
		 * @param	dest		The BitmapData to overlay the gradient onto
		 * @param	width		The width of the FlxSprite (and therefore gradient)
		 * @param	height		The height of the FlxSprite (and therefore gradient)
		 * @param	colors		An array of colour values for the gradient to cycle through
		 * @param	destX		The X offset the gradient is drawn at (default 0)
		 * @param	destY		The Y offset the gradient is drawn at (default 0)
		 * @param	chunkSize	If you want a more old-skool looking chunky gradient, increase this value!
		 * @param	rotation	Angle of the gradient in degrees. 90 = top to bottom, 180 = left to right. Any angle is valid
		 * @param	interpolate	Interpolate the colours? True uses RGB interpolation, false uses linear RGB
		 * @return	The composited BitmapData
		 */
		public static function overlayGradientOnBitmapData(dest:BitmapData, width:int, height:int, colors:Array, destX:int = 0, destY:int = 0, chunkSize:int = 1, rotation:int = 90, interpolate:Boolean = true):BitmapData
		{
			if (width > dest.width)
			{
				width = dest.width;
			}
			
			if (height > dest.height)
			{
				height = dest.height;
			}
			
			var source:BitmapData = createGradientBitmapData(width, height, colors, chunkSize, rotation, interpolate);
			
			dest.copyPixels(source, new Rectangle(0, 0, source.width, source.height), new Point(destX, destY), null, null, true);
			
			return dest;
		}
		
	}

}