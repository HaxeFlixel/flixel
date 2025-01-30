package flixel.system.frontEnds;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.display.BitmapData;
#if FLX_OPENGL_AVAILABLE
import lime.graphics.opengl.GL;
#end

/**
 * Internal storage system to prevent graphics from being used repeatedly in memory.
 * 
 * Accessed via `FlxG.bitmap`.
 */
class BitmapFrontEnd
{
	#if FLX_OPENGL_AVAILABLE
	/**
	 * Returns the maximum allowed width and height (in pixels) for a texture.
	 * This value is only available on hardware-accelerated targets that use OpenGL.
	 * On unsupported targets, the returned value will always be -1.
	 * 
	 * @see https://opengl.gpuinfo.org/displaycapability.php?name=GL_MAX_TEXTURE_SIZE
	 */
	public var maxTextureSize(get, never):Int;
	#end

	/**
	 * Helper FlxFrame object. Containing only one frame.
	 * Useful for drawing colored rectangles of all sizes in FlxG.renderTile mode.
	 */
	public var whitePixel(get, never):FlxFrame;

	@:allow(flixel.system.frontEnds.BitmapLogFrontEnd)
	var _cache:Map<String, FlxGraphic>;

	var _whitePixel:FlxFrame;

	var _lastUniqueKeyIndex:Int = 0;

	public function new()
	{
		reset();
	}

	public function onAssetsReload(_):Void
	{
		for (key in _cache.keys())
		{
			var obj = _cache.get(key);
			if (obj != null && obj.canBeRefreshed)
			{
				obj.onAssetsReload();
			}
		}
	}

	/**
	 * Check the local bitmap cache to see if a bitmap with this key has been loaded already.
	 *
	 * @param   key  The key identifying the bitmap.
	 * @return  Whether or not this file can be found in the cache.
	 */
	public inline function checkCache(key:String):Bool
	{
		return get(key) != null;
	}

	/**
	 * Creates a new graphic of a colored rectangle and caches it.
	 *
	 * @param   width   How wide the rectangle should be.
	 * @param   height  How high the rectangle should be.
	 * @param   color   What color the rectangle should be (0xAARRGGBB).
	 * @param   unique  Ensures that the bitmap data uses a new slot in the cache.
	 * @param   key     Force the cache to use a specific Key to index the bitmap.
	 * @return  The created graphic.
	 */
	public function create(width:Int, height:Int, color:FlxColor, unique = false, ?key:String):FlxGraphic
	{
		return FlxGraphic.fromRectangle(width, height, color, unique, key);
	}

	/**
	 * Loads a bitmap from a file, clones it if necessary and caches it.
	 * @param   graphic  Optional FlxGraphics object to create FlxGraphic from.
	 * @param   unique   Ensures that the bitmap data uses a new slot in the cache.
	 * @param   key      Force the cache to use a specific Key to index the bitmap.
	 * @return  The FlxGraphic we just created.
	 */
	public function add(graphic:FlxGraphicAsset, unique = false, ?key:String):FlxGraphic
	{
		if ((graphic is FlxGraphic))
		{
			return FlxGraphic.fromGraphic(cast graphic, unique, key);
		}
		else if ((graphic is BitmapData))
		{
			return FlxGraphic.fromBitmapData(cast graphic, unique, key);
		}

		// String case
		return FlxGraphic.fromAssetKey(Std.string(graphic), unique, key);
	}

	/**
	 * Caches the specified graphic.
	 *
	 * @param   graphic  The graphic to cache.
	 * @return  The cached graphic.
	 */
	public inline function addGraphic(graphic:FlxGraphic):FlxGraphic
	{
		_cache.set(graphic.key, graphic);
		return graphic;
	}

	/**
	 * Gets an FlxGraphic object from this storage from its key.
	 * 
	 * @param   key  The FlxGraphics key (or name).
	 * @return  The FlxGraphic with the specified key, or null if the object doesn't exist.
	 */
	public inline function get(key:String):FlxGraphic
	{
		return _cache.get(key);
	}

