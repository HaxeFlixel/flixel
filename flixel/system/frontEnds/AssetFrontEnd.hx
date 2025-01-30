package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.debug.log.LogStyle;
import haxe.io.Bytes;
import haxe.io.Path;
import haxe.Json;
import haxe.xml.Access;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.AssetCache;
import openfl.utils.Future;
import openfl.text.Font;

using StringTools;

/**
 * Accessed via `FlxG.assets`. The main interface for the asset system. By default, OpenFl's
 * Asset system is used, which uses relative path strings to retrive assets, though you can completely
 * avoid Openfl's asset system by setting custom methods to the following dynamic fields: `getAssetUnsafe`,
 * `loadAsset`, `exists`, `isLocal` and `list`.
 * 
 * ## Common Uses
 * The initial reason for making customizable asset system
 * was to allow for "hot-reloading", or testing new assets in your game without recompiling, with
 * each change. Say, if you would like a debug feature where you load assets from source assets,
 * rather than the assets copied over to your export folder, you could overwrite this system to do
 * just that.
 * 
 * Other potential uses for this are modding, bypassing the manifest and loading resources from
 * a remote location.
 * 
 * ### Quick Setup for "Hot-Reloading"
 * To simplify the process mentioned above, the `FLX_CUSTOM_ASSETS_DIRECTORY` flag was created.
 * By adding `-DFLX_CUSTOM_ASSETS_DIRECTORY="assets"` to your lime build command
 * it will automatically grab assets from your project root's assets folder rather than, the
 * default "export/hl/bin/assets". This will only work with a single asset root folder with one
 * asset library and will use the openfl asset system if the asset id starts with "flixel/" or
 * tries to references a specific library using the format: "libName:asset/path/file.ext".
 * 
 * @since 5.9.0
 */
class AssetFrontEnd
{
	#if FLX_CUSTOM_ASSETS_DIRECTORY
	/**
	 * The target directory
	 */
	final directory:String;
	
	/**
	 * The parent of the target directory, is prepended to any `id` passed in
	 */
	final parentDirectory:String;
	
	public function new ()
	{
		final rawPath = '${haxe.macro.Compiler.getDefine("FLX_CUSTOM_ASSETS_DIRECTORY")}';
		directory = '${haxe.macro.Compiler.getDefine("FLX_CUSTOM_ASSETS_DIRECTORY_ABS")}';
		// Verify valid directory
		if (sys.FileSystem.exists(directory) == false)
			throw 'Error finding custom asset directory:"$directory" from given path: $rawPath';
		// remove final "/assets" since the id typically contains it
		final split = directory.split("/");
		split.pop();
		parentDirectory = split.join("/");
	}
	
	function getPath(id:String)
	{
		return Path.normalize('$parentDirectory/$id');
	}
	
	/**
	 * True for assets packaged with all HaxeFlixel build, and any non-default libraries
	 */
	function useOpenflAssets(id:String)
	{
		return id.startsWith("flixel/") || id.contains(':');
	}
	#else
	public function new () {}
	#end
	
	#if (FLX_DEFAULT_SOUND_EXT == "1" || FLX_NO_DEFAULT_SOUND_EXT)
	public final defaultSoundExtension:String = #if flash ".mp3" #else ".ogg" #end;
	#else
	public final defaultSoundExtension:String = '.${haxe.macro.Compiler.getDefine("FLX_DEFAULT_SOUND_EXT")}';
	#end
	
