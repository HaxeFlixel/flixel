package flixel.input.actions;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputType;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogSteam;
import flixel.input.actions.FlxActionInputAnalog.FlxAnalogState;
import flixel.input.actions.FlxActionInputAnalog.FlxAnalogAxis;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalSteam;
import flixel.input.actions.FlxActionManager.ActionSetJson;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.Json;
#if FLX_STEAMWRAP
import steamwrap.data.ControllerConfig.ControllerActionSet;
#end

using flixel.util.FlxArrayUtil;

/**
 * @since 4.6.0
 */
@:allow(flixel.input.actions.FlxActionManager)
class FlxActionSet implements IFlxDestroyable
{
	/**
	 * Name of the action set
	 */
	public var name(default, null):String = "";

	#if FLX_STEAMWRAP
	/**
	 * This action set's numeric handle for the Steam API (ignored if not using Steam)
	 */
	public var steamHandle(default, null):Int = -1;
	#end

	/**
	 * Digital actions in this set
	 */
	public var digitalActions(default, null):Array<FlxActionDigital>;

	/**
	 * Analog actions in this set
	 */
	public var analogActions(default, null):Array<FlxActionAnalog>;

	/**
	 * Whether this action set runs when update() is called
	 */
	public var active:Bool = true;

	#if FLX_STEAMWRAP
	/**
	 * Create an action set from a steamwrap configuration file.
	 *
	 * NOTE: no steam inputs will be attached to the created actions; you must call
	 * attachSteamController() which will automatically add or remove steam
	 * inputs for a particular controller.
	 *
	 * This is unique to steam inputs, which cannot be constructed directly.
	 * Non-steam inputs can be constructed and added to the actions normally.
	 *
	 * @param	SteamSet	A steamwrap ControllerActionSet file (found in ControllerConfig)
	 * @param	CallbackDigital	A function to call when digital actions fire
	 * @param	CallbackAnalog	A function to call when analog actions fire
	 * @return	An action set
	 */
	@:access(flixel.input.actions.FlxActionManager)
	private static function fromSteam(SteamSet:ControllerActionSet, CallbackDigital:FlxActionDigital->Void, CallbackAnalog:FlxActionAnalog->Void):FlxActionSet
	{
		if (SteamSet == null)
			return null;

		var digitalActions:Array<FlxActionDigital> = [];
		var analogActions:Array<FlxActionAnalog> = [];

		if (SteamSet.button != null)
		{
			for (b in SteamSet.button)
			{
				if (b == null)
					continue;
				var action = new FlxActionDigital(b.name, CallbackDigital);
				var aHandle = FlxSteamController.getDigitalActionHandle(b.name);
				action.steamHandle = aHandle;
				digitalActions.push(action);
			}
		}
		if (SteamSet.analogTrigger != null)
		{
			for (a in SteamSet.analogTrigger)
			{
				if (a == null)
					continue;
				var action = new FlxActionAnalog(a.name, CallbackAnalog);
				var aHandle = FlxSteamController.getAnalogActionHandle(a.name);
				action.steamHandle = aHandle;
				analogActions.push(action);
			}
		}
		for (s in SteamSet.stickPadGyro)
		{
			if (s == null)
				continue;
			var action = new FlxActionAnalog(s.name, CallbackAnalog);
			var aHandle = FlxSteamController.getAnalogActionHandle(s.name);
			action.steamHandle = aHandle;
			analogActions.push(action);
		}

		var set = new FlxActionSet(SteamSet.name, digitalActions, analogActions);
		set.steamHandle = FlxSteamController.getActionSetHandle(SteamSet.name);

		return set;
	}
	#end

	/**
	 * Create an action set from a parsed Json object
	 *
	 * @param	Data	A parsed Json object
	 * @param	CallbackDigital	A function to call when digital actions fire
	 * @param	CallbackAnalog	A function to call when analog actions fire
	 * @return	An action set
	 */
	@:access(flixel.input.actions.FlxActionManager)
	static function fromJson(Data:ActionSetJson, CallbackDigital:FlxActionDigital->Void, CallbackAnalog:FlxActionAnalog->Void):FlxActionSet
	{
		var digitalActions:Array<FlxActionDigital> = [];
		var analogActions:Array<FlxActionAnalog> = [];

		if (Data == null)
			return null;

		if (Data.digitalActions != null)
		{
			var arrD:Array<Dynamic> = Data.digitalActions;
			for (d in arrD)
			{
				var dName:String = cast d;
				var action = new FlxActionDigital(dName, CallbackDigital);
				digitalActions.push(action);
			}
		}

		if (Data.analogActions != null)
		{
			var arrA:Array<Dynamic> = Data.analogActions;
			for (a in arrA)
			{
				var aName:String = cast a;
				var action = new FlxActionAnalog(aName, CallbackAnalog);
				analogActions.push(action);
			}
		}

		if (Data.name != null)
		{
			var name:String = Data.name;
			var set = new FlxActionSet(name, digitalActions, analogActions);
			return set;
		}

		return null;
	}

