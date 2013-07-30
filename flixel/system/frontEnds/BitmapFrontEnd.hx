package flixel.system.frontEnds;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.loaders.CachedGraphics;
import flixel.util.loaders.TextureRegion;

class BitmapFrontEnd
{
	/**
	 * Internal storage system to prevent graphics from being used repeatedly in memory.
	 */
	private var _cache:Map<String, CachedGraphics>;
	
	public function new()
	{
		clearCache();
	}
	
	#if !flash
	public var whitePixel(get, null):CachedGraphics;
	
	private var _whitePixel:CachedGraphics;
	
	private function get_whitePixel():CachedGraphics
	{
		if (_whitePixel == null)
		{
			var bd:BitmapData = new BitmapData(2, 2, true, FlxColor.WHITE);
			_whitePixel = new CachedGraphics("whitePixel", bd, true);
			_whitePixel.tilesheet.addTileRect(new Rectangle(0, 0, 1, 1), new Point(0, 0));
		}
		
		return _whitePixel;
	}
	
	public function onContext():Void
	{
		var obj:CachedGraphics;
		
		if (_cache != null)
		{
			for (key in _cache.keys())
			{
				obj = _cache.get(key);
				if (obj != null && obj.isDumped)
				{
					obj.onContext();
				}
			}
		}
	}
	#end
	
	/**
	 * Dumps bits of all cached graphics. This restores memory, but you can't read / write pixels on those graphics anymore.
	 * You can call onContext() method for each CachedGraphic object which will restore it again.
	 */
	public function dumpCache():Void
	{
		#if !(flash || js)
		var obj:CachedGraphics;
		
		if (_cache != null)
		{
			for (key in _cache.keys())
			{
				obj = _cache.get(key);
				if (obj != null && obj.canBeDumped)
				{
					obj.dump();
				}
			}
		}
		#end
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
	public function create(Width:Int, Height:Int, Color:Int, Unique:Bool = false, Key:String = null):CachedGraphics
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
			_cache.set(key, new CachedGraphics(key, new BitmapData(Width, Height, true, Color)));
		}
		
		return _cache.get(key);
	}
	
	/**
	 * Loads a bitmap from a file, caches it, and generates a horizontally flipped version if necessary.
	 * 
	 * @param	Graphic		The image file that you want to load.
	 * @param	Unique		Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key			Force the cache to use a specific Key to index the bitmap.
	 * @return	The <code>BitmapData</code> we just created.
	 */
	public function add(Graphic:Dynamic, Unique:Bool = false, Key:String = null):CachedGraphics
	{
		if (Graphic == null)
		{
			return null;
		}
		else if (Std.is(Graphic, CachedGraphics))
		{
			return cast Graphic;
		}
		
		var region:TextureRegion = null;
		
		var isClass:Bool = true;
		var isBitmap:Bool = true;
		var isRegion:Bool = true;
		if (Std.is(Graphic, Class))
		{
			isClass = true;
			isBitmap = false;
			isRegion = false;
		}
		else if (Std.is(Graphic, BitmapData))
		{
			isClass = false;
			isBitmap = true;
			isRegion = false;
		}
		else if (Std.is(Graphic, TextureRegion))
		{
			isClass = false;
			isBitmap = false;
			isRegion = true;
			
			region = cast(Graphic, TextureRegion);
		}
		else if (Std.is(Graphic, String))
		{
			isClass = false;
			isBitmap = false;
			isRegion = false;
		}
		else
		{
			return null;
		}
		
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
			else if (isRegion)
			{
				key = region.data.key;
			}
			else
			{
				key = Graphic;
			}
			
			if (Unique)
			{
				key = getUniqueKey((key == null) ? "pixels" : key);
			}
		}
		
		// If there is no data for this key, generate the requested graphic
		if (!checkCache(key))
		{
			var bd:BitmapData = null;
			if (isClass)
			{
				bd = Type.createInstance(cast(Graphic, Class<Dynamic>), [0, 0]);
			}
			else if (isBitmap)
			{
				bd = cast Graphic;
			}
			else if (isRegion)
			{
				bd = region.data.bitmap;
			}
			else
			{
				bd = FlxAssets.getBitmapData(Graphic);
			}
			
			if (Unique)
			{
				bd = bd.clone();
			}
			
			var co:CachedGraphics = new CachedGraphics(key, bd);
			
			if (isClass && !Unique)
			{
				co.assetsClass = cast Graphic;
			}
			else if (!isClass && !isBitmap && !isRegion && !Unique)
			{
				co.assetsKey = cast Graphic;
			}
			
			_cache.set(key, co);
		}
		
		return _cache.get(key);
	}
	
	// TODO: document it
	public function get(key:String):CachedGraphics
	{
		return _cache.get(key);
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
			var data:BitmapData = _cache.get(key).bitmap;
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
	
	public function remove(key:String):Void
	{
		if (_cache.exists(key))
		{
			var obj:CachedGraphics = _cache.get(key);
			_cache.remove(key);
			obj.destroy();
		}
	}
	
	/**
	 * Dumps the cache's image references.
	 */
	public function clearCache():Void
	{
		var newCache:Map<String, CachedGraphics> = new Map();
		var obj:CachedGraphics;
		
		if (_cache != null)
		{
			for (key in _cache.keys())
			{
				obj = _cache.get(key);
				_cache.remove(key);
				
				if (!obj.persist)
				{
					if (obj != null)
					{
						obj.destroy();
						obj = null;
					}
				}
				else
				{
					newCache.set(key, obj);
				}
			}
		}
		
		_cache = newCache;
	}
}