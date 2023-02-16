package flixel.graphics;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxImageFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
#if !FLX_DRAW_QUADS
import openfl.display.Tilesheet;
#end

/**
 * `BitmapData` wrapper which is used for rendering.
 * It stores info about all frames, generated for specific `BitmapData` object.
 */
class FlxGraphic implements IFlxDestroyable
{
	/**
	 * The default value for the `persist` variable at creation if none is specified in the constructor.
	 * @see [FlxGraphic.persist](https://api.haxeflixel.com/flixel/graphics/FlxGraphic.html#persist)
	 */
	public static var defaultPersist:Bool = false;

	/**
	 * Creates and caches FlxGraphic object from openfl.Assets key string.
	 *
	 * @param   Source   `openfl.Assets` key string. For example: `"assets/image.png"`.
	 * @param   Unique   Ensures that the `BitmapData` uses a new slot in the cache.
	 *                   If `true`, then `BitmapData` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @param   Cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  Cached `FlxGraphic` object we just created.
	 */
	public static function fromAssetKey(Source:String, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = null;

		if (!Cache)
		{
			bitmap = FlxAssets.getBitmapData(Source);
			if (bitmap == null)
				return null;
			return createGraphic(bitmap, Key, Unique, Cache);
		}

		var key:String = FlxG.bitmap.generateKey(Source, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		bitmap = FlxAssets.getBitmapData(Source);
		if (bitmap == null)
			return null;

		graphic = createGraphic(bitmap, key, Unique);
		graphic.assetsKey = Source;
		return graphic;
	}

	/**
	 * Creates and caches `FlxGraphic` object from a specified `Class<BitmapData>`.
	 *
	 * @param   Source   `Class<BitmapData>` to create `BitmapData` for `FlxGraphic` from.
	 * @param   Unique   Ensures that the `BitmapData` uses a new slot in the cache.
	 *                   If `true`, then `BitmapData` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @param   Cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  `FlxGraphic` object we just created.
	 */
	public static function fromClass(Source:Class<BitmapData>, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = null;
		if (!Cache)
		{
			bitmap = FlxAssets.getBitmapFromClass(Source);
			return createGraphic(bitmap, Key, Unique, Cache);
		}

		var key:String = FlxG.bitmap.getKeyForClass(Source);
		key = FlxG.bitmap.generateKey(key, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		bitmap = FlxAssets.getBitmapFromClass(Source);
		graphic = createGraphic(bitmap, key, Unique);
		graphic.assetsClass = Source;
		return graphic;
	}

	/**
	 * Creates and caches `FlxGraphic` object from specified `BitmapData` object.
	 *
	 * @param   Source   `BitmapData` for `FlxGraphic` to use.
	 * @param   Unique   Ensures that the `BitmapData` uses a new slot in the cache.
	 *                   If `true`, then `BitmapData` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @param   Cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  `FlxGraphic` object we just created.
	 */
	public static function fromBitmapData(Source:BitmapData, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		if (!Cache)
			return createGraphic(Source, Key, Unique, Cache);

		var key:String = FlxG.bitmap.findKeyForBitmap(Source);

		var assetKey:String = null;
		var assetClass:Class<BitmapData> = null;
		var graphic:FlxGraphic = null;
		if (key != null)
		{
			graphic = FlxG.bitmap.get(key);
			assetKey = graphic.assetsKey;
			assetClass = graphic.assetsClass;
		}

		key = FlxG.bitmap.generateKey(key, Key, Unique);
		graphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		graphic = createGraphic(Source, key, Unique);
		graphic.assetsKey = assetKey;
		graphic.assetsClass = assetClass;
		return graphic;
	}

	/**
	 * Creates and (optionally) caches a `FlxGraphic` object from the specified `FlxFrame`.
	 * It uses frame's `BitmapData`, not the `frame.parent.bitmap`.
	 *
	 * @param   Source   `FlxFrame` to get the `BitmapData` from.
	 * @param   Unique   Ensures that the bitmap data uses a new slot in the cache.
	 *                   If `true`, then `BitmapData` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @param   Cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  `FlxGraphic` object we just created.
	 */
	public static function fromFrame(Source:FlxFrame, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var key:String = Source.name;
		if (key == null)
			key = Source.frame.toString();
		key = Source.parent.key + ":" + key;
		key = FlxG.bitmap.generateKey(key, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		var bitmap:BitmapData = Source.paint();
		graphic = createGraphic(bitmap, key, Unique, Cache);
		var image:FlxImageFrame = FlxImageFrame.fromGraphic(graphic);
		image.getByIndex(0).name = Source.name;
		return graphic;
	}

	/**
	 * Creates and caches a FlxGraphic object from the specified `FlxFramesCollection`.
	 * It uses `frames.parent.bitmap` as a source for the `FlxGraphic`'s `BitmapData`.
	 * It also copies all the frames collections onto the newly created `FlxGraphic`.
	 *
	 * @param   Source   `FlxFramesCollection` to get the `BitmapData` from.
	 * @param   Unique   Ensures that the `BitmapData` uses a new slot in the cache.
	 *                   If `true`, then `BitmapData` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @return  Cached `FlxGraphic` object we just created.
	 */
	public static inline function fromFrames(Source:FlxFramesCollection, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		return fromGraphic(Source.parent, Unique, Key);
	}

	/**
	 * Creates and caches a `FlxGraphic` object from the specified `FlxGraphic` object.
	 * It copies all the frame collections onto the newly created `FlxGraphic`.
	 *
	 * @param   Source   `FlxGraphic` to get the `BitmapData` from.
	 * @param   Unique   Ensures that the `BitmapData` uses a new slot in the cache.
	 *                   If `true`, then `BitmapData` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @return  Cached `FlxGraphic` object we just created.
	 */
	public static function fromGraphic(Source:FlxGraphic, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		if (!Unique)
			return Source;

		var key:String = FlxG.bitmap.generateKey(Source.key, Key, Unique);
		var graphic:FlxGraphic = createGraphic(Source.bitmap, key, Unique);
		graphic.unique = Unique;
		graphic.assetsClass = Source.assetsClass;
		graphic.assetsKey = Source.assetsKey;
		return FlxG.bitmap.addGraphic(graphic);
	}

	/**
	 * Generates and caches new `FlxGraphic` object with a colored rectangle.
	 *
	 * @param   Width    How wide the rectangle should be.
	 * @param   Height   How high the rectangle should be.
	 * @param   Color    What color the rectangle should have (`0xAARRGGBB`).
	 * @param   Unique   Ensures that the `BitmapData` uses a new slot in the cache.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @return  The `FlxGraphic` object we just created.
	 */
	public static function fromRectangle(Width:Int, Height:Int, Color:FlxColor, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		var systemKey:String = Width + "x" + Height + ":" + Color;
		var key:String = FlxG.bitmap.generateKey(systemKey, Key, Unique);

		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		var bitmap = new BitmapData(Width, Height, true, Color);
		return createGraphic(bitmap, key);
	}

	/**
	 * Helper method for cloning specified `BitmapData` if necessary.
	 *
	 * @param   Bitmap   `BitmapData` to process
	 * @param   Unique   Whether we need to clone specified `BitmapData` object or not
	 * @return  Processed `BitmapData`
	 */
	static inline function getBitmap(Bitmap:BitmapData, Unique:Bool = false):BitmapData
	{
		return Unique ? Bitmap.clone() : Bitmap;
	}

	/**
	 * Creates and caches the specified `BitmapData` object.
	 *
	 * @param   Bitmap   `BitmapData` to use as a graphic source for the new `FlxGraphic`.
	 * @param   Key      Key to use as a cache key for the created `FlxGraphic`.
	 * @param   Unique   Whether the new `FlxGraphic` object uses a unique `BitmapData` or not.
	 *                   If `true`, the specified `BitmapData` will be cloned.
	 * @param   Cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  Created `FlxGraphic` object.
	 */
	static function createGraphic(Bitmap:BitmapData, Key:String, Unique:Bool = false, Cache:Bool = true):FlxGraphic
	{
		Bitmap = FlxGraphic.getBitmap(Bitmap, Unique);
		var graphic:FlxGraphic = null;

		if (Cache)
		{
			graphic = new FlxGraphic(Key, Bitmap);
			graphic.unique = Unique;
			FlxG.bitmap.addGraphic(graphic);
		}
		else
		{
			graphic = new FlxGraphic(null, Bitmap);
		}

		return graphic;
	}

	/**
	 * Key used in the `BitmapFrontEnd` cache.
	 */
	public var key(default, null):String;

	/**
	 * The cached `BitmapData` object.
	 */
	public var bitmap(default, set):BitmapData;

	/**
	 * Width of the cached `BitmapData`.
	 */
	public var width(default, null):Int = 0;

	/**
	 * Height of the cached `BitmapData`.
	 */
	public var height(default, null):Int = 0;

	/**
	 * Asset name from `openfl.Assets`.
	 */
	public var assetsKey(default, null):String;

	/**
	 * Class name for the `BitmapData`.
	 */
	public var assetsClass(default, null):Class<BitmapData>;

	/**
	 * Whether this graphic object should stay in the cache after state changes or not.
	 * `destroyOnNoUse` has no effect when this is set to `true`.
	 */
	public var persist:Bool = false;

	/**
	 * Whether this `FlxGraphic` should be destroyed when `useCount` becomes zero (defaults to `true`).
	 * Has no effect when `persist` is `true`.
	 */
	public var destroyOnNoUse(get, set):Bool;

	/**
	 * Whether the `BitmapData` of this graphic object has been dumped or not.
	 */
	public var isDumped(default, null):Bool = false;

	/**
	 * Whether the `BitmapData` of this graphic object has been loaded or not.
	 */
	public var isLoaded(get, never):Bool;

	/**
	 * Whether the `BitmapData` of this graphic object can be dumped for decreased memory usage,
	 * but may cause some issues (when you need direct access to pixels of this graphic.
	 * If the graphic is dumped then you should call `undump()` and have total access to pixels.
	 */
	public var canBeDumped(get, never):Bool;

	#if FLX_DRAW_QUADS
	public var shader(default, null):FlxShader;
	#else

	/**
	 * Tilesheet for this graphic object. It is used only for `FlxG.renderTile` mode.
	 */
	public var tilesheet(get, never):Tilesheet;
	#end

	/**
	 * Usage counter for this `FlxGraphic` object.
	 */
	public var useCount(get, set):Int;

	/**
	 * `FlxImageFrame` object for the whole bitmap.
	 */
	public var imageFrame(get, never):FlxImageFrame;

	/**
	 * Atlas frames for this graphic.
	 * You should fill it yourself with one of `FlxAtlasFrames`'s static methods
	 * (like `fromTexturePackerJson()`, `fromTexturePackerXml()`, etc).
	 */
	public var atlasFrames(get, never):FlxAtlasFrames;

	/**
	 * Storage for all available frame collection of all types for this graphic object.
	 */
	var frameCollections:Map<FlxFrameCollectionType, Array<Dynamic>>;

	/**
	 * All types of frames collection which had been added to this graphic object.
	 * It helps to avoid map iteration, which produces a lot of garbage.
	 */
	var frameCollectionTypes:Array<FlxFrameCollectionType>;

	/**
	 * Shows whether this object unique in cache or not.
	 *
	 * Whether undumped `BitmapData` should be cloned or not.
	 * It is `false` by default, since it significantly increases memory consumption.
	 */
	public var unique:Bool = false;

	/**
	 * Internal var holding `FlxImageFrame` for the whole bitmap of this graphic.
	 * Use public `imageFrame` var to access/generate it.
	 */
	var _imageFrame:FlxImageFrame;

	#if !FLX_DRAW_QUADS
	/**
	 * Internal var holding Tilesheet for bitmap of this graphic.
	 * It is used only in `FlxG.renderTile` mode
	 */
	var _tilesheet:Tilesheet;
	#end

	var _useCount:Int = 0;

	var _destroyOnNoUse:Bool = true;

	/**
	 * `FlxGraphic` constructor
	 *
	 * @param   Key       Key string for this graphic object, with which you can get it from bitmap cache.
	 * @param   Bitmap    `BitmapData` for this graphic object.
	 * @param   Persist   Whether or not this graphic stay in the cache after resetting it.
	 *                    Default value is `false`, which means that this graphic will be destroyed at the cache reset.
	 */
	function new(Key:String, Bitmap:BitmapData, ?Persist:Bool)
	{
		key = Key;
		persist = (Persist != null) ? Persist : defaultPersist;

		frameCollections = new Map<FlxFrameCollectionType, Array<Dynamic>>();
		frameCollectionTypes = new Array<FlxFrameCollectionType>();
		bitmap = Bitmap;

		#if FLX_DRAW_QUADS
		shader = new FlxShader();
		#end
	}

	/**
	 * Dumps bits of `BitmapData` to decrease memory usage, but you can't read/write pixels on it anymore
	 * (but you can call `onContext()` (or `undump()`) method which will restore it again).
	 */
	public function dump():Void
	{
		#if (lime_legacy && !flash)
		if (FlxG.renderTile && canBeDumped)
		{
			bitmap.dumpBits();
			isDumped = true;
		}
		#end
	}

	/**
	 * Undumps bits of the `BitmapData` - regenerates it and regenerate tilesheet data for this object
	 */
	public function undump():Void
	{
		var newBitmap:BitmapData = getBitmapFromSystem();
		if (newBitmap != null)
			bitmap = newBitmap;
		isDumped = false;
	}

	/**
	 * Use this method to restore cached `BitmapData` (if it's possible).
	 * It's called automatically when the RESIZE event occurs.
	 */
	public function onContext():Void
	{
		// no need to restore tilesheet if it hasn't been dumped
		if (isDumped)
		{
			undump(); // restore everything
			dump(); // and dump BitmapData again
		}
	}

	/**
	 * Asset reload callback for this graphic object.
	 * It regenerated its tilesheet and resets frame bitmaps.
	 */
	public function onAssetsReload():Void
	{
		if (!canBeDumped)
			return;

		var dumped:Bool = isDumped;
		undump();
		if (dumped)
			dump();
	}

	/**
	 * Trying to free the memory as much as possible
	 */
	public function destroy():Void
	{
		bitmap = FlxDestroyUtil.dispose(bitmap);

		#if FLX_DRAW_QUADS
		shader = null;
		#else
		if (FlxG.renderTile)
			_tilesheet = null;
		#end

		key = null;
		assetsKey = null;
		assetsClass = null;
		_imageFrame = null; // no need to dispose _imageFrame since it exists in imageFrames

		if (frameCollections == null) // no need to destroy frame collections if it's already null
			return;

		var collections:Array<FlxFramesCollection>;
		for (collectionType in frameCollectionTypes)
		{
			collections = cast frameCollections.get(collectionType);
			FlxDestroyUtil.destroyArray(collections);
		}

		frameCollections = null;
		frameCollectionTypes = null;
	}

	/**
	 * Stores specified `FlxFrame` collection in internal map (this helps reduce object creation).
	 *
	 * @param   collection   frame collection to store.
	 */
	public function addFrameCollection(collection:FlxFramesCollection):Void
	{
		if (collection.type != null)
		{
			var collections:Array<Dynamic> = getFramesCollections(collection.type);
			collections.push(collection);
		}
	}

	/**
	 * Searches frame collections of specified type for this `FlxGraphic` object.
	 *
	 * @param   type   The type of frames collections to search for.
	 * @return  Array of available frames collections of specified type for this object.
	 */
	public inline function getFramesCollections(type:FlxFrameCollectionType):Array<Dynamic>
	{
		var collections:Array<Dynamic> = frameCollections.get(type);
		if (collections == null)
		{
			collections = new Array<FlxFramesCollection>();
			frameCollections.set(type, collections);
		}
		return collections;
	}

	/**
	 * Creates empty frame for this graphic with specified size.
	 * This method could be useful for tile frames, in case when you'll need empty tile.
	 *
	 * @param   size   dimensions of the frame to add.
	 * @return  Empty frame with specified size which belongs to this `FlxGraphic` object.
	 */
	public inline function getEmptyFrame(size:FlxPoint):FlxFrame
	{
		var frame = new FlxFrame(this);
		frame.type = FlxFrameType.EMPTY;
		frame.frame = FlxRect.get();
		frame.sourceSize.copyFrom(size);
		return frame;
	}

	#if !FLX_DRAW_QUADS
	/**
	 * Tilesheet getter. Generates new one (and regenerates) if there is no tilesheet for this graphic yet.
	 */
	function get_tilesheet():Tilesheet
	{
		if (_tilesheet == null)
		{
			var dumped:Bool = isDumped;

			if (dumped)
				undump();

			_tilesheet = new Tilesheet(bitmap);

			if (dumped)
				dump();
		}

		return _tilesheet;
	}
	#end

	/**
	 * Gets the `BitmapData` for this graphic object from OpenFL.
	 * This method is used for undumping graphic.
	 */
	function getBitmapFromSystem():BitmapData
	{
		var newBitmap:BitmapData = null;
		if (assetsClass != null)
			newBitmap = FlxAssets.getBitmapFromClass(assetsClass);
		else if (assetsKey != null)
			newBitmap = FlxAssets.getBitmapData(assetsKey);

		if (newBitmap != null)
			return FlxGraphic.getBitmap(newBitmap, unique);

		return null;
	}
	
	inline function get_isLoaded()
	{
		return bitmap != null && !bitmap.rect.isEmpty();
	}

	inline function get_canBeDumped():Bool
	{
		return assetsClass != null || assetsKey != null;
	}

	function get_useCount():Int
	{
		return _useCount;
	}

	function set_useCount(Value:Int):Int
	{
		if (Value <= 0 && _destroyOnNoUse && !persist)
			FlxG.bitmap.remove(this);

		return _useCount = Value;
	}

	function get_destroyOnNoUse():Bool
	{
		return _destroyOnNoUse;
	}

	function set_destroyOnNoUse(Value:Bool):Bool
	{
		if (Value && _useCount <= 0 && key != null && !persist)
			FlxG.bitmap.remove(this);

		return _destroyOnNoUse = Value;
	}

	function get_imageFrame():FlxImageFrame
	{
		if (_imageFrame == null)
			_imageFrame = FlxImageFrame.fromRectangle(this, FlxRect.get(0, 0, bitmap.width, bitmap.height));

		return _imageFrame;
	}

	function get_atlasFrames():FlxAtlasFrames
	{
		return FlxAtlasFrames.findFrame(this, null);
	}

	function set_bitmap(value:BitmapData):BitmapData
	{
		if (value != null)
		{
			bitmap = value;
			width = bitmap.width;
			height = bitmap.height;
			#if (!flash && !FLX_DRAW_QUADS)
			if (FlxG.renderTile && _tilesheet != null)
				_tilesheet = new Tilesheet(bitmap);
			#end
		}

		return value;
	}
}
