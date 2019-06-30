package flixel.input.gamepad.lists;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * A helper class for gamepad input.
 * Provides optimized gamepad button checking using direct array access.
 */
class FlxGamepadButtonList extends FlxBaseGamepadList
{
	public var A(get, never):Bool;

	inline function get_A()
		return check(FlxGamepadInputID.A);

	public var B(get, never):Bool;

	inline function get_B()
		return check(FlxGamepadInputID.B);

	public var X(get, never):Bool;

	inline function get_X()
		return check(FlxGamepadInputID.X);

	public var Y(get, never):Bool;

	inline function get_Y()
		return check(FlxGamepadInputID.Y);

	public var LEFT_SHOULDER(get, never):Bool;

	inline function get_LEFT_SHOULDER()
		return check(FlxGamepadInputID.LEFT_SHOULDER);

	public var RIGHT_SHOULDER(get, never):Bool;

	inline function get_RIGHT_SHOULDER()
		return check(FlxGamepadInputID.RIGHT_SHOULDER);

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return check(FlxGamepadInputID.BACK);

	public var START(get, never):Bool;

	inline function get_START()
		return check(FlxGamepadInputID.START);

	public var LEFT_STICK_CLICK(get, never):Bool;

	inline function get_LEFT_STICK_CLICK()
		return check(FlxGamepadInputID.LEFT_STICK_CLICK);

	public var RIGHT_STICK_CLICK(get, never):Bool;

	inline function get_RIGHT_STICK_CLICK()
		return check(FlxGamepadInputID.RIGHT_STICK_CLICK);

	public var GUIDE(get, never):Bool;

	inline function get_GUIDE()
		return check(FlxGamepadInputID.GUIDE);

	public var DPAD_UP(get, never):Bool;

	inline function get_DPAD_UP()
		return check(FlxGamepadInputID.DPAD_UP);

	public var DPAD_DOWN(get, never):Bool;

	inline function get_DPAD_DOWN()
		return check(FlxGamepadInputID.DPAD_DOWN);

	public var DPAD_LEFT(get, never):Bool;

	inline function get_DPAD_LEFT()
		return check(FlxGamepadInputID.DPAD_LEFT);

	public var DPAD_RIGHT(get, never):Bool;

	inline function get_DPAD_RIGHT()
		return check(FlxGamepadInputID.DPAD_RIGHT);

	public var LEFT_TRIGGER_BUTTON(get, never):Bool;

	inline function get_LEFT_TRIGGER_BUTTON()
		return check(FlxGamepadInputID.LEFT_TRIGGER_BUTTON);

	public var RIGHT_TRIGGER_BUTTON(get, never):Bool;

	inline function get_RIGHT_TRIGGER_BUTTON()
		return check(FlxGamepadInputID.RIGHT_TRIGGER_BUTTON);

	#if !FLX_JOYSTICK_API
	public var LEFT_TRIGGER(get, never):Bool;

	inline function get_LEFT_TRIGGER()
		return check(FlxGamepadInputID.LEFT_TRIGGER);

	public var RIGHT_TRIGGER(get, never):Bool;

	inline function get_RIGHT_TRIGGER()
		return check(FlxGamepadInputID.RIGHT_TRIGGER);
	#else
	public var LEFT_TRIGGER(get, never):Bool;

	inline function get_LEFT_TRIGGER()
		return check(FlxGamepadInputID.LEFT_TRIGGER_FAKE);

	public var RIGHT_TRIGGER(get, never):Bool;

	inline function get_RIGHT_TRIGGER()
		return check(FlxGamepadInputID.RIGHT_TRIGGER_FAKE);
	#end

	public var LEFT_ANALOG_STICK(get, never):Bool;

	inline function get_LEFT_ANALOG_STICK()
		return check(FlxGamepadInputID.LEFT_ANALOG_STICK);

	public var RIGHT_ANALOG_STICK(get, never):Bool;

	inline function get_RIGHT_ANALOG_STICK()
		return check(FlxGamepadInputID.RIGHT_ANALOG_STICK);

	public var DPAD(get, never):Bool;

	inline function get_DPAD()
		return check(FlxGamepadInputID.DPAD);

	public var TILT_PITCH(get, never):Bool;

	inline function get_TILT_PITCH()
		return check(FlxGamepadInputID.TILT_PITCH);

	public var TILT_ROLL(get, never):Bool;

	inline function get_TILT_ROLL()
		return check(FlxGamepadInputID.TILT_ROLL);

	public var POINTER_X(get, never):Bool;

	inline function get_POINTER_X()
		return check(FlxGamepadInputID.POINTER_X);

	public var POINTER_Y(get, never):Bool;

	inline function get_POINTER_Y()
		return check(FlxGamepadInputID.POINTER_Y);

	public var EXTRA_0(get, never):Bool;

	inline function get_EXTRA_0()
		return check(FlxGamepadInputID.EXTRA_0);

	public var EXTRA_1(get, never):Bool;

	inline function get_EXTRA_1()
		return check(FlxGamepadInputID.EXTRA_1);

	public var EXTRA_2(get, never):Bool;

	inline function get_EXTRA_2()
		return check(FlxGamepadInputID.EXTRA_2);

	public var EXTRA_3(get, never):Bool;

	inline function get_EXTRA_3()
		return check(FlxGamepadInputID.EXTRA_3);

	public var LEFT_STICK_DIGITAL_UP(get, never):Bool;

	inline function get_LEFT_STICK_DIGITAL_UP()
		return check(FlxGamepadInputID.LEFT_STICK_DIGITAL_UP);

	public var LEFT_STICK_DIGITAL_RIGHT(get, never):Bool;

	inline function get_LEFT_STICK_DIGITAL_RIGHT()
		return check(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT);

	public var LEFT_STICK_DIGITAL_DOWN(get, never):Bool;

	inline function get_LEFT_STICK_DIGITAL_DOWN()
		return check(FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN);

	public var LEFT_STICK_DIGITAL_LEFT(get, never):Bool;

	inline function get_LEFT_STICK_DIGITAL_LEFT()
		return check(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT);

	public var RIGHT_STICK_DIGITAL_UP(get, never):Bool;

	inline function get_RIGHT_STICK_DIGITAL_UP()
		return check(FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP);

	public var RIGHT_STICK_DIGITAL_RIGHT(get, never):Bool;

	inline function get_RIGHT_STICK_DIGITAL_RIGHT()
		return check(FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT);

	public var RIGHT_STICK_DIGITAL_DOWN(get, never):Bool;

	inline function get_RIGHT_STICK_DIGITAL_DOWN()
		return check(FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN);

	public var RIGHT_STICK_DIGITAL_LEFT(get, never):Bool;

	inline function get_RIGHT_STICK_DIGITAL_LEFT()
		return check(FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT);

	public function new(status:FlxInputState, gamepad:FlxGamepad)
	{
		super(status, gamepad);
	}
}
