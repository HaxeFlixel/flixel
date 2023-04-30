package flixel.input.actions;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.IFlxInput;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.actions.FlxActionInput.FlxInputType;
import flixel.input.actions.FlxActionInputAnalog.FlxAnalogAxis;
import flixel.input.actions.FlxActionInputAnalog.FlxAnalogState;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogClickAndDragMouseMotion;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogGamepad;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogMouseMotion;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogMousePosition;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalIFlxInput;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalGamepad;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalKeyboard;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalMouse;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalMouseWheel;
#if android
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalAndroid;
#end
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.input.android.FlxAndroidKey;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
#if FLX_STEAMWRAP
import steamwrap.api.Controller.EControllerActionOrigin;
#end

using flixel.util.FlxArrayUtil;

/**
 * A digital action is a binary on/off event like "jump" or "fire".
 * FlxActions let you attach multiple inputs to a single in-game action,
 * so "jump" could be performed by a keyboard press, a mouse click,
 * or a gamepad button press.
 *
 * @since 4.6.0
 */
class FlxActionDigital extends FlxAction
{
	/**
	 * Function to call when this action occurs
	 */
	public var callback:FlxActionDigital->Void;

	/**
	 * Create a new digital action
	 * @param	Name	name of the action
	 * @param	Callback	function to call when this action occurs
	 */
	public function new(?Name:String = "", ?Callback:FlxActionDigital->Void)
	{
		super(FlxInputType.DIGITAL, Name);
		callback = Callback;
	}

	/**
	 * Add a digital input (any kind) that will trigger this action
	 * @param	input
	 * @return	This action
	 */
	public function add(input:FlxActionInputDigital):FlxActionDigital
	{
		addGenericInput(input);
		return this;
	}

	/**
	 * Add a generic IFlxInput action input
	 *
	 * WARNING: IFlxInput objects are often member variables of some other
	 * object that is often destructed at the end of a state. If you don't
	 * destroy() this input (or the action you assign it to), the IFlxInput
	 * reference will persist forever even after its parent object has been
	 * destroyed!
	 *
	 * @param	Input	A generic IFlxInput object (ex: FlxButton.input)
	 * @param	Trigger	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @return	This action
	 */
	public function addInput(Input:IFlxInput, Trigger:FlxInputState):FlxActionDigital
	{
		return add(new FlxActionInputDigitalIFlxInput(Input, Trigger));
	}

	/**
	 * Add a gamepad action input for digital (button-like) events
	 * @param	InputID "universal" gamepad input ID (A, X, DPAD_LEFT, etc)
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @param	GamepadID specific gamepad ID, or FlxInputDeviceID.ALL / FIRST_ACTIVE
	 * @return	This action
	 */
	public function addGamepad(InputID:FlxGamepadInputID, Trigger:FlxInputState, GamepadID:Int = FlxInputDeviceID.FIRST_ACTIVE):FlxActionDigital
	{
		return add(new FlxActionInputDigitalGamepad(InputID, Trigger, GamepadID));
	}

	/**
	 * Add a keyboard action input
	 * @param	Key Key identifier (FlxKey.SPACE, FlxKey.Z, etc)
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @return	This action
	 */
	public function addKey(Key:FlxKey, Trigger:FlxInputState):FlxActionDigital
	{
		return add(new FlxActionInputDigitalKeyboard(Key, Trigger));
	}

	/**
	 * Mouse button action input
	 * @param	ButtonID Button identifier (FlxMouseButtonID.LEFT / MIDDLE / RIGHT)
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @return	This action
	 */
	public function addMouse(ButtonID:FlxMouseButtonID, Trigger:FlxInputState):FlxActionDigital
	{
		return add(new FlxActionInputDigitalMouse(ButtonID, Trigger));
	}

	/**
	 * Action for mouse wheel events
	 * @param	Positive	True: respond to mouse wheel values > 0; False: respond to mouse wheel values < 0
	 * @param	Trigger		What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @return	This action
	 */
	public function addMouseWheel(Positive:Bool, Trigger:FlxInputState):FlxActionDigital
	{
		return add(new FlxActionInputDigitalMouseWheel(Positive, Trigger));
	}

	#if android
	/**
	 * Android buttons action inputs
	 * @param	Key	Android button key, BACK, or MENU probably (might need to set FlxG.android.preventDefaultKeys to disable the default behaviour and allow proper use!)
	 * @param	Trigger		What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @return	This action
	 * 
	 * @since 4.10.0
	 */
	public function addAndroidKey(Key:FlxAndroidKey, Trigger:FlxInputState):FlxActionDigital
	{
		return add(new FlxActionInputDigitalAndroid(Key, Trigger));
	}
	#end

	override public function destroy():Void
	{
		callback = null;
		super.destroy();
	}

	override public function check():Bool
	{
		var val = super.check();
		if (val && callback != null)
		{
			callback(this);
		}
		return val;
	}
}

