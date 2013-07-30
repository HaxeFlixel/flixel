package flixel.util;

/**
 * ...
 * @author Zaphod
 */
@:generic class FlxPool<T>
{
	private var _pool:Array<T>;
	
	public var length(get, never):Int;
	
	public function new() 
	{
		_pool = [];
	}
	
	inline public function get():T
	{
		return _pool.pop();
	}
	
	public function put(obj:T):Void
	{
		// we don't want to have the same object in pool twice
		if (obj != null && FlxArrayUtil.indexOf(_pool, obj) < 0)
		{
			_pool.push(obj);
		}
	}
	
	inline public function putUnsafe(obj:T):Void
	{
		if (obj != null)
		{
			_pool.push(obj);
		}
	}
	
	inline public function clear():Array<T>
	{
		var oldPool = _pool;
		_pool = [];
		return oldPool;
	}
	
	inline private function get_length():Int
	{
		return _pool.length;
	}
}