	/**
	 * Used by methods like `getAsset`, `getBitmapData`, `getText`, their "unsafe" counterparts and
	 * the like to get assets synchronously. Can be set to a custom function to avoid the existing
	 * asset system. Unlike its "safe" counterpart, there is no log on missing assets
	 * 
	 * @param   id        The id of the asset, usually a path
	 * @param   type      The type of asset to look for, determines the type
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  The asset, if found, otherwise `null` is returned
	 */
	public dynamic function getAssetUnsafe(id:String, type:FlxAssetType, useCache = true):Null<Any>
	{
		#if FLX_STANDARD_ASSETS_DIRECTORY
		return getOpenflAssetUnsafe(id, type, useCache);
		#else
		
		if (useOpenflAssets(id))
			return getOpenflAssetUnsafe(id, type, useCache);
		// load from custom assets directory
		final canUseCache = useCache && Assets.cache.enabled;
		
		final asset:Any = switch type
		{
			// No caching
			case TEXT:
				sys.io.File.getContent(getPath(id));
			case BINARY:
				sys.io.File.getBytes(getPath(id));
			
			// Check cache
			case IMAGE if (canUseCache && Assets.cache.hasBitmapData(id)):
				Assets.cache.getBitmapData(id);
			case SOUND if (canUseCache && Assets.cache.hasSound(id)):
				Assets.cache.getSound(id);
			case FONT if (canUseCache && Assets.cache.hasFont(id)):
				Assets.cache.getFont(id);
			
			// Get asset and set cache
			case IMAGE:
				final bitmap = BitmapData.fromFile(getPath(id));
				if (canUseCache)
					Assets.cache.setBitmapData(id, bitmap);
				bitmap;
			case SOUND:
				final sound = Sound.fromFile(getPath(id));
				if (canUseCache)
					Assets.cache.setSound(id, sound);
				sound;
			case FONT:
				final font = Font.fromFile(getPath(id));
				if (canUseCache)
					Assets.cache.setFont(id, font);
				font;
		}
		
		return asset;
		#end
	}
	
	function getOpenflAssetUnsafe(id:String, type:FlxAssetType, useCache = true):Null<Any>
	{
		// Use openfl assets
		return switch(type)
		{
			case TEXT: Assets.getText(id);
			case BINARY: Assets.getBytes(id);
			case IMAGE: Assets.getBitmapData(id, useCache);
			case SOUND: Assets.getSound(id, useCache);
			case FONT: Assets.getFont(id, useCache);
		}
	}
	
	/**
	 * Calls `getAssetUnsafe` if the asset exists, otherwise logs that the asset is missing, via `FlxG.log`
	 * 
	 * @param   id        The id of the asset, usually a path
	 * @param   type      The type of asset to look for, determines the type
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  How to log, if the asset is not found. Uses `LogStyle.ERROR` by default
	 */
	public function getAsset(id:String, type:FlxAssetType, useCache = true, ?logStyle:LogStyle):Null<Any>
	{
		inline function log(message:String)
		{
			if (logStyle == null)
				logStyle = LogStyle.ERROR;
			FlxG.log.advanced(message, logStyle);
		}
		
		if (exists(id, type))
		{
			if (isLocal(id, type))
				return getAssetUnsafe(id, type, useCache);
			
			log('$type asset "$id" exists, but only asynchronously');
			return null;
		}
		
		log('Could not find a $type asset with ID \'$id\'.');
		return null;
	}
	
	/**
	 * Used by methods like `loadBitmapData`, `loadText` and the like to get assets asynchronously.
	 * Can be set to a custom function to avoid the existing asset system.
	 * 
	 * @param   id        The id of the asset, usually a path
	 * @param   type      The type of asset to look for, determines the type
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public dynamic function loadAsset(id:String, type:FlxAssetType, useCache = true):Future<Any>
	{
		#if FLX_STANDARD_ASSETS_DIRECTORY
		return loadOpenflAsset(id, type, useCache);
		#else
		
		if (useOpenflAssets(id))
			return loadOpenflAsset(id, type, useCache);
		
		// get the asset synchronously and wrap it in a future
		return Future.withValue(getAsset(id, type, useCache));
		// TODO: html?
		#end
	}
	
	function loadOpenflAsset(id:String, type:FlxAssetType, useCache = true):Future<Any>
	{
		return switch(type)
		{
			case TEXT: Assets.loadText(id);
			case BINARY: Assets.loadBytes(id);
			case IMAGE: Assets.loadBitmapData(id, useCache);
			case SOUND: Assets.loadSound(id, useCache);
			case FONT: Assets.loadFont(id, useCache);
		}
	}
	
	/**
	 * Whether a specific asset ID and type exists.
	 * Can be set to a custom function to avoid the existing asset system.
	 * 
	 * @param   id    The ID or asset path for the asset
	 * @param   type  The asset type to match, or null to match any type
	 */
	public dynamic function exists(id:String, ?type:FlxAssetType)
	{
		#if FLX_DEFAULT_SOUND_EXT
		// add file extension
		if (type == SOUND)
			id = addSoundExt(id);
		#end
		
		#if FLX_STANDARD_ASSETS_DIRECTORY
		return Assets.exists(id, type.toOpenFlType());
		#else
		if (useOpenflAssets(id))
			return Assets.exists(id, type.toOpenFlType());
		// Can't verify contents match expected type without
		return sys.FileSystem.exists(getPath(id));
		#end
	}
	
