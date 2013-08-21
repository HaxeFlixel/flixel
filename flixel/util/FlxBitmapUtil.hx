package flixel.util;

import flash.display.BitmapData;

class FlxBitmapUtil
{
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
			
			var pixel1:UInt, pixel2:UInt;
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
							
							resultR = (diffR > 0) ? diffR : (256 + diffR);
							resultG = (diffG > 0) ? diffG : (256 + diffG);
							resultB = (diffB > 0) ? diffB : (256 + diffB);
							
							resultColor = (0xFF << 24 | resultR << 16 | resultG << 8 | resultB);
							result.setPixel32(i, j, resultColor);
							
							checkAlpha = false;
						}
						
						if (checkAlpha)
						{
							alpha1 = (pixel1 >> 24) & 0xff;
							alpha2 = (pixel2 >> 24) & 0xff;
							diffA = alpha1 - alpha2;
							resultAlpha = (diffA > 0) ? diffA : (256 + diffA);
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