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
import openfl.display.Tilesheet;

/**
 * BitmapData wrapper which is used for rendering.
 * It stores info about all frames, generated for specific BitmapData object.
 */
class FlxGraphic implements IFlxDestroyable
{
	/**
	 * The default value for the CachedGraphics persist variable
	 * at creation if none is specified in the constructor.
	 */
	public static var defaultPersist:Bool = false;
	
	/**
	 * Creates and caches FlxGraphic object from openfl.Assets key string.
	 * 
	 * @param	Source	openfl.Assets key string. For example: "assets/image.png".
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache. If true, then BitmapData for this FlxGraphic will be cloned, which means extra memory.
	 * @param	Key		Force the cache to use a specific Key to index the bitmap.
	 * @param	Cache	Whether to use graphic caching or not. Default value is true, which means automatic caching.
	 * @return	Cached FlxGraphic object we just created.
	 */
	public static function fromAssetKey(Source:String, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = null;
		
		if (!Cache)
		{
			bitmap = FlxAssets.getBitmapData(Source);
			if (bitmap == null)
			{
				return null;
			}
			return createGraphic(bitmap, Key, Unique, Cache);
		}
		
		var key:String = FlxG.bitmap.generateKey(Source, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
		{
			return graphic;
		}
		
		bitmap = FlxAssets.getBitmapData(Source);
		if (bitmap == null)
		{
			return null;
		}
		
		graphic = createGraphic(bitmap, key, Unique);
		graphic.assetsKey = Source;
		return graphic;
	}
	
	/**
	 * Creates and caches FlxGraphic object from specified Class<BitmapData>.
	 * 
	 * @param	Source	Class<BitmapData> to create BitmapData for FlxGraphic from.
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache. If true, then BitmapData for this FlxGraphic will be cloned, which means extra memory.
	 * @param	Key	Force the cache to use a specific Key to index the bitmap.
	 * @param	Cache	Whether to use graphic caching or not. Default value is true, which means automatic caching.
	 * @return	FlxGraphic object we just created.
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
		{
			return graphic;
		}
		
		bitmap = FlxAssets.getBitmapFromClass(Source);
		graphic = createGraphic(bitmap, key, Unique);
		graphic.assetsClass = Source;
		return graphic;
	}
	
	/**
	 * Creates and caches FlxGraphic object from specified BitmapData object.
	 * 
	 * @param	BitmapData for FlxGraphic object to use.
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache. If true, then BitmapData for this FlxGraphic will be cloned, which means extra memory.
	 * @param	Key	Force the cache to use a specific Key to index the bitmap.
	 * @param	Cache	Whether to use graphic caching or not. Default value is true, which means automatic caching.
	 * @return	FlxGraphic object we just created.
	 */
	public static function fromBitmapData(Source:BitmapData, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		if (!Cache)
		{
			return createGraphic(Source, Key, Unique, Cache);
		}
		
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
		{
			return graphic;
		}
		
		graphic = createGraphic(Source, key, Unique);
		graphic.assetsKey = assetKey;
		graphic.assetsClass = assetClass;
		return graphic;
	}
	
	/**
	 * Creates and caches FlxGraphic object from specified FlxFrame object.
	 * It uses frame's BitmapData, not the frame.parent.bitmap.
	 * 
	 * @param	FlxFrame to get BitmapData from for FlxGraphic object.
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache. If true, then BitmapData for this FlxGraphic will be cloned, which means extra memory.
	 * @param	Key	Force the cache to use a specific Key to index the bitmap.
	 * @return	Cached FlxGraphic object we just created.
	 */
	public static function fromFrame(Source:FlxFrame, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		var key:String = Source.name;
		if (key == null)
		{
			key = Source.frame.toString();
		}
		key = Source.parent.key + ":" + key;
		key = FlxG.bitmap.generateKey(key, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
		{
			return graphic;
		}
		
		var bitmap:BitmapData = Source.paint();
		graphic = createGraphic(bitmap, key, Unique);
		var image:FlxImageFrame = FlxImageFrame.fromGraphic(graphic);
		image.getByIndex(0).name = Source.name;
		return graphic;
	}
	
	/**
	 * Creates and caches FlxGraphic object from specified FlxFramesCollection object.
	 * It uses frames.parent.bitmap as a source for FlxGraphic BitmapData.
	 * It also copies all the frames collections onto newly created FlxGraphic.
	 * 
	 * @param	FlxFramesCollection to get BitmapData from for FlxGraphic object.
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache. If true, then BitmapData for this FlxGraphic will be cloned, which means extra memory.
	 * @param	Key	Force the cache to use a specific Key to index the bitmap.
	 * @return	Cached FlxGraphic object we just created.
	 */
	public static inline function fromFrames(Source:FlxFramesCollection, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		return fromGraphic(Source.parent, Unique, Key);
	}
	
	/**
	 * Creates and caches FlxGraphic object from specified FlxGraphic object.
	 * It copies all the frames collections onto newly created FlxGraphic.
	 * 
	 * @param	FlxGraphic to get BitmapData from for FlxGraphic object.
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache. If true, then BitmapData for this FlxGraphic will be cloned, which means extra memory.
	 * @param	Key	Force the cache to use a specific Key to index the bitmap.
	 * @return	Cached FlxGraphic object we just created.
	 */
	public static function fromGraphic(Source:FlxGraphic, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		if (!Unique)
		{
			return Source;
		}
		
		var key:String = FlxG.bitmap.generateKey(Source.key, Key, Unique);
		var graphic:FlxGraphic = createGraphic(Source.bitmap, key, Unique);
		graphic.unique = Unique;
		graphic.assetsClass = Source.assetsClass;
		graphic.assetsKey = Source.assetsKey;
		return FlxG.bitmap.addGraphic(graphic);
	}
	
	/**
	 * Generates and caches new FlxGraphic object with a colored rectangle.
	 * 
	 * @param	Width	How wide the rectangle should be.
	 * @param	Height	How high the rectangle should be.
	 * @param	Color	What color the rectangle should be (0xAARRGGBB)
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key		Force the cache to use a specific Key to index the bitmap.
	 * @return	The FlxGraphic object we just created.
	 */
	public static function fromRectangle(Width:Int, Height:Int, Color:FlxColor, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		var systemKey:String = Width + "x" + Height + ":" + Color;
		var key:String = FlxG.bitmap.generateKey(systemKey, Key, Unique);
		
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
		{
			return graphic;
		}
		
		var bitmap:BitmapData = new BitmapData(Width, Height, true, Color);
		return createGraphic(bitmap, key);
	}
	
	/**
	 * Helper method for cloning specified BitmapData if necessary.
	 * Added to reduce code duplications.
	 * 
	 * @param	Bitmap 	BitmapData to process
	 * @param	Unique	Whether we need to clone specified BitmapData object or not
	 * @return	Processed BitmapData
	 */
	private static inline function getBitmap(Bitmap:BitmapData, Unique:Bool = false):BitmapData
	{
		return Unique ? Bitmap.clone() : Bitmap;
	}
	
	/**
	 * Creates and caches specified BitmapData object.
	 * 
	 * @param	Bitmap	BitmapData to use as a graphic source for new FlxGraphic.
	 * @param	Key		Key to use as a cache key for created FlxGraphic.
	 * @param	Unique	Whether new FlxGraphic object uses unique BitmapData or not. If true, then specified BitmapData will be cloned.
	 * @param	Cache	Whether to use graphic caching or not. Default value is true, which means automatic caching.
	 * @return	Created FlxGraphic object.
	 */
	private static function createGraphic(Bitmap:BitmapData, Key:String, Unique:Bool = false, Cache:Bool = true):FlxGraphic
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
	 * Key in BitmapFrontEnd cache
	 */
	public var key(default, null):String;
	/**
	 * Cached BitmapData object
	 */
	public var bitmap(default, set):BitmapData;
	
	/**
	 * The width of cached BitmapData.
	 * Added for faster access/typing
	 */
	public var width(default, null):Int = 0;
	/**
	 * The height of cached BitmapData.
	 * Added for faster access/typing
	 */
	public var height(default, null):Int = 0;
	
	/**
	 * Asset name from openfl.Assets
	 */
	public var assetsKey(default, null):String;
	/**
	 * Class name for the BitmapData
	 */
	public var assetsClass(default, null):Class<BitmapData>;
	
	/**
	 * Whether this graphic object should stay in cache after state changes or not.
	 */
	public var persist:Bool = false;
	/**
	 * Whether we should destroy this FlxGraphic object when useCount become zero.
	 * Default is true.
	 */
	public var destroyOnNoUse(get, set):Bool;
	
	/**
	 * Whether the BitmapData of this graphic object has been dumped or not.
	 */
	public var isDumped(default, null):Bool = false;
	/**
	 * Whether the BitmapData of this graphic object can be dumped for decreased memory usage,
	 * but may cause some issues (when you need direct access to pixels of this graphic.
	 * If the graphic is dumped then you should call undump() and have total access to pixels.
	 */
	public var canBeDumped(get, never):Bool;
	
	/**
	 * Tilesheet for this graphic object. It is used only for FlxG.renderTile mode
	 */
	public var tilesheet(get, null):Tilesheet;
	
	/**
	 * Usage counter for this FlxGraphic object.
	 */
	public var useCount(get, set):Int;
	
	/**
	 * ImageFrame object for the whole bitmap
	 */
	public var imageFrame(get, null):FlxImageFrame;
	
	/**
	 * Atlas frames for this graphic.
	 * You should fill it yourself with one of the AtlasFrames static methods
	 * (like texturePackerJSON(), texturePackerXML(), sparrow(), libGDX()).
	 */
	public var atlasFrames(get, null):FlxAtlasFrames;
	
	/**
	 * Storage for all available frame collection of all types for this graphic object.
	 */
	private var frameCollections:Map<FlxFrameCollectionType, Array<Dynamic>>;
	
	/**
	 * All types of frames collection which had been added to this graphic object.
	 * It helps to avoid map iteration, which produces a lot of garbage.
	 */
	private var frameCollectionTypes:Array<FlxFrameCollectionType>;
	
	/**
	 * Shows whether this object unique in cache or not.
	 * 
	 * Whether undumped BitmapData should be cloned or not.
	 * It is false by default, since significantly reduces memory consumption.
	 */
	public var unique:Bool = false;
	
	/**
	 * Internal var holding ImageFrame for the whole bitmap of this graphic.
	 * Use public imageFrame var to access/generate it.
	 */
	private var _imageFrame:FlxImageFrame;
	
	/**
	 * Internal var holding Tilesheet for bitmap of this graphic.
	 * It is used only in FlxG.renderTile mode
	 */
	private var _tilesheet:Tilesheet;
	
	private var _useCount:Int = 0;
	
	private var _destroyOnNoUse:Bool = true;
	
	/**
	 * FlxGraphic constructor
	 * @param	Key			key string for this graphic object, with which you can get it from bitmap cache
	 * @param	Bitmap		BitmapData for this graphic object
	 * @param	Persist		Whether or not this graphic stay in the cache after reseting cache. Default value is false which means that this graphic will be destroyed at the cache reset.
	 */
	private function new(Key:String, Bitmap:BitmapData, ?Persist:Bool)
	{
		key = Key;
		persist = (Persist != null) ? Persist : defaultPersist;
		
		frameCollections = new Map<FlxFrameCollectionType, Array<Dynamic>>();
		frameCollectionTypes = new Array<FlxFrameCollectionType>();
		bitmap = Bitmap;
	}
	
	/**
	 * Dumps bits of bitmapdata == less memory, but you can't read/write pixels on it anymore
	 * (but you can call onContext() (or undump()) method which will restore it again)
	 */
	public function dump():Void
	{
	#if lime_legacy	
		#if (!flash && !nme)
		if (FlxG.renderTile)
		{
			if (canBeDumped)
			{
				bitmap.dumpBits();
				isDumped = true;
			}
		}
		#end
	#end
	}
	
	/**
	 * Undumps bits of bitmapdata - regenerates it and regenerate tilesheet data for this object
	 */
	public function undump():Void
	{
		var newBitmap:BitmapData = getBitmapFromSystem();	
		if (newBitmap != null)
		{
			bitmap = newBitmap;
		}
		isDumped = false;
	}
	
	/**
	 * Use this method to restore cached bitmapdata (if it's possible).
	 * It's called automatically when the RESIZE event occurs.
	 */
	public function onContext():Void
	{
		// no need to restore tilesheet if it hasn't been dumped
		if (isDumped)
		{
			undump();	// restore everything
			dump();		// and dump bitmapdata again
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
		if (FlxG.renderTile)
		{
			_tilesheet = null;
		}
		key = null;
		assetsKey = null;
		assetsClass = null;
		_imageFrame = null;	// no need to dispose _imageFrame since it exists in imageFrames
		
		var collections:Array<FlxFramesCollection>;
		var collectionType:FlxFrameCollectionType;
		for (collectionType in frameCollectionTypes)
		{
			collections = cast frameCollections.get(collectionType);
			FlxDestroyUtil.destroyArray(collections);
		}
		
		frameCollections = null;
		frameCollectionTypes = null;
	}
	
	/**
	 * Stores specified FlxFrame collection in internal map (this helps reduce object creation).
	 * 
	 * @param	collection	frame collection to store.
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
	 * Searches frames collections of specified type for this FlxGraphic object.
	 * 
	 * @param	type	The type of frames collections to search for.
	 * @return	Array of available frames collections of specified type for this object.
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
	 * @param	size	dimensions of the frame to add.
	 * @return	Empty frame with specified size which belongs to this FlxGraphic object.
	 */
	public inline function getEmptyFrame(size:FlxPoint):FlxFrame
	{
		var frame:FlxFrame = new FlxFrame(this);
		frame.type = FlxFrameType.EMPTY;
		frame.frame = FlxRect.get();
		frame.sourceSize.copyFrom(size);
		return frame;
	}
	
	/**
	 * Tilesheet getter. Generates new one (and regenerates) if there is no tilesheet for this graphic yet.
	 */
	private function get_tilesheet():Tilesheet
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
	
	/**
	 * Gets BitmapData for this graphic object from OpenFl.
	 * This method is used for undumping graphic.
	 */
	private function getBitmapFromSystem():BitmapData
	{
		var newBitmap:BitmapData = null;
		if (assetsClass != null)
		{
			newBitmap = FlxAssets.getBitmapFromClass(assetsClass);
		}
		else if (assetsKey != null)
		{
			newBitmap = FlxAssets.getBitmapData(assetsKey);
		}
		
		if (newBitmap != null)
		{
			return FlxGraphic.getBitmap(newBitmap, unique);
		}
		
		return null;
	}
	
	private inline function get_canBeDumped():Bool
	{
		return ((assetsClass != null) || (assetsKey != null));
	}
	
	private function get_useCount():Int
	{
		return _useCount;
	}
	
	private function set_useCount(Value:Int):Int
	{
		if ((Value <= 0) && _destroyOnNoUse && !persist)
		{
			FlxG.bitmap.remove(this);
		}
		
		return _useCount = Value;
	}
	
	private function get_destroyOnNoUse():Bool
	{
		return _destroyOnNoUse;
	}
	
	private function set_destroyOnNoUse(Value:Bool):Bool
	{
		if (Value && _useCount <= 0 && key != null && !persist)
		{
			FlxG.bitmap.remove(this);
		}
		
		return _destroyOnNoUse = Value;
	}
	
	private function get_imageFrame():FlxImageFrame
	{
		if (_imageFrame == null)
		{
			_imageFrame = FlxImageFrame.fromRectangle(this, FlxRect.get(0, 0, bitmap.width, bitmap.height));
		}
		
		return _imageFrame;
	}
	
	private function get_atlasFrames():FlxAtlasFrames
	{
		return FlxAtlasFrames.findFrame(this, null);
	}
	
	private function set_bitmap(value:BitmapData):BitmapData
	{
		if (value != null)
		{
			bitmap = value;
			width = bitmap.width;
			height = bitmap.height;
			#if (!flash && !nme)
			if (FlxG.renderTile)
			{
				if (_tilesheet != null)
				{
					_tilesheet = new Tilesheet(bitmap);
				}
			}
			#end
		}
		
		return value;
	}
}