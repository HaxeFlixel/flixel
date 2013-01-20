package org.flixel.system.input;

interface IFlxInput {
	function reset():Void;
	function update():Void;
	function onFocus():Void;
	function onFocusLost():Void;
	function toString() : String;
	function destroy():Void;
}
