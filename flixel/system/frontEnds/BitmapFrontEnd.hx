package flixel.system.frontEnds;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import flixel.FlxG;
import flixel.util.FlxColor;

class BitmapFrontEnd
{
	/**
	 * Internal storage system to prevent graphics from being used repeatedly in memory.
	 */
	public var _cache:Map<String, BitmapData>;
	public var _lastBitmapDataKey:String;
	
	public function new()
	{
		clearCache();
	}
	
	/**
	 * Check the local bitmap cache to see if a bitmap with this key has been loaded already.
	 * 
	 * @param	Key		The string key identifying the bitmap.
	 * @return	Whether or not this file can be found in the cache.
	 */
	public function checkCache(Key:String):Bool
	{
		return (_cache.exists(Key) && _cache.get(Key) != null);
	}
		
	/**
	 * Generates a new <code>BitmapData</code> object (a colored square) and caches it.
	 * 
	 * @param	Width	How wide the square should be.
	 * @param	Height	How high the square should be.
	 * @param	Color	What color the square should be (0xAARRGGBB)
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key		Force the cache to use a specific Key to index the bitmap.
	 * @return	The <code>BitmapData</code> we just created.
	 */
	public function create(Width:Int, Height:Int, Color:Int, Unique:Bool = false, Key:String = null):BitmapData
	{
		var key:String = Key;
		if (key == null)
		{
			key = Width + "x" + Height + ":" + Color;
			if (Unique && checkCache(key))
			{
				key = getUniqueKey(key);
			}
		}
		if (!checkCache(key))
		{
			_cache.set(key, new BitmapData(Width, Height, true, Color));
		}
		_lastBitmapDataKey = key;
		return _cache.get(key);
	}
	
	/**
	 * Loads a bitmap from a file, caches it, and generates a horizontally flipped version if necessary.
	 * 
	 * @param	Graphic		The image file that you want to load.
	 * @param	Reverse		Whether to generate a flipped version.
	 * @param	Unique		Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key			Force the cache to use a specific Key to index the bitmap.
	 * @param	FrameWidth
	 * @param	FrameHeight
	 * @param 	SpacingX
	 * @param 	SpacingY
	 * @return	The <code>BitmapData</code> we just created.
	 */
	public function add(Graphic:Dynamic, Reverse:Bool = false, Unique:Bool = false, Key:String = null, FrameWidth:Int = 0, FrameHeight:Int = 0, SpacingX:Int = 1, SpacingY:Int = 1):BitmapData
	{
		if (Graphic == null)
		{
			return null;
		}
		
		var isClass:Bool = true;
		var isBitmap:Bool = true;
		if (Std.is(Graphic, Class))
		{
			isClass = true;
			isBitmap = false;
		}
		else if (Std.is(Graphic, BitmapData))
		{
			isClass = false;
			isBitmap = true;
		}
		else if (Std.is(Graphic, String))
		{
			isClass = false;
			isBitmap = false;
		}
		else
		{
			return null;
		}
		
		var additionalKey:String = "";
		#if !flash
		if (FrameWidth != 0 || FrameHeight != 0 || SpacingX != 1 || SpacingY != 1)
		{
			additionalKey = "FrameSize:" + FrameWidth + "_" + FrameHeight + "_Spacing:" + SpacingX + "_" + SpacingY;
		}
		#end
		
		var key:String = Key;
		if (key == null)
		{
			if (isClass)
			{
				key = Type.getClassName(cast(Graphic, Class<Dynamic>));
			}
			else if (isBitmap)
			{
				if (!Unique)
				{
					key = getCacheKeyFor(cast Graphic);
					if (key == null)
					{
						key = getUniqueKey();
					}
				}
			}
			else
			{
				key = Graphic;
			}
			key += (Reverse ? "_REVERSE_" : "");
			key += additionalKey;
			
			if (Unique)
			{
				key = getUniqueKey((key == null) ? "pixels" : key);
			}
		}
		
		var tempBitmap:BitmapData;
		
		// If there is no data for this key, generate the requested graphic
		if (!checkCache(key))
		{
			var bd:BitmapData = null;
			if (isClass)
			{
				bd = Type.createInstance(cast(Graphic, Class<Dynamic>), []).bitmapData;
			}
			else if (isBitmap)
			{
				bd = cast Graphic;
			}
			else
			{
				bd = FlxAssets.getBitmapData(Graphic);
			}
			
			#if !flash
			if (additionalKey != "")
			{
				var numHorizontalFrames:Int = (FrameWidth == 0) ? 1 : Std.int(bd.width / FrameWidth);
				var numVerticalFrames:Int = (FrameHeight == 0) ? 1 : Std.int(bd.height / FrameHeight);
				
				FrameWidth = (FrameWidth == 0) ? bd.width : FrameWidth;
				FrameHeight = (FrameHeight == 0) ? bd.height : FrameHeight;
				
				var tempBitmap:BitmapData = new BitmapData(bd.width + numHorizontalFrames * SpacingX, bd.height + numVerticalFrames * SpacingY, true, FlxColor.TRANSPARENT);
				
				var tempRect:Rectangle = new Rectangle(0, 0, FrameWidth, FrameHeight);
				var tempPoint:Point = new Point();
				
				for (i in 0...(numHorizontalFrames))
				{
					tempPoint.x = i * (FrameWidth + SpacingX);
					tempRect.x = i * FrameWidth;
					
					for (j in 0...(numVerticalFrames))
					{
						tempPoint.y = j * (FrameHeight + SpacingY);
						tempRect.y = j * FrameHeight;
						tempBitmap.copyPixels(bd, tempRect, tempPoint);
					}
				}
				
				bd = tempBitmap;
			}
			#else
			if (Reverse)
			{
				var newPixels:BitmapData = new BitmapData(bd.width * 2, bd.height, true, 0x00000000);
				newPixels.draw(bd);
				var mtx:Matrix = new Matrix();
				mtx.scale( -1, 1);
				mtx.translate(newPixels.width, 0);
				newPixels.draw(bd, mtx);
				bd = newPixels;
				
			}
			#end
			else if (Unique)	
			{
				bd = bd.clone();
			}
			
			_cache.set(key, bd);
		}
		
		_lastBitmapDataKey = key;
		return _cache.get(key);
	}
	
