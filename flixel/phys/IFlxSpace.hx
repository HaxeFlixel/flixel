package flixel.phys;

import flixel.FlxObject;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

interface IFlxSpace extends IFlxDestroyable
{
	public function step (elapsed : Float) : Void;
	public function createBody (parent : FlxObject) : IFlxBody;
	public function destroy() : Void;
}