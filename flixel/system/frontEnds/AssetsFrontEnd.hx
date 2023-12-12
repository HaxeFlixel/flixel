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
 * @since 5.6.0
 */
class AssetsFrontEnd
{
	public function new () {}
	
	/**
	 * Used by methods like `getBitmapData`, `getText` and the like to get assets synchronously.
	 * Can be set to a custom function to avoid the existing asset system.
	 * @param   id        The id of the asset, usually a path
	 * @param   type      The type of asset to look for, determines the type
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public dynamic function getAsset(id:String, type:FlxAssetType, useCache = true):Any
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
	
	public function getAssetAndLog(id:String, type:FlxAssetType, useCache = true, ?logStyle:LogStyle):Any
	{
		if (exists(id, type))
			return getAsset(id, type, useCache);
		
		if (logStyle == null)
			logStyle = LogStyle.WARNING;
		FlxG.log.advanced('Could not find a $type asset with ID \'$id\'.', logStyle);
		return null;
	}
	
	/**
	 * Used by methods like `loadBitmapData`, `loadText` and the like to get assets asynchronously.
	 * Can be set to a custom function to avoid the existing asset system.
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
	 * Returns whether a specific asset exists. 
	 * @param   id    The ID or asset path for the asset
	 * @param   type  The asset type to match, or null to match any type
	 * @return  Whether the requested asset ID and type exists
	**/
	public dynamic function exists(id:String, ?type:FlxAssetType)
	{
		return Assets.exists(id, type.toOpenFlType());
	}
	
	/**
	 * Returns whether an asset is "local", and therefore can be loaded synchronously
	 * @param   id        The ID or asset path for the asset
	 * @param   type      The asset type to match, or null to match any type
	 * @param   useCache  Whether to allow use of the asset cache
	 * @return  Whether the asset is local
	 */
	public inline function isLocal(id:String, ?type:FlxAssetType, useCache = true)
	{
		return Assets.isLocal(id, type.toOpenFlType(), useCache);
	}
	
	/**
	 * Returns a list of all assets (by type)
	 * @param   type  The asset type to match, or null to match any type
	 * @return  An array of asset ID values
	**/
	public inline function list(?type:FlxAssetType)
	{
		return Assets.list(type.toOpenFlType());
	}
	
	/**
	 * Gets an instance of a bitmap
	 * @param   id        The ID or asset path for the bitmap
	 * @param   useCache  Whether to allow use of the asset cache
	 * @return  A new BitmapData object
	**/
	public inline function getBitmapData(id:String, useCache = false):BitmapData
	{
		return cast getAsset(id, IMAGE, useCache);
	}
	
	/**
	 * Gets an instance of a bitmap, logs when the asset is not found.
	 * @param   id        The ID or asset path for the bitmap
	 * @param   useCache  Whether to allow use of the asset cache
	 * @return  A new BitmapData object
	**/
	public inline function getBitmapDataWarn(id:String, useCache = false, ?logStyle:LogStyle):BitmapData
	{
		return cast getAssetAndLog(id, IMAGE, useCache, logStyle);
	}
	
	/**
	 * Gets an instance of a sound
	 * @param   id        The ID or asset path for the sound
	 * @param   useCache  Whether to allow use of the asset cache
	 * @return  A new `Sound` object Note: Dos not return a `FlxSound`
	 */
	public inline function getSound(id:String, useCache = true):Sound
	{
		return cast getAsset(id, SOUND, useCache);
	}
	
	/**
	 * Gets an instance of a sound, logs when the asset is not found.
	 * @param   id        The ID or asset path for the sound
	 * @param   useCache  Whether to allow use of the asset cache
	 * @param   logStyle  Determines how the missing asset message is logged
	 * @return  A new `Sound` object Note: Dos not return a `FlxSound`
	 */
	public inline function getSoundWarn(id:String, useCache = true, ?logStyle:LogStyle):Sound
	{
		return cast getAssetAndLog(id, SOUND, useCache, logStyle);
	}
	
