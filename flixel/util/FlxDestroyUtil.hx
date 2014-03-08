package flixel.util;
import flixel.interfaces.IFlxDestroyable;
import flixel.interfaces.IFlxPooled;

class FlxDestroyUtil
{
	/**
	 * Checks if an object is not null before calling destroy(), always returns null.
	 * 
	 * @param	Object	An IFlxDestroyable object that will be destroyed if it's not null.
	 * @return	Null
	 */
	public static function destroy<T:IFlxDestroyable>(Object:Null<IFlxDestroyable>):T
	{
		if (Object != null)
			Object.destroy(); 
		return null;
	}
	
	/**
	 * Checks if an object is not null before calling putting it back into the pool, always returns null.
	 * 
	 * @param	Object	An IFlxPooled object that will be put back into the pool if it's not null
	 * @return	Null
	 */
	public static function put<T:IFlxPooled>(Object:IFlxPooled):T
	{
		if (Object != null)
			Object.put();
		return null;
	}
}