	/**
	 * Returns whether an asset is "local", and therefore can be loaded synchronously, or with the
	 * `getAsset` method, otherwise the `loadAsset` method should be used.
	 * Can be set to a custom function to avoid the existing asset system.
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   type      The asset type to match, or null to match any type
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  Whether the asset is local
	 */
	public dynamic function isLocal(id:String, ?type:FlxAssetType, useCache = true)
	{
		#if FLX_DEFAULT_SOUND_EXT
		// add file extension
		if (type == SOUND)
			id = addSoundExt(id);
		#end
		
		#if FLX_STANDARD_ASSETS_DIRECTORY
		return Assets.isLocal(id, type.toOpenFlType(), useCache);
		#else
		
		if (useOpenflAssets(id))
			Assets.isLocal(id, type.toOpenFlType(), useCache);
		
		return true;
		#end
	}
	
	/**
	 * Returns a list of all assets (by type).
	 * Can be set to a custom function to avoid the existing asset system.
	 * 
	 * @param   type  The asset type to match, or null to match any type
	 * @return  An array of asset ID values
	 */
	public dynamic function list(?type:FlxAssetType)
	{
		#if FLX_STANDARD_ASSETS_DIRECTORY
		return Assets.list(type.toOpenFlType());
		#else
		// list all files in the directory, recursively
		final list = [];
		function addFiles(directory:String, prefix = "")
		{
			for (path in sys.FileSystem.readDirectory(directory))
			{
				if (sys.FileSystem.isDirectory('$directory/$path'))
					addFiles('$directory/$path', prefix + path + '/');
				else
					list.push(prefix + path);
			}
		}
		final prefix = Path.withoutDirectory(directory) + "/";
		addFiles(directory, prefix);
		return list;
		#end
	}
	
	/**
	 * Gets an instance of a bitmap. Unlike its "safe" counterpart, there is no log on missing assets
	 * 
	 * @param   id        The ID or asset path for the bitmap
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  A new BitmapData object
	 */
	public inline function getBitmapDataUnsafe(id:String, useCache = false):BitmapData
	{
		return cast getAssetUnsafe(id, IMAGE, useCache);
	}
	
	/**
	 * Gets an instance of a bitmap, logs when the asset is not found
	 * 
	 * @param   id        The ID or asset path for the bitmap
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  A new BitmapData object
	 */
	public inline function getBitmapData(id:String, useCache = false, ?logStyle:LogStyle):BitmapData
	{
		return cast getAsset(id, IMAGE, useCache, logStyle);
	}
	
	/**
	 * Gets an instance of a sound. Unlike its "safe" counterpart, there is no log on missing assets
	 * 
	 * @param   id        The ID or asset path for the sound
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  A new `Sound` object Note: Dos not return a `FlxSound`
	 */
	public inline function getSoundUnsafe(id:String, useCache = true):Sound
	{
		return cast getAssetUnsafe(addSoundExtIf(id), SOUND, useCache);
	}
	
	/**
	 * Gets an instance of a sound, logs when the asset is not found.
	 * 
	 * **Note:** If the `FLX_DEFAULT_SOUND_EXT` flag is enabled, you may omit the file extension
	 * 
	 * @param   id        The ID or asset path for the sound
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  How to log, if the asset is not found. Uses `LogStyle.ERROR` by default
	 * @return  A new `Sound` object Note: Dos not return a `FlxSound`
	 */
	public inline function getSound(id:String, useCache = true, ?logStyle:LogStyle):Sound
	{
		return cast getAsset(addSoundExtIf(id), SOUND, useCache, logStyle);
	}
	
