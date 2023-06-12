package flixel.util;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.errors.Error;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

/**
 * A class to help automate and simplify save game functionality. A simple wrapper for the OpenFl's
 * SharedObject, with a couple helpers. It's used automatically by various flixel utilities like
 * the sound tray, as well as some debugging features.
 * 
 * ## Resources
 * - [Handbook - FlxSave](https://haxeflixel.com/documentation/flxsave/)
 * - [Demo - Save](https://haxeflixel.com/demos/Save/)
 * 
 * ## Making your own
 * You can use a specific save name and path by calling the following,
 * ```haxe
 * FlxG.save.bind("myGameName", "myGameStudioName");
 * ```
 * It is recommended that you do so before creating an instance of FlxGame.
 * 
 * Note: It is NOT recommended to make you own instance of `FlxSave`, one is made for you when
 * a FlxGame is created at `FlxG.save`. The default `name` and `path` is specified by your
 * Project.xml's "file" and "company", respectively. That said, nothing is stopping you from
 * instantiating your own instance.
 * 
 * ## Default Paths
 * - Windows: ```"C:\Users\<username>\AppData\Roaming\<localPath>\<name>.sol"```
 * - Mac: ```"/Users/<username>/Library/Application Support/<localPath>/<name>.sol"```
 * - Chrome: In the developer tools, go to the Application tab, and under
 *     `Storage->Local Storage->https://<url>.com` with the key:`<localPath>:<name>"`
 * 
 * ## 5.0.0 Migration
 * In older version of flixel, a null path on html5 would use the current url. FlxSaves with a
 * null path will now look for that path, if the new default path is not found. If data is found
 * at the legacy, it is loaded, but `flush` calls will save to the new default path. The old save
 * is not deleted.
 * 
 * Prior to 5.0.0, FlxG.save's default save name was `"flixel"`, now it uses the project name as
 * defined in Project.xml. FlxG.save will automatically look for the old default save if the new
 * one is not found, and any flush call will save to the new path and id.
 * 
 * Previously, on desktop targets, saves were added to subfolders based on the project's name and
 * company, eg: `"/<app company>/<app title>/<localPath>/<name>.sol"`. This prevent separate
 * projects from referencing each others saves (this was OpenFL attempting to mirror Flash's
 * SharedObject behaviour). To allow cross-save referencing, the new location is simply: 
 * `'/<localPath>/<name>.sol'`. If no data is found in this location, `FlxSave` will look in the
 * old location, any `flush` call will save to the new location. For example, a save named with the
 * old default name `"flixel"` may be saved at `"<...>/FooBarGames/PorbsAdventure/flixel.sol"`.
 * The new default save name "PorbsAdventure" would be at `"<...>/FooBarGames/PorbsAdventure.sol"`.
 * @see [Flixel 5.0.0 Migration guide](https://github.com/HaxeFlixel/flixel/wiki/Flixel-5.0.0-Migration-guide)
 */
@:allow(flixel.util.FlxSharedObject)
class FlxSave implements IFlxDestroyable
{
	
	static var invalidChars = ~/[ ~%&\\;:"',<>?#]+/g;
	
	/**
	 * Checks for `~%&\;:"',<>?#` or space characters
	 */
	static function hasInvalidChars(str:String)
	{
		#if html5
		// most chars are fine on browsers
		return true;
		#else
		return invalidChars.match(str);
		#end
	}
	
	/**
	 * Converts invalid characters to "-", producing a valid string for a FlxSave's name and path
	 */
	@:allow(flixel.FlxG.initSave)
	static function validate(str:String)
	{
		#if html5
		// most chars are fine on browsers
		return str;
		#else
		return invalidChars.split(str).join("-");
		#end
	}
	
	/**
	 * Converts invalid characters to "-", and logs a warning in debug mode
	 */
	static function validateAndWarn(str, fieldId:String)
	{
		var newStr = validate(str);
		#if debug
		if (newStr != str)
			FlxG.log.warn('FlxSave $fieldId: "$str" contains invalid characters, using "$newStr" instead');
		#end
		return newStr;
	}
	
	/**
	 * Allows you to directly access the data container in the local shared object.
	 */
	public var data(default, null):Dynamic;

	/**
	 * The name of the local shared object.
	 */
	public var name(get, never):String;

	/**
	 * The path of the local shared object.
	 * @since 4.6.0
	 */
	public var path(get, never):String;

	/**
	 * The current status of the save.
	 * @since 5.0.0
	 */
	public var status(default, null):FlxSaveStatus = EMPTY;

	/**
	 * Wether the save was successfully bound.
	 * @since 5.0.0
	 */
	public var isBound(get, never):Bool;
	
	/**
	 * The local shared object itself.
	 */
	var _sharedObject:SharedObject;

	public function new() {}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_sharedObject = null;
		status = EMPTY;
		data = null;
	}

