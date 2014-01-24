package flixel.interfaces;

@:allow(flixel.system.frontEnds.InputFrontEnd)
interface IFlxInput 
{
	private function reset():Void;
	private function update():Void;
	private function onFocus():Void;
	private function onFocusLost():Void;
	public function destroy():Void;
}
