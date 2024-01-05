package flixel.input.gamepad;

import flixel.input.FlxInput.FlxInputState;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.util.FlxDestroyUtil;
#if FLX_JOYSTICK_API
import flixel.FlxG;
import flixel.math.FlxPoint;
import openfl.events.JoystickEvent;
#elseif FLX_GAMEINPUT_API
import openfl.ui.GameInput;
import openfl.ui.GameInputDevice;
import openfl.events.GameInputEvent;

using flixel.util.FlxStringUtil;
#end

class FlxGamepadManager implements IFlxInputManager
{
	/**
	 * The first accessed gamepad - can be `null`!
	 */
	public var firstActive:FlxGamepad;

	/**
	 * The last accessed gamepad - can be `null`!
	 */
	public var lastActive:FlxGamepad;

	/**
	 * A counter for the number of active gamepads
	 */
	public var numActiveGamepads(get, never):Int;

	/**
	 * Global Gamepad deadzone. The lower, the more sensitive the gamepad. Should be
	 * between 0.0 and 1.0. Null by default, overrides the deadzone of gamepads if non-null.
	 */
	public var globalDeadZone:Null<Float>;

	/**
	 * Signal for when a device is connected; returns the connected gamepad object to the attached listener
	 * @since 4.6.0
	 */
	public var deviceConnected(default, null):FlxTypedSignal<FlxGamepad->Void>;

	/**
	 * Signal for when a device is disconnected; returns the id of the disconnected gamepad to the attached listener
	 * @since 4.6.0
	 */
	public var deviceDisconnected(default, null):FlxTypedSignal<FlxGamepad->Void>;

	/**
	 * Stores all gamepads - can have null entries, but index matches event.device
	 */
	var _gamepads:Array<FlxGamepad> = [];

	/**
	 * Stores all gamepads - no null entries, but index does *not* match event.device
	 */
	var _activeGamepads:Array<FlxGamepad> = [];

	#if FLX_GAMEINPUT_API
	/**
	 * GameInput needs to be statically created, otherwise GameInput.numDevices will be zero during construction.
	 */
	static var _gameInput:GameInput = new GameInput();
	#end

	/**
	 * Returns a FlxGamepad with the specified ID or null if none was found.
	 * For example, if there are 4 gamepads connected, they will have the IDs 0-3.
	 */
	public inline function getByID(GamepadID:Int):FlxGamepad
	{
		return _activeGamepads[GamepadID];
	}

	function removeByID(GamepadID:Int):Void
	{
		var gamepad:FlxGamepad = _gamepads[GamepadID];

		if (gamepad != null)
		{
			_gamepads[GamepadID] = null;

			var i = _activeGamepads.indexOf(gamepad);
			if (i != -1)
			{
				_activeGamepads[i] = null;
				deviceDisconnected.dispatch(gamepad);
			}

			FlxDestroyUtil.destroy(gamepad);
		}

		if (lastActive == gamepad)
			lastActive = null;

		if (firstActive == gamepad)
			firstActive = null;
	}

	function createByID(GamepadID:Int, ?Model:FlxGamepadModel):FlxGamepad
	{
		var gamepad:FlxGamepad = _gamepads[GamepadID];
		if (gamepad == null)
		{
			gamepad = new FlxGamepad(GamepadID, this, Model);
			_gamepads[GamepadID] = gamepad;

			// fill the first "empty spot" in the array
			var nullFound:Bool = false;
			for (i in 0..._activeGamepads.length)
			{
				if (_activeGamepads[i] == null)
				{
					_activeGamepads[i] = gamepad;
					nullFound = true;
					break;
				}
			}

			if (!nullFound)
				_activeGamepads.push(gamepad);
		}

		lastActive = gamepad;
		if (firstActive == null)
			firstActive = gamepad;

		return gamepad;
	}

	/**
	 * Get array of ids for gamepads with any pressed buttons or moved Axis, Ball and Hat.
	 *
	 * @param	IDsArray	optional array to fill with ids
	 * @return	array filled with active gamepad ids
	 */
	public function getActiveGamepadIDs(?IDsArray:Array<Int>):Array<Int>
	{
		if (IDsArray == null)
			IDsArray = [];

		for (gamepad in _gamepads)
			if (gamepad != null && gamepad.anyInput())
				IDsArray.push(gamepad.id);

		return IDsArray;
	}

