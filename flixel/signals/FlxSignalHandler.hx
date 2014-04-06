package flixel.signals;

import flixel.interfaces.IFlxDestroyable;

class FlxSignalHandler<T> implements IFlxDestroyable
{
	public var listener:T;
	public var isOnce(default, null):Bool = false;
	
	public function new(listener:T, isOnce:Bool) 
	{
		this.listener = listener;
		this.isOnce = isOnce;
	}
	
	public function destroy()
	{
		listener = null;
	}
}