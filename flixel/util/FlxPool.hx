package flixel.util;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
#if haxe_concurrent
import hx.concurrent.lock.RLock;
#end

/**
 * A generic container that facilitates pooling and recycling of objects.
 * WARNING: Pooled objects must have parameter-less constructors: function new()
 */
#if !display
@:generic
#end
class FlxPool<T:IFlxDestroyable> implements IFlxPool<T>
{
	public var length(get, never):Int;

	var _pool:Array<T> = [];
	var _class:Class<T>;

	#if haxe_concurrent
	var _lock:RLock;
	#end

	/**
	 * Objects aren't actually removed from the array in order to improve performance.
	 * _count keeps track of the valid, accessible pool objects.
	 */
	var _count:Int = 0;

	public function new(classObj:Class<T>)
	{
		_class = classObj;
		#if haxe_concurrent
		_lock = new RLock();
		#end
	}

	public function get():T
	{
		#if haxe_concurrent
		_lock.acquire();
		#end
		var result:T;
		if (_count == 0)
		{
			result = Type.createInstance(_class, []);
		} else {
			result = _pool[--_count];
		}
		#if haxe_concurrent
		_lock.release();
		#end
		return result;
	}

	public function put(obj:T):Void
	{
		#if haxe_concurrent
		_lock.acquire();
		#end
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
		#if haxe_concurrent
		_lock.release();
		#end
	}

	public function putUnsafe(obj:T):Void
	{
		#if haxe_concurrent
		_lock.acquire();
		#end
		if (obj != null)
		{
			obj.destroy();
			_pool[_count++] = obj;
		}
		#if haxe_concurrent
		_lock.release();
		#end
	}

	public function preAllocate(numObjects:Int):Void
	{
		#if haxe_concurrent
		_lock.acquire();
		#end
		while (numObjects-- > 0)
		{
			_pool[_count++] = Type.createInstance(_class, []);
		}
		#if haxe_concurrent
		_lock.release();
		#end
	}

	public function clear():Array<T>
	{
		#if haxe_concurrent
		_lock.acquire();
		#end
		_count = 0;
		var oldPool = _pool;
		_pool = [];
		#if haxe_concurrent
		_lock.release();
		#end
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