	/**
	 * Get array of gamepads with any pressed buttons or moved Axis, Ball and Hat.
	 *
	 * @param	GamepadArray	optional array to fill with active gamepads
	 * @return	array filled with active gamepads
	 */
	public function getActiveGamepads(?GamepadArray:Array<FlxGamepad>):Array<FlxGamepad>
	{
		if (GamepadArray == null)
			GamepadArray = [];

		for (gamepad in _gamepads)
			if (gamepad != null && gamepad.anyInput())
				GamepadArray.push(gamepad);

		return GamepadArray;
	}

	/**
	 * Get first found active gamepad id (with any pressed buttons or moved Axis, Ball and Hat).
	 * Returns "-1" if no active gamepad has been found.
	 */
	public function getFirstActiveGamepadID():Int
	{
		var firstActive:FlxGamepad = getFirstActiveGamepad();
		return (firstActive == null) ? -1 : firstActive.id;
	}

	/**
	 * Get first found active gamepad (with any pressed buttons or moved Axis, Ball and Hat).
	 * Returns null if no active gamepad has been found.
	 */
	public function getFirstActiveGamepad():FlxGamepad
	{
		for (gamepad in _gamepads)
			if (gamepad != null && gamepad.anyInput())
				return gamepad;

		return null;
	}

	/**
	 * Whether any buttons have the specified input state on any gamepad.
	 */
	public function anyButton(state:FlxInputState = PRESSED):Bool
	{
		for (gamepad in _gamepads)
			if (gamepad != null && gamepad.anyButton(state))
				return true;

		return false;
	}

	/**
	 * Whether there's any input at all on any gamepad.
	 */
	public function anyInput():Bool
	{
		for (gamepad in _gamepads)
			if (gamepad != null && gamepad.anyInput())
				return true;

		return false;
	}

	/**
	 * Whether this button is pressed on any gamepad.
	 */
	public inline function anyPressed(buttonID:FlxGamepadInputID):Bool
	{
		return anyHasState(buttonID, FlxInputState.PRESSED);
	}

	/**
	 * Whether this button was just pressed on any gamepad.
	 */
	public inline function anyJustPressed(buttonID:FlxGamepadInputID):Bool
	{
		return anyHasState(buttonID, FlxInputState.JUST_PRESSED);
	}

	/**
	 * Whether this button was just released on any gamepad.
	 */
	public inline function anyJustReleased(buttonID:FlxGamepadInputID):Bool
	{
		return anyHasState(buttonID, FlxInputState.JUST_RELEASED);
	}

	function anyHasState(buttonID:FlxGamepadInputID, state:FlxInputState):Bool
	{
		for (gamepad in _gamepads)
			if (gamepad != null && gamepad.checkStatus(buttonID, state))
				return true;

		return false;
	}

	/**
	 * Check to see if the X axis is moved on any Gamepad.
	 *
	 * @param AxisID The axis id
	 * @return Float Value from -1 to 1 or 0 if no X axes were moved
	 */
	public function anyMovedXAxis(RawAxisID:FlxGamepadAnalogStick):Float
	{
		for (gamepad in _gamepads)
		{
			if (gamepad == null)
				continue;

			var value = gamepad.getXAxisRaw(RawAxisID);
			if (value != 0)
				return value;
		}

		return 0;
	}

	/**
	 * Check to see if the Y axis is moved on any Gamepad.
	 *
	 * @param AxisID The axis id
	 * @return Float Value from -1 to 1 or 0 if no Y axes were moved
	 */
	public function anyMovedYAxis(RawAxisID:FlxGamepadAnalogStick):Float
	{
		for (gamepad in _gamepads)
		{
			if (gamepad == null)
				continue;

			var value = gamepad.getYAxisRaw(RawAxisID);
			if (value != 0)
				return value;
		}

		return 0;
	}

