package flixel.input.gamepad;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.lists.FlxGamepadAnalogList;
import flixel.input.gamepad.lists.FlxGamepadButtonList;
import flixel.input.gamepad.lists.FlxGamepadMotionValueList;
import flixel.input.gamepad.lists.FlxGamepadPointerValueList;
import flixel.input.gamepad.mappings.FlxGamepadMapping;
import flixel.input.gamepad.mappings.LogitechMapping;
import flixel.input.gamepad.mappings.MFiMapping;
import flixel.input.gamepad.mappings.MayflashWiiRemoteMapping;
import flixel.input.gamepad.mappings.OUYAMapping;
import flixel.input.gamepad.mappings.PS4Mapping;
import flixel.input.gamepad.mappings.PSVitaMapping;
import flixel.input.gamepad.mappings.WiiRemoteMapping;
import flixel.input.gamepad.mappings.SwitchProMapping;
import flixel.input.gamepad.mappings.SwitchJoyconLeftMapping;
import flixel.input.gamepad.mappings.SwitchJoyconRightMapping;
import flixel.input.gamepad.mappings.XInputMapping;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;
#if FLX_GAMEINPUT_API
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;
import flixel.math.FlxMath;
#elseif FLX_JOYSTICK_API
import flixel.math.FlxPoint;
#end

@:allow(flixel.input.gamepad)
class FlxGamepad implements IFlxDestroyable
{
	public var id(default, null):Int;

	#if FLX_GAMEINPUT_API
	/**
	 * The device name. Used to determine the `model`.
	 */
	public var name(get, never):String;
	#end

	/**
	 * The gamepad model used for the mapping of the IDs.
	 * Defaults to `detectedModel`, but can be changed manually.
	 */
	public var model(default, set):FlxGamepadModel;

	/**
	 * The gamepad model this gamepad has been identified as.
	 */
	public var detectedModel(default, null):FlxGamepadModel;

	/**
	 * The mapping that is used to map the raw hardware IDs to the values in `FlxGamepadInputID`.
	 * Determined by the current `model`.
	 * It's also possible to create a custom mapping and assign it here.
	 */
	public var mapping:FlxGamepadMapping;

	public var connected(default, null):Bool = true;

	/**
	 * For gamepads that can have things plugged into them (the Wii Remote, basically).
	 * Making the user set this helps Flixel properly interpret inputs properly.
	 * EX: if you plug a nunchuk into the Wii Remote, you will get different values for
	 * certain buttons than with the Wii Remote alone.
	 * (This is probably why Wii games ask the player what control scheme they are using.)
	 *
	 * In the future, this could also be used for any attachment that exposes new API features
	 * to the controller, e.g. a microphone or headset
	 */
	public var attachment(default, set):FlxGamepadAttachment;

	/**
	 * Gamepad deadzone. The lower, the more sensitive the gamepad.
	 * Should be between 0.0 and 1.0. Defaults to 0.15.
	 */
	public var deadZone(get, set):Float;

	/**
	 * Which dead zone mode to use for analog sticks.
	 */
	public var deadZoneMode:FlxGamepadDeadZoneMode = INDEPENDENT_AXES;

	/**
	 * Helper class to check if a button is pressed.
	 */
	public var pressed(default, null):FlxGamepadButtonList;

	/**
	 * Helper class to check if a button is released
	 */
	public var released(default, null):FlxGamepadButtonList;

	/**
	 * Helper class to check if a button was just pressed.
	 */
	public var justPressed(default, null):FlxGamepadButtonList;

	/**
	 * Helper class to check if a button was just released.
	 */
	public var justReleased(default, null):FlxGamepadButtonList;

	/**
	 * Helper class to get the justMoved, justReleased, and float values of analog input.
	 */
	public var analog(default, null):FlxGamepadAnalogList;

	/**
	 * Helper class to get the float values of motion-sensing input, if it is supported
	 */
	public var motion(default, null):FlxGamepadMotionValueList;

	/**
	 * Helper class to get the float values of mouse-like pointer input, if it is supported.
	 * (contains continously updated X and Y coordinates, each between 0.0 and 1.0)
	 */
	public var pointer(default, null):FlxGamepadPointerValueList;

	#if FLX_JOYSTICK_API
	public var hat(default, null):FlxPoint = FlxPoint.get();
	public var ball(default, null):FlxPoint = FlxPoint.get();
	#end