	/**
	 * Automatically creates or reconnects to locally saved data.
	 *
	 * @param   name  The name of the save (should be the same each time to access old data).
	 *                May not contain spaces or any of the following characters:
	 *                `~ % & \ ; : " ' , < > ? #`
	 * @param   path  The full or partial path to the file that created the shared object.
	 *                Mainly used to differentiate from other FlxSaves. If you do not specify
	 *                this parameter, the company name specified in your Project.xml is used.
	 * @return  Whether or not you successfully connected to the save data.
	 */
	public function bind(name:String, ?path:String):Bool
	{
		destroy();
		
		name = validateAndWarn(name, "name");
		if (path != null)
			path = validateAndWarn(path, "path");
		
		try
		{
			_sharedObject = FlxSharedObject.getLocal(name, path);
			status = BOUND(name, path);
		}
		catch (e:Error)
		{
			FlxG.log.error('Error:${e.message} name:"$name", path:"$path".');
			destroy();
			return false;
		}
		data = _sharedObject.data;
		return true;
	}

	/**
	 * Creates a new FlxSave and copies the data from old to new,
	 * flushes the new save (if changed) and then optionally erases the old save.
	 * 
	 * @param   name         The name of the save.
	 * @param   path         The full or partial path to the file that created the save.
	 * @param   overwrite    Whether the data should overwrite, should the 2 saves share data fields. defaults to false.
	 * @param   eraseSave    Whether to erase the save after successfully migrating the data. defaults to true.
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @return  Whether or not you successfully found, merged and flushed data.
	 */
	public function mergeDataFrom(name:String, ?path:String, overwrite = false, eraseSave = true, minFileSize = 0):Bool
	{
		if (!checkStatus())
			return false;
		
		final oldSave = new FlxSave();
		// check old save location
		if (oldSave.bind(name, path))
		{
			final success = mergeData(oldSave.data, overwrite, minFileSize);

			if (eraseSave)
				oldSave.erase();
			oldSave.destroy();

			// save changes, if there are any
			return success;
		}

		oldSave.destroy();

		return false;
	}

	/**
	 * Copies the given data over to this save and flushes (if changed).
	 * 
	 * @param   sourceData   The data to merge
	 * @param   overwrite    Whether the data should overwrite, should the 2 saves share data fields. defaults to false.
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @return  Whether or not you successfully saved the data.
	 */
	public function mergeData(sourceData:Dynamic, overwrite = false, minFileSize = 0)
	{
		var hasAnyField = false;
		for (field in Reflect.fields(sourceData))
		{
			hasAnyField = true;
			// Don't overwrite any existing data in the new save
			if (overwrite || !Reflect.hasField(data, field))
				Reflect.setField(data, field, Reflect.field(sourceData, field));
		}

		// save changes, if there are any
		if (hasAnyField)
			return flush(minFileSize);

		return true;
	}

	/**
	 * A way to safely call flush() and destroy() on your save file.
	 * Will correctly handle storage size popups and all that good stuff.
	 * If you don't want to save your changes first, just call destroy() instead.
	 *
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @return  The result of result of the flush() call (see below for more details).
	 */
	public function close(minFileSize:Int = 0):Bool
	{
		var success = flush(minFileSize);
		destroy();
		return success;
	}

	/**
	 * Writes the local shared object to disk immediately. Leaves the object open in memory.
	 *
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @return  Whether or not the data was written immediately. False could be an error OR a storage request popup.
	 */
	public function flush(minFileSize:Int = 0):Bool
	{
		if (!checkStatus())
			return false;

		try
		{
			var result = _sharedObject.flush(minFileSize);

			if (result != FLUSHED)
				status = ERROR("FlxSave is requesting extra storage space.");
		}
		catch (e:Error)
		{
			status = ERROR("There was an problem flushing the save data.");
		}

		checkStatus();

		return isBound;
	}

	/**
	 * Erases everything stored in the local shared object.
	 * Data is immediately erased and the object is saved that way,
	 * so use with caution!
	 *
	 * @return	Returns false if the save object is not bound yet.
	 */
	public function erase():Bool
	{
		if (!checkStatus())
			return false;

		_sharedObject.clear();
		data = {};
		return true;
	}

