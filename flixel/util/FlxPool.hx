package flixel.util;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.typeLimit.OneOfTwo;

/**
 * Helper type that allows the `FlxPool` constructor to take the new function param and the old,
 * deprecated `Class<T>` param. This will be removed, soon anf FlxPool will only take a function.
 */
abstract PoolFactory<T:IFlxDestroyable>(()->T)
{
	@:from
	#if FLX_NO_UNIT_TEST
	@:deprecated("use `MyType.new` or `()->new MyType()` instead of `MyType`)")
	#end
	public static inline function fromClass<T:IFlxDestroyable>(classRef:Class<T>):PoolFactory<T>
	{
		return fromFunction(()->Type.createInstance(classRef, []));
	}

	@:from
	public static inline function fromFunction<T:IFlxDestroyable>(func:()->T):PoolFactory<T>
	{
		return cast func;
	}
	
	@:allow(flixel.util.FlxPool)
	inline function getFunction():()->T
	{
		return this;
	}
}

/**
 * A generic container that facilitates pooling and recycling of objects.
 * WARNING: Pooled objects must have parameter-less constructors: function new()
 */
class FlxPool<T:IFlxDestroyable> implements IFlxPool<T>
{
	public var length(get, never):Int;

	var _pool:Array<T> = [];
	var _constructor:()->T;

	/**
	 * Objects aren't actually removed from the array in order to improve performance.
	 * _count keeps track of the valid, accessible pool objects.
	 */
	var _count:Int = 0;

	/**
	 * Creates a pool of the specified type
	 * @param   constructor  A function that takes no args and creates an instance,
	 *                       example: `FlxRect.new.bind(0, 0, 0, 0)`
	 */
	
	public function new(constructor:PoolFactory<T>)
	{
		_constructor = constructor.getFunction();
	}

	public function get():T
	{
		if (_count == 0)
		{
			return _constructor();
		}
		return _pool[--_count];
	}

	public function put(obj:T):Void
	{
		// we don't want to have the same object in the accessible pool twice (ok to have multiple in the inaccessible zone)
		if (obj != null)
		{
			var i:Int = _pool.indexOf(obj);
			// if the object's spot in the pool was overwritten, or if it's at or past _count (in the inaccessible zone)
			if (i == -1 || i >= _count)
			{
				obj.destroy();
				_pool[_count++] = obj;
			}
		}
	}

	public function putUnsafe(obj:T):Void
	{
		if (obj != null)
		{
			obj.destroy();
			_pool[_count++] = obj;
		}
	}

	public function preAllocate(numObjects:Int):Void
	{
		while (numObjects-- > 0)
		{
			_pool[_count++] = _constructor();
		}
	}

	public function clear():Array<T>
	{
		_count = 0;
		var oldPool = _pool;
		_pool = [];
		return oldPool;
	}

	inline function get_length():Int
	{
		return _count;
	}
}

interface IFlxPooled extends IFlxDestroyable
{
	function put():Void;
}

interface IFlxPool<T:IFlxDestroyable>
{
	function preAllocate(numObjects:Int):Void;
	function clear():Array<T>;
}
