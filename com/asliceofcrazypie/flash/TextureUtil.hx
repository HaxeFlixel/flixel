package com.asliceofcrazypie.flash;

import flash.display3D.Context3D;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;

import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.geom.Point;

/**
 * ...
 * @author Zaphod
 */
class TextureUtil
{
	public static function uploadTexture(image:BitmapData, context:Context3D, mipmap:Bool = true):Texture
	{
		if (context != null)
		{
			var texture:Texture = context.createTexture(image.width, image.height, Context3DTextureFormat.BGRA, false);
			
			texture.uploadFromBitmapData(image);
			
			if (mipmap)
			{
				// generate mipmaps
				var currentWidth:Int = image.width;
				var currentHeight:Int = image.height;
				var level:Int = 1;
				var canvas:BitmapData = new BitmapData(currentWidth >> 1, currentHeight >> 1, true, 0);
				var transform:Matrix = new Matrix(0.5, 0, 0, 0.5);
				
				while (currentWidth >= 2 && currentHeight >= 2) //should that be an OR?
				{
					currentWidth = currentWidth >> 1;
					currentHeight = currentHeight >> 1;
					canvas.fillRect(canvas.rect, 0);
					canvas.draw(image, transform, null, null, null, true);
					texture.uploadFromBitmapData(canvas, level++);
					transform.scale(0.5, 0.5); 
				}
				
				canvas.dispose();
			}
			
			return texture;
		}
		
		return null;
	}
	
	//helper methods
	public static inline function roundUpToPow2(number:Int):Int
	{
		number--;
		number |= number >> 1;
		number |= number >> 2;
		number |= number >> 4;
		number |= number >> 8;
		number |= number >> 16;
		number++;
		return number;
	}
	
	public static inline function isTextureOk(texture:BitmapData):Bool
	{
		return (roundUpToPow2(texture.width) == texture.width && roundUpToPow2(texture.height) == texture.height);
	}
	
	public static inline function fixTextureSize(texture:BitmapData):BitmapData
	{
		return if (isTextureOk(texture))
		{
			texture;
		}
		else
		{
			var newTexture:BitmapData = new BitmapData(roundUpToPow2(texture.width), roundUpToPow2(texture.height), true, 0);
			newTexture.copyPixels(texture, texture.rect, new Point(), null, null, true);
			newTexture;
		}
	}
	
}