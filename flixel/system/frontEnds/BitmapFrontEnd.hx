package flixel.system.frontEnds;

import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import openfl.Assets;

#if !flash
import openfl.gl.GL;
#end

/**
 * Internal storage system to prevent graphics from being used repeatedly in memory.
 */
class BitmapFrontEnd
{
	#if !flash
	/**
	 * Gets max texture size for native targets
	 */
	public var maxTextureSize(get, never):Int;
	#end

	/**
	 * Helper FlxFrame object. Containing only one frame.
	 * Useful for drawing colored rectangles of all sizes in FlxG.renderTile mode.
	 */
	public var whitePixel(get, never):FlxFrame;

	@:allow(flixel.system.frontEnds.BitmapLogFrontEnd)
	private var _cache:Map<String, FlxGraphic>;
	
	private var _whitePixel:FlxFrame;

	private var _lastUniqueKeyIndex:Int = 0;

	public function new()
	{
		clearCache();
	}
	
	public function onAssetsReload(_):Void 
	{
		for (key in _cache.keys())
		{
			var obj = _cache.get(key);
			if (obj != null && obj.canBeDumped)
			{
				obj.onAssetsReload();
			}
		}
	}
	
	/**
	 * New context handler.
	 * Regenerates tilesheets for all dumped graphics objects in the cache.
	 */
	public function onContext():Void
	{
		for (key in _cache.keys())
		{
			var obj = _cache.get(key);
			if (obj != null && obj.isDumped)
			{
				obj.onContext();
			}
		}
	}
	
	/**
	 * Dumps bits of all graphics in the cache. This frees some memory, but you can't read/write pixels on those graphics anymore.
	 * You can call undump() method for each FlxGraphic (or undumpCache()) object which will restore it again.
	 */
	public function dumpCache():Void
	{
		#if !web
		for (key in _cache.keys())
		{
			var obj = _cache.get(key);
			if (obj != null && obj.canBeDumped)
			{
				obj.dump();
			}
		}
		#end
	}
	
