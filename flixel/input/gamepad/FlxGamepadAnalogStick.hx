package flixel.input.gamepad;

import flixel.util.FlxStringUtil;

typedef FlxGamepadAnalogStick = FlxTypedGamepadAnalogStick<Int>;

class FlxTypedGamepadAnalogStick<TInputID:Int>
{
	public var x(default, null):Int;
	public var y(default, null):Int;

	/**
	 * a raw button input ID, for sending a digital event for "up" alongside the analog event
	 */
	public var rawUp(default, null):TInputID = cast -1;

	/**
	 * a raw button input ID, for sending a digital event for "down" alongside the analog event
	 */
	public var rawDown(default, null):TInputID = cast -1;

	/**
	 * a raw button input ID, for sending a digital event for "left" alongside the analog event
	 */
	public var rawLeft(default, null):TInputID = cast -1;

	/**
	 * a raw button input ID, for sending a digital event for "right" alongside the analog event
	 */
	public var rawRight(default, null):TInputID = cast -1;

	/**
	 * the absolute value the dpad must be greater than before digital inputs are sent
	 */
	public var digitalThreshold(default, null):Float = 0.5;

	/**
	 * when analog inputs are received, how to process them digitally
	 */
	public var mode(default, null):FlxAnalogToDigitalMode = BOTH;

	public function new(x:Int, y:Int, ?settings:FlxGamepadAnalogStickSettings<TInputID>)
	{
		this.x = x;
		this.y = y;

		if (settings != null)
		{
			if (settings.mode != null)
				mode = settings.mode;
			
			if (settings.up != null)
				rawUp = settings.up;
			
			if (settings.down != null)
				rawDown = settings.down;
			
			if (settings.left != null)
				rawLeft = settings.left;
			
			if (settings.right != null)
				rawRight = settings.right;
			
			if (settings.threshold != null)
				digitalThreshold = settings.threshold;
		}
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("x", x),
			LabelValuePair.weak("y", y),
			LabelValuePair.weak("rawUp", rawUp),
			LabelValuePair.weak("rawDown", rawDown),
			LabelValuePair.weak("rawLeft", rawLeft),
			LabelValuePair.weak("rawRight", rawRight),
			LabelValuePair.weak("digitalThreshold", digitalThreshold),
			LabelValuePair.weak("mode", mode)
		]);
	}
}

typedef FlxGamepadAnalogStickSettings<TInputID:Int> =
{
	?up:TInputID,
	?down:TInputID,
	?left:TInputID,
	?right:TInputID,
	?threshold:Float,
	?mode:FlxAnalogToDigitalMode
}

enum FlxAnalogToDigitalMode
{
	/**
	 * Send both digital and analog events when the analog stick is moved
	 */
	BOTH;

	/**
	 * Send only digital events when the analog stick is moved
	 */
	ONLY_DIGITAL;

	/**
	 * Send only analog events when the analog stick is moved
	 */
	ONLY_ANALOG;
}