	/**
	 * Gets the contents of a text-based asset
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public inline function getText(id:String, useCache = true):String
	{
		return cast getAsset(id, TEXT, useCache);
	}
	
	/**
	 * Gets the contents of a text-based asset, logs when the asset is not found.
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  Determines how the missing asset message is logged
	 */
	public inline function getTextWarn(id:String, useCache = true, ?logStyle:LogStyle):String
	{
		return cast getAssetAndLog(id, TEXT, useCache, logStyle);
	}
	
	/**
	 * Parses the contents of a xml-based asset into an `Xml` object
	 * @param   id  The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public inline function getXml(id:String, useCache = true)
	{
		final text = getText(id, useCache);
		return text != null ? parseXml(text) : null;
	}
	
	/**
	 * Parses the contents of a xml-based asset into an `Xml` object
	 * @param   id  The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  Determines how the missing asset message is logged
	 */
	public inline function getXmlWarn(id:String, useCache = true, ?logStyle:LogStyle)
	{
		final text = getTextWarn(id, useCache, logStyle);
		return text != null ? parseXml(text) : null;
	}
	
	/**
	 * Gets the contents of a xml-based asset
	 * @param   id  The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public inline function getJson(id:String, useCache = true)
	{
		final text = getText(id, useCache);
		return text != null ? parseJson(text) : null;
	}
	
	/**
	 * Gets the contents of a xml-based asset
	 * @param   id  The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  Determines how the missing asset message is logged
	 */
	public inline function getJsonWarn(id:String, useCache = true, ?logStyle:LogStyle)
	{
		final text = getTextWarn(id, useCache, logStyle);
		return text != null ? parseJson(text) : null;
	}
	
	/**
	 * Gets the contents of a binary asset
	 * @param   id  The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 */
	public inline function getBytes(id:String, useCache = true):Bytes
	{
		return cast getAsset(id, BINARY, useCache);
	}
	
	/**
	 * Gets the contents of a binary asset
	 * @param   id  The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache (if one exists)
	 * @param   logStyle  Determines how the missing asset message is logged
	 */
	public inline function getBytesWarn(id:String, useCache = true, ?logStyle:LogStyle):Bytes
	{
		return cast getAssetAndLog(id, BINARY, useCache);
	}
	
	/**
	 * Gets the contents of a font asset
	 * @param   id  The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache
	 */
	public inline function getFont(id:String, useCache = true):Font
	{
		return cast getAsset(id, FONT, useCache);
	}
	
	/**
	 * Gets the contents of a font asset
	 * @param   id  The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache
	 * @param   logStyle  Determines how the missing asset message is logged
	 */
	public inline function getFontWarn(id:String, useCache = true, ?logStyle:LogStyle):Font
	{
		return cast getAssetAndLog(id, FONT, useCache, logStyle);
	}
	
	/**
	 * Loads an bitmap asset asynchronously
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache
	 * @return  Returns a `Future` which allows listeners to be added via methods like `onComplete`
	 */
	public inline function loadBitmapData(id:String, useCache = false):Future<BitmapData>
	{
		return cast loadAsset(id, IMAGE, useCache);
	}
	
	/**
	 * Loads a sound asset asynchronously
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache
	 * @return  Returns a `Future` which allows listeners to be added via methods like `onComplete`
	 */
	public inline function loadSound(id:String, useCache = true):Future<Sound>
	{
		return cast loadAsset(id, SOUND, useCache);
	}
	
	/**
	 * Loads a text asset asynchronously
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
	 * @param   id        The ID or asset path for the asset
	 * @param   useCache  Whether to allow use of the asset cache
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
 */
enum abstract FlxAssetType(String)
{
	/** Binary assets (data that is not readable as text) */
	public var BINARY = "binary";
	
	/** Font assets, such as *.ttf or *.otf files */
	public var FONT = "font";
	
	/** Image assets, such as *.png or *.jpg files */
	public var IMAGE ="image";
	
	/** Audio assets, such as *.ogg or *.wav files */
	public var SOUND = "sound";
	
	/** Text assets */
	public var TEXT = "text";
	
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
