package flixel.util.signals;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.signals.FlxSignalHandler;

/**
 * ...
 * @author Kevin
 */
typedef AnyHandler = FlxSignalHandler<Dynamic>;
typedef AnySignal = FlxSignal<Dynamic, Dynamic>;
 
private class FlxSignal<THandler:AnyHandler, TListener> implements IFlxDestroyable
{
	/**
	 * If this signal is active and should dispatch events. IMPORTANT: Setting this 
	 * property during a  dispatch will only affect the next dispatch.
	 */
	public var active:Bool = true;	
	
	private var _handlers:Array<THandler>;	
	
	public function new() 
	{
		_handlers = [];			
	}
	
	public function add(listener:TListener)
	{
		return registerListener(listener);
	}
	
	public function addOnce(listener:TListener)
	{
		return registerListener(listener, true);
	}
	
	public function remove(listener:TListener):THandler
	{
		var handler = getHandler(listener);
		_handlers.remove(handler);
		return handler;
	}
	
	public function removeAll():Void 
	{
		FlxArrayUtil.clearArray(_handlers);
	}
	
	public function has(listener:TListener):Bool
	{
		if (listener == null)
			return false;
		
		return getHandler(listener) != null;
	}
	
	public function destroy():Void
	{
		removeAll();
		_handlers = null;
	}
	
	private function registerListener(listener:TListener, isOnce:Bool = false):THandler
	{
		var handler = getHandler(listener);
		
		if (handler == null)
		{
			handler = createHandler(listener, isOnce);
			_handlers.push(handler);
			return handler;
		}
		else
		{
			// If the listener was previously added, definitely don't add it again.
			// But throw an exception if their once values differ.
			if(handler.isOnce != isOnce)
				throw "You cannot addOnce() then add() the same listener without removing the relationship first.";
			else
				return handler;
		}
	}
	
	/**
	 * Return the handler of the listener or null if not exist.
	 * Does not care about the isOnce property.
	 * @param	listener
	 * @return	the handler, or null if the listener is not yet added
	 */
	private function getHandler(listener:TListener):THandler
	{
		for (handler in _handlers)
		{
			if (handler.listener == listener)
			{
				return handler; // Listener was already registered.
			}
		}
		
		return null; // Listener not yet registered.
	}
	
	private function createHandler(listener:TListener, isOnce:Bool):THandler
	{
		throw "This function must be overridden.";
		return null;
	}
	
}

class FlxSignal0 extends FlxSignal<FlxSignalHandler0, Void->Void>
{
	public function dispatch():Void
	{
		if (!active)
			return;
		
		for (handler in _handlers)
		{
			handler.execute();
			
			if (handler.isOnce)
				remove(handler.listener);
		}
	}
	
	override function createHandler(listener:Void->Void, isOnce:Bool)
	{
		return new FlxSignalHandler0(listener, isOnce);
	}
}

class FlxSignal1<T1> extends FlxSignal<FlxSignalHandler1<T1>, T1->Void>
{
	public function dispatch(value1:T1):Void
	{
		if (!active)
			return;
		
		for (handler in _handlers)
		{
			handler.execute(value1);
			
			if (handler.isOnce)
				remove(handler.listener);
		}
	}
	
	override function createHandler(listener:T1->Void, isOnce:Bool)
	{
		return new FlxSignalHandler1<T1>(listener, isOnce);
	}
}

class FlxSignal2<T1, T2> extends FlxSignal<FlxSignalHandler2<T1, T2>, T1->T2->Void>
{
	public function dispatch(value1:T1, value2:T2):Void
	{
		if (!active)
			return;
		
		for (handler in _handlers)
		{
			handler.execute(value1, value2);
			
			if (handler.isOnce)
				remove(handler.listener);
		}
	}
	
	override function createHandler(listener:T1->T2->Void, isOnce:Bool)
	{
		return new FlxSignalHandler2<T1, T2>(listener, isOnce);
	}
}

class FlxSignal3<T1, T2, T3> extends FlxSignal<FlxSignalHandler3<T1, T2, T3>, T1->T2->T3->Void>
{
	public function dispatch(value1:T1, value2:T2, value3:T3):Void
	{
		if (!active)
			return;
		
		for (handler in _handlers)
		{
			handler.execute(value1, value2, value3);
			
			if (handler.isOnce)
				remove(handler.listener);
		}
	}
	
	override function createHandler(listener:T1->T2->T3->Void, isOnce:Bool)
	{
		return new FlxSignalHandler3<T1, T2, T3>(listener, isOnce);
	}
}

class FlxSignal4<T1, T2, T3, T4> extends FlxSignal<FlxSignalHandler4<T1, T2, T3, T4>, T1->T2->T3->T4->Void>
{
	public function dispatch(value1:T1, value2:T2, value3:T3, value4:T4):Void
	{
		if (!active)
			return;
		
		for (handler in _handlers)
		{
			handler.execute(value1, value2, value3, value4);
			
			if (handler.isOnce)
				remove(handler.listener);
		}
	}
	
	override function createHandler(listener:T1->T2->T3->T4->Void, isOnce:Bool)
	{
		return new FlxSignalHandler4<T1, T2, T3, T4>(listener, isOnce);
	}
}
