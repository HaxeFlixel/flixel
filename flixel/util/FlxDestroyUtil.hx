package flixel.util;

import flash.display.BitmapData;
import flixel.interfaces.IFlxDestroyable;
import flixel.interfaces.IFlxPooled;

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
			object.destroy(); 
		return null;
	}
	
	/**
	 * Completely destroys an Array of destroyable objects:
	 * 1) Clears the array structure
	 * 2) Calls FlxDestroyUtil.destroy() on every element
	 *
	 * @param	array	An Array of IFlxDestroyable objects
	 * @return	null
	 */
	public static function destroyArray<T:IFlxDestroyable>(array:Array<T>):Array<T>
	{
		if (array != null)
		{
			while (array.length > 0)
			{
				destroy(array.pop());
			}
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
			object.put();
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
			while (array.length > 0)
			{
				put(array.pop());
			}
		}
		return null;
	}
	
	/**
	 * Checks if a BitmapData object is not null before calling dispose() on it, always returns null.
	 * 
	 * @param	Bitmap	A BitampData to be disposed if not null
	 * @return 	null
	 */
	public static function dispose(Bitmap:BitmapData):BitmapData
	{
		if (Bitmap != null)
			Bitmap.dispose();
		return null;
	}
}