	/**
	 * Gets an instance of a sound, logs when the asset is not found
	 * 
	 * @param   id        The ID or asset path for the sound
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  How to log, if the asset is not found. Uses `LogStyle.ERROR` by default
	 * @return  A new `Sound` object Note: Dos not return a `FlxSound`
	 */
	public inline function getSoundAddExt(id:String, useCache = true, ?logStyle:LogStyle):Sound
	{
		return getSound(addSoundExt(id), useCache, logStyle);
	}
	
	inline function addSoundExtIf(id:String)
	{
		#if FLX_DEFAULT_SOUND_EXT
		return addSoundExt(id);
		#else
		return id;
		#end
	}
	
	inline function addSoundExt(id:String)
	{
		if (!id.endsWith(".mp3") && !id.endsWith(".ogg") && !id.endsWith(".wav"))
			return id + defaultSoundExtension;
			
		return id;
	}
	
	/**
	 * Gets the contents of a text-based asset. Unlike its "safe" counterpart, there is no log
	 * on missing assets
	 * 
	 * **Note:** The default asset system does not cache text assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public inline function getTextUnsafe(id:String, useCache = true):String
	{
		return cast getAssetUnsafe(id, TEXT, useCache);
	}
	
	/**
	 * Gets the contents of a text-based asset, logs when the asset is not found
	 * 
	 * **Note:** The default asset system does not cache text assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  How to log, if the asset is not found. Uses `LogStyle.ERROR` by default
	 */
	public inline function getText(id:String, useCache = true, ?logStyle:LogStyle):String
	{
		return cast getAsset(id, TEXT, useCache, logStyle);
	}
	
	/**
	 * Parses the contents of an xml-based asset into an `Xml` object.
	 * Unlike its "safe" counterpart, there is no log on missing assets
	 * 
	 * **Note:** The default asset system does not cache xml assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public inline function getXmlUnsafe(id:String, useCache = true)
	{
		final text = getTextUnsafe(id, useCache);
		return text != null ? parseXml(text) : null;
	}
	
	/**
	 * Parses the contents of an xml-based asset into an `Xml` object, logs when the asset is not found
	 * 
	 * **Note:** The default asset system does not cache xml assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  How to log, if the asset is not found. Uses `LogStyle.ERROR` by default
	 */
	public inline function getXml(id:String, useCache = true, ?logStyle:LogStyle)
	{
		final text = getText(id, useCache, logStyle);
		return text != null ? parseXml(text) : null;
	}
	
	/**
	 * Gets the contents of a json-based asset.
	 * Unlike its "safe" counterpart, there is no log on missing assets
	 * 
	 * **Note:** The default asset system does not cache json assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public inline function getJsonUnsafe(id:String, useCache = true)
	{
		final text = getTextUnsafe(id, useCache);
		return text != null ? parseJson(text) : null;
	}
	
	/**
	 * Gets the contents of a json-based asset, logs when the asset is not found
	 * 
	 * **Note:** The default asset system does not cache json assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  How to log, if the asset is not found. Uses `LogStyle.ERROR` by default
	 */
	public inline function getJson(id:String, useCache = true, ?logStyle:LogStyle)
	{
		final text = getText(id, useCache, logStyle);
		return text != null ? parseJson(text) : null;
	}
	
	/**
	 * Gets the contents of a binary asset.
	 * Unlike its "safe" counterpart, there is no log on missing assets
	 * 
	 * **Note:** The default asset system does not cache binary assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public inline function getBytesUnsafe(id:String, useCache = true):Bytes
	{
		return cast getAssetUnsafe(id, BINARY, useCache);
	}
	
	/**
	 * Gets the contents of a binary asset, logs when the asset is not found
	 * 
	 * **Note:** The default asset system does not cache binary assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  How to log, if the asset is not found. Uses `LogStyle.ERROR` by default
	 */
	public inline function getBytes(id:String, useCache = true, ?logStyle:LogStyle):Bytes
	{
		return cast getAsset(id, BINARY, useCache);
	}
	
	/**
	 * Gets the contents of a font asset.
	 * Unlike its "safe" counterpart, there is no log on missing assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache
	 */
	public inline function getFontUnsafe(id:String, useCache = true):Font
	{
		return cast getAssetUnsafe(id, FONT, useCache);
	}
	