	/**
	 * Helper method for loading and modifying tilesheets for tilemaps and tileblocks. It should help resolve tilemap tearing issue for native targets
	 * 
	 * @param	Graphic		The image file that you want to load.
	 * @param	Reverse		Whether to generate a flipped version.
	 * @param	Unique		Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key			Force the cache to use a specific Key to index the bitmap.
	 * @param	FrameWidth
	 * @param	FrameHeight
	 * @param	RepeatX
	 * @param	RepeatY
	 * @return
	 */
	public function addTilemap(Graphic:Dynamic, Reverse:Bool = false, Unique:Bool = false, Key:String = null, FrameWidth:Int = 0, FrameHeight:Int = 0, RepeatX:Int = 1, RepeatY:Int = 1):BitmapData
	{
		var bitmap:BitmapData = FlxG.bitmap.add(Graphic, Reverse, Unique, Key, FrameWidth, FrameHeight, RepeatX + 1, RepeatY + 1);
		
		// Now modify tilemap image - insert repeatable pixels
		var extendedFrameWidth:Int = FrameWidth + RepeatX + 1;
		var extendedFrameHeight:Int = FrameHeight + RepeatY + 1;
		var numCols:Int = Std.int(bitmap.width / extendedFrameWidth);
		var numRows:Int = Std.int(bitmap.height / extendedFrameHeight);
		var tempRect:Rectangle = new Rectangle();
		var tempPoint:Point = new Point();
		var pixelColor:Int;
		
		tempRect.y = 0;
		tempRect.width = 1;
		tempRect.height = bitmap.height;
		tempPoint.y = 0;
		for (i in 0...numCols)
		{
			var tempX:Int = i * extendedFrameWidth + FrameWidth;
			tempRect.x = tempX - 1;
			
			for (j in 0...RepeatX)
			{
				tempPoint.x = tempX + j;
				bitmap.copyPixels(bitmap, tempRect, tempPoint);
			}
		}
		
		tempRect.x = 0;
		tempRect.width = bitmap.width;
		tempRect.height = 1;
		tempPoint.x = 0;
		for (i in 0...numRows)
		{
			var tempY:Int = i * extendedFrameHeight + FrameHeight;
			tempRect.y = tempY - 1;
			
			for (j in 0...RepeatY)
			{
				tempPoint.y = tempY + j;
				bitmap.copyPixels(bitmap, tempRect, tempPoint);
			}
		}
		
		return bitmap;
	}
	
	/**
	 * Gets key from bitmap cache for specified bitmapdata
	 * 
	 * @param	bmd	bitmapdata to find in cache
	 * @return	bitmapdata's key or null if there isn't such bitmapdata in cache
	 */
	public function getCacheKeyFor(bmd:BitmapData):String
	{
		for (key in _cache.keys())
		{
			var data:BitmapData = _cache.get(key);
			if (data == bmd)
			{
				return key;
			}
		}
		return null;
	}
	
	/**
	 * Gets unique key for bitmap cache
	 * 
	 * @param	baseKey	key's prefix
	 * @return	unique key
	 */
	public function getUniqueKey(baseKey:String = "pixels"):String
	{
		if (checkCache(baseKey))
		{
			var inc:Int = 0;
			var ukey:String;
			do
			{
				ukey = baseKey + inc++;
			} while(checkCache(ukey));
			baseKey = ukey;
		}
		return baseKey;
	}
	
	private function fromAssetsCache(bmd:BitmapData):Bool
	{
		var cachedBitmapData:Map<String, BitmapData> = Assets.cachedBitmapData;
		if (cachedBitmapData != null)
		{
			for (key in cachedBitmapData.keys())
			{
				var cacheBmd:BitmapData = cachedBitmapData.get(key);
				if (cacheBmd == bmd)
				{
					return true;
				}
			}
		}
		return false;
	}
	
	/**
	 * Removes bitmapdata from cache
	 * 
	 * @param	Graphic	bitmapdata's key to remove
	 */
	public function remove(Graphic:String):Void
	{
		if (_cache.exists(Graphic))
		{
			var bmd:BitmapData = _cache.get(Graphic);
			_cache.remove(Graphic);
			if (fromAssetsCache(bmd) == false)
			{
				bmd.dispose();
				bmd = null;
			}
		}
	}
	
	/**
	 * Dumps the cache's image references.
	 */
	public function clearCache():Void
	{
		var bmd:BitmapData;
		if (_cache != null)
		{
			for (key in _cache.keys())
			{
				bmd = _cache.get(key);
				_cache.remove(key);
				if (bmd != null && fromAssetsCache(bmd) == false)
				{
					bmd.dispose();
					bmd = null;
				}
			}
		}
		_cache = new Map();
	}
	
	/**
	 * Clears flash.Assests.cachedBitmapData. Use it only when you need it and know what are you doing.
	 */
	public function clearAssetsCache():Void
	{
		for (key in Assets.cachedBitmapData.keys())
		{
			var bmd:BitmapData = Assets.cachedBitmapData.get(key);
			bmd.dispose();
			Assets.cachedBitmapData.remove(key);
		}
	}
}