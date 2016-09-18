package flixel.util;

#if flash
import flash.Vector;
#else
import openfl.Vector;
#end

import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.geom.Matrix;
import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import openfl.display.IBitmapDrawable;
import openfl.display3D.textures.Texture;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

// TODO: implement it...
// TODO: hack in openfl and lime asset management system to create FlxBitmapData objects (not just BitmapData)...

/**
 * I need this class for flash target with stage3D support
 * @author Zaphod
 */
class FlxBitmapData extends BitmapData
{
	public var texture(get, null):Texture;
	
	private var _dirty:Bool = true;
	
	public function new(width:Int, height:Int, transparent:Bool = true, fillColor:UInt = 0xFFFFFFFF) 
	{
		super(width, height, transparent, fillColor);
	}
	
	override public function dispose():Void 
	{
		if (texture != null)
		{
			texture.dispose();
			texture = null;
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
	
	#if flash
	override public function pixelDissolve(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, randomSeed:Int = 0, numPixels:Int = 0, fillColor:UInt = 0):Int
	{
		_dirty = true;
		return super.pixelDissolve(sourceBitmapData, sourceRect, destPoint, randomSeed, numPixels, fillColor);
	}
	#end
	
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
		#if flash
		var result:FlxBitmapData = new FlxBitmapData(width, height, transparent);
		result.copyPixels(this, this.rect, new Point(0, 0));
		return result;
		#else
		if (!__isValid) 
		{
			return new FlxBitmapData(width, height, transparent);	
		}
		
		if (image == null || image.buffer == null) 
		{
			return null;
		}
		
		var bitmapData:FlxBitmapData = new FlxBitmapData(0, 0, transparent);
		bitmapData.__fromImage(image);
		bitmapData.image.transparent = transparent;
		return bitmapData;
		#end
	}
	
	// TODO: implement it...
	private function get_texture():Texture
	{
		if (_dirty)
		{
			
		}
		
		#if FLX_RENDER_GL
	//	this.getTexture()
		#end
		
		_dirty = false;
		return null;
	}
	
}