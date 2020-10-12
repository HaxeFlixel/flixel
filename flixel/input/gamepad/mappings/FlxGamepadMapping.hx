package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepad.FlxGamepadAttachment;
import flixel.input.gamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepadInputID;
#if flash
import openfl.system.Capabilities;
#end

class FlxGamepadMapping
{
	public var supportsMotion:Bool = false;
	public var supportsPointer:Bool = false;

	public var leftStick:FlxGamepadAnalogStick;
	public var rightStick:FlxGamepadAnalogStick;

	@:allow(flixel.input.gamepad.FlxGamepad)
	var attachment(default, set):FlxGamepadAttachment = NONE;

	var manufacturer:Manufacturer;

	public function new(?attachment:FlxGamepadAttachment)
	{
		if (attachment != null)
			this.attachment = attachment;

		#if flash
		manufacturer = switch (Capabilities.manufacturer)
		{
			case "Google Pepper": GooglePepper;
			case "Adobe Windows": AdobeWindows;
			default: Unknown;
		}
		#end

		initValues();
	}

	function initValues():Void {}

	public function getAnalogStick(ID:FlxGamepadInputID):FlxGamepadAnalogStick
	{
		return switch (ID)
		{
			case FlxGamepadInputID.LEFT_ANALOG_STICK:
				leftStick;
			case FlxGamepadInputID.RIGHT_ANALOG_STICK:
				rightStick;
			case _:
				null;
		}
	}

	/**
	 * Given a raw hardware code, return the "universal" ID
	 */
	public function getID(rawID:Int):FlxGamepadInputID
	{
		return FlxGamepadInputID.NONE;
	}

	/**
	 * Given an ID, return the raw hardware code
	 */
	public function getRawID(ID:FlxGamepadInputID):Int
	{
		return -1;
	}

	/**
	 * Whether this axis needs to be flipped
	 */
	public function isAxisFlipped(axisID:Int):Bool
	{
		return false;
	}

	public function isAxisForMotion(ID:FlxGamepadInputID):Bool
	{
		return false;
	}

	#if FLX_JOYSTICK_API
	/**
	 * Given an axis index value like 0-6, figures out which input that
	 * corresponds to and returns a "fake" ButtonID for that input
	 */
	public function axisIndexToRawID(axisID:Int):Int
	{
		return -1;
	}

	public function checkForFakeAxis(ID:FlxGamepadInputID):Int
	{
		return -1;
	}
	#end

	function set_attachment(attachment:FlxGamepadAttachment):FlxGamepadAttachment
	{
		return this.attachment = attachment;
	}
	
	public function getInputLabel(id:FlxGamepadInputID):Null<String>
	{
		if (getRawID(id) == -1)
			return null;// return empty string, "unknown" or enum maybe?
		
		return switch (id)
		{
			case A: "a";
			case B: "b";
			case X: "x";
			case Y: "y";
			case BACK: "back";
			case GUIDE: "guide";
			case START: "start";
			case LEFT_STICK_CLICK: "ls-click";
			case RIGHT_STICK_CLICK: "rs-click";
			case LEFT_SHOULDER: "lb";
			case RIGHT_SHOULDER: "rb";
			case LEFT_TRIGGER: "lt";
			case RIGHT_TRIGGER: "rt";
			case LEFT_TRIGGER_BUTTON: "l2-click";
			case RIGHT_TRIGGER_BUTTON: "r2-click";
			case DPAD: "dpad";
			case DPAD_UP: "up";
			case DPAD_DOWN: "down";
			case DPAD_LEFT: "left";
			case DPAD_RIGHT: "right";
			case LEFT_ANALOG_STICK: "ls";
			case RIGHT_ANALOG_STICK: "rs";
			case LEFT_STICK_DIGITAL_UP: "ls-up";
			case LEFT_STICK_DIGITAL_DOWN: "ls-down";
			case LEFT_STICK_DIGITAL_LEFT: "ls-left";
			case LEFT_STICK_DIGITAL_RIGHT: "ls-right";
			case RIGHT_STICK_DIGITAL_UP: "rs-up";
			case RIGHT_STICK_DIGITAL_DOWN: "rs-down";
			case RIGHT_STICK_DIGITAL_LEFT: "rs-left";
			case RIGHT_STICK_DIGITAL_RIGHT: "rs-right";
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: "l2";
			case RIGHT_TRIGGER_FAKE: "r2";
			#end
			default: null;
		}
	}
}

@SuppressWarnings("checkstyle:MemberName")
enum Manufacturer
{
	GooglePepper;
	AdobeWindows;
	Unknown;
}
