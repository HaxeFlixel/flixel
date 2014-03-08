package flixel.interfaces;

import flixel.interfaces.IFlxDestroyable;

interface IFlxPooled extends IFlxDestroyable
{
	public function put():Void;
}