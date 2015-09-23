package flixel.util;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * @author Tiago Ling Alexandre
 */
interface IFlxPool<T:IFlxDestroyable> 
{
	function preAllocate(numObjects:Int):Void;
	function clear():Array<T>;
}