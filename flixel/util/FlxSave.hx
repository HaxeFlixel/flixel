package flixel.util;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.errors.Error;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

/**
 * A class to help automate and simplify save game functionality. A simple
 * wrapper for the OpenFl's SharedObject, with a cople helpers. It's used
 * automatically by various flixel utilities like the sound tray, as well as
 * some debugging features.
 * 
 * ## Making your own
 * You can use a specific save name and path by calling the following,
 * ```haxe
 * FlxG.save.bind("myGameName", "myGameStudioName");
 * ```
 * It is recommended thatg you do so before creating an instance of FlxGame.
 * 
 * It is not recommended to make you own instance of `FlxSave`, one is made
 * for you when a FlxGame is created at `FlxG.save`. The default `name` and
 * `path` is specified by your Project.xml's "file" and "company",
 * respectively. That said, nothing is stopping you from instantiating
 * your own instance.
 * ## Default Paths
 * - Windows: ```"C:\Users\<username>\AppData\Roaming\<localPath>/<name>.sol"```
 * - Mac: ```"/Users/<username>/Library/Application Support/<localPath>/<name>.sol"```
 * - Chrome: In the developer tools, go to the Application tab, and under
 *     `Storage->Local Storage->https://<url>.com` with the key:`<localPath>:<name>"`
 */
class FlxSave implements IFlxDestroyable
{
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
	 *                Mainly used to differentiate from other FlxSaves.
	 *                If you do not specify this parameter, the full path is used.
	 * @return  Whether or not you successfully connected to the save data.
	 */
	public function bind(name:String, ?path:String):Bool
	{
		destroy();
		try
		{
			_sharedObject = SharedObject.getLocal(name, path);
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
			final success = mergeData(oldSave.data);

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
		if (data != null)
		{
			for (fields in Reflect.fields(data))
				return false;
		}
		
		return true;
	}
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