	/**
	 * Gets the contents of a font asset, logs when the asset is not found
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  How to log, if the asset is not found. Uses `LogStyle.ERROR` by default
	 */
	public inline function getFont(id:String, useCache = true, ?logStyle:LogStyle):Font
	{
		return cast getAsset(id, FONT, useCache, logStyle);
	}
	
	/**
	 * Loads a bitmap asset asynchronously
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  Returns a `Future` which allows listeners to be added via methods like `onComplete`
	 */
	public inline function loadBitmapData(id:String, useCache = false):Future<BitmapData>
	{
		return cast loadAsset(id, IMAGE, useCache);
	}
	
	/**
	 * Loads a sound asset asynchronously
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  Returns a `Future` which allows listeners to be added via methods like `onComplete`
	 */
	public inline function loadSound(id:String, useCache = true):Future<Sound>
	{
		return cast loadAsset(id, SOUND, useCache);
	}
	
	/**
	 * Loads a text asset asynchronously
	 * 
	 * **Note:** The default asset system does not cache text assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  Returns a `Future` which allows listeners to be added via methods like `onComplete`
	 */
	public inline function loadText(id:String, useCache = true):Future<String>
	{
		return cast loadAsset(id, TEXT, useCache);
	}
	
	/**
	 * Loads an xml asset asynchronously
	 * 
	 * **Note:** The default asset system does not cache xml assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  Returns a `Future` which allows listeners to be added via methods like `onComplete`
	 */
	public inline function loadXml(id:String, useCache = true):Future<Xml>
	{
		return wrapFuture(loadText(id, useCache), parseXml);
	}
	
	/**
	 * Loads a json asset asynchronously
	 * 
	 * **Note:** The default asset system does not cache json assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  Returns a `Future` which allows listeners to be added via methods like `onComplete`
	 */
	public inline function loadJson(id:String, useCache = true):Future<Dynamic>
	{
		return wrapFuture(loadText(id, useCache), parseJson);
	}
	
	/**
	 * Loads a binary asset asynchronously
	 * 
	 * **Note:** The default asset system does not cache binary assets
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  Returns a `Future` which allows listeners to be added via methods like `onComplete`
	 */
	public inline function loadBytes(id:String, useCache = true):Future<Bytes>
	{
		return cast loadAsset(id, BINARY, useCache);
	}
	
	/**
	 * Loads a font asset asynchronously
	 * 
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @return  Returns a `Future` which allows listeners to be added via methods like `onComplete`
	 */
	public inline function loadFont(id:String, useCache = true):Future<Font>
	{
		return cast loadAsset(id, FONT, useCache);
	}
	
	/**
	 * Parses a json string, creates and returns a struct
	 */
	public inline function parseJson(jsonText:String)
	{
		return Json.parse(jsonText);
	}
	
	/**
	 * Parses an xml string, creates and returns an `Xml` object
	 */
	public inline function parseXml(xmlText:String)
	{
		return Xml.parse(xmlText);
	}
	
	inline function wrapFuture<T1, T2>(future:Future<T1>, converter:(T1)->T2):Future<T2>
	{
		final promise = new lime.app.Promise<T2>();
		
		future.onComplete((data)->promise.complete(converter(data)));
		future.onError((error)->promise.error(error));
		future.onProgress((progress, total)->promise.progress(progress, total));
		
		return promise.future;
	}
}

/**
 * The AssetType enum lists the core set of available
 * asset types from the OpenFL command-line tools.
 * @since 5.9.0
 */
enum abstract FlxAssetType(String)
{
	/** Binary assets (data that is not readable as text) */
	var BINARY = "binary";
	
	/** Font assets, such as *.ttf or *.otf files */
	var FONT = "font";
	
	/** Image assets, such as *.png or *.jpg files */
	var IMAGE ="image";
	
	/** Audio assets, such as *.ogg or *.wav files */
	var SOUND = "sound";
	
	/** Text assets */
	var TEXT = "text";
	
	public function toOpenFlType()
	{
		return switch((cast this:FlxAssetType))
		{
			case BINARY: AssetType.BINARY;
			case FONT: AssetType.FONT;
			case IMAGE: AssetType.IMAGE;
			case SOUND: AssetType.SOUND;
			case TEXT: AssetType.TEXT;
		}
	}
}