/**
 * Analog actions are events with continuous (floating-point) values, and up
 * to two axes (x,y). This is for events like "move" and "accelerate" where the
 * event is not simply on or off.
 *
 * FlxActions let you attach multiple inputs to a single in-game action,
 * so "move" could be performed by a gamepad joystick, a mouse movement, etc.
 *
 * @since 4.6.0
 */
class FlxActionAnalog extends FlxAction
{
	/**
	 * Function to call when this action occurs
	 */
	public var callback:FlxActionAnalog->Void;

	/**
	 * X axis value, or the value of a single-axis analog input.
	 */
	public var x(get, never):Float;

	/**
	 * Y axis value. (If action only has single-axis input this is always == 0)
	 */
	public var y(get, never):Float;

	/**
	 * Create a new analog action
	 * @param	Name	name of the action
	 * @param	Callback	function to call when this action occurs
	 */
	public function new(?Name:String = "", ?Callback:FlxActionAnalog->Void)
	{
		super(FlxInputType.ANALOG, Name);
		callback = Callback;
	}

	/**
	 * Add an analog input that will trigger this action
	 */
	public function add(input:FlxActionInputAnalog):FlxActionAnalog
	{
		addGenericInput(input);
		return this;
	}

	/**
	 * Add mouse input -- same as mouse motion, but requires a particular mouse button to be PRESSED
	 * Very useful for e.g. panning a map or canvas around
	 * @param	ButtonID	Button identifier (FlxMouseButtonID.LEFT / MIDDLE / RIGHT)
	 * @param	Trigger	What state triggers this action (MOVED, JUST_MOVED, STOPPED, JUST_STOPPED)
	 * @param	Axis	which axes to monitor for triggering: X, Y, EITHER, or BOTH
	 * @param	PixelsPerUnit	How many pixels of movement = 1.0 in analog motion (lower: more sensitive, higher: less sensitive)
	 * @param	DeadZone	Minimum analog value before motion will be reported
	 * @param	InvertY	Invert the Y axis
	 * @param	InvertX	Invert the X axis
	 * @return	This action
	 */
	public function addMouseClickAndDragMotion(ButtonID:FlxMouseButtonID, Trigger:FlxAnalogState, Axis:FlxAnalogAxis = FlxAnalogAxis.EITHER,
			PixelsPerUnit:Int = 10, DeadZone:Float = 0.1, InvertY:Bool = false, InvertX:Bool = false):FlxActionAnalog
	{
		return add(new FlxActionInputAnalogClickAndDragMouseMotion(ButtonID, Trigger, Axis, PixelsPerUnit, DeadZone, InvertY, InvertX));
	}

	/**
	 * Add mouse input -- X/Y is the RELATIVE motion of the mouse since the last frame
	 * @param	Trigger	What state triggers this action (MOVED, JUST_MOVED, STOPPED, JUST_STOPPED)
	 * @param	Axis	which axes to monitor for triggering: X, Y, EITHER, or BOTH
	 * @param	PixelsPerUnit	How many pixels of movement = 1.0 in analog motion (lower: more sensitive, higher: less sensitive)
	 * @param	DeadZone	Minimum analog value before motion will be reported
	 * @param	InvertY	Invert the Y axis
	 * @param	InvertX	Invert the X axis
	 * @return	This action
	 */
	public function addMouseMotion(Trigger:FlxAnalogState, Axis:FlxAnalogAxis = EITHER, PixelsPerUnit:Int = 10, DeadZone:Float = 0.1, InvertY:Bool = false,
			InvertX:Bool = false):FlxActionAnalog
	{
		return add(new FlxActionInputAnalogMouseMotion(Trigger, Axis, PixelsPerUnit, DeadZone, InvertY, InvertX));
	}

	/**
	 * Add mouse input -- X/Y is the mouse's absolute screen position
	 * @param	Trigger What state triggers this action (MOVED, JUST_MOVED, STOPPED, JUST_STOPPED)
	 * @param	Axis which axes to monitor for triggering: X, Y, EITHER, or BOTH
	 * @return	This action
	 */
	public function addMousePosition(Trigger:FlxAnalogState, Axis:FlxAnalogAxis = EITHER):FlxActionAnalog
	{
		return add(new FlxActionInputAnalogMousePosition(Trigger, Axis));
	}

	/**
	 * Add gamepad action input for analog (trigger, joystick, touchpad, etc) events
	 * @param	InputID "universal" gamepad input ID (LEFT_TRIGGER, RIGHT_ANALOG_STICK, TILT_PITCH, etc)
	 * @param	Trigger What state triggers this action (MOVED, JUST_MOVED, STOPPED, JUST_STOPPED)
	 * @param	Axis which axes to monitor for triggering: X, Y, EITHER, or BOTH
	 * @param	GamepadID specific gamepad ID, or FlxInputDeviceID.FIRST_ACTIVE / ALL
	 * @return	This action
	 */
	public function addGamepad(InputID:FlxGamepadInputID, Trigger:FlxAnalogState, Axis:FlxAnalogAxis = EITHER,
			GamepadID:Int = FlxInputDeviceID.FIRST_ACTIVE):FlxActionAnalog
	{
		return add(new FlxActionInputAnalogGamepad(InputID, Trigger, Axis, GamepadID));
	}

	override public function update():Void
	{
		_x = null;
		_y = null;
		super.update();
	}

	override public function destroy():Void
	{
		callback = null;
		super.destroy();
	}

	override public function toString():String
	{
		return "FlxAction(" + type + ") name:" + name + " x/y:" + _x + "," + _y;
	}

	override public function check():Bool
	{
		var val = super.check();
		if (val && callback != null)
		{
			callback(this);
		}
		return val;
	}

	function get_x():Float
	{
		return (_x != null) ? _x : 0;
	}

	function get_y():Float
	{
		return (_y != null) ? _y : 0;
	}
}

/**
 * @since 4.6.0
 */
@:allow(flixel.input.actions.FlxActionDigital, flixel.input.actions.FlxActionAnalog, flixel.input.actions.FlxActionSet)
class FlxAction implements IFlxDestroyable
{
	/**
	 * Digital or Analog
	 */
	public var type(default, null):FlxInputType;

	/**
	 * The name of the action, "jump", "fire", "move", etc.
	 */
	public var name(default, null):String;

	/**
	 * This action's numeric handle for the Steam API (ignored if not using Steam)
	 */
	var steamHandle(default, null):Int = -1;

	/**
	 * If true, this action has just been triggered
	 */
	public var triggered(default, null):Bool = false;

	/**
	 * The inputs attached to this action
	 */
	public var inputs:Array<FlxActionInput>;

	var _x:Null<Float> = null;
	var _y:Null<Float> = null;

	var _timestamp:Int = 0;
	var _checked:Bool = false;

	/**
	 * Whether the steam controller inputs for this action have changed since the last time origins were polled. Always false if steam isn't active
	 */
	public var steamOriginsChanged(default, null):Bool = false;

	#if FLX_STEAMWRAP
	var _steamOriginsChecksum:Int = 0;
	var _steamOrigins:Array<EControllerActionOrigin>;
	#end

	function new(InputType:FlxInputType, Name:String)
	{
		type = InputType;
		name = Name;
		inputs = [];
		#if FLX_STEAMWRAP
		_steamOrigins = [];
		for (i in 0...FlxSteamController.MAX_ORIGINS)
		{
			_steamOrigins.push(cast 0);
		}
		#end
	}

	public function getFirstSteamOrigin():Int
	{
		#if FLX_STEAMWRAP
		if (_steamOrigins == null)
			return 0;
		for (i in 0..._steamOrigins.length)
		{
			if (_steamOrigins[i] != EControllerActionOrigin.NONE)
			{
				return cast _steamOrigins[i];
			}
		}
		#end
		return 0;
	}

	public function getSteamOrigins(?origins:Array<Int>):Array<Int>
	{
		#if FLX_STEAMWRAP
		if (origins == null)
		{
			origins = [];
		}
		if (_steamOrigins != null)
		{
			for (i in 0..._steamOrigins.length)
			{
				origins[i] = cast _steamOrigins[i];
			}
		}
		#end
		return origins;
	}

	public function removeAll(Destroy:Bool = true):Void
	{
		var len = inputs.length;
		for (i in 0...len)
		{
			var j = len - i - 1;
			var input = inputs[j];
			remove(input, Destroy);
			inputs.splice(j, 1);
		}
	}

	public function remove(Input:FlxActionInput, Destroy:Bool = false):Void
	{
		if (Input == null)
			return;
		inputs.remove(Input);
		if (Destroy)
		{
			Input.destroy();
		}
	}

	public function toString():String
	{
		return "FlxAction(" + type + ") name:" + name;
	}

	/**
	 * See if this action has just been triggered
	 */
	public function check():Bool
	{
		_x = null;
		_y = null;

		if (_timestamp == FlxG.game.ticks)
		{
			triggered = _checked;
			return _checked; // run no more than once per frame
		}

		_timestamp = FlxG.game.ticks;
		_checked = false;

		var len = inputs != null ? inputs.length : 0;
		for (i in 0...len)
		{
			var j = len - i - 1;
			var input = inputs[j];

			if (input.destroyed)
			{
				inputs.splice(j, 1);
				continue;
			}

			input.update();

			if (input.check(this))
			{
				_checked = true;
			}
		}

		triggered = _checked;
		return _checked;
	}

	/**
	 * Check input states & fire callbacks if anything is triggered
	 */
	public function update():Void
	{
		check();
	}

	public function destroy():Void
	{
		FlxDestroyUtil.destroyArray(inputs);
		inputs = null;
		#if FLX_STEAMWRAP
		FlxArrayUtil.clearArray(_steamOrigins);
		_steamOrigins = null;
		#end
	}

	public function match(other:FlxAction):Bool
	{
		return name == other.name && steamHandle == other.steamHandle;
	}

	function addGenericInput(input:FlxActionInput):FlxAction
	{
		if (inputs == null)
		{
			inputs = [];
		}
		if (!checkExists(input))
			inputs.push(input);

		return this;
	}

	function checkExists(input:FlxActionInput):Bool
	{
		if (inputs == null)
			return false;
		return inputs.contains(input);
	}
}
