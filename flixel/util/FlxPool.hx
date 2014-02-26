package flixel.util;

import flixel.interfaces.IFlxDestroyable;

/**
 * A generic container that facilitates pooling and recycling of objects.
 * WARNING: Pooled objects must have parameterless constructors: function new()
 */
@:generic class FlxPool<T:IFlxDestroyable>
{
	private var _pool:Array<T>;
	private var _class:Class<T>;
	
	public var length(get, never):Int;
	
	public function new(classObj:Class<T>) 
	{
		_pool = [];
		_class = classObj;
	}
	
	public function get():T
	{
		var obj:T = _pool.pop();
		if (obj == null) obj = Type.createInstance(_class, []);
		return obj;
	}
	
	public function put(obj:T):Void
	{
		// we don't want to have the same object in pool twice
		if (obj != null && FlxArrayUtil.indexOf(_pool, obj) < 0)
		{
			obj.destroy();
			_pool.push(obj);
		}
	}
	
	public function putUnsafe(obj:T):Void
	{
		if (obj != null)
		{
			obj.destroy();
			_pool.push(obj);
		}
	}
	
	public function preAllocate(numObjects:Int):Void
	{
		for (i in 0...numObjects)
		{
			_pool.push(Type.createInstance(_class, []));
		}
	}
	
	public function clear():Array<T>
	{
		var oldPool = _pool;
		_pool = [];
		return oldPool;
	}
	
	private inline function get_length():Int
	{
		return _pool.length;
	}
}