	var axis:Array<Float> = [for (i in 0...6) 0];
	var axisActive:Bool = false;

	var manager:FlxGamepadManager;
	var _deadZone:Float = 0.15;

	#if FLX_GAMEINPUT_API
	var _device:GameInputDevice;
	#end

	var buttons:Array<FlxGamepadButton> = [];

	public function new(ID:Int, Manager:FlxGamepadManager, ?Model:FlxGamepadModel, ?Attachment:FlxGamepadAttachment)
	{
		id = ID;

		manager = Manager;

		pressed = new FlxGamepadButtonList(FlxInputState.PRESSED, this);
		released = new FlxGamepadButtonList(FlxInputState.RELEASED, this);
		justPressed = new FlxGamepadButtonList(FlxInputState.JUST_PRESSED, this);
		justReleased = new FlxGamepadButtonList(FlxInputState.JUST_RELEASED, this);
		analog = new FlxGamepadAnalogList(this);
		motion = new FlxGamepadMotionValueList(this);
		pointer = new FlxGamepadPointerValueList(this);

		if (Model == null)
		{
			#if vita
			Model = PSVITA;
			#elseif ps4
			Model = PS4;
			#elseif xbox1
			Model = XINPUT;
			#else
			Model = XINPUT;
			#end
		}

		if (Attachment == null)
			Attachment = NONE;

		model = Model;
		detectedModel = Model;
	}

	function getButton(RawID:Int):FlxGamepadButton
	{
		if (RawID == -1)
			return null;
		var gamepadButton:FlxGamepadButton = buttons[RawID];

		if (gamepadButton == null)
		{
			gamepadButton = new FlxGamepadButton(RawID);
			buttons[RawID] = gamepadButton;
		}

		return gamepadButton;
	}

	inline function applyAxisFlip(axisValue:Float, axisID:Int):Float
	{
		if (mapping.isAxisFlipped(axisID))
			axisValue *= -1;
		return axisValue;
	}

	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
	{
		#if FLX_GAMEINPUT_API
		var control:GameInputControl;
		var button:FlxGamepadButton;

		if (_device == null)
			return;

		for (i in 0..._device.numControls)
		{
			control = _device.getControlAt(i);

			// quick absolute value for analog sticks
			button = getButton(i);

			if (isAxisForAnalogStick(i))
			{
				handleAxisMove(i, control.value, button.value);
			}

			button.value = control.value;

			var value = Math.abs(control.value);

			if (value < deadZone)
			{
				button.release();
			}
			else if (value > deadZone)
			{
				button.press();
			}
		}
		#elseif FLX_JOYSTICK_API
		for (i in 0...axis.length)
		{
			// do a reverse axis lookup to get a "fake" RawID and generate a button state object
			var button = getButton(mapping.axisIndexToRawID(i));
			if (button != null)
			{
				// TODO: account for circular deadzone if an analog stick input is detected?
				var value = applyAxisFlip(Math.abs(axis[i]), i);
				if (value > deadZone)
				{
					button.press();
				}
				else if (value < deadZone)
				{
					button.release();
				}
			}

			axisActive = false;
		}
		#end

		for (button in buttons)
		{
			if (button != null)
			{
				button.update();
			}
		}
	}

	public function reset():Void
	{
		for (button in buttons)
		{
			if (button != null)
			{
				button.reset();
			}
		}

		var numAxis:Int = axis.length;

		for (i in 0...numAxis)
		{
			axis[i] = 0;
		}

		#if FLX_JOYSTICK_API
		hat.set();
		ball.set();
		#end
	}

	public function destroy():Void
	{
		connected = false;

		buttons = null;
		axis = null;
		manager = null;

		#if FLX_JOYSTICK_API
		hat = FlxDestroyUtil.put(hat);
		ball = FlxDestroyUtil.put(ball);

		hat = null;
		ball = null;
		#end
	}

	/**
	 * Check the status of a "universal" button ID, auto-mapped to this gamepad (something like FlxGamepadInputID.A).
	 *
	 * @param	ID			"universal" gamepad input ID
	 * @param	Status		The key state to check for
	 * @return	Whether the provided button has the specified status
	 */
	public inline function checkStatus(ID:FlxGamepadInputID, Status:FlxInputState):Bool
	{
		return switch (ID)
		{
			case FlxGamepadInputID.ANY: anyButton(Status);
			case FlxGamepadInputID.NONE: !anyButton(Status);
			default: checkStatusRaw(mapping.getRawID(ID), Status);
		}
	}

