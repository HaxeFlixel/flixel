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
		if (obj != null)
		{
			var l:Int = length;
			var i:Int = 0;
			while (i < l)
			{
				if (_pool[i++] == obj)
				{
					// we don't want to have the same object in pool twice
					return;
				}
			}
			
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
	
	inline public function destroy():Array<T>
	{
		var oldPool = _pool;
		_pool = null;
		return oldPool;
	}
	
	inline private function get_length():Int
	{
		return _pool.length;
	}
}