package flixel.util;

#if macro
import haxe.macro.Expr;
#else
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

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

private class FlxBaseSignal<T> implements IFlxSignal<T> 
{	
	/**
	 * Typed function reference used to dispatch this signal.
	 */
	public var dispatch:T;
	
	private var handlers:Array<FlxSignalHandler<T>>;
	private var pendingRemove:Array<FlxSignalHandler<T>>;
	private var processingListeners:Bool = false;
	
	
	public function new() 
	{
		handlers = [];
		pendingRemove = [];
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
				if (processingListeners)
					pendingRemove.push(handler);
				else
				{
					handlers.remove(handler);
					handler.destroy();
				}
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
		FlxDestroyUtil.destroyArray(handlers);
	}
	
	public function destroy():Void
	{
		removeAll();
		handlers = null;
		pendingRemove = null;
	}
	
	private function registerListener(listener:T, dispatchOnce:Bool):FlxSignalHandler<T>
	{
		var handler = getHandler(listener);
		
		if (handler == null)
		{
			handler = new FlxSignalHandler<T>(listener, dispatchOnce);
			handlers.push(handler);
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
		for (handler in handlers)
		{
			if (
				#if neko // simply comparing the functions doesn't do the trick on neko
					Reflect.compareMethods(handler.listener, listener)
				#else
					handler.listener == listener
				#end )
			{
				return handler; // Listener was already registered.
			}
		}
		return null; // Listener not yet registered.
	}
}

private class FlxSignal0 extends FlxBaseSignal<Void->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch0;
	}
	
	public function dispatch0():Void
	{
		Macro.buildDispatch();
	}
}

private class FlxSignal1<T1> extends FlxBaseSignal<T1->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch1;
	}
	
	public function dispatch1(value1:T1):Void
	{
		Macro.buildDispatch(value1);
	}
}

private class FlxSignal2<T1,T2> extends FlxBaseSignal<T1->T2->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch2;
	}
	
	public function dispatch2(value1:T1, value2:T2):Void
	{
		Macro.buildDispatch(value1, value2);
	}
}

private class FlxSignal3<T1,T2,T3> extends FlxBaseSignal<T1->T2->T3->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch3;
	}
	
	public function dispatch3(value1:T1, value2:T2, value3:T3):Void
	{
		Macro.buildDispatch(value1, value2, value3);
	}
}

private class FlxSignal4<T1,T2,T3,T4> extends FlxBaseSignal<T1->T2->T3->T4->Void>
{
	public function new()
	{
		super();
		this.dispatch = dispatch4;
	}
	
	public function dispatch4(value1:T1, value2:T2, value3:T3, value4:T4):Void
	{
		Macro.buildDispatch(value1, value2, value3, value4);
	}
}

interface IFlxSignal<T> extends IFlxDestroyable
{
	public var dispatch:T;
	public function add(listener:T):Void;
	public function addOnce(listener:T):Void;
	public function remove(listener:T):Void;
	public function removeAll():Void;
	public function has(listener:T):Bool;
}

#end

private class Macro
{
	macro public static function buildDispatch(exprs:Array<Expr>):Expr
	{
		return macro
		{ 
			processingListeners = true;
			for (handler in handlers)
			{
				handler.listener($a{exprs});
				
				if (handler.dispatchOnce)
					remove(handler.listener);
			}
			
			processingListeners = false;
			
			for (handler in pendingRemove)
			{
				remove(handler.listener);
			}
			if (pendingRemove.length > 0)
				pendingRemove = [];
		}
	}
}
