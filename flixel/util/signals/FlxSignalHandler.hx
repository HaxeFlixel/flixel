package flixel.util.signals;

/**
 * ...
 * @author Kevin
 */
class FlxSignalHandler<TListener>
{
	public var listener:TListener;
	
	public var isOnce(default, null):Bool;	
	
	public function new(listener:TListener, isOnce:Bool) 
	{
		this.listener = listener;
		this.isOnce = isOnce;
	}
	
}

class FlxSignalHandler0 extends FlxSignalHandler <Void->Void>
{
	public function execute():Void
	{
		listener();
	}
}

class FlxSignalHandler1<T1> extends FlxSignalHandler <T1->Void>
{
	public function execute(value1:T1):Void
	{
		listener(value1);
	}
}

class FlxSignalHandler2<T1, T2> extends FlxSignalHandler <T1->T2->Void>
{
	public function execute(value1:T1, value2:T2):Void
	{
		listener(value1, value2);
	}
}