	/**
	 * Handy utility function for checking and warning if the shared object is bound yet or not.
	 *
	 * @return	Whether the shared object was bound yet.
	 */
	function checkStatus():Bool
	{
		switch (status)
		{
			case EMPTY:
				FlxG.log.warn("You must call FlxSave.bind() before you can read or write data.");
			case ERROR(msg):
				FlxG.log.error(msg);
			default:
				return true;
		}
		return false;
	}

	function get_name()
	{
		return switch (status)
		{
			// can't use the pattern var `name` or it will break in 4.0.5
			case BOUND(n, _): n;
			default: null;
		}
	}

	function get_path()
	{
		return switch (status)
		{
			// can't use the pattern var `path` or it will break in 4.0.5
			case BOUND(_, p): p;
			default: null;
		}
	}

	inline function get_isBound()
	{
		return status.match(BOUND(_, _));
	}

	/**
	 * Scans the data for any properties.
	 * @since 5.0.0
	 */
	public function isEmpty()
	{
		return data == null || Reflect.fields(data).length == 0;
	}
}

/**
 * Internal helper for overriding OpenFL save directories. Ignored on flash. If no data is found at
 * the desired path, it will check the legacy path, but `flush` calls will save to the new path.
 * 
 * ## Paths
 * - Windows: ```"C:\Users\<username>\AppData\Roaming\<localPath>\<name>.sol"```
 * - Mac: ```"/Users/<username>/Library/Application Support/<localPath>/<name>.sol"```
 * 
 * If localPath is null, the Project.xml's app company metadata is used. FlxG.save's default bind
 * args are `bind(app.company, app.file)`.
 * 
 * ## Legacy Paths
 * Openfl's default save location are created using app metadata from the Project.xml
 * - Windows: ```"C:\Users\<username>\AppData\Roaming\<app company>\<app title>\<localPath>\<name>.sol"```
 * - Mac: ```"/Users/<username>/Library/Application Support/<app company>/<app title>/<localPath>/<name>.sol"```
 * 
 * This prevents 2 different HaxeFlixel apps from using each other's save files, but cross-save
 * referencing is a really cool idea so let's allow it!
 */
@:access(openfl.net.SharedObject)
private class FlxSharedObject extends SharedObject
{
	#if (flash || android || ios)
	/** Use SharedObject as usual */
	public static inline function getLocal(name:String, ?localPath:String):SharedObject
	{
		return SharedObject.getLocal(name, localPath);
	}
	
	public static inline function exists(name:String, ?path:String)
	{
		return true;
	}
	#else
	static var all:Map<String, FlxSharedObject>;
	
	static function init()
	{
		if (all == null)
		{
			all = new Map();
			
			var app = lime.app.Application.current;
			if (app != null)
				app.onExit.add(onExit);
		}
	}
	
	static function onExit(_)
	{
		for (sharedObject in all)
			sharedObject.flush();
	}
	
	/**
	 * Returns the company name listed in the Project.xml
	 */
	static function getDefaultLocalPath()
	{
		var meta = openfl.Lib.current.stage.application.meta;
		var path = meta["company"];
		if (path == null || path == "")
			path = "HaxeFlixel";
		else
			path = FlxSave.validate(path);
		
		return path;
	}
	