	/**
	 * Gets a key from a cached BitmapData.
	 *
	 * @param   bmd  BitmapData to find in the cache.
	 * @return  The BitmapData's key or null if there isn't such BitmapData in cache.
	 */
	public function findKeyForBitmap(bmd:BitmapData):String
	{
		for (key in _cache.keys())
		{
			var obj = _cache.get(key);
			if (obj != null && obj.bitmap == bmd)
				return key;
		}
		return null;
	}

	/**
	 * Helper method for getting cache key for FlxGraphic objects created from the class.
	 *
	 * @param   source  BitmapData source class.
	 * @return  Full name for provided class.
	 */
	public inline function getKeyForClass(source:Class<Dynamic>):String
	{
		return Type.getClassName(source);
	}

	/**
	 * Creates string key for further caching.
	 *
	 * @param   systemKey  The first string key to use as a base for a new key. It's usually an asset key ("assets/image.png").
	 * @param   userKey    The second string key to use as a base for a new key. It's usually a key provided by the user
	 * @param   unique     Whether generated key should be unique or not.
	 * @return  Created key.
	 */
	public function generateKey(systemKey:String, userKey:String, unique = false):String
	{
		var key:String = userKey;
		if (key == null)
			key = systemKey;

		if (unique || key == null)
			key = getUniqueKey(key);

		return key;
	}

	/**
	 * Gets unique key for bitmap cache.
	 *
	 * @param   baseKey  key's prefix.
	 * @return  unique key.
	 */
	public function getUniqueKey(?baseKey:String):String
	{
		if (baseKey == null)
			baseKey = "pixels";

		if (!checkCache(baseKey))
			return baseKey;

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
	 * @param   baseKey       Beginning of the key. Usually it is the key for original spritesheet graphics (like "assets/tile.png").
	 * @param   frameSize     The size of tile in spritesheet.
	 * @param   frameSpacing  Offsets between tiles in offsets.
	 * @param   region        Region of image to use as spritesheet graphics source.
	 * @return  Generated key for spritesheet with inserted spaces between tiles.
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
	 * @param   graphic  The object you want to remove and destroy.
	 */
	public function remove(graphic:FlxGraphic):Void
	{
		if (graphic != null)
		{
			removeKey(graphic.key);
			// TODO: find causes of this, and prevent crashes from double graphic destroys
			if (!graphic.isDestroyed)
				graphic.destroy();
		}
	}

	/**
	 * Totally removes FlxGraphic object with specified key.
	 * @param   key  Key of the cached graphic.
	 */
	public function removeByKey(key:String):Void
	{
		if (key != null)
		{
			var obj = get(key);
			removeKey(key);

			if (obj != null)
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
	 * Graphics object will be removed and destroyed only if it shouldn't persist in the cache and its useCount is 0.
	 */
	public function clearCache():Void
	{
		if (_cache == null)
		{
			_cache = new Map();
			return;
		}

		for (key in _cache.keys())
		{
			var obj = get(key);
			if (obj != null && !obj.persist && obj.useCount <= 0)
			{
				removeKey(key);
				obj.destroy();
			}
		}
	}

	inline function removeKey(key:String):Void
	{
		if (key != null)
		{
			Assets.cache.removeBitmapData(key);
			_cache.remove(key);
		}
	}

	/**
	 * Completely resets bitmap cache, which means destroying ALL of the cached FlxGraphic objects.
	 */
	public function reset():Void
	{
		if (_cache == null)
		{
			_cache = new Map();
			return;
		}

		for (key in _cache.keys())
		{
			var obj = get(key);
			removeKey(key);

			if (obj != null)
				obj.destroy();
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

	#if FLX_OPENGL_AVAILABLE
	function get_maxTextureSize():Int
	{
		if (FlxG.stage.window.context.attributes.hardware)
			return cast GL.getParameter(GL.MAX_TEXTURE_SIZE);
		
		return -1;
	}
	#end

	function get_whitePixel():FlxFrame
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
