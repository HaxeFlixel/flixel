package flixel.util;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.InterpolationMethod;
import flash.display.Shape;
import flash.display.SpreadMethod;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * Adds a set of color gradient creation / rendering functions
 * 
 * @version 1.6 - May 9th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 * @see Requires FlxMath
 */
class FlxGradient
{
	public static function createGradientMatrix(width:Int, height:Int, colors:Array<Int>, chunkSize:Int = 1, rotation:Int = 90):GradientMatrix
	{
		var gradientMatrix:Matrix = new Matrix();
		
		//	Rotation (in radians) that the gradient is rotated
		var rot:Float = FlxAngle.asRadians(rotation);
		
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
		
		var alpha:Array<Float> = new Array();
		
		for (ai in 0...colors.length)
		{
			alpha.push(FlxColorUtil.getAlphaFloat(colors[ai]));
		}
		
		var ratio:Array<Int> = new Array();
		
		if (colors.length == 2)
		{
			ratio[0] = 0;
			ratio[1] = 255;
		}
		else
		{
			//	Spread value
			var spread:Int = Std.int(255 / (colors.length - 1));
			
			ratio.push(0);
			
			for (ri in 1...(colors.length - 1))
			{
				ratio.push(ri * spread);
			}
			
			ratio.push(255);
		}
		
		return { matrix: gradientMatrix, alpha: alpha, ratio: ratio };
	}
	
	public static function createGradientArray(width:Int, height:Int, colors:Array<Int>, chunkSize:Int = 1, rotation:Int = 90, interpolate:Bool = true):Array<Int>
	{
		var data:BitmapData = createGradientBitmapData(width, height, colors, chunkSize, rotation, interpolate);
		var result:Array<Int> = new Array();
		
		for (y in 0...(data.height))
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
	public static function createGradientFlxSprite(width:Int, height:Int, colors:Array<Int>, chunkSize:Int = 1, rotation:Int = 90, interpolate:Bool = true):FlxSprite
	{
		var data:BitmapData = createGradientBitmapData(width, height, colors, chunkSize, rotation, interpolate);
		var dest:FlxSprite = new FlxSprite();
		dest.pixels = data;
		return dest;
	}
	
	public static function createGradientBitmapData(width:Int, height:Int, colors:Array<Int>, chunkSize:Int = 1, rotation:Int = 90, interpolate:Bool = true):BitmapData
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
		
		#if !flash
		var key:String = "Gradient: " + width + " x " + height + ", colors: [";
		var a:Int;
		var rgb:Int;
		for (col in colors)
		{
			a = (col >> 24) & 255;
			rgb = col & 0x00ffffff;
			
			key = key + rgb + "_" + a + ", ";
		}
		key = key + "], chunkSize: " + chunkSize + ", rotation: " + rotation;
		
		if (FlxG.bitmap.checkCache(key))
		{
			return FlxG.bitmap.get(key).bitmap;
		}
		#end
		
		var gradient:GradientMatrix = createGradientMatrix(width, height, colors, chunkSize, rotation);
		
		var s:Shape = new Shape();
		
		if (interpolate)
		{
			s.graphics.beginGradientFill(GradientType.LINEAR, cast(colors), gradient.alpha, gradient.ratio, gradient.matrix, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
		}
		else
		{
			s.graphics.beginGradientFill(GradientType.LINEAR, cast(colors), gradient.alpha, gradient.ratio, gradient.matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB, 0);
		}
		
		if (chunkSize == 1)
		{
			s.graphics.drawRect(0, 0, width, height);
		}
		else
		{
			s.graphics.drawRect(0, 0, width, height / chunkSize);
		}
		
		var data:BitmapData = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		
		if (chunkSize == 1)
		{
			data.draw(s);
		}
		else
		{
			var tempBitmap:Bitmap = new Bitmap(new BitmapData(width, Std.int(height / chunkSize), true, FlxColor.TRANSPARENT));
			tempBitmap.bitmapData.draw(s);
			tempBitmap.scaleY = chunkSize;
			
			var sM:Matrix = new Matrix();
			sM.scale(tempBitmap.scaleX, tempBitmap.scaleY);
			
			data.draw(tempBitmap, sM);
		}
		
		#if !flash
		FlxG.bitmap.add(data, false, key);
		#end
		
		return data;
	}
	
	/**
	 * Creates a new gradient and overlays that on-top of the given FlxSprite at the destX/destY coordinates (default 0,0)
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
	public static function overlayGradientOnFlxSprite(dest:FlxSprite, width:Int, height:Int, colors:Array<Int>, destX:Int = 0, destY:Int = 0, chunkSize:Int = 1, rotation:Int = 90, interpolate:Bool = true):FlxSprite
	{
		if (width > dest.width)
		{
			width = Std.int(dest.width);
		}
		
		if (height > dest.height)
		{
			height = Std.int(dest.height);
		}
		
		var source:FlxSprite = createGradientFlxSprite(width, height, colors, chunkSize, rotation, interpolate);
		dest.stamp(source, destX, destY);
		return dest;
	}
	
	/**
	 * Creates a new gradient and overlays that on-top of the given BitmapData at the destX/destY coordinates (default 0,0)
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
	public static function overlayGradientOnBitmapData(dest:BitmapData, width:Int, height:Int, colors:Array<Int>, destX:Int = 0, destY:Int = 0, chunkSize:Int = 1, rotation:Int = 90, interpolate:Bool = true):BitmapData
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

typedef GradientMatrix = {
    var matrix:Matrix;
    var alpha:Array<Float>;
    var ratio:Array<Int>;
}