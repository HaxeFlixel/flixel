package flixel.util;

import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
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
	
	#if FLX_TRACK_POOLS
	/** Set to false before creating FlxGame to prevent logs */
	public var autoLog = true;
	
	// For some reason, this causes CI errors: `final _tracked = new Map<T, String>();`
	
	final _tracked:Map<T, String> = [];
	final _leakCount:Map<String, Int> = [];
	var _totalCreated = 0;
	var _autoLogInitted = false;
	#end

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
		final obj:T = if (_count == 0)
		{
			#if FLX_TRACK_POOLS
			_totalCreated++;
			#end
			_constructor();
		}
		else
			_pool[--_count];
		
		#if FLX_TRACK_POOLS
		trackGet(obj);
		#end
		
		return obj;
	}

	public function put(obj:T):Void
	{
		// we don't want to have the same object in the accessible pool twice (ok to have multiple in the inaccessible zone)
		if (obj != null)
		{
			var i:Int = _pool.indexOf(obj);
			// if the object's spot in the pool was overwritten, or if it's at or past _count (in the inaccessible zone)
			if (i == -1 || i >= _count)
				putHelper(obj);
		}
	}

	public function putUnsafe(obj:T):Void
	{
		// TODO: remove null check and make private?
		if (obj != null)
			putHelper(obj);
	}
	
	function putHelper(obj:T)
	{
		obj.destroy();
		_pool[_count++] = obj;
		
		#if FLX_TRACK_POOLS
		trackPut(obj);
		#end
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
	
	#if FLX_TRACK_POOLS
	public function addLogs(?id:String)
	{
		if (id == null)
		{
			if (_pool.length == 0)
				preAllocate(1);
			
			id = Type.getClassName(Type.getClass(_pool[0])).split(".").pop().split("FlxBase").pop().split("Flx").pop();
		}
		
		FlxG.watch.addFunction(id + "-pool", function()
		{
			var most = 0;
			var topStack:String = null;
			for (stack in _leakCount.keys())
			{
				final count = _leakCount[stack];
				if (most < count)
				{
					most = count;
					topStack = stack;
				}
			}
			
			var msg = '$length/$_totalCreated';
			if (topStack != null)
				msg += ' | $most from ${prettyStack(topStack)}';
			return msg;
		});
	}
	
	function trackGet(obj:T)
	{
		final callStack = haxe.CallStack.callStack();
		final stack = stackToString(callStack[2]);
		if (stack == null)
			return;
		
		if (autoLog && !_autoLogInitted && FlxG.signals != null)
		{
			_autoLogInitted = true;
			FlxG.signals.postStateSwitch.add(()->addLogs());
			if (FlxG.game != null && FlxG.state != null)
				addLogs();
		}
		
		_tracked[obj] = stack;
		if (_leakCount.exists(stack) == false)
			_leakCount[stack] = 0;
		
		_leakCount[stack]++;
	}
	
	inline function trackPut(obj:T)
	{
		final stack = _tracked[obj];
		_tracked.remove(obj);
		_leakCount[stack]--;
	}
	
	function stackToString(stack:haxe.CallStack.StackItem)
	{
		return switch (stack)
		{
			case FilePos(_, file, line, _): '$file[$line]';
			default: null;
		}
	}
	
	inline function prettyStack(pos:String)
	{
		return pos.split("/").pop().split(".hx").join("");
	}
	#end
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