	/**
	 * Check the status of a raw button ID (like XInputID.A).
	 *
	 * @param	RawID	Index into buttons array.
	 * @param	Status	The key state to check for
	 * @return	Whether the provided button has the specified status
	 */
	public inline function checkStatusRaw(RawID:Int, Status:FlxInputState):Bool
	{
		var button = buttons[RawID];
		return button != null && button.hasState(Status);
	}

	/**
	 * Helper function to check the status of an array of buttons
	 *
	 * @param	IDArray	An array of button IDs
	 * @param	State	The button state to check for
	 * @return	Whether at least one of the keys has the specified status
	 */
	function checkButtonArrayState(IDArray:Array<FlxGamepadInputID>, Status:FlxInputState):Bool
	{
		if (IDArray == null)
		{
			return false;
		}

		for (code in IDArray)
		{
			if (checkStatus(code, Status))
				return true;
		}

		return false;
	}

	/**
	 * Helper function to check the status of an array of buttons
	 *
	 * @param	IDArray	An array of keys as Strings
	 * @param	State	The key state to check for
	 * @return	Whether at least one of the keys has the specified status
	 */
	function checkButtonArrayStateRaw(IDArray:Array<Int>, Status:FlxInputState):Bool
	{
		if (IDArray == null)
		{
			return false;
		}

		for (code in IDArray)
		{
			if (checkStatusRaw(code, Status))
				return true;
		}

		return false;
	}

	/**
	 * Check if at least one button from an array of button IDs is pressed.
	 *
	 * @param	IDArray	An array of "universal" gamepad input IDs
	 * @return	Whether at least one of the buttons is pressed
	 */
	public inline function anyPressed(IDArray:Array<FlxGamepadInputID>):Bool
	{
		return checkButtonArrayState(IDArray, PRESSED);
	}

	/**
	 * Check if at least one button from an array of raw button IDs is pressed.
	 *
	 * @param	RawIDArray	An array of raw button IDs
	 * @return	Whether at least one of the buttons is pressed
	 */
	public inline function anyPressedRaw(RawIDArray:Array<Int>):Bool
	{
		return checkButtonArrayStateRaw(RawIDArray, PRESSED);
	}

	/**
	 * Check if at least one button from an array of universal button IDs was just pressed.
	 *
	 * @param	IDArray	An array of "universal" gamepad input IDs
	 * @return	Whether at least one of the buttons was just pressed
	 */
	public inline function anyJustPressed(IDArray:Array<FlxGamepadInputID>):Bool
	{
		return checkButtonArrayState(IDArray, JUST_PRESSED);
	}

	/**
	 * Check if at least one button from an array of raw button IDs was just pressed.
	 *
	 * @param	RawIDArray	An array of raw button IDs
	 * @return	Whether at least one of the buttons was just pressed
	 */
	public inline function anyJustPressedRaw(RawIDArray:Array<Int>):Bool
	{
		return checkButtonArrayStateRaw(RawIDArray, JUST_PRESSED);
	}

	/**
	 * Check if at least one button from an array of gamepad input IDs was just released.
	 *
	 * @param	IDArray	An array of "universal" gamepad input IDs
	 * @return	Whether at least one of the buttons was just released
	 */
	public inline function anyJustReleased(IDArray:Array<FlxGamepadInputID>):Bool
	{
		return checkButtonArrayState(IDArray, JUST_RELEASED);
	}

	/**
	 * Check if at least one button from an array of raw button IDs was just released.
	 *
	 * @param	RawArray	An array of raw button IDs
	 * @return	Whether at least one of the buttons was just released
	 */
	public inline function anyJustReleasedRaw(RawIDArray:Array<Int>):Bool
	{
		return checkButtonArrayStateRaw(RawIDArray, JUST_RELEASED);
	}

	/**
	 * Get the first found "universal" ID of the button which is currently pressed.
	 * Returns NONE if no button is pressed.
	 */
	public inline function firstPressedID():FlxGamepadInputID
	{
		var id = firstPressedRawID();
		if (id < 0)
			return id;

		return mapping.getID(id);
	}

	/**
	 * Get the first found raw ID of the button which is currently pressed.
	 * Returns -1 if no button is pressed.
	 */
	public function firstPressedRawID():Int
	{
		for (button in buttons)
		{
			if (button != null && button.pressed)
			{
				return button.ID;
			}
		}
		return -1;
	}

