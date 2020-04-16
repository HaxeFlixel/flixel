package flixel.input.gamepad;

import flixel.input.FlxInput;

@:forward
abstract FlxGamepadAxis(FlxAnalogInput<Int, Float>)
{
	inline public function new (id:Int)
	{
		this = new FlxAnalogInput<Int, Float>(id, true);
	}
}

class FlxGamepadButton extends FlxInput<Int>
{
	#if flash

	override public function release():Void
	{
		// simulate button onUp event which does not exist on flash
		if (!currentValue)
		{
			return;
		}

		super.release();
	}

	override public function press():Void
	{
		// simulate button onDown event which does not exist on flash
		if (currentValue)
		{
			return;
		}

		super.press();
	}
	#end
}
