package flixel.input.gamepad;

import flixel.util.FlxStringUtil;

typedef FlxGamepadAnalogStick = FlxTypedGamepadAnalogStick<Int>;

class FlxTypedGamepadAnalogStick<TInputID:Int>
{
	public var x(default, null):TInputID;
	public var y(default, null):TInputID;

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

	public function new(x:Int, y:Int, ?settings:FlxGamepadAnalogStickSettings)
	{
		this.x = cast x;
		this.y = cast y;

		if (settings == null)
			return;

		mode = (settings.mode != null) ? settings.mode : BOTH;
		rawUp = cast (settings.up != null) ? settings.up : -1;
		rawDown = cast (settings.down != null) ? settings.down : -1;
		rawLeft = cast (settings.left != null) ? settings.left : -1;
		rawRight = cast (settings.right != null) ? settings.right : -1;
		digitalThreshold = (settings.threshold != null) ? settings.threshold : 0.5;
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

typedef FlxGamepadAnalogStickSettings =
{
	?up:Int,
	?down:Int,
	?left:Int,
	?right:Int,
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
