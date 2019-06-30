package flixel.input;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

@:allow(flixel.system.frontEnds.InputFrontEnd)
interface IFlxInputManager extends IFlxDestroyable
{
	function reset():Void;
	private function update():Void;
	private function onFocus():Void;
	private function onFocusLost():Void;
}
