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
 * It is not recommended to make you own instance of `FlxSave`, one is made
 * for you when a FlxGame is created at `FlxG.save`. The default `name` and
 * `path` is specified by your Project.xml's "file" and "company",
 * respectively. That said, nothing is stopping you from instantiating
 * your own instance.
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
	public var name(default, null):String;

	/**
	 * The path of the local shared object.
	 * @since 4.6.0
	 */
	public var path(default, null):String;

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
		name = null;
		path = null;
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
		this.name = name;
		this.path = path;
		try
		{
			_sharedObject = SharedObject.getLocal(name, path);
		}
		catch (e:Error)
		{
			FlxG.log.error("There was a problem binding to\nthe shared object data from FlxSave.");
			destroy();
			return false;
		}
		data = _sharedObject.data;
		return true;
	}

	/**
	 * A way to safely call flush() and destroy() on your save file.
	 * Will correctly handle storage size popups and all that good stuff.
	 * If you don't want to save your changes first, just call destroy() instead.
	 *
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @param   onComplete   This callback will be triggered when the data is written successfully.
	 * @return  The result of result of the flush() call (see below for more details).
	 */
	public function close(minFileSize:Int = 0, ?onComplete:Bool->Void):Bool
	{
		var success = flush(minFileSize, onComplete);
		destroy();
		return success;
	}

	/**
	 * Writes the local shared object to disk immediately. Leaves the object open in memory.
	 *
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @param   onComplete   This callback will be triggered when the data is written successfully.
	 * @return  Whether or not the data was written immediately. False could be an error OR a storage request popup.
	 */
	public function flush(minFileSize:Int = 0, ?onComplete:Bool->Void):Bool
	{
		if (!checkBinding())
			return false;

		var result = null;
		try
		{
			result = _sharedObject.flush();
		}
		catch (_:Error)
		{
			return onDone(ERROR, onComplete);
		}

		return onDone(result == FLUSHED ? SUCCESS : PENDING, onComplete);
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
		if (!checkBinding())
		{
			return false;
		}
		_sharedObject.clear();
		data = {};
		return true;
	}

	/**
	 * Event handler for special case storage requests.
	 * Handles logging of errors and calling of callback.
	 *
	 * @param   result  One of the result codes (PENDING, ERROR, or SUCCESS).
	 * @return  Whether the operation was a success or not.
	 */
	function onDone(result:FlxSaveStatus, ?onComplete:Bool->Void):Bool
	{
		switch (result)
		{
			case PENDING:
				FlxG.log.warn("FlxSave is requesting extra storage space.");
			case ERROR:
				FlxG.log.error("There was a problem flushing\nthe shared object data from FlxSave.");
			default:
		}

		if (onComplete != null)
			onComplete(result == SUCCESS);

		return result == SUCCESS;
	}

	/**
	 * Handy utility function for checking and warning if the shared object is bound yet or not.
	 *
	 * @return	Whether the shared object was bound yet.
	 */
	function checkBinding():Bool
	{
		if (_sharedObject == null)
		{
			FlxG.log.warn("You must call FlxSave.bind()\nbefore you can read or write data.");
			return false;
		}
		return true;
	}
}

enum FlxSaveStatus
{
	SUCCESS;
	PENDING;
	ERROR;
}
