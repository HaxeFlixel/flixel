package flixel.input.gamepad;

import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxDestroyUtil;
using flixel.util.FlxStringUtil;

#if FLX_JOYSTICK_API
import openfl.events.JoystickEvent;
#elseif FLX_GAMEINPUT_API
import flash.ui.GameInput;
import flash.ui.GameInputDevice;
import flash.events.GameInputEvent;
#end

class FlxGamepadManager implements IFlxInputManager
{
	/**
	 * The first accessed gamepad - can be null!
	 */
	public var firstActive:FlxGamepad;
	/**
	 * The last accessed gamepad - can be null!
	 */
	public var lastActive:FlxGamepad;
	
	/**
	 * A counter for the number of active gamepads
	 */
	public var numActiveGamepads(get, null):Int;
	
	/**
	 * Global Gamepad deadzone. The lower, the more sensitive the gamepad. Should be
	 * between 0.0 and 1.0. Null by default, overrides the deadzone of gamepads if non-null.
	 */
	public var globalDeadZone:Null<Float>;
	
	/**
	 * Stores all gamepads - can have null entries, but index matches event.device
	 */
	private var _gamepads:Array<FlxGamepad> = [];
	/**
	 * Stores all gamepads - no null entries, but index does *not* match event.device
	 */
	private var _activeGamepads:Array<FlxGamepad> = [];
	
	#if FLX_GAMEINPUT_API
	/**
	 * GameInput needs to be statically created, otherwise GameInput.numDevices will be zero during construction.
	 */
	private static var _gameInput:GameInput = new GameInput();
	#elseif FLX_JOYSTICK_API
	private static inline var JOYSTICK_BUTTON_UP:String = "buttonUp";
	private static inline var JOYSTICK_BUTTON_DOWN:String = "buttonDown";
	#end
	
	/**
	 * Returns a FlxGamepad with the specified ID or null if none was found.
	 * For example, if there are 4 gamepads connected, they will have the IDs 0-3.
	 */
	public inline function getByID(GamepadID:Int):FlxGamepad
	{
		return _activeGamepads[GamepadID];
	}
	
	private function removeByID(GamepadID:Int):Void
	{
		var gamepad:FlxGamepad = _gamepads[GamepadID];
		if (gamepad != null)
		{
			FlxDestroyUtil.destroy(gamepad);
			_gamepads[GamepadID] = null;
			
			var i = _activeGamepads.indexOf(gamepad);
			if (i != -1)
			{
				_activeGamepads[i] = null;
			}
		}
		
		if (lastActive == gamepad)
			lastActive = null;
		
		if (firstActive == gamepad)
			firstActive = null;
	}
	
	private function createByID(GamepadID:Int, ?Model:FlxGamepadModel):FlxGamepad
	{
		var gamepad:FlxGamepad = _gamepads[GamepadID];
		if (gamepad == null)
		{
			gamepad = new FlxGamepad(GamepadID, this, Model);
			_gamepads[GamepadID] = gamepad;
			
			//fill the first "empty spot" in the array
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
			{
				_activeGamepads.push(gamepad);
			}
		}
		
		lastActive = gamepad;
		if (firstActive == null)
		{
			firstActive = gamepad;
		}
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
		{
			IDsArray = [];
		}
		
		for (gamepad in _gamepads)
		{
			if ((gamepad != null) && gamepad.anyInput())
			{
				IDsArray.push(gamepad.id);
			}
		}
		
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
		{
			GamepadArray = [];
		}
		
		for (gamepad in _gamepads)
		{
			if ((gamepad != null) && gamepad.anyInput())
			{
				GamepadArray.push(gamepad);
			}
		}
		
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
		{
			if (gamepad != null && gamepad.anyInput())
			{
				return gamepad;
			}
		}
		
		return null;
	}
	
