package flixel.util;

#if !flash
typedef FlxBitmapData = flash.display.BitmapData;
#else
import openfl.Vector;
import flash.Vector;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DTextureFormat;
import openfl.geom.Matrix;
import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import openfl.display.IBitmapDrawable;
import openfl.display3D.textures.Texture;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

// TODO: hack in openfl and lime asset management system to create FlxBitmapData objects (not just BitmapData)...

/**
 * I need this class for flash target with stage3D support
 * @author Zaphod
 */
class FlxBitmapData extends BitmapData
{
	private var _texture:Texture;
	
	private var _dirty:Bool = true;
	
	public function new(width:Int, height:Int, transparent:Bool = true, fillColor:UInt = 0xFFFFFFFF) 
	{
		super(width, height, transparent, fillColor);
	}
	
	override public function dispose():Void 
	{
		if (_texture != null)
		{
			_texture.dispose();
			_texture = null;
		}
		
		super.dispose();
	}
	
	override public function applyFilter(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter):Void 
	{
		super.applyFilter(sourceBitmapData, sourceRect, destPoint, filter);
		_dirty = true;
	}
	
	override public function colorTransform(rect:Rectangle, colorTransform:ColorTransform):Void 
	{
		super.colorTransform(rect, colorTransform);
		_dirty = true;
	}
	
	override public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Bool = false):Void 
	{
		super.copyPixels(sourceBitmapData, sourceRect, destPoint, alphaBitmapData, alphaPoint, mergeAlpha);
		_dirty = true;
	}
	
	override public function draw(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null, clipRect:Rectangle = null, smoothing:Bool = false):Void 
	{
		super.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
		_dirty = true;
	}
	
	override public function drawWithQuality(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null, clipRect:Rectangle = null, smoothing:Bool = false, quality:StageQuality = null):Void 
	{
		super.drawWithQuality(source, matrix, colorTransform, blendMode, clipRect, smoothing, quality);
		_dirty = true;
	}
	
	override public function fillRect(rect:Rectangle, color:Int):Void 
	{
		super.fillRect(rect, color);
		_dirty = true;
	}
	
	override public function floodFill(x:Int, y:Int, color:Int):Void 
	{
		super.floodFill(x, y, color);
		_dirty = true;
	}
	
	override public function merge(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, redMultiplier:UInt, greenMultiplier:UInt, blueMultiplier:UInt, alphaMultiplier:UInt):Void 
	{
		super.merge(sourceBitmapData, sourceRect, destPoint, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		_dirty = true;
	}
	
	override public function noise(randomSeed:Int, low:Int = 0, high:Int = 255, channelOptions:Int = 7, grayScale:Bool = false):Void 
	{
		super.noise(randomSeed, low, high, channelOptions, grayScale);
		_dirty = true;
	}
	
	override public function paletteMap(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, redArray:Array<Int> = null, greenArray:Array<Int> = null, blueArray:Array<Int> = null, alphaArray:Array<Int> = null):Void 
	{
		super.paletteMap(sourceBitmapData, sourceRect, destPoint, redArray, greenArray, blueArray, alphaArray);
		_dirty = true;
	}
	
	override public function perlinNoise(baseX:Float, baseY:Float, numOctaves:UInt, randomSeed:Int, stitch:Bool, fractalNoise:Bool, channelOptions:UInt = 7, grayScale:Bool = false, offsets:Array<Point> = null):Void 
	{
		super.perlinNoise(baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, grayScale, offsets);
		_dirty = true;
	}
	
	override public function pixelDissolve(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, randomSeed:Int = 0, numPixels:Int = 0, fillColor:UInt = 0):Int
	{
		_dirty = true;
		return super.pixelDissolve(sourceBitmapData, sourceRect, destPoint, randomSeed, numPixels, fillColor);
	}
	
	override public function scroll(x:Int, y:Int):Void 
	{
		super.scroll(x, y);
		_dirty = true;
	}
	
	override public function setPixel(x:Int, y:Int, color:Int):Void 
	{
		super.setPixel(x, y, color);
		_dirty = true;
	}
	
	override public function setPixel32(x:Int, y:Int, color:Int):Void 
	{
		super.setPixel32(x, y, color);
		_dirty = true;
	}
	
	override public function setPixels(rect:Rectangle, byteArray:ByteArray):Void 
	{
		super.setPixels(rect, byteArray);
		_dirty = true;
	}
	
	override public function setVector(rect:Rectangle, inputVector:Vector<UInt>) 
	{
		super.setVector(rect, inputVector);
		_dirty = true;
	}
	
	override public function clone():FlxBitmapData 
	{
		var result:FlxBitmapData = new FlxBitmapData(width, height, transparent);
		result.copyPixels(this, this.rect, new Point(), null, null, true);
		return result;
	}
	
	public function getTexture(context:Context3D, generateMipmaps:Bool = true):Texture
	{
		if (_dirty)
		{
			if (_texture != null)
			{
				_texture.dispose();
			}
			
			var textureBD:BitmapData = fixTextureSize(this);
			
			var textureWidth:Int = textureBD.width;
			var textureHeight:Int = textureBD.height;
			
			_texture = context.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, false);
			_texture.uploadFromBitmapData(this);
			
			if (generateMipmaps) // generate mipmaps
			{
				var level:Int = 1;
				var canvas:BitmapData = new BitmapData(textureWidth >> 1, textureHeight >> 1, true, 0);
				var transform:Matrix = new Matrix(0.5, 0, 0, 0.5);
				
				while (textureWidth >= 2 && textureHeight >= 2) //should that be an OR?
				{
					textureWidth = textureWidth >> 1;
					textureHeight = textureHeight >> 1;
					canvas.fillRect(canvas.rect, 0);
					canvas.draw(textureBD, transform, null, null, null, true);
					_texture.uploadFromBitmapData(canvas, level++);
					transform.scale(0.5, 0.5); 
				}
				
				canvas.dispose();
			}
			
			if (textureBD != this)
			{
				textureBD.dispose();
			}
		}
		
		_dirty = false;
		return _texture;
	}
	
	private static function fixTextureSize(texture:BitmapData):BitmapData
	{
		return if (powOfTwo(texture.width) == texture.width && powOfTwo(texture.height) == texture.height && texture.width == texture.height)
		{
			texture;
		}
		else
		{
			var newWidth = powOfTwo(texture.width);
			var newHeight = powOfTwo(texture.height);
			var newSize = (newWidth > newHeight) ? newWidth : newHeight;
			var newTexture:BitmapData = new BitmapData(newSize, newSize, true, 0);
			newTexture.copyPixels(texture, texture.rect, new Point(), null, null, true);
			newTexture;
		}
	}
	
	// TODO: move it to FlxMath (since i use it in GLRenderHelper as well)...
	private static inline function powOfTwo(value:Int):Int
	{
		var n = 1;
		while (n < value) n <<= 1;
		return n;
	}
	
}
#end