package flixel.interfaces;

/**
 * ...
 * @author Sam Batista
 */
interface IFlxSignal<T> extends IFlxDestroyable
{
	public var dispatch:T;
	public function add(listener:T):Void;
	public function addOnce(listener:T):Void;
	public function remove(listener:T):Void;
	public function removeAll():Void;
	public function has(listener:T):Bool;
}