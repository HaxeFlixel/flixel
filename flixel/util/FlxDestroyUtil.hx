package flixel.util;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flixel.util.FlxPool.IFlxPooled;

class FlxDestroyUtil
{
	/**
	 * Checks if an object is not null before calling destroy(), always returns null.
	 *
	 * @param	object	An IFlxDestroyable object that will be destroyed if it's not null.
	 * @return	null
	 */
	public static function destroy<T:IFlxDestroyable>(object:Null<IFlxDestroyable>):T
	{
		if (object != null)
		{
			object.destroy();
		}
		return null;
	}

	/**
	 * Destroy every element of an array of IFlxDestroyables
	 *
	 * @param	array	An Array of IFlxDestroyable objects
	 * @return	null
	 */
	public static function destroyArray<T:IFlxDestroyable>(array:Array<T>):Array<T>
	{
		if (array != null)
		{
			for (e in array)
				destroy(e);
			array.splice(0, array.length);
		}
		return null;
	}

	/**
	 * Checks if an object is not null before putting it back into the pool, always returns null.
	 *
	 * @param	object	An IFlxPooled object that will be put back into the pool if it's not null
	 * @return	null
	 */
	public static function put<T:IFlxPooled>(object:IFlxPooled):T
	{
		if (object != null)
		{
			object.put();
		}
		return null;
	}

	/**
	 * Puts all objects in an Array of IFlxPooled objects back into
	 * the pool by calling FlxDestroyUtil.put() on them
	 *
	 * @param	array	An Array of IFlxPooled objects
	 * @return	null
	 */
	public static function putArray<T:IFlxPooled>(array:Array<T>):Array<T>
	{
		if (array != null)
		{
			for (e in array)
				put(e);
			array.splice(0, array.length);
		}
		return null;
	}

	#if !macro
	/**
	 * Checks if a BitmapData object is not null before calling dispose() on it, always returns null.
	 *
	 * @param	Bitmap	A BitmapData to be disposed if not null
	 * @return 	null
	 */
	public static function dispose(bitmapData:BitmapData):BitmapData
	{
		if (bitmapData != null)
		{
			bitmapData.dispose();
		}
		return null;
	}

	/**
	 * Checks if a BitmapData object is not null and it's size isn't equal to specified one before calling dispose() on it.
	 */
	public static function disposeIfNotEqual(bitmapData:BitmapData, width:Float, height:Float):BitmapData
	{
		if (bitmapData != null && (bitmapData.width != width || bitmapData.height != height))
		{
			bitmapData.dispose();
			return null;
		}
		else if (bitmapData != null)
		{
			return bitmapData;
		}

		return null;
	}

	public static function removeChild<T:DisplayObject>(parent:DisplayObjectContainer, child:T):T
	{
		if (parent != null && child != null && parent.contains(child))
		{
			parent.removeChild(child);
		}
		return null;
	}
	#end
}

interface IFlxDestroyable
{
	function destroy():Void;
}
