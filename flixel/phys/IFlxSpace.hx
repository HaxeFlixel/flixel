package flixel.phys;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

interface IFlxSpace extends IFlxDestroyable
{
	public function step (elapsed : Float) : Void;
}