	/**
	 * Whether any buttons have the specified input state on any gamepad.
	 */
	public function anyButton(state:FlxInputState = PRESSED):Bool
	{
		for (gamepad in _gamepads)
		{
			if (gamepad != null && gamepad.anyButton(state))
			{
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Check to see if any buttons are pressed right or Axis, Ball and Hat Moved on any gamepad.
	 */
	public function anyInput():Bool
	{
		for (gamepad in _gamepads)
		{
			if (gamepad != null && gamepad.anyInput())
			{
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Check to see if this button is pressed on any Gamepad.
	 * 
	 * @param 	ButtonID  The button id (from 0 to 7).
	 * @return 	Whether the button is pressed
	 */
	public function anyPressed(buttonID:FlxGamepadInputID):Bool
	{
		for (gamepad in _gamepads)
		{
			if (gamepad != null && gamepad.checkStatus(buttonID, PRESSED))
			{
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Check to see if this button was just pressed on any Gamepad.
	 * 
	 * @param 	ButtonID 	The button id (from 0 to 7).
	 * @return 	Whether the button was just pressed
	*/
	public function anyJustPressed(buttonID:FlxGamepadInputID):Bool
	{
		for (gamepad in _gamepads)
		{
			if (gamepad != null && gamepad.checkStatus(buttonID, JUST_PRESSED))
			{
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Check to see if this button is just released on any Gamepad.
	 * 
	 * @param 	ButtonID 	The Button id (from 0 to 7).
	 * @return 	Whether the button is just released.
	*/
	public function anyJustReleased(buttonID:FlxGamepadInputID):Bool
	{
		for (gamepad in _gamepads)
		{
			if (gamepad != null && gamepad.checkStatus(buttonID, JUST_RELEASED))
			{
				return true;
			}
		}
		
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
			if (gamepad != null)
			{
				var value = gamepad.getXAxisRaw(RawAxisID);
				if (value != 0) return value;
			}
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
			if (gamepad != null)
			{
				var value = gamepad.getYAxisRaw(RawAxisID);
				if (value != 0) return value;
			}
		}
		
		return 0;
	}
	
	/**
	 * Clean up memory. Internal use only.
	 */
	@:noCompletion
	public function destroy():Void
	{
		for (gamepad in _gamepads)
		{
			gamepad = FlxDestroyUtil.destroy(gamepad);
		}
		
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
		{
			if (gamepad != null)
			{
				gamepad.reset();
			}
		}
	}
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		#if FLX_JOYSTICK_API
		FlxG.stage.addEventListener(JoystickEvent.AXIS_MOVE, handleAxisMove);
		FlxG.stage.addEventListener(JoystickEvent.BALL_MOVE, handleBallMove);
		FlxG.stage.addEventListener(JoystickEvent.BUTTON_DOWN, handleButtonDown);
		FlxG.stage.addEventListener(JoystickEvent.BUTTON_UP, handleButtonUp);
		FlxG.stage.addEventListener(JoystickEvent.HAT_MOVE, handleHatMove);
		FlxG.stage.addEventListener(JoystickEvent.DEVICE_REMOVED, handleDeviceRemoved);
		FlxG.stage.addEventListener(JoystickEvent.DEVICE_ADDED, handleDeviceAdded);
		#elseif FLX_GAMEINPUT_API
		_gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onDeviceAdded);
		_gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
		
		for (i in 0...GameInput.numDevices)
		{
			addGamepad(GameInput.getDeviceAt(i));
		}
		#end
	}
	
	#if FLX_GAMEINPUT_API
	private function onDeviceAdded(Event:GameInputEvent):Void
	{
		addGamepad(Event.device);
	}
	
	private function onDeviceRemoved(Event:GameInputEvent):Void
	{
		removeGamepad(Event.device);
	}
	
	private function findGamepadIndex(Device:GameInputDevice):Int
	{
		if (Device != null)
		{
			for (i in 0...GameInput.numDevices)
			{
				var currentDevice = GameInput.getDeviceAt(i);
				if (currentDevice == Device)
				{
					return i;
				}
			}
		}
		return -1;
	}
	
	private function addGamepad(Device:GameInputDevice):Void
	{
		if (Device != null)
		{
			Device.enabled = true;
			var id:Int = findGamepadIndex(Device);
			
			if (id >= 0)
			{
				var gamepad:FlxGamepad = createByID(id, getModelFromFlashDeviceName(Device.name));
				gamepad._device = Device;
			}
		}
	}
	
	private function getModelFromFlashDeviceName(str:String):FlxGamepadModel
	{
		str = str.toLowerCase();
		var strip = ["-", "_"];
		for (s in strip)
		{
			while (str.indexOf(s) != -1)
			{
				str = StringTools.replace(str, s, "");
			}
		}
		
		//"Sony PLAYSTATION(R)3 Controller" is the PS3 controller, but that is not supported as its PC drivers are terrible,
		//and the most popular tools just turn it into a 360 controller
		
		// needs to be checked even though it's default to not mistake it for XInput on flash 
		return if (str.contains("xbox") && str.contains("360")) XBOX360;
			else if (str.contains("ouya")) OUYA;                                      //"OUYA Game Controller"
			else if (str.contains("wireless controller") || str.contains("ps4")) PS4; //"Wireless Controller" or "PS4 controller"
			else if (str.contains("logitech")) Logitech;
			else if (str.contains("xinput")) XInput;
			else if (str.contains("nintendo rvlcnt01tr")) WII_REMOTE;                  //WiiRemote with motion plus
			else if (str.contains("nintendo rvlcnt01")) WII_REMOTE;                    //WiiRemote w/o  motion plus
			else if (str.contains("mayflash wiimote pc adapter")) MAYFLASH_WII_REMOTE;  //WiiRemote paired to MayFlash DolphinBar (with or w/o motion plus)
			else if (str.contains("mfi")) MFI;
			else XBOX360; //default
	}
	
	private function removeGamepad(Device:GameInputDevice):Void
	{
		if (Device != null)
		{
			for (i in 0..._gamepads.length)
			{
				var gamepad:FlxGamepad = _gamepads[i];
				if (gamepad != null && gamepad._device == Device)
				{
					removeByID(i);
				}
			}
		}
	}
	#end
	
	#if FLX_JOYSTICK_API
	private function getModelFromJoystick(f:Float):FlxGamepadModel
	{
		//id "1" is PS3, but that is not supported as its PC drivers are terrible,
		// and the most popular tools just turn it into a 360 controller
		return switch (Math.round(f))
		{
			case 2: PS4;
			case 3: OUYA;
			case 4: MAYFLASH_WII_REMOTE;
			case 5: WII_REMOTE;
			default: XBOX360;
		}
	}
	
	private function handleButtonDown(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = createByID(FlashEvent.device);
		var button:FlxGamepadButton = gamepad.getButton(FlashEvent.id);
		if (button != null) 
		{
			button.press();
		}
	}
	
	private function handleButtonUp(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = createByID(FlashEvent.device);
		var button:FlxGamepadButton = gamepad.getButton(FlashEvent.id);
		if (button != null) 
		{
			button.release();
		}
	}
	
	private function handleAxisMove(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = createByID(FlashEvent.device);
		
		var oldAxis = gamepad.axis;
		var newAxis = FlashEvent.axis;
		
		for (i in 0...newAxis.length)
		{
			var isForStick = gamepad.isAxisForAnalogStick(i);
			var isForMotion = gamepad.isAxisForMotion(i);
			if (!isForStick && !isForMotion)
			{
				// in legacy this returns a (-1,1) range, but in flash/next it
				// returns (0,1) so we normalize to (0,1) for legacy target only
				newAxis[i] = (newAxis[i] + 1) / 2;
			}
			else if (isForStick)
			{
				//check to see if we should send digital inputs as well as analog
				var stick:FlxGamepadAnalogStick = gamepad.getAnalogStickByAxis(i);
				if (stick.mode == ONLY_DIGITAL || stick.mode == BOTH)
				{
					var newVal = newAxis[i];
					var oldVal = oldAxis[i];
					
					var neg = stick.digitalThreshold * -1;
					var pos = stick.digitalThreshold;
					var digitalButton = -1;
					
					//pressed/released for digital LEFT/UP
					if (newVal < neg && oldVal >= neg)
					{
						     if (i == stick.x) digitalButton = stick.rawLeft;
						else if (i == stick.y) digitalButton = stick.rawUp;
						handleButtonDown(new JoystickEvent(JoystickEvent.BUTTON_DOWN, FlashEvent.bubbles, FlashEvent.cancelable, FlashEvent.device, digitalButton));
					}
					else if (newVal >= neg && oldVal < neg)
					{
						     if (i == stick.x) digitalButton = stick.rawLeft;
						else if (i == stick.y) digitalButton = stick.rawUp;
						handleButtonUp(new JoystickEvent(JoystickEvent.BUTTON_UP, FlashEvent.bubbles, FlashEvent.cancelable, FlashEvent.device, digitalButton));
					}
					
					//pressed/released for digital RIGHT/DOWN
					if (newVal > pos && oldVal <= pos)
					{
						     if (i == stick.x) digitalButton = stick.rawRight;
						else if (i == stick.y) digitalButton = stick.rawDown;
						handleButtonDown(new JoystickEvent(JoystickEvent.BUTTON_DOWN, FlashEvent.bubbles, FlashEvent.cancelable, FlashEvent.device, digitalButton));
					}
					else if (newVal <= pos && oldVal > pos)
					{
						     if (i == stick.x) digitalButton = stick.rawRight;
						else if (i == stick.y) digitalButton = stick.rawDown;
						handleButtonUp(new JoystickEvent(JoystickEvent.BUTTON_UP, FlashEvent.bubbles, FlashEvent.cancelable, FlashEvent.device, digitalButton));
					}
					
					if (stick.mode == ONLY_DIGITAL)
					{
						//still haven't figured out how to suppress the analog inputs properly. Oh well.
					}
				}
			}
		}
		
		gamepad.axis = newAxis;
		
		gamepad.axisActive = true;
	}
	
	private function handleBallMove(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = createByID(FlashEvent.device);
		gamepad.ball.x = (Math.abs(FlashEvent.x) < gamepad.deadZone) ? 0 : FlashEvent.x;
		gamepad.ball.y = (Math.abs(FlashEvent.y) < gamepad.deadZone) ? 0 : FlashEvent.y;
	}
	
	private function handleHatMove(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = createByID(FlashEvent.device);
		
		var oldx = gamepad.hat.x;
		var oldy = gamepad.hat.y;
		
		var newx = (Math.abs(FlashEvent.x) < gamepad.deadZone) ? 0 : FlashEvent.x;
		var newy = (Math.abs(FlashEvent.y) < gamepad.deadZone) ? 0 : FlashEvent.y;
		
		gamepad.hat.x = newx;
		gamepad.hat.y = newy;
		
		#if FLX_JOYSTICK_API
		var newType:String = "";
		var newId:Int = 0;
		
		var change = false;
		
		//We see if there's been a change so we can properly set "justPressed"/"justReleased", etc.
		if (oldx != newx)
		{
			change = true;
			
			if (oldx == -1)
			{
				newType = JOYSTICK_BUTTON_UP;
				newId = gamepad.getRawID(FlxGamepadInputID.DPAD_LEFT);
			}
			else if (oldx == 1)
			{
				newType = JOYSTICK_BUTTON_UP;
				newId = gamepad.getRawID(FlxGamepadInputID.DPAD_RIGHT);
			}
			
			if (newx == -1)
			{
				newType = JOYSTICK_BUTTON_DOWN;
				newId = gamepad.getRawID(FlxGamepadInputID.DPAD_LEFT);
			}
			else if (newx == 1)
			{
				newType = JOYSTICK_BUTTON_DOWN;
				newId = gamepad.getRawID(FlxGamepadInputID.DPAD_RIGHT);
			}
		}
		
		if (oldy != newy)
		{
			change = true;
			
			if (oldy == -1)
			{
				newType = JOYSTICK_BUTTON_UP;
				newId = gamepad.getRawID(FlxGamepadInputID.DPAD_UP);
			}
			else if (oldy == 1)
			{
				newType = JOYSTICK_BUTTON_UP;
				newId = gamepad.getRawID(FlxGamepadInputID.DPAD_DOWN);
			}
			
			if (newy == -1)
			{
				newType = JOYSTICK_BUTTON_DOWN;
				newId = gamepad.getRawID(FlxGamepadInputID.DPAD_UP);
			}
			else if (newy == 1)
			{
				newType = JOYSTICK_BUTTON_DOWN;
				newId = gamepad.getRawID(FlxGamepadInputID.DPAD_DOWN);
			}
		}
		
		//Send a fake joystick button event that corresponds to the DPAD codes
		if (change && newType != "")
		{
			var newEvent = new JoystickEvent(newType, FlashEvent.bubbles, FlashEvent.cancelable,
				FlashEvent.device, newId, FlashEvent.x, FlashEvent.y, FlashEvent.z);
			
			if (newType == JOYSTICK_BUTTON_UP)
			{
				handleButtonUp(newEvent);
			}
			else if (newType == JOYSTICK_BUTTON_DOWN)
			{
				handleButtonDown(newEvent);
			}
		}
		#end
	}

	private function handleDeviceAdded(event:JoystickEvent):Void
	{
		createByID(event.device, getModelFromJoystick(event.x));
	}
	
	private function handleDeviceRemoved(event:JoystickEvent):Void
	{
		removeByID(event.device);
	}
	#end
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	private function update():Void
	{
		for (gamepad in _gamepads)
		{
			if (gamepad != null)
			{
				gamepad.update();
			}
		}
	}
	
	private inline function onFocus():Void {}

	private inline function onFocusLost():Void
	{
		reset();
	}

	private function get_numActiveGamepads():Int
	{
		var count = 0;
		for (gamepad in _gamepads)
		{
			if (gamepad != null)
			{
				count++;
			}
		}
		return count;
	}
}