	/**
	 * Get the first found "universal" ButtonID of the button which has been just pressed.
	 * Returns NONE if no button was just pressed.
	 */
	public inline function firstJustPressedID():FlxGamepadInputID
	{
		var id = firstJustPressedRawID();
		if (id < 0)
			return id;

		return mapping.getID(id);
	}

	/**
	 * Get the first found raw ID of the button which has been just pressed.
	 * Returns -1 if no button was just pressed.
	 */
	public function firstJustPressedRawID():Int
	{
		for (button in buttons)
		{
			if (button != null && button.justPressed)
			{
				return button.ID;
			}
		}
		return -1;
	}

	/**
	 * Get the first found "universal" ButtonID of the button which has been just released.
	 * Returns NONE if no button was just released.
	 */
	public inline function firstJustReleasedID():FlxGamepadInputID
	{
		var id = firstJustReleasedRawID();
		if (id < 0)
			return id;

		return mapping.getID(id);
	}

	/**
	 * Get the first found raw ID of the button which has been just released.
	 * Returns -1 if no button was just released.
	 */
	public function firstJustReleasedRawID():Int
	{
		for (button in buttons)
		{
			if (button != null && button.justReleased)
			{
				return button.ID;
			}
		}
		return -1;
	}

	/**
	 * Gets the value of the specified axis using the "universal" ButtonID -
	 * use this only for things like FlxGamepadButtonID.LEFT_TRIGGER,
	 * use getXAxis() / getYAxis() for analog sticks!
	 */
	public function getAxis(AxisButtonID:FlxGamepadInputID):Float
	{
		#if !FLX_JOYSTICK_API
		return getAxisRaw(mapping.getRawID(AxisButtonID));
		#else
		var fakeAxisRawID:Int = mapping.checkForFakeAxis(AxisButtonID);
		if (fakeAxisRawID == -1)
		{
			// return the regular axis value
			var rawID = mapping.getRawID(AxisButtonID);
			return applyAxisFlip(getAxisRaw(rawID), AxisButtonID);
		}
		else
		{
			// if analog isn't supported for this input, return the correct digital button input instead
			var btn = getButton(fakeAxisRawID);
			if (btn == null)
				return 0;
			if (btn.pressed)
				return 1;
		}
		return 0;
		#end
	}

	/**
	 * Gets the value of the specified axis using the raw ID -
	 * use this only for things like XInputID.LEFT_TRIGGER,
	 * use getXAxis() / getYAxis() for analog sticks!
	 */
	public inline function getAxisRaw(RawAxisID:Int):Float
	{
		var axisValue = getAxisValue(RawAxisID);
		if (Math.abs(axisValue) > deadZone)
		{
			return axisValue;
		}
		return 0;
	}

	function isAxisForAnalogStick(AxisIndex:Int):Bool
	{
		var leftStick = mapping.leftStick;
		var rightStick = mapping.rightStick;

		if (leftStick != null)
		{
			if (AxisIndex == leftStick.x || AxisIndex == leftStick.y)
				return true;
		}
		if (rightStick != null)
		{
			if (AxisIndex == rightStick.x || AxisIndex == rightStick.y)
				return true;
		}
		return false;
	}

	inline function getAnalogStickByAxis(AxisIndex:Int):FlxGamepadAnalogStick
	{
		var leftStick = mapping.leftStick;
		var rightStick = mapping.rightStick;

		if (leftStick != null && AxisIndex == leftStick.x || AxisIndex == leftStick.y)
			return leftStick;
		if (rightStick != null && AxisIndex == rightStick.x || AxisIndex == rightStick.y)
			return rightStick;
		return null;
	}

	/**
	 * Given a ButtonID for an analog stick, gets the value of its x axis
	 * @param	AxesButtonID an analog stick like FlxGamepadButtonID.LEFT_STICK
	 */
	public inline function getXAxis(AxesButtonID:FlxGamepadInputID):Float
	{
		return getAnalogXAxisValue(mapping.getAnalogStick(AxesButtonID));
	}

	/**
	 * Given both raw IDs for the axes of an analog stick, gets the value of its x axis
	 */
	public inline function getXAxisRaw(Stick:FlxGamepadAnalogStick):Float
	{
		return getAnalogXAxisValue(Stick);
	}

