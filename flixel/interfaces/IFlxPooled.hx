package flixel.interfaces;

import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxPool.FlxPool;

interface IFlxPooled extends IFlxDestroyable
{
	public function put():Void;
	private var _inPool:Bool;
}