	public static function getLocal(name:String, ?localPath:String):SharedObject
	{
		if (name == null || name == "")
			throw new Error('Error: Invalid name:"$name".');
		
		if (localPath == null)
			localPath = "";
		
		var id = localPath + "/" + name;
		
		init();
		
		if (!all.exists(id))
		{
			var encodedData = null;
			
			try
			{
				if (~/(?:^|\/)\.\.\//.match(localPath))
					throw new Error("../ not allowed in localPath");
				
				encodedData = getData(name, localPath);
			}
			catch (e:Dynamic) {}
			
			if (localPath == "")
				localPath = getDefaultLocalPath();
			
			final sharedObject = new FlxSharedObject();
			sharedObject.data = {};
			sharedObject.__localPath = localPath;
			sharedObject.__name = name;
			
			if (encodedData != null && encodedData != "")
			{
				try
				{
					final unserializer = new haxe.Unserializer(encodedData);
					final resolver = { resolveEnum: Type.resolveEnum, resolveClass: SharedObject.__resolveClass };
					unserializer.setResolver(cast resolver);
					sharedObject.data = unserializer.unserialize();
				}
				catch (e:Dynamic) {}
			}
			
			all.set(id, sharedObject);
		}
		
		return all.get(id);
	}
	
	#if (js && html5)
	static function getData(name:String, ?localPath:String)
	{
		final storage = js.Browser.getLocalStorage();
		if (storage == null)
			return null;
		
		function get(path:String)
		{
			return storage.getItem(path + ":" + name);
		}
		
		// do not check for legacy saves when path is provided
		if (localPath != "")
			return get(localPath);
		
		var encodedData:String;
		// check default localPath
		encodedData = get(getDefaultLocalPath());
		if (encodedData != null)
			return encodedData;
		
		// check pre-5.0.0 default local path
		encodedData = get(js.Browser.window.location.pathname);
		if (encodedData != null)
			return encodedData;
		
		// check pre-4.6.0 default local path
		return get(js.Browser.window.location.href);
	}
	
	public static function exists(name:String, ?localPath:String)
	{
		final storage = js.Browser.getLocalStorage();
		
		if (storage == null)
			return false;
		
		inline function has(path:String)
		{
			return storage.getItem(path + ":" + name) != null;
		}
		
		return has(localPath)
			|| has(getDefaultLocalPath())
			|| has(js.Browser.window.location.pathname)
			|| has(js.Browser.window.location.href);
	}
	
	// should include every sys target
	#else
	
	static function getData(name:String, ?localPath:String)
	{
		var path = getPath(localPath, name);
		if (sys.FileSystem.exists(path))
			return sys.io.File.getContent(path);
		
		// No save found, check the legacy save path
		path = getLegacyPath(localPath, name);
		if (sys.FileSystem.exists(path))
			return sys.io.File.getContent(path);
		
		return null;
	}
	
	static function getPath(localPath:String, name:String):String
	{
		// Avoid ever putting .sol files directly in AppData
		if (localPath == "")
			localPath = getDefaultLocalPath();
		
		var directory = lime.system.System.applicationStorageDirectory;
		var path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		
		name = StringTools.replace(name, "//", "/");
		name = StringTools.replace(name, "//", "/");
		
		if (StringTools.startsWith(name, "/"))
		{
			name = name.substr(1);
		}
		
		if (StringTools.endsWith(name, "/"))
		{
			name = name.substring(0, name.length - 1);
		}
		
		if (name.indexOf("/") > -1)
		{
			var split = name.split("/");
			name = "";
			
			for (i in 0...(split.length - 1))
			{
				name += "#" + split[i] + "/";
			}
			
			name += split[split.length - 1];
		}
		
		return path + name + ".sol";
	}
	
	/**
	 * Whether the save exists, checks both the old and new path.
	 */
	public static inline function exists(name:String, ?localPath:String)
	{
		return newExists(localPath, name)
			|| legacyExists(localPath, name);
	}
	
	/**
	 * Whether the save exists, checks the NEW location
	 */
	static inline function newExists(name:String, ?localPath:String)
	{
		return sys.FileSystem.exists(getPath(localPath, name));
	}
	
	static inline function getLegacyPath(localPath:String, name:String)
	{
		return SharedObject.__getPath(localPath, name);
	}
	
	/**
	 * Whether the save exists, checks the LEGACY location
	 */
	static inline function legacyExists(name:String, ?localPath:String)
	{
		return sys.FileSystem.exists(getLegacyPath(localPath, name));
	}
	
	override function flush(minDiskSpace:Int = 0)
	{
		if (Reflect.fields(data).length == 0)
		{
			return SharedObjectFlushStatus.FLUSHED;
		}
		
		var encodedData = haxe.Serializer.run(data);
		
		try
		{
			var path = getPath(__localPath, __name);
			var directory = haxe.io.Path.directory(path);
			
			if (!sys.FileSystem.exists(directory))
				SharedObject.__mkdir(directory);
			
			var output = sys.io.File.write(path, false);
			output.writeString(encodedData);
			output.close();
		}
		catch (e:Dynamic)
		{
			return SharedObjectFlushStatus.PENDING;
		}
		
		return SharedObjectFlushStatus.FLUSHED;
	}
	
	override function clear()
	{
		data = {};
		
		try
		{
			var path = getPath(__localPath, __name);
			
			if (sys.FileSystem.exists(path))
				sys.FileSystem.deleteFile(path);
		}
		catch (e:Dynamic) {}
	}
	#end
	#end
}

enum FlxSaveStatus
{
	/**
	 * The initial state, call bind() in order to use.
	 */
	EMPTY;

	/**
	 * The save is set up correctly.
	 */
	BOUND(name:String, ?path:String);

	/**
	 * There was an issue.
	 */
	ERROR(msg:String);
}