	/**
	 * Given a ButtonID for an analog stick, gets the value of its y axis
	 * @param	AxesButtonID an analog stick like FlxGamepadButtonID.LEFT_STICK
	 */
	public inline function getYAxis(AxesButtonID:FlxGamepadInputID):Float
	{
		return getYAxisRaw(mapping.getAnalogStick(AxesButtonID));
	}

	/**
	 * Given both raw ID's for the axes of an analog stick, gets the value of its Y axis
	 * (should be used in flash to correct the inverted y axis)
	 */
	public function getYAxisRaw(Stick:FlxGamepadAnalogStick):Float
	{
		return getAnalogYAxisValue(Stick);
	}

	/**
	 * Convenience method that wraps `getXAxis()` and `getYAxis()` into a `FlxPoint`.
	 *
	 * @param	AxesButtonID an analog stick like `FlxGamepadButtonID.LEFT_STICK`
	 * @since	4.3.0
	 */
	public function getAnalogAxes(AxesButtonID:FlxGamepadInputID):FlxPoint
	{
		return FlxPoint.get(getXAxis(AxesButtonID), getYAxis(AxesButtonID));
	}

	/**
	 * Whether any buttons have the specified input state.
	 */
	public function anyButton(state:FlxInputState = PRESSED):Bool
	{
		for (button in buttons)
		{
			if (button != null && button.hasState(state))
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Check to see if any buttons are pressed right or Axis, Ball and Hat moved now.
	 */
	public function anyInput():Bool
	{
		if (anyButton())
			return true;

		var numAxis:Int = axis.length;

		for (i in 0...numAxis)
		{
			if (axis[0] != 0)
			{
				return true;
			}
		}

		#if FLX_JOYSTICK_API
		if (ball.x != 0 || ball.y != 0)
		{
			return true;
		}

		if (hat.x != 0 || hat.y != 0)
		{
			return true;
		}
		#end

		return false;
	}

	function getAxisValue(AxisID:Int):Float
	{
		var axisValue:Float = 0;

		#if FLX_GAMEINPUT_API
		if (AxisID == -1)
		{
			return 0;
		}
		if (_device != null && _device.enabled && FlxMath.inBounds(AxisID, 0, _device.numControls - 1))
		{
			axisValue = _device.getControlAt(AxisID).value;
		}
		#else
		if (AxisID < 0 || AxisID >= axis.length)
		{
			return 0;
		}

		axisValue = axis[AxisID];
		#end

		if (isAxisForAnalogStick(AxisID))
		{
			axisValue = applyAxisFlip(axisValue, AxisID);
		}

		return axisValue;
	}

	function getAnalogXAxisValue(stick:FlxGamepadAnalogStick):Float
	{
		if (stick == null)
			return 0;
		return if (deadZoneMode == CIRCULAR)
			getAnalogAxisValueCircular(stick, stick.x);
		else
			getAnalogAxisValueIndependent(stick.x);
	}

	function getAnalogYAxisValue(stick:FlxGamepadAnalogStick):Float
	{
		if (stick == null)
			return 0;
		return if (deadZoneMode == CIRCULAR)
			getAnalogAxisValueCircular(stick, stick.y);
		else
			getAnalogAxisValueIndependent(stick.y);
	}

	function getAnalogAxisValueCircular(stick:FlxGamepadAnalogStick, axisID:Int):Float
	{
		if (stick == null)
			return 0;
		var xAxis = getAxisValue(stick.x);
		var yAxis = getAxisValue(stick.y);

		var vector = FlxPoint.get(xAxis, yAxis);
		var length = vector.length;
		vector.put();

		if (length > deadZone)
		{
			return getAxisValue(axisID);
		}
		return 0;
	}

	function getAnalogAxisValueIndependent(axisID:Int):Float
	{
		var axisValue = getAxisValue(axisID);
		if (Math.abs(axisValue) > deadZone)
			return axisValue;
		return 0;
	}

	function handleAxisMove(axis:Int, newValue:Float, oldValue:Float)
	{
		newValue = applyAxisFlip(newValue, axis);
		oldValue = applyAxisFlip(oldValue, axis);

		// check to see if we should send digital inputs as well as analog
		var stick:FlxGamepadAnalogStick = getAnalogStickByAxis(axis);
		if (stick.mode == ONLY_DIGITAL || stick.mode == BOTH)
		{
			handleAxisMoveSub(stick, axis, newValue, oldValue, 1.0);
			handleAxisMoveSub(stick, axis, newValue, oldValue, -1.0);

			if (stick.mode == ONLY_DIGITAL)
			{
				// still haven't figured out how to suppress the analog inputs properly. Oh well.
			}
		}
	}

	function handleAxisMoveSub(stick:FlxGamepadAnalogStick, axis:Int, value:Float, oldValue:Float, sign:Float = 1.0)
	{
		var digitalButton = -1;

		if (axis == stick.x)
		{
			digitalButton = (sign < 0) ? stick.rawLeft : stick.rawRight;
		}
		else if (axis == stick.y)
		{
			digitalButton = (sign < 0) ? stick.rawUp : stick.rawDown;
		}

		var threshold = stick.digitalThreshold;
		var valueSign = value * sign;
		var oldValueSign = oldValue * sign;

		if (valueSign > threshold && oldValueSign <= threshold)
		{
			var btn = getButton(digitalButton);
			if (btn != null)
				btn.press();
		}
		else if (valueSign <= threshold && oldValueSign > threshold)
		{
			var btn = getButton(digitalButton);
			if (btn != null)
				btn.release();
		}
	}

	function createMappingForModel(model:FlxGamepadModel):FlxGamepadMapping
	{
		return switch (model)
		{
			case LOGITECH: new LogitechMapping(attachment);
			case OUYA: new OUYAMapping(attachment);
			case PS4: new PS4Mapping(attachment);
			case PSVITA: new PSVitaMapping(attachment);
			case XINPUT: new XInputMapping(attachment);
			case MAYFLASH_WII_REMOTE: new MayflashWiiRemoteMapping(attachment);
			case WII_REMOTE: new WiiRemoteMapping(attachment);
			case MFI: new MFiMapping(attachment);
			case SWITCH_PRO: new SwitchProMapping(attachment);
			case SWITCH_JOYCON_LEFT: new SwitchJoyconLeftMapping(attachment);
			case SWITCH_JOYCON_RIGHT: new SwitchJoyconRightMapping(attachment);
			// default to XInput if we don't have a mapping for this
			case _: new XInputMapping(attachment);
		}
	}

	#if FLX_GAMEINPUT_API
	function get_name():String
	{
		if (_device == null)
			return null;
		return _device.name;
	}
	#end

	function set_model(Model:FlxGamepadModel):FlxGamepadModel
	{
		model = Model;
		mapping = createMappingForModel(model);

		return model;
	}

	function set_attachment(Attachment:FlxGamepadAttachment):FlxGamepadAttachment
	{
		attachment = Attachment;
		mapping.attachment = Attachment;
		return attachment;
	}

	function get_deadZone():Float
	{
		return (manager == null || manager.globalDeadZone == null) ? _deadZone : manager.globalDeadZone;
	}

	inline function set_deadZone(deadZone:Float):Float
	{
		return _deadZone = deadZone;
	}
	
	/** 
	 * @since 4.8.0
	 */
	public inline function getInputLabel(id:FlxGamepadInputID)
	{
		return mapping.getInputLabel(id);
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("id", id),
			LabelValuePair.weak("model", model),
			LabelValuePair.weak("deadZone", deadZone)
		]);
	}
}

enum FlxGamepadDeadZoneMode
{
	/**
	 * The value of each axis is compared to the deadzone individually.
	 * Works better when an analog stick is used like arrow keys for 4-directional-input.
	 */
	INDEPENDENT_AXES;

	/**
	 * X and y are combined against the deadzone combined.
	 * Works better when an analog stick is used as a two-dimensional control surface.
	 */
	CIRCULAR;
}

enum FlxGamepadModel
{
	LOGITECH;
	OUYA;
	PS4;
	PSVITA;
	XINPUT;
	MAYFLASH_WII_REMOTE;
	WII_REMOTE;
	MFI;

	/** 
	 * @since 4.8.0
	 */
	SWITCH_PRO; // also dual joycons

	/** 
	 * @since 4.8.0
	 */
	SWITCH_JOYCON_LEFT;

	/** 
	 * @since 4.8.0
	 */
	SWITCH_JOYCON_RIGHT;

	UNKNOWN;
}

enum FlxGamepadAttachment
{
	WII_NUNCHUCK;
	WII_CLASSIC_CONTROLLER;
	NONE;
}
