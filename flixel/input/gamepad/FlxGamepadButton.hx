package flixel.input.gamepad;

import flixel.input.FlxInput;

class FlxGamepadButton extends FlxInput<Int>
{
	#if flash
	private var _pressed:Bool = false;
	
	/**
	 * Optional analog value, so we can check when the value has changed from the last frame
	 */
	public var value:Float = 0;
	
	override public function release():Void
	{
		// simulate button onUp event which does not exist on flash
		if (!_pressed)
		{
			return;
		}
		_pressed = false;
		
		super.release();
	}
	
	override public function press():Void
	{
		// simulate button onDown event which does not exist on flash
		if (_pressed)
		{
			return;
		}
		_pressed = true;
		
		super.press();
	}
	#end
}