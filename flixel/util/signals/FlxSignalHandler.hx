package flixel.util.signals;
import flixel.interfaces.IFlxDestroyable;

/**
 * ...
 * @author Kevin
 */
class FlxSignalHandler<TListener> implements IFlxDestroyable
{
	public var listener:TListener;
	
	public var isOnce(default, null):Bool = false;	
	
	public function new(listener:TListener, isOnce:Bool) 
	{
		this.listener = listener;
		this.isOnce = isOnce;
	}
	
	public function destroy()
	{
		listener = null;
	}
	
}

class FlxSignalHandler0 extends FlxSignalHandler <Void->Void>
{
	public inline function execute():Void
	{
		listener();
	}
}

class FlxSignalHandler1<T1> extends FlxSignalHandler <T1->Void>
{
	public inline function execute(value1:T1):Void
	{
		listener(value1);
	}
}

class FlxSignalHandler2<T1, T2> extends FlxSignalHandler <T1->T2->Void>
{
	public inline function execute(value1:T1, value2:T2):Void
	{
		listener(value1, value2);
	}
}

class FlxSignalHandler3<T1, T2, T3> extends FlxSignalHandler <T1->T2->T3->Void>
{
	public inline function execute(value1:T1, value2:T2, value3:T3):Void
	{
		listener(value1, value2, value3);
	}
}

class FlxSignalHandler4<T1, T2, T3, T4> extends FlxSignalHandler <T1->T2->T3->T4->Void>
{
	public inline function execute(value1:T1, value2:T2, value3:T3, value4:T4):Void
	{
		listener(value1, value2, value3, value4);
	}
}
