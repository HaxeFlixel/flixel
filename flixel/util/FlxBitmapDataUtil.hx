package flixel.util;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.math.FlxAngle;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import openfl.geom.Matrix;

/**
 * Just a collection of BitmapData utility methods.
 * Just for crossplatform stuff, since not all methods are implemented across all targets.
 */
class FlxBitmapDataUtil
{
	/**
	 * Performs per-channel blending from a source image to a destination image.
	 * 
	 * @param	sourceBitmapData	The input bitmap image to use. The source image can be a different BitmapData object, or it can refer to the current BitmapData object.
	 * @param	sourceRect			A rectangle that defines the area of the source image to use as input. 
	 * @param	destBitmapData		The output bitmap image to use.
	 * @param	destPoint			The point within the destination image (the current BitmapData instance) that corresponds to the upper-left corner of the source rectangle.
	 * @param	redMultiplier		A hexadecimal uint value by which to multiply the red channel value.
	 * @param	greenMultiplier		A hexadecimal uint value by which to multiply the green channel value.
	 * @param	blueMultiplier		A hexadecimal uint value by which to multiply the blue channel value.
	 * @param	alphaMultiplier		A hexadecimal uint value by which to multiply the alpha transparency value. 
	 */
	public static function merge(sourceBitmapData:BitmapData, sourceRect:Rectangle, destBitmapData:BitmapData, destPoint:Point, redMultiplier:Int, greenMultiplier:Int, blueMultiplier:Int, alphaMultiplier:Int):Void
	{
		#if flash
		destBitmapData.merge(sourceBitmapData, sourceRect, destPoint, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		#else
		if (destPoint.x >= destBitmapData.width ||
		    destPoint.y >= destBitmapData.height ||
		    sourceRect.x >= sourceBitmapData.width ||
		    sourceRect.y >= sourceBitmapData.height ||
		    sourceRect.x + sourceRect.width <= 0 ||
		    sourceRect.y + sourceRect.height <= 0)
		{
			return;
		}
		
		// need to cut off sourceRect if it too big...
		while (sourceRect.x + sourceRect.width > sourceBitmapData.width ||
		       sourceRect.y + sourceRect.height > sourceBitmapData.height ||
		       sourceRect.x < 0 ||
		       sourceRect.y < 0 ||
		       destPoint.x < 0 ||
		       destPoint.y < 0 )
		{
			if (sourceRect.x + sourceRect.width > sourceBitmapData.width)	sourceRect.width = sourceBitmapData.width - sourceRect.x;
			if (sourceRect.y + sourceRect.height > sourceBitmapData.height)	sourceRect.height = sourceBitmapData.height - sourceRect.y;
			
			if (sourceRect.x < 0)	
			{
				destPoint.x = destPoint.x - sourceRect.x;
				sourceRect.width = sourceRect.width + sourceRect.x;
				sourceRect.x = 0;
			}
			
			if (sourceRect.y < 0)	
			{
				destPoint.y = destPoint.y - sourceRect.y;
				sourceRect.height = sourceRect.height + sourceRect.y;
				sourceRect.y = 0;
			}
			
			if (destPoint.x >= destBitmapData.width || destPoint.y >= destBitmapData.height)	return;
			
			if (destPoint.x < 0)
			{
				sourceRect.x = sourceRect.x - destPoint.x;
				sourceRect.width = sourceRect.width + destPoint.x;
				destPoint.x = 0;
			}
			
			if (destPoint.y < 0)
			{
				sourceRect.y = sourceRect.y - destPoint.y;
				sourceRect.height = sourceRect.height + destPoint.y;
				destPoint.y = 0;
			}
		}
		
		if (sourceRect.width <= 0 || sourceRect.height <= 0) return;
		
		var startSourceX:Int = Math.round(sourceRect.x);
		var startSourceY:Int = Math.round(sourceRect.y); 
		
		var width:Int = Math.round(sourceRect.width);
		var height:Int = Math.round(sourceRect.height); 
		
		var sourceX:Int = startSourceX;
		var sourceY:Int = startSourceY;
		
		var destX:Int = Math.round(destPoint.x);
		var destY:Int = Math.round(destPoint.y);
		
		var currX:Int = destX;
		var currY:Int = destY;
		
		var sourceColor:FlxColor;
		var destColor:FlxColor;
		
		var resultRed:Int;
		var resultGreen:Int;
		var resultBlue:Int;
		var resultAlpha:Int;
		
		var resultColor:FlxColor = 0x0;
		destBitmapData.lock();
		// iterate througn pixels using following rule:
		// new redDest = [(redSrc * redMultiplier) + (redDest * (256 - redMultiplier))] / 256; 
		for (i in 0...width)
		{
			for (j in 0...height)
			{
				sourceX = startSourceX + i;
				sourceY = startSourceY + j;
				
				currX = destX + i;
				currY = destY + j;
				
				sourceColor = sourceBitmapData.getPixel32(sourceX, sourceY);
				destColor = destBitmapData.getPixel32(currX, currY);
				
				// calculate merged color components
				resultRed = mergeColorComponent(sourceColor.red, destColor.red, redMultiplier);
				resultGreen = mergeColorComponent(sourceColor.green, destColor.green, greenMultiplier);
				resultBlue = mergeColorComponent(sourceColor.blue, destColor.blue, blueMultiplier);
				resultAlpha = mergeColorComponent(sourceColor.alpha, destColor.alpha, alphaMultiplier);
				
				// calculate merged color
				resultColor = FlxColor.fromRGB(resultRed, resultGreen, resultBlue, resultAlpha);
				
				// set merged color for current pixel
				destBitmapData.setPixel32(currX, currY, resultColor);
			}
		}
		destBitmapData.unlock();
		#end
	}
	
	private static inline function mergeColorComponent(source:Int, dest:Int, multiplier:Int):Int
	{
		return Std.int(((source * multiplier) + (dest * (256 - multiplier))) / 256);
	}
	
	/**
	 * Compares two BitmapData objects.
	 * 
	 * @param	Bitmap1		The source BitmapData object to compare with.
	 * @param	Bitmap2		The BitmapData object to compare with the source BitmapData object.
	 * @return	If the two BitmapData objects have the same dimensions (width and height), 
	 * the method returns a new BitmapData object that has the difference between the two objects. 
	 * If the BitmapData objects are equivalent, the method returns the number 0.
	 * If the widths of the BitmapData objects are not equal, the method returns the number -3. 
	 * If the heights of the BitmapData objects are not equal, the method returns the number -4.
	 */
	public static function compare(Bitmap1:BitmapData,  Bitmap2:BitmapData):Dynamic
	{
		#if flash
		return Bitmap1.compare(Bitmap2);
		#else
		if (Bitmap1 == Bitmap2)
		{
			return 0;
		}
		if (Bitmap1.width != Bitmap2.width)
		{
			return -3;
		}
		else if (Bitmap1.height != Bitmap2.height)
		{
			return -4;
		}
		else
		{
			var width:Int = Bitmap1.width;
			var height:Int = Bitmap1.height;
			var result:BitmapData = new BitmapData(width, height, true, 0x0);
			var identical:Bool = true;
			
			var pixel1:Int, pixel2:Int;
			var rgb1:Int, rgb2:Int;
			var r1:Int, g1:Int, b1:Int;
			var r2:Int, g2:Int, b2:Int;
			var alpha1:Int, alpha2:Int;
			var resultAlpha:Int, resultColor:FlxColor;
			var resultR:Int, resultG:Int, resultB:Int;
			var diffR:Int, diffG:Int, diffB:Int, diffA:Int;
			var checkAlpha:Bool = true;
			
			for (i in 0...width)
			{
				for (j in 0...height)
				{
					pixel1 = Bitmap1.getPixel32(i, j);
					pixel2 = Bitmap2.getPixel32(i, j);
					
					if (pixel1 != pixel2)
					{
						identical = false;
						checkAlpha = true;
						
						rgb1 = pixel1 & 0x00ffffff;
						rgb2 = pixel2 & 0x00ffffff;
						
						if (rgb1 != rgb2)
						{
							r1 = pixel1 >> 16 & 0xFF;
							g1 = pixel1 >> 8 & 0xFF;
							b1 = pixel1 & 0xFF;
							
							r2 = pixel2 >> 16 & 0xFF;
							g2 = pixel2 >> 8 & 0xFF;
							b2 = pixel2 & 0xFF;
							
							diffR = r1 - r2;
							diffG = g1 - g2;
							diffB = b1 - b2;
							
							resultR = (diffR >= 0) ? diffR : (256 + diffR);
							resultG = (diffG >= 0) ? diffG : (256 + diffG);
							resultB = (diffB >= 0) ? diffB : (256 + diffB);
							
							resultColor = (0xFF << 24 | resultR << 16 | resultG << 8 | resultB);
							result.setPixel32(i, j, resultColor);
							
							checkAlpha = false;
						}
						
						if (checkAlpha)
						{
							alpha1 = (pixel1 >> 24) & 0xff;
							alpha2 = (pixel2 >> 24) & 0xff;
							diffA = alpha1 - alpha2;
							resultAlpha = (diffA >= 0) ? diffA : (256 + diffA);
							resultColor = (resultAlpha | 0xFF << 16 | 0xFF << 8 | 0xFF);
							
							if (alpha1 != alpha2)
							{
								result.setPixel32(i, j, resultColor);
							}
						}	
					}
				}
			}
			
			if (!identical)
			{
				return result;
			}
		}
		
		return 0;
		#end
	}
	
	/**
	 * Returns the amount of bytes a bitmapData occupies in memory.
	 */
	public static inline function getMemorySize(bitmapData:BitmapData):Float
	{
		return bitmapData.width * bitmapData.height * 4;
	}
	
	/**
	 * Replaces all bitmapData's pixels with specified color with newColor pixels. 
	 * WARNING: very expensive (especially on big graphics) as it iterates over every single pixel.
	 * 
	 * @param	bitmapData			BitmapData to change
	 * @param	color				Color to replace
	 * @param	newColor			New color
	 * @param	fetchPositions		Whether we need to store positions of pixels which colors were replaced
	 * @param	rect				area to apply color replacement. Optional, uses whole image area if the rect is null
	 * @return	Array replaced pixels positions
	 */
	public static function replaceColor(bitmapData:BitmapData, color:FlxColor, newColor:FlxColor, fetchPositions:Bool = false, rect:FlxRect = null):Array<FlxPoint>
	{
		var positions:Array<FlxPoint> = null;
		if (fetchPositions)
		{
			positions = new Array<FlxPoint>();
		}
		
		var startX:Int = 0;
		var startY:Int = 0;
		var columns:Int = bitmapData.width;
		var rows:Int = bitmapData.height;
		
		if (rect != null)
		{
			startX = Std.int(rect.x);
			startY = Std.int(rect.y);
			columns = Std.int(rect.width);
			rows = Std.int(rect.height);
		}
		
		columns = Std.int(Math.max(columns, bitmapData.width));
		rows = Std.int(Math.max(rows, bitmapData.height));
		
		var row:Int = 0;
		var column:Int = 0;
		var x:Int, y:Int;
		
		var changed:Bool = false;
		bitmapData.lock();
		while (row < rows)
		{
			column = 0;
			while (column < columns)
			{
				x = startX + column;
				y = startY + row;
				if (bitmapData.getPixel32(x, y) == cast color)
				{
					bitmapData.setPixel32(x, y, newColor);
					changed = true;
					if (fetchPositions)
					{
						positions.push(FlxPoint.get(x, y));
					}
				}
				column++;
			}
			row++;
		}
		bitmapData.unlock();
		
		if (changed && positions == null)
		{
			positions = new Array<FlxPoint>();
		}
		
		return positions;
	}
	
	/**
	 * Gets image without spaces between tiles and generates new one with spaces and adds borders around them.
	 * @param	bitmapData	original image without spaces between tiles.
	 * @param	frameSize	the size of tile in spritesheet.
	 * @param	spacing		spaces between tiles to add.
	 * @param	border		how many times to copy border of tiles.
	 * @param	region		region of image to use as a source graphics for spritesheet. Default value is null, which means that whole image will be used.
	 * @return	Image for spritesheet with inserted spaces between tiles.
	 */
	public static function addSpacesAndBorders(bitmapData:BitmapData, frameSize:FlxPoint = null, spacing:FlxPoint = null, border:FlxPoint = null, region:FlxRect = null):BitmapData
	{
		if (region == null)
		{
			region = new FlxRect(0, 0, bitmapData.width, bitmapData.height);
		}
		
		var frameWidth:Int = Std.int(region.width);
		var frameHeight:Int = Std.int(region.height);
		
		if (frameSize != null)
		{
			frameWidth = Std.int(frameSize.x);
			frameHeight = Std.int(frameSize.y);
		}
		
		var numHorizontalFrames:Int = Std.int(region.width / frameWidth);
		var numVerticalFrames:Int = Std.int(region.height / frameHeight);
		
		var spaceX:Int = 0;
		var spaceY:Int = 0;
		
		if (spacing != null)
		{
			spaceX = Std.int(spacing.x);
			spaceY = Std.int(spacing.y);
		}
		
		var borderX:Int = 0;
		var borderY:Int = 0;
		
		if (border != null)
		{
			borderX = Std.int(border.x);
			borderY = Std.int(border.y); 
		}
		
		var result:BitmapData = new BitmapData(
						Std.int(region.width + (numHorizontalFrames - 1) * spaceX + 2 * numHorizontalFrames * borderX), 
						Std.int(region.height + (numVerticalFrames - 1) * spaceY + 2 * numVerticalFrames * borderY), 
						true, 
						FlxColor.TRANSPARENT);
						
		result.lock();
		var tempRect:Rectangle = new Rectangle(0, 0, frameWidth, frameHeight);
		var tempPoint:Point = new Point();
		
		// insert spaces
		for (i in 0...(numHorizontalFrames))
		{
			tempPoint.x = i * (frameWidth + spaceX + 2 * borderX) + borderX;
			tempRect.x = i * frameWidth + region.x;
			
			for (j in 0...(numVerticalFrames))
			{
				tempPoint.y = j * (frameHeight + spaceY + 2 * borderY) + borderY;
				tempRect.y = j * frameHeight + region.y;
				result.copyPixels(bitmapData, tempRect, tempPoint);
			}
		}
		
		// copy borders
		tempPoint.setTo(0, 0);
		tempRect.setTo(0, 0, 1, result.height);
		for (i in 0...(numHorizontalFrames))
		{
			tempRect.x = i * (frameWidth + 2 * borderX + spaceX) + borderX;
			
			for (j in 0...borderX)
			{
				tempPoint.x = tempRect.x - j - 1;
				result.copyPixels(result, tempRect, tempPoint);
			}
			
			tempRect.x += frameWidth - 1;
			
			for (j in 0...borderX)
			{
				tempPoint.x = tempRect.x + j + 1;
				result.copyPixels(result, tempRect, tempPoint);
			}
		}
		
		tempPoint.setTo(0, 0);
		tempRect.setTo(0, 0, result.width, 1);
		for (i in 0...(numVerticalFrames))
		{
			tempRect.y = i * (frameHeight + 2 * borderY + spaceY) + borderY;
			
			for (j in 0...borderY)
			{
				tempPoint.y = tempRect.y - j - 1;
				result.copyPixels(result, tempRect, tempPoint);
			}
			
			tempRect.y += frameHeight - 1;
			
			for (j in 0...borderY)
			{
				tempPoint.y = tempRect.y + j + 1;
				result.copyPixels(result, tempRect, tempPoint);
			}
		}
		
		result.unlock();
		return result;
	}
	
	/**
	 * Generates BitmapData with prerotated brush stamped on it
	 * 
	 * @param	brush			The image you want to rotate and stamp.
	 * @param	rotations		The number of rotation frames the final sprite should have. For small sprites this can be quite a large number (360 even) without any problems.
	 * @param	antiAliasing	Whether to use high quality rotations when creating the graphic.  Default is false.
	 * @param	autoBuffer		Whether to automatically increase the image size to accomodate rotated corners.  Default is false.  Will create frames that are 150% larger on each axis than the original frame or graphic.
	 * @return	Created BitmapData with stamped prerotations on it.
	 */
	public static function generateRotations(brush:BitmapData, rotations:Int = 16, antiAliasing:Bool = false, autoBuffer:Bool = false):BitmapData
	{
		var brushWidth:Int = brush.width;
		var brushHeight:Int = brush.height;
		var max:Int = (brushHeight > brushWidth) ? brushHeight : brushWidth;
		max = (autoBuffer) ? Std.int(max * 1.5) : max;
		
		var rows:Int = Std.int(Math.sqrt(rotations));
		var columns:Int = Math.ceil(rotations / rows);
		var bakedRotationAngle:Float = 360 / rotations;
		
		var width:Int = max * columns;
		var height:Int = max * rows;
		
		var result:BitmapData = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		
		var row:Int = 0;
		var column:Int = 0;
		var bakedAngle:Float = 0;
		var halfBrushWidth:Int = Std.int(brushWidth * 0.5);
		var halfBrushHeight:Int = Std.int(brushHeight * 0.5);
		var midpointX:Int = Std.int(max * 0.5);
		var midpointY:Int = Std.int(max * 0.5);
		
		var matrix:Matrix = FlxMatrix.matrix;
		
		while (row < rows)
		{
			column = 0;
			while (column < columns)
			{
				matrix.identity();
				matrix.translate( -halfBrushWidth, -halfBrushHeight);
				matrix.rotate(bakedAngle * FlxAngle.TO_RAD);
				matrix.translate(max * column + midpointX, midpointY);
				bakedAngle += bakedRotationAngle;
				result.draw(brush, matrix, null, null, null, antiAliasing);
				column++;
			}
			midpointY += max;
			row++;
		}
		
		return result;
	}
}