	/**
	 * Clean up memory. Internal use only.
	 */
	@:noCompletion
	public function destroy():Void
	{
		_gamepads = FlxDestroyUtil.destroyArray(_gamepads);

		firstActive = null;
		lastActive = null;
		_gamepads = null;

		#if FLX_GAMEINPUT_API
		// not sure this is needed - can't imagine any use case where FlxGamepadManager would be destroyed
		_gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, onDeviceAdded);
		_gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
		#end
	}

	/**
	 * Resets all the keys on all joys.
	 */
	public function reset():Void
	{
		for (gamepad in _gamepads)
			if (gamepad != null)
				gamepad.reset();
	}

	@:allow(flixel.FlxG)
	function new()
	{
		deviceConnected = new FlxTypedSignal<FlxGamepad->Void>();
		deviceDisconnected = new FlxTypedSignal<FlxGamepad->Void>();
		#if FLX_JOYSTICK_API
		FlxG.stage.addEventListener(JoystickEvent.AXIS_MOVE, handleAxisMove);
		FlxG.stage.addEventListener(JoystickEvent.BALL_MOVE, handleBallMove);
		FlxG.stage.addEventListener(JoystickEvent.BUTTON_DOWN, handleButtonDownEvent);
		FlxG.stage.addEventListener(JoystickEvent.BUTTON_UP, handleButtonUpEvent);
		FlxG.stage.addEventListener(JoystickEvent.HAT_MOVE, handleHatMove);
		FlxG.stage.addEventListener(JoystickEvent.DEVICE_REMOVED, handleDeviceRemoved);
		FlxG.stage.addEventListener(JoystickEvent.DEVICE_ADDED, handleDeviceAdded);
		#elseif FLX_GAMEINPUT_API
		_gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onDeviceAdded);
		_gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);

		for (i in 0...GameInput.numDevices)
			addGamepad(GameInput.getDeviceAt(i));
		#end
	}

	#if FLX_GAMEINPUT_API
	function onDeviceAdded(Event:GameInputEvent):Void
	{
		addGamepad(Event.device);
	}

	function onDeviceRemoved(Event:GameInputEvent):Void
	{
		removeGamepad(Event.device);
	}

	function findGamepadIndex(Device:GameInputDevice):Int
	{
		if (Device == null)
			return -1;

		for (i in 0...GameInput.numDevices)
			if (GameInput.getDeviceAt(i) == Device)
				return i;

		return -1;
	}

	function addGamepad(Device:GameInputDevice):Void
	{
		if (Device == null)
			return;

		Device.enabled = true;
		var id:Int = findGamepadIndex(Device);

		if (id < 0)
			return;

		var gamepad:FlxGamepad = createByID(id, getModelFromDeviceName(Device.name));
		gamepad._device = Device;

		deviceConnected.dispatch(gamepad);
	}

	function getModelFromDeviceName(name:String):FlxGamepadModel
	{
		// If we're actually running on console hardware, we know what controller hardware you're using
		// TODO: add support for multiple controller types on console that support that (WiiU for instance)
		if (name == null)
			return UNKNOWN;

		#if vita
		return PSVITA;
		#elseif ps4
		return PS4;
		#elseif xbox1
		return XINPUT;
		#end

		// "Sony PLAYSTATION(R)3 Controller" is the PS3 controller, but that is not supported as its PC drivers are terrible,
		// and the most popular tools just turn it into a 360 controller

		name = name.toLowerCase().remove("-").remove("_");
		return if (name.contains("ouya"))
				OUYA; // "OUYA Game Controller"
			else if (name.contains("wireless controller") || name.contains("ps4"))
				PS4; // "Wireless Controller" or "PS4 controller"
			else if (name.contains("logitech"))
				LOGITECH;
			else if ((name.contains("xbox") && name.contains("360")) || name.contains("xinput"))
				XINPUT;
			else if (name.contains("nintendo rvlcnt01tr"))
				WII_REMOTE; // WiiRemote with motion plus
			else if (name.contains("nintendo rvlcnt01"))
				WII_REMOTE; // WiiRemote w/o  motion plus
			else if (name.contains("mayflash wiimote pc adapter"))
				MAYFLASH_WII_REMOTE; // WiiRemote paired to MayFlash DolphinBar (with or w/o motion plus)
			else if (name.contains("pro controller") || name.contains("joycon l+r"))
				SWITCH_PRO;
			else if (name.contains("joycon (l)"))
				SWITCH_JOYCON_LEFT;
			else if (name.contains("joycon (r)"))
				SWITCH_JOYCON_RIGHT;
			else if (name.contains("mfi"))
				MFI;// Keep last. "mfi" may show up in brand names, words, serials or SKUs
			else
				UNKNOWN;
	}

	function removeGamepad(Device:GameInputDevice):Void
	{
		if (Device == null)
			return;

		for (i in 0..._gamepads.length)
		{
			var gamepad:FlxGamepad = _gamepads[i];
			if (gamepad != null && gamepad._device == Device)
			{
				removeByID(i);
			}
		}
	}
	#end

	#if FLX_JOYSTICK_API
	function getModelFromJoystick(id:Float):FlxGamepadModel
	{
		// id "1" is PS3, but that is not supported as its PC drivers are terrible,
		// and the most popular tools just turn it into a 360 controller
		return switch (Math.round(id))
		{
			case 0: XINPUT;
			case 2: PS4;
			case 3: OUYA;
			case 4: MAYFLASH_WII_REMOTE;
			case 5: WII_REMOTE;
			default: UNKNOWN;
		}
	}

	function handleButtonDownEvent(event:JoystickEvent):Void
	{
		handleButtonDown(event.device, event.id);
	}

	function handleButtonDown(device:Int, id:Int):Void
	{
		var button:FlxGamepadButton = createByID(device).getButton(id);
		if (button != null)
			button.press();
	}

	function handleButtonUpEvent(event:JoystickEvent):Void
	{
		handleButtonUp(event.device, event.id);
	}

	function handleButtonUp(device:Int, id:Int):Void
	{
		var button:FlxGamepadButton = createByID(device).getButton(id);
		if (button != null)
			button.release();
	}

	function handleAxisMove(event:JoystickEvent):Void
	{
		var device:Int = event.device;
		var gamepad:FlxGamepad = createByID(device);

		var oldAxis = gamepad.axis;
		var newAxis = event.axis;

		for (i in 0...newAxis.length)
		{
			var isForStick = gamepad.isAxisForAnalogStick(i);
			var isForMotion = gamepad.mapping.isAxisForMotion(i);

			if (!isForStick && !isForMotion)
			{
				// in legacy this returns a (-1, 1) range, but in flash/next it
				// returns (0,1) so we normalize to (0, 1) for legacy target only
				newAxis[i] = (newAxis[i] + 1) / 2;
			}
			else if (isForStick)
			{
				gamepad.handleAxisMove(i, newAxis[i], (i >= 0 && i < oldAxis.length) ? oldAxis[i] : 0);
			}
		}

		gamepad.axis = newAxis;
		gamepad.axisActive = true;
	}

	function copyToPointWithDeadzone(gamepad:FlxGamepad, point:FlxPoint, event:JoystickEvent):Void
	{
		point.x = (Math.abs(event.x) < gamepad.deadZone) ? 0 : event.x;
		point.y = (Math.abs(event.y) < gamepad.deadZone) ? 0 : event.y;
	}

	function handleBallMove(event:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = createByID(event.device);
		copyToPointWithDeadzone(gamepad, gamepad.ball, event);
	}

	function handleHatMove(event:JoystickEvent):Void
	{
		var device:Int = event.device;
		var gamepad:FlxGamepad = createByID(device);

		var oldX = gamepad.hat.x;
		var oldY = gamepad.hat.y;

		copyToPointWithDeadzone(gamepad, gamepad.hat, event);

		checkDpadAxisChange(device, oldX, gamepad.hat.x, FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.DPAD_RIGHT);
		checkDpadAxisChange(device, oldY, gamepad.hat.y, FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.DPAD_DOWN);
	}

	function checkDpadAxisChange(device:Int, oldValue:Float, newValue:Float, negativeID:FlxGamepadInputID, positiveID:FlxGamepadInputID):Void
	{
		if (oldValue == newValue)
			return;

		var rawNegativeID = createByID(device).mapping.getRawID(negativeID);
		var rawPositiveID = createByID(device).mapping.getRawID(positiveID);

		if (oldValue == -1)
			handleButtonUp(device, rawNegativeID);
		else if (oldValue == 1)
			handleButtonUp(device, rawPositiveID);

		if (newValue == -1)
			handleButtonDown(device, rawNegativeID);
		else if (newValue == 1)
			handleButtonDown(device, rawPositiveID);
	}

	function handleDeviceAdded(event:JoystickEvent):Void
	{
		var gamepad = createByID(event.device, getModelFromJoystick(event.x));
		deviceConnected.dispatch(gamepad);
	}

	function handleDeviceRemoved(event:JoystickEvent):Void
	{
		removeByID(event.device);
	}
	#end

	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	function update():Void
	{
		for (gamepad in _gamepads)
			if (gamepad != null)
				gamepad.update();
	}

	inline function onFocus():Void {}

	inline function onFocusLost():Void
	{
		reset();
	}

	function get_numActiveGamepads():Int
	{
		var count = 0;
		for (gamepad in _gamepads)
			if (gamepad != null)
				count++;
		return count;
	}
}
