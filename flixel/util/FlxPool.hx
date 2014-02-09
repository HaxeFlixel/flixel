package flixel.util;

/**
 * A generic container that facilitates pooling and recycling of objects.
 */
@:generic class FlxPool<T:({ private function new():Void; function destroy():Void; })>
{
	private var _pool:Array<T>;
	
	public var length(get, never):Int;
	
	public function new() 
	{
		_pool = [];
	}
	
	public inline function get():T
	{
		var obj:T = _pool.pop();
		if (obj == null)	obj = new T();
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
	
	public inline function putUnsafe(obj:T):Void
	{
		if (obj != null)
		{
			obj.destroy();
			_pool.push(obj);
		}
	}
	
	public inline function clear():Array<T>
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
