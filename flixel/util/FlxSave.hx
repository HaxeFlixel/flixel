package flixel.util;

import flash.errors.Error;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * A class to help automate and simplify save game functionality.
 * Basically a wrapper for the Flash SharedObject thing, but
 * handles some annoying storage request stuff too.
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

	/**
	 * Internal tracker for callback function in case save takes too long.
	 */
	var _onComplete:Bool->Void;

	/**
	 * Internal tracker for save object close request.
	 */
	var _closeRequested:Bool = false;

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
		_onComplete = null;
		_closeRequested = false;
	}

	/**
	 * Automatically creates or reconnects to locally saved data.
	 *
	 * @param	Name	The name of the object (should be the same each time to access old data).
	 * 					May not contain spaces or any of the following characters: `~ % & \ ; : " ' , < > ? #`
	 * @param	Path	The full or partial path to the file that created the shared object,
	 * 					and that determines where the shared object will be stored locally.
	 * 					If you do not specify this parameter, the full path is used.
	 * @return	Whether or not you successfully connected to the save data.
	 */
	public function bind(Name:String, ?Path:String):Bool
	{
		destroy();
		name = Name;
		path = Path;
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
	 * @param	MinFileSize		If you need X amount of space for your save, specify it here.
	 * @param	OnComplete		This callback will be triggered when the data is written successfully.
	 * @return	The result of result of the flush() call (see below for more details).
	 */
	public function close(MinFileSize:Int = 0, ?OnComplete:Bool->Void):Bool
	{
		_closeRequested = true;
		return flush(MinFileSize, OnComplete);
	}

	/**
	 * Writes the local shared object to disk immediately. Leaves the object open in memory.
	 *
	 * @param	MinFileSize		If you need X amount of space for your save, specify it here.
	 * @param	OnComplete		This callback will be triggered when the data is written successfully.
	 * @return	Whether or not the data was written immediately. False could be an error OR a storage request popup.
	 */
	public function flush(MinFileSize:Int = 0, ?OnComplete:Bool->Void):Bool
	{
		if (!checkBinding())
		{
			return false;
		}
		_onComplete = OnComplete;
		var result = null;
		try
		{
			result = _sharedObject.flush();
		}
		catch (_:Error)
		{
			return onDone(ERROR);
		}

		return onDone(result == SharedObjectFlushStatus.FLUSHED ? SUCCESS : PENDING);
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
	 * @param	Result		One of the result codes (PENDING, ERROR, or SUCCESS).
	 * @return	Whether the operation was a success or not.
	 */
	function onDone(Result:FlxSaveStatus):Bool
	{
		switch (Result)
		{
			case FlxSaveStatus.PENDING:
				FlxG.log.warn("FlxSave is requesting extra storage space.");
			case FlxSaveStatus.ERROR:
				FlxG.log.error("There was a problem flushing\nthe shared object data from FlxSave.");
			default:
		}

		if (_onComplete != null)
			_onComplete(Result == SUCCESS);

		if (_closeRequested)
			destroy();

		return Result == SUCCESS;
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
