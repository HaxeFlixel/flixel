package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.debug.log.LogStyle;
import haxe.io.Bytes;
import haxe.Json;
import haxe.xml.Access;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Future;
import openfl.text.Font;

/**
 * Accessed via `FlxG.log`
 * 
 * @since 5.9.0
 */
class AssetsFrontEnd
{
	public function new () {}
	
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
		if (exists(id, type))
			return getAssetUnsafe(id, type, useCache);
		
		if (logStyle == null)
			logStyle = LogStyle.ERROR;
		FlxG.log.advanced('Could not find a $type asset with ID \'$id\'.', logStyle);
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
		return Assets.exists(id, type.toOpenFlType());
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
		return Assets.isLocal(id, type.toOpenFlType(), useCache);
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
		return Assets.list(type.toOpenFlType());
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
		return cast getAssetUnsafe(id, SOUND, useCache);
	}
	
	/**
	 * Gets an instance of a sound, logs when the asset is not found
	 * 
	 * @param   id        The ID or asset path for the sound
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  How to log, if the asset is not found. Uses `LogStyle.ERROR` by default
	 * @return  A new `Sound` object Note: Dos not return a `FlxSound`
	 */
	public inline function getSound(id:String, useCache = true, ?logStyle:LogStyle):Sound
	{
		return cast getAsset(id, SOUND, useCache, logStyle);
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
	 * Parses the contents of a xml-based asset into an `Xml` object.
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
	 * Parses the contents of a xml-based asset into an `Xml` object, logs when the asset is not found
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
	 * Gets the contents of a xml-based asset.
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
	 * Gets the contents of a xml-based asset, logs when the asset is not found
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
	 * Loads an bitmap asset asynchronously
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
	 * Loads a text asset asynchronously
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
	 * Loads a text asset asynchronously
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
	 * Parses an xml string, creates and returns an Xml object
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