	/**
	 * Restores graphics of all dumped objects in the cache.
	 */
	public function undumpCache():Void
	{
		#if !web
		for (key in _cache.keys())
		{
			var obj = _cache.get(key);
			if (obj != null && obj.isDumped)
			{
				obj.undump();
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
	public inline function checkCache(Key:String):Bool
	{
		return get(Key) != null;
	}
	
	/**
	 * Generates a new BitmapData object (a colored rectangle) and caches it.
	 * 
	 * @param	Width	How wide the rectangle should be.
	 * @param	Height	How high the rectangle should be.
	 * @param	Color	What color the rectangle should be (0xAARRGGBB)
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key		Force the cache to use a specific Key to index the bitmap.
	 * @return	The BitmapData we just created.
	 */
	public function create(Width:Int, Height:Int, Color:FlxColor, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		return FlxGraphic.fromRectangle(Width, Height, Color, Unique, Key);
	}
	
	/**
	 * Loads a bitmap from a file, clones it if necessary and caches it.
	 * @param	Graphic		Optional FlxGraphics object to create FlxGraphic from.
	 * @param	Frames			Optional FlxFramesCollection object to create FlxGraphic from.
	 * @param	Bitmap			Optional BitmapData object to create FlxGraphic from.
	 * @param	BitmapClass	Optional Class for BitmapData to create FlxGraphic from.
	 * @param	Str			Optional String key to use for FlxGraphic instantiation.
	 * @param	Unique			Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key				Force the cache to use a specific Key to index the bitmap.
	 * @return	The FlxGraphic we just created.
	 */
	public function add(Graphic:FlxGraphicAsset, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		if (Std.is(Graphic, FlxGraphic))
		{
			return FlxGraphic.fromGraphic(cast Graphic, Unique, Key);
		}
		else if (Std.is(Graphic, BitmapData))
		{
			return FlxGraphic.fromBitmapData(cast Graphic, Unique, Key);
		}
		
		// String case
		return FlxGraphic.fromAssetKey(Std.string(Graphic), Unique, Key);
	}
	
	/**
	 * Caches specified FlxGraphic object.
	 * 
	 * @param	graphic	FlxGraphic to store in the cache.
	 * @return	cached FlxGraphic object.
	 */
	public inline function addGraphic(graphic:FlxGraphic):FlxGraphic
	{
		_cache.set(graphic.key, graphic);
		return graphic;
	}
	
	/**
	 * Gets FlxGraphic object from this storage by specified key. 
	 * @param	key	Key for FlxGraphic object (its name)
	 * @return	FlxGraphic with the key name, or null if there is no such object
	 */
	public inline function get(key:String):FlxGraphic
	{
		return _cache.get(key);
	}
	
	/**
	 * Gets key from bitmap cache for specified bitmapdata
	 * 
	 * @param	bmd	bitmapdata to find in cache
	 * @return	bitmapdata's key or null if there isn't such bitmapdata in cache
	 */
	public function findKeyForBitmap(bmd:BitmapData):String
	{
		for (key in _cache.keys())
		{
			if (_cache.get(key).bitmap == bmd)
				return key;
		}
		return null;
	}
	
	/**
	 * Helper method for getting cache key for FlxGraphic objects created from the class.
	 * 
	 * @param	source	BitmapData source class. 
	 * @return	Full name for provided class.
	 */
	public inline function getKeyForClass(source:Class<Dynamic>):String
	{
		return Type.getClassName(source);
	}
	
	/**
	 * Creates string key for further caching.
	 * 
	 * @param	systemKey	The first string key to use as a base for a new key. It's usually a key from openfl.Assets ("assets/image.png").
	 * @param	userKey		The second string key to use as a base for a new key. It's usually a key provided by the user
	 * @param	unique		Whether generated key should be unique or not.
	 * @return	Created key.
	 */
	public function generateKey(systemKey:String, userKey:String, unique:Bool = false):String
	{
		var key:String = userKey;
		if (key == null)
			key = systemKey;
		
		if (unique || key == null)
			key = getUniqueKey(key);
		
		return key;
	}
	
	/**
	 * Gets unique key for bitmap cache
	 * 
	 * @param	baseKey	key's prefix
	 * @return	unique key
	 */
	public function getUniqueKey(?baseKey:String):String
	{
		if (baseKey == null)
			baseKey = "pixels";
		
		var i:Int = _lastUniqueKeyIndex;
		var uniqueKey:String;
		do
		{
			i++;
			uniqueKey = baseKey + i;
		}
		while (checkCache(uniqueKey));
		
		_lastUniqueKeyIndex = i;
		return uniqueKey;
	}
	
	/**
	 * Generates key from provided base key and information about tile size and offsets in spritesheet 
	 * and the region of image to use as spritesheet graphics source.
	 * 
	 * @param	baseKey			Beginning of the key. Usually it is the key for original spritesheet graphics (like "assets/tile.png") 
	 * @param	frameSize		the size of tile in spritesheet
	 * @param	frameSpacing	offsets between tiles in offsets
	 * @param	region			region of image to use as spritesheet graphics source
	 * @return	Generated key for spritesheet with inserted spaces between tiles
	 */
	public function getKeyWithSpacesAndBorders(baseKey:String, ?frameSize:FlxPoint, ?frameSpacing:FlxPoint, ?frameBorder:FlxPoint, ?region:FlxRect):String
	{
		var result:String = baseKey;
		
		if (region != null)
			result += "_Region:" + region.x + "_" + region.y + "_" + region.width + "_" + region.height;
		
		if (frameSize != null)
			result += "_FrameSize:" + frameSize.x + "_" + frameSize.y;
		
		if (frameSpacing != null)
			result += "_Spaces:" + frameSpacing.x + "_" + frameSpacing.y;
		
		if (frameBorder != null)
			result += "_Border:" + frameBorder.x + "_" + frameBorder.y;
		
		return result;
	}
	
	/**
	 * Totally removes specified FlxGraphic object.
	 * @param	FlxGraphic object you want to remove and destroy.
	 */
	public function remove(graphic:FlxGraphic):Void
	{
		if (graphic != null)
			removeByKey(graphic.key);
	}
	
	/**
	 * Totally removes FlxGraphic object with specified key.
	 * @param	key	the key for cached FlxGraphic object.
	 */
	public function removeByKey(key:String):Void
	{
		if (key != null && _cache.exists(key))
		{
			var obj:FlxGraphic = _cache.get(key);
			Assets.cache.removeBitmapData(key);
			_cache.remove(key);
			obj.destroy();
		}
	}
	
	public function removeIfNoUse(graphic:FlxGraphic):Void
	{
		if (graphic != null && graphic.useCount == 0 && !graphic.persist)
			remove(graphic);
	}
	
	/**
	 * Clears image cache (and destroys those images).
	 * Graphics object will be removed and destroyed only if it shouldn't persist in the cache
	 */
	public function clearCache():Void
	{
		if (_cache == null)
			_cache = new Map();
		
		for (key in _cache.keys())
		{
			var obj = _cache.get(key);
			if (obj != null && !obj.persist && obj.useCount <= 0)
			{
				removeByKey(key);
			}
		}
	}
	
	/**
	 * Completely resets bitmap cache, which means destroying ALL of the cached FlxGraphic objects.
	 */
	public function reset():Void
	{
		if (_cache == null)
			_cache = new Map();
		
		for (key in _cache.keys())
		{
			var obj = _cache.get(key);
			if (obj != null && !obj.persist)
			{
				removeByKey(key);
			}
		}
	}
	
	/**
	 * Removes all unused graphics from cache,
	 * but skips graphics which should persist in cache and shouldn't be destroyed on no use.
	 */
	public function clearUnused():Void
	{
		for (key in _cache.keys())
		{
			var obj = _cache.get(key);
			if (obj != null && obj.useCount <= 0 && !obj.persist && obj.destroyOnNoUse)
			{
				removeByKey(key);
			}
		}
	}
	
	#if !flash
	private function get_maxTextureSize():Int
	{
		return cast GL.getParameter(GL.MAX_TEXTURE_SIZE);
	}
	#end
	
	private function get_whitePixel():FlxFrame
	{
		if (_whitePixel == null)
		{
			var bd = new BitmapData(10, 10, true, FlxColor.WHITE);
			var graphic:FlxGraphic = FlxG.bitmap.add(bd, true, "whitePixels");
			graphic.persist = true;
			_whitePixel = graphic.imageFrame.frame;
		}
		
		return _whitePixel;
	}
}