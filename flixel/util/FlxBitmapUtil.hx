package flixel.util;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

class FlxBitmapUtil
{
	public static function merge(sourceBitmapData:BitmapData, sourceRect:Rectangle, destBitmapData:BitmapData, destPoint:Point, redMultiplier:Int, greenMultiplier:Int, blueMultiplier:Int, alphaMultiplier:Int):Void
	{
		#if flash
		destBitmapData.merge(sourceBitmapData, sourceRect, destPoint, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		#else
		if (	destPoint.x >= destBitmapData.width ||
				destPoint.y >= destBitmapData.height ||
				sourceRect.x >= sourceBitmapData.width ||
				sourceRect.y >= sourceBitmapData.height ||
				sourceRect.x + sourceRect.width <= 0 ||
				sourceRect.y + sourceRect.height <= 0)
		{
			return;
		}
		
		// need to cut off sourceRect if it too big...
		while (	sourceRect.x + sourceRect.width > sourceBitmapData.width ||
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
		
		var sourceColor:Int;
		var destColor:Int;
		
		var sourceRed:Int;
		var sourceGreen:Int;
		var sourceBlue:Int;
		var sourceAlpha:Int;
		
		var destRed:Int;
		var destGreen:Int;
		var destBlue:Int;
		var destAlpha:Int;
		
		var resultRed:Int;
		var resultGreen:Int;
		var resultBlue:Int;
		var resultAlpha:Int;
		
		var resultColor:Int = 0x0;
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
				
				// get color components
				sourceRed = FlxColorUtil.getRed(sourceColor);
				sourceGreen = FlxColorUtil.getGreen(sourceColor);
				sourceBlue = FlxColorUtil.getBlue(sourceColor);
				sourceAlpha = FlxColorUtil.getAlpha(sourceColor);
				
				destRed = FlxColorUtil.getRed(destColor);
				destGreen = FlxColorUtil.getGreen(destColor);
				destBlue = FlxColorUtil.getBlue(destColor);
				destAlpha = FlxColorUtil.getAlpha(destColor);
				
				// calculate merged color components
				resultRed = mergeColorComponent(sourceRed, destRed, redMultiplier);
				resultGreen = mergeColorComponent(sourceGreen, destGreen, greenMultiplier);
				resultBlue = mergeColorComponent(sourceBlue, destBlue, blueMultiplier);
				resultAlpha = mergeColorComponent(sourceAlpha, destAlpha, alphaMultiplier);
				
				// calculate merged color
				resultColor = FlxColorUtil.getColor32(resultAlpha, resultRed, resultGreen, resultBlue);
				
				// set merged color for current pixel
				destBitmapData.setPixel32(currX, currY, resultColor);
			}
		}
		destBitmapData.unlock();
		#end
	}
	
	inline private static function mergeColorComponent(source:Int, dest:Int, multiplier:Int):Int
	{
		return Std.int(((source * multiplier) + (dest * (256 - multiplier))) / 256);
	}
	
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
			var resultAlpha:Int, resultColor:Int;
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
}