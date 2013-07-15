package flixel.system.frontEnds;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.system.layer.frames.FlxFrame;
import flixel.util.loaders.SpriteSheetRegion;
import openfl.Assets;
import flixel.FlxG;
import flixel.util.FlxColor;

import flixel.util.loaders.TexturePackerData;
import flixel.system.FlxAssets;
import flixel.system.layer.TileSheetExt;
import flixel.system.layer.TileSheetData;

class BitmapFrontEnd
{
	/**
	 * Internal storage system to prevent graphics from being used repeatedly in memory.
	 */
	private var _cache:Map<String, CachedGraphicsObject>;
	
	public function new()
	{
		clearCache();
	}
	
	#if !flash
	public var whitePixel(get, null):CachedGraphicsObject;
	
	private var _whitePixel:CachedGraphicsObject;
	
	private function get_whitePixel():CachedGraphicsObject
	{
		if (_whitePixel == null)
		{
			var bd:BitmapData = new BitmapData(2, 2, true, FlxColor.WHITE);
			_whitePixel = new CachedGraphicsObject("whitePixel", bd, true);
			_whitePixel.tilesheet.addTileRect(new Rectangle(0, 0, 1, 1), new Point(0, 0));
		}
		
		return _whitePixel;
	}
	
	public function onContext():Void
	{
		var obj:CachedGraphicsObject;
		
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
	
	public function dumpCache():Void
	{
		#if !(flash || js)
		var obj:CachedGraphicsObject;
		
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
	public function create(Width:Int, Height:Int, Color:Int, Unique:Bool = false, Key:String = null):CachedGraphicsObject
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
			_cache.set(key, new CachedGraphicsObject(key, new BitmapData(Width, Height, true, Color)));
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
	public function add(Graphic:Dynamic, Unique:Bool = false, Key:String = null):CachedGraphicsObject
	{
		if (Graphic == null)
		{
			return null;
		}
		else if (Std.is(Graphic, CachedGraphicsObject))
		{
			return cast Graphic;
		}
		
		var region:SpriteSheetRegion = null;
		
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
		else if (Std.is(Graphic, SpriteSheetRegion))
		{
			isClass = false;
			isBitmap = false;
			isRegion = true;
			
			region = cast(Graphic, SpriteSheetRegion);
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
				bd = Type.createInstance(cast(Graphic, Class<Dynamic>), []);
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
			
			var co:CachedGraphicsObject = new CachedGraphicsObject(key, bd);
			
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
	public function get(key:String):CachedGraphicsObject
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
			var obj:CachedGraphicsObject = _cache.get(key);
			_cache.remove(key);
			obj.destroy();
		}
	}
	
	/**
	 * Dumps the cache's image references.
	 */
	public function clearCache():Void
	{
		var newCache:Map<String, CachedGraphicsObject> = new Map();
		var obj:CachedGraphicsObject;
		
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

class CachedGraphicsObject
{
	/**
	 * Key in BitmapFrontEnd cache
	 */
	public var key:String;
	/**
	 * Cached BitmapData object
	 */
	public var bitmap:BitmapData;
	/**
	 * TexturePackerData associated with bitmapdata
	 */
	public var data:TexturePackerData;
	
	private var _tilesheet:TileSheetData;
	/**
	 * Whether this Cached object should stay in cache after state change or not.
	 */
	public var persist:Bool = false;
	/**
	 * Asset name from openfl.Assets
	 */
	public var assetsKey:String;
	/**
	 * Class name for bitmapdata
	 */
	public var assetsClass:Class<BitmapData>;
	
	/**
	 * Says if bitmapdata of this Cache object has been dumped or not
	 */
	public var isDumped(default, null):Bool = false;
	
	/**
	 * Says if bitmapdata of this Cache object can be dumped for less memory usage
	 */
	public var canBeDumped(get, null):Bool;
	
	public var tilesheet(get_tilesheet, null):TileSheetData;
	
	public function new(key:String, bitmap:BitmapData, persist:Bool = false)
	{
		this.key = key;
		this.bitmap = bitmap;
		this.persist = persist;
	}
	
	/**
	 * Dumps bits of bitmapdata = less memory, but you can't read / write pixels on it anymore 
	 * (but you can call onContext() method which will restore it again)
	 */
	public function dump():Void
	{
		#if !(flash || js)
		if (canBeDumped)
		{
			bitmap.dumpBits();
			bitmap = null;
			isDumped = true;
		}
		#end
	}
	
	// TODO: check this later
	public function undump():Void
	{
		#if !(flash || js)
		if (isDumped)
		{
			var newBitmap:BitmapData = getBitmapFromSystem();
			
			if (newBitmap != null)
			{
				bitmap = newBitmap;
				if (_tilesheet != null)
				{
					// regenerate tilesheet
					_tilesheet.onContext(newBitmap);
				}
			}
			
			isDumped = false;
		}
		#end
	}
	
	/**
	 * Use this method to restore cached bitmapdata (it it's possible).
	 * It's called automatically when RESIZE event occurs.
	 */
	public function onContext():Void
	{
		// no need to restore tilesheet if it haven't been dumped
		if (isDumped)
		{
			// restore everything
			undump();
			// and dump bitmapdata again
			dump();
		}
	}
	
	private function get_tilesheet():TileSheetData 
	{
		if (_tilesheet == null) 
		{
			if (isDumped)
				onContext();
			
			_tilesheet = new TileSheetData(bitmap);
		}
		
		return _tilesheet;
	}
	
	private function getBitmapFromSystem():BitmapData
	{
		var newBitmap:BitmapData = null;
		if (assetsClass != null)
		{
			newBitmap = Type.createInstance(cast(assetsClass, Class<Dynamic>), []);
		}
		else if (assetsKey != null)
		{
			newBitmap = FlxAssets.getBitmapData(assetsKey);
		}
		
		return newBitmap;
	}
	
	public function getRegionForFrame(frameName:String):SpriteSheetRegion
	{
		var region:SpriteSheetRegion = new SpriteSheetRegion(this);
		var frame:FlxFrame = tilesheet.getFrame(frameName);
		if (frame != null)
		{
			region.region.startX = Std.int(frame.frame.x);
			region.region.startY = Std.int(frame.frame.y);
			region.region.width = Std.int(frame.frame.width);
			region.region.height = Std.int(frame.frame.height);
		}
		
		return region;
	}
	
	public function destroy():Void
	{
		key = null;
		if (bitmap != null)
		{
			bitmap.dispose();
		}
		bitmap = null;
		if (data != null)
		{
			data.destroy();
		}
		data = null;
		if (_tilesheet != null)
		{
			_tilesheet.destroy();
		}
		_tilesheet = null;
		
		assetsKey = null;
		assetsClass = null;
	}
	
	private function get_canBeDumped():Bool
	{
		return (assetsClass != null || assetsKey != null);
	}
}