package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

class CodeValuePair
{
	public var code:Int;
	public var value:FlxInputState;

	public function new(code:Int, value:FlxInputState)
	{
		this.code = code;
		this.value = value;
	}
}
