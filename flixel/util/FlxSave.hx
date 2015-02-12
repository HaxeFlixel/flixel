package flixel.util;

import flash.errors.Error;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

#if flash
import flash.events.NetStatusEvent;
#end

/**
 * A class to help automate and simplify save game functionality.
 * Basicaly a wrapper for the Flash SharedObject thing, but
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
	 * The local shared object itself.
	 */
	private var _sharedObject:SharedObject;
	
	/**
	 * Internal tracker for callback function in case save takes too long.
	 */
	private var _onComplete:Bool->Void;
	/**
	 * Internal tracker for save object close request.
	 */
	private var _closeRequested:Bool = false;
	
	public function new() {}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_sharedObject = null;
		name = null;
		data = null;
		_onComplete = null;
		_closeRequested = false;
	}
	
	/**
	 * Automatically creates or reconnects to locally saved data.
	 * 
	 * @param	Name	The name of the object (should be the same each time to access old data).
	 * @return	Whether or not you successfully connected to the save data.
	 */
	public function bind(Name:String):Bool
	{
		destroy();
		name = Name;
		try
		{
			_sharedObject = SharedObject.getLocal(name);
		}
		catch(e:Error)
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
	 * @return	Whether or not the data was written immediately.  False could be an error OR a storage request popup.
	 */
	public function flush(MinFileSize:Int = 0, ?OnComplete:Bool->Void):Bool
	{
		if (!checkBinding())
		{
			return false;
		}
		_onComplete = OnComplete;
		#if flash
		var result:String = null;
		#else
		var result:SharedObjectFlushStatus;
		#end
		try 
		{ 
			#if !js
			result = _sharedObject.flush(MinFileSize); 
			#else
			result = _sharedObject.flush(); 
			#end
		}
		catch (e:Error) { return onDone(ERROR); }
		#if flash
		if (result == "pending")
		#else
		if (result == SharedObjectFlushStatus.PENDING)
		#end
		{
			#if flash
			_sharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
			#end
		}
		#if flash
		return onDone((result == "flushed") ? SUCCESS : PENDING);
		#else
		return onDone((result == SharedObjectFlushStatus.FLUSHED) ? SUCCESS : PENDING);
		#end
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
	 */
	#if flash
	private function onFlushStatus(E:NetStatusEvent):Void
	{
		_sharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
		onDone((E.info.code == "SharedObject.Flush.Success") ? SUCCESS : ERROR);
	}
	#end
	
	/**
	 * Event handler for special case storage requests.
	 * Handles logging of errors and calling of callback.
	 * 
	 * @param	Result		One of the result codes (PENDING, ERROR, or SUCCESS).
	 * @return	Whether the operation was a success or not.
	 */
	private function onDone(Result:FlxSaveStatus):Bool
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
	private function checkBinding():Bool
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