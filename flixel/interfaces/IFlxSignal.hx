package flixel.interfaces;

/**
 * ...
 * @author Sam Batista
 */
interface IFlxSignal<T> extends IFlxDestroyable
{
	var dispatch:T;
	function add(listener:T):Void;
	function addOnce(listener:T):Void;
	function remove(listener:T):Void;
	function removeAll():Void;
	function has(listener:T):Bool;
}