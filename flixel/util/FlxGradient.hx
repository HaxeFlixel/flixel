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
import flixel.math.FlxAngle;

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
	public static function createGradientMatrix(width:Int, height:Int, colors:Array<FlxColor>, chunkSize:UInt = 1, rotation:Int = 90):GradientMatrix
	{
		var gradientMatrix = new Matrix();

		//	Rotation (in radians) that the gradient is rotated
		var rot:Float = FlxAngle.asRadians(rotation);

		//	Last 2 values = horizontal and vertical shift (in pixels)
		gradientMatrix.createGradientBox(width, height / chunkSize, rot, 0, 0);

		//	Create the alpha and ratio arrays
		var alpha = new Array<Float>();

		for (ai in 0...colors.length)
		{
			alpha.push(colors[ai].alphaFloat);
		}

		var ratio = new Array<Int>();

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

		return {matrix: gradientMatrix, alpha: alpha, ratio: ratio};
	}

	public static function createGradientArray(width:Int, height:Int, colors:Array<FlxColor>, chunkSize:UInt = 1, rotation:Int = 90,
			interpolate:Bool = true):Array<FlxColor>
	{
		var data:BitmapData = createGradientBitmapData(width, height, colors, chunkSize, rotation, interpolate);
		var result = new Array<Int>();

		for (y in 0...data.height)
		{
			result.push(data.getPixel32(0, y));
		}

		return result;
	}

	/**
	 * Creates a FlxSprite of the given width/height with a colour gradient flowing through it.
	 *
	 * @param   width         The width of the FlxSprite (and therefore gradient)
	 * @param   height        The height of the FlxSprite (and therefore gradient)
	 * @param   colors        An array of colour values for the gradient to cycle through
	 * @param   chunkSize     If you want a more old-skool looking chunky gradient, increase this value!
	 * @param   rotation      Angle of the gradient in degrees. 90 = top to bottom, 180 = left to right. Any angle is valid
	 * @param   interpolate   Interpolate the colours? True uses RGB interpolation, false uses linear RGB
	 * @return  A FlxSprite containing your gradient (if valid parameters given!)
	 */
	public static function createGradientFlxSprite(width:Int, height:Int, colors:Array<FlxColor>, chunkSize:UInt = 1, rotation:Int = 90,
			interpolate:Bool = true):FlxSprite
	{
		var data:BitmapData = createGradientBitmapData(width, height, colors, chunkSize, rotation, interpolate);
		var dest = new FlxSprite();
		dest.pixels = data;
		return dest;
	}

	public static function createGradientBitmapData(width:UInt, height:UInt, colors:Array<FlxColor>, chunkSize:UInt = 1, rotation:Int = 90,
			interpolate:Bool = true):BitmapData
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

		var gradient:GradientMatrix = createGradientMatrix(width, height, colors, chunkSize, rotation);
		var shape = new Shape();
		var interpolationMethod = interpolate ? InterpolationMethod.RGB : InterpolationMethod.LINEAR_RGB;

		#if flash
		var colors = colors.map(function(c):UInt return c);
		#end
		shape.graphics.beginGradientFill(GradientType.LINEAR, colors, gradient.alpha, gradient.ratio, gradient.matrix, SpreadMethod.PAD, interpolationMethod,
			0);

		shape.graphics.drawRect(0, 0, width, height / chunkSize);

		var data = new BitmapData(width, height, true, FlxColor.TRANSPARENT);

		if (chunkSize == 1)
		{
			data.draw(shape);
		}
		else
		{
			var tempBitmap = new Bitmap(new BitmapData(width, Std.int(height / chunkSize), true, FlxColor.TRANSPARENT));
			tempBitmap.bitmapData.draw(shape);
			tempBitmap.scaleY = chunkSize;

			var sM = new Matrix();
			sM.scale(tempBitmap.scaleX, tempBitmap.scaleY);

			data.draw(tempBitmap, sM);

			// The scaled bitmap might not have filled the data. Fill the remaining pixels with the last color.
			var remainingRect = new openfl.geom.Rectangle(0, tempBitmap.height, width, height - tempBitmap.height);
			data.fillRect(remainingRect, colors[colors.length - 1]);
		}

		return data;
	}

	/**
	 * Creates a new gradient and overlays that on-top of the given FlxSprite at the destX/destY coordinates (default 0,0)
	 * Use low alpha values in the colours to have the gradient overlay and not destroy the image below
	 *
	 * @param   dest          The FlxSprite to overlay the gradient onto
	 * @param   width         The width of the FlxSprite (and therefore gradient)
	 * @param   height        The height of the FlxSprite (and therefore gradient)
	 * @param   colors        An array of colour values for the gradient to cycle through
	 * @param   destX         The X offset the gradient is drawn at (default 0)
	 * @param   destY         The Y offset the gradient is drawn at (default 0)
	 * @param   chunkSize     If you want a more old-skool looking chunky gradient, increase this value!
	 * @param   rotation      Angle of the gradient in degrees. 90 = top to bottom, 180 = left to right. Any angle is valid
	 * @param   interpolate   Interpolate the colours? True uses RGB interpolation, false uses linear RGB
	 * @return  The composited FlxSprite (for chaining, if you need)
	 */
	public static function overlayGradientOnFlxSprite(dest:FlxSprite, width:Int, height:Int, colors:Array<FlxColor>, destX:Int = 0, destY:Int = 0,
			chunkSize:UInt = 1, rotation:Int = 90, interpolate:Bool = true):FlxSprite
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
		source.destroy();
		return dest;
	}

	/**
	 * Creates a new gradient and overlays that on-top of the given BitmapData at the destX/destY coordinates (default 0,0)
	 * Use low alpha values in the colours to have the gradient overlay and not destroy the image below
	 *
	 * @param   dest          The BitmapData to overlay the gradient onto
	 * @param   width         The width of the FlxSprite (and therefore gradient)
	 * @param   height        The height of the FlxSprite (and therefore gradient)
	 * @param   colors        An array of colour values for the gradient to cycle through
	 * @param   destX         The X offset the gradient is drawn at (default 0)
	 * @param   destY         The Y offset the gradient is drawn at (default 0)
	 * @param   chunkSize     If you want a more old-skool looking chunky gradient, increase this value!
	 * @param   rotation      Angle of the gradient in degrees. 90 = top to bottom, 180 = left to right. Any angle is valid
	 * @param   interpolate   Interpolate the colours? True uses RGB interpolation, false uses linear RGB
	 * @return  The composited BitmapData
	 */
	public static function overlayGradientOnBitmapData(dest:BitmapData, width:Int, height:Int, colors:Array<FlxColor>, destX:Int = 0, destY:Int = 0,
			chunkSize:UInt = 1, rotation:Int = 90, interpolate:Bool = true):BitmapData
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
		source.dispose();
		return dest;
	}
}

typedef GradientMatrix =
{
	matrix:Matrix,
	alpha:Array<Float>,
	ratio:Array<Int>
}
