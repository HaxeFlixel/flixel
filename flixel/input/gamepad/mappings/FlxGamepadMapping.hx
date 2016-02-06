package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
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
	private var attachment(default, set):FlxGamepadAttachment = NONE;
	
	private var manufacturer:Manufacturer;
	
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
	
	private function initValues():Void {}
	
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
	
	public function isAxisForMotion(ID:FlxGamepadInputID):Bool
	{
		return false;
	}
	
	/**
	 * Whether this axis needs to be flipped
	 */
	public function isAxisFlipped(axisID:Int):Bool
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
	
	private function set_attachment(attachment:FlxGamepadAttachment):FlxGamepadAttachment
	{
		return this.attachment = attachment;
	}
}

enum Manufacturer
{
	GooglePepper;
	AdobeWindows;
	Unknown;
}