	public function toJson():String
	{
		var space:String = "\t";
		return Json.stringify(this, function(key:Dynamic, value:Dynamic):Dynamic
		{
			if ((value is FlxAction))
			{
				var fa:FlxAction = cast value;
				return {
					"type": fa.type,
					"name": fa.name,
					"steamHandle": fa.steamHandle
				}
			}
			return value;
		}, space);
	}

	public function new(Name:String, ?DigitalActions:Array<FlxActionDigital>, ?AnalogActions:Array<FlxActionAnalog>)
	{
		name = Name;
		if (DigitalActions == null)
			DigitalActions = [];
		if (AnalogActions == null)
			AnalogActions = [];
		digitalActions = DigitalActions;
		analogActions = AnalogActions;
	}

	/**
	 * Automatically adds or removes inputs for a steam controller
	 * to any steam-affiliated actions
	 * @param	Handle	steam controller handle from FlxSteam.getConnectedControllers(), or FlxInputDeviceID.FIRST_ACTIVE / ALL
	 * @param	Attach	true: adds inputs, false: removes inputs
	 */
	public function attachSteamController(Handle:Int, Attach:Bool = true):Void
	{
		attachSteamControllerSub(Handle, Attach, FlxInputType.DIGITAL, digitalActions, null);
		attachSteamControllerSub(Handle, Attach, FlxInputType.ANALOG, null, analogActions);
	}

	public function add(Action:FlxAction):Bool
	{
		if (Action.type == DIGITAL)
		{
			var dAction:FlxActionDigital = cast Action;
			if (digitalActions.contains(dAction))
				return false;
			digitalActions.push(dAction);
			return true;
		}
		else if (Action.type == ANALOG)
		{
			var aAction:FlxActionAnalog = cast Action;
			if (analogActions.contains(aAction))
				return false;
			analogActions.push(aAction);
			return true;
		}
		return false;
	}

	public function destroy():Void
	{
		digitalActions = FlxDestroyUtil.destroyArray(digitalActions);
		analogActions = FlxDestroyUtil.destroyArray(analogActions);
	}

	/**
	 * Remove an action from this set
	 * @param	Action a FlxAction
	 * @param	Destroy whether to destroy it as well
	 * @return	whether it was found and removed
	 */
	public function remove(Action:FlxAction, Destroy:Bool = true):Bool
	{
		var result = false;
		if (Action.type == DIGITAL)
		{
			result = digitalActions.remove(cast Action);
			if (result && Destroy)
			{
				Action.destroy();
			}
		}
		else if (Action.type == ANALOG)
		{
			result = analogActions.remove(cast Action);
			if (result && Destroy)
			{
				Action.destroy();
			}
		}
		return result;
	}

	/**
	 * Update all the actions in this set (each will check inputs & potentially trigger)
	 */
	public function update():Void
	{
		if (!active)
			return;
		for (digitalAction in digitalActions)
		{
			digitalAction.update();
		}
		for (analogAction in analogActions)
		{
			analogAction.update();
		}
	}

	function attachSteamControllerSub(Handle:Int, Attach:Bool, InputType:FlxInputType, DigitalActions:Array<FlxActionDigital>,
			AnalogActions:Array<FlxActionAnalog>)
	{
		var length = InputType == FlxInputType.DIGITAL ? DigitalActions.length : AnalogActions.length;

		for (i in 0...length)
		{
			var action = InputType == FlxInputType.DIGITAL ? DigitalActions[i] : AnalogActions[i];

			if (action.steamHandle != -1) // all steam-affiliated actions will have this numeric ID assigned
			{
				var inputExists = false;
				var theInput:FlxActionInput = null;

				// check if any of the steam controller inputs match this handle
				if (action.inputs != null)
				{
					for (input in action.inputs)
					{
						if (input.device == FlxInputDevice.STEAM_CONTROLLER && input.deviceID == Handle)
						{
							inputExists = true;
							theInput = input;
						}
					}
				}

				if (Attach)
				{
					// attaching: add inputs for this controller if they don't exist

					if (!inputExists)
					{
						if (InputType == FlxInputType.DIGITAL)
						{
							DigitalActions[i].add(new FlxActionInputDigitalSteam(action.steamHandle, FlxInputState.JUST_PRESSED, Handle));
						}
						else if (InputType == FlxInputType.ANALOG)
						{
							AnalogActions[i].add(new FlxActionInputAnalogSteam(action.steamHandle, FlxAnalogState.MOVED, FlxAnalogAxis.EITHER, Handle));
						}
					}
				}
				else if (inputExists)
				{
					// detaching: remove inputs for this controller if they exist
					action.remove(theInput);
				}
			}
		}
	}
}
