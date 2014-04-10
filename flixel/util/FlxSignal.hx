package flixel.util;

#if macro
import haxe.macro.Expr;
#end

import flixel.interfaces.IFlxSignal;
import flixel.interfaces.IFlxDestroyable;

typedef FlxSignal = FlxTypedSignal<Void->Void>;

@:multiType
abstract FlxTypedSignal<T>(IFlxSignal<T>)
{
	public var dispatch(get, never):T;
	
	public function new();
	
	public inline function add(listener:T):Void 
	{
		this.add(listener);
	}
	
	public inline function addOnce(listener:T):Void 
	{
		this.addOnce(listener);
	}
	
	public inline function remove(listener:T):Void
	{
		this.remove(listener);
	}
	
	public inline function has(listener:T):Bool 
	{
		return this.has(listener);
	}
	
	public inline function removeAll():Void 
	{
		this.removeAll();
	}
	
	private inline function get_dispatch():T
	{
		return this.dispatch;
	}
	
	@:to 
	private static inline function toSignal0(signal:IFlxSignal<Void->Void>):FlxSignal0 
	{
		return new FlxSignal0();
	}
	
	@:to 
	private static inline function toSignal1<T1>(signal:IFlxSignal<T1->Void>):FlxSignal1<T1> 
	{
		return new FlxSignal1();
	}
	
	@:to 
	private static inline function toSignal2<T1, T2>(signal:IFlxSignal<T1->T2->Void>):FlxSignal2<T1,T2> 
	{
		return new FlxSignal2();
	}
	
	@:to 
	private static inline function toSignal3<T1, T2, T3>(signal:IFlxSignal<T1->T2->T3->Void>):FlxSignal3<T1,T2,T3> 
	{
		return new FlxSignal3();
	}
	
	@:to 
	private static inline function toSignal4<T1, T2, T3, T4>(signal:IFlxSignal<T1->T2->T3->T4->Void>):FlxSignal4<T1,T2,T3,T4> 
	{
		return new FlxSignal4();
	}
}

private class FlxSignalHandler<T> implements IFlxDestroyable
{
	public var listener:T;
	public var dispatchOnce(default, null):Bool = false;
	
	public function new(listener:T, dispatchOnce:Bool) 
	{
		this.listener = listener;
		this.dispatchOnce = dispatchOnce;
	}
	
	public function destroy()
	{
		listener = null;
	}
}

private class FlxSignalBase<T> implements IFlxSignal<T> 
{
	macro static function buildDispatch(exprs:Array<Expr>):Expr
	{
		return macro
		{ 
			for (handler in _handlers)
			{
				handler.listener($a{exprs});
				
				if (handler.dispatchOnce)
					remove(handler.listener);
			}
		}
	}
	
	/**
	 * Typed function reference used to dispatch this signal.
	 */
	public var dispatch:T;
	
	private var _handlers:Array<FlxSignalHandler<T>>;
	
	public function new() 
	{
		_handlers = [];
	}
	
	public function add(listener:T)
	{
		if (listener != null)
			registerListener(listener, false);
	}
	
	public function addOnce(listener:T):Void
	{
		if (listener != null)
			registerListener(listener, true);
	}
	
	public function remove(listener:T):Void
	{
		if (listener != null)
		{
			var handler = getHandler(listener);
			if (handler != null)
			{
				_handlers.remove(handler);
				handler.destroy();
				handler = null;
			}
		}
	}
	
	public function has(listener:T):Bool
	{
		if (listener == null)
			return false;
		return getHandler(listener) != null;
	}
	
	public inline function removeAll():Void 
	{
		while (_handlers.length > 0)
		{
			var handler = _handlers.pop();
			handler.destroy();
			handler = null;
		}
	}
	
	public function destroy():Void
	{
		removeAll();
		_handlers = null;
	}
	
	private function registerListener(listener:T, dispatchOnce:Bool):FlxSignalHandler<T>
	{
		var handler = getHandler(listener);
		
		if (handler == null)
		{
			handler = new FlxSignalHandler<T>(listener, dispatchOnce);
			_handlers.push(handler);
			return handler;
		}
		else
		{
			// If the listener was previously added, definitely don't add it again.
			// But throw an exception if their once values differ.
			if (handler.dispatchOnce != dispatchOnce)
				throw "You cannot addOnce() then add() the same listener without removing the relationship first.";
			else
				return handler;
		}
	}
	
	private function getHandler(listener:T):FlxSignalHandler<T>
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
}

private class FlxSignal0 extends FlxSignalBase<Void->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch0;
	}
	
	public function dispatch0():Void
	{
		FlxSignalBase.buildDispatch();
	}
}

private class FlxSignal1<T1> extends FlxSignalBase<T1->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch1;
	}
	
	public function dispatch1(value1:T1):Void
	{
		FlxSignalBase.buildDispatch(value1);
	}
}

private class FlxSignal2<T1,T2> extends FlxSignalBase<T1->T2->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch2;
	}
	
	public function dispatch2(value1:T1, value2:T2):Void
	{
		FlxSignalBase.buildDispatch(value1, value2);
	}
}

private class FlxSignal3<T1,T2,T3> extends FlxSignalBase<T1->T2->T3->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch3;
	}
	
	public function dispatch3(value1:T1, value2:T2, value3:T3):Void
	{
		FlxSignalBase.buildDispatch(value1, value2, value3);
	}
}

private class FlxSignal4<T1,T2,T3,T4> extends FlxSignalBase<T1->T2->T3->T4->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch4;
	}
	
	public function dispatch4(value1:T1, value2:T2, value3:T3, value4:T4):Void
	{
		FlxSignalBase.buildDispatch(value1, value2, value3, value4);
	}
}
