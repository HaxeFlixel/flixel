package flixel.input.actions;

import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.actions.FlxActionInput.FlxInputType;
import flixel.input.actions.FlxActionManager.ActionSetRegister;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.Json;

#if FLX_STEAMWRAP
import flixel.input.actions.FlxActionInput.FlxInputType;
import steamwrap.api.Steam;
import steamwrap.data.ControllerConfig;
#end

using flixel.util.FlxArrayUtil;

/**
 * High level input manager for `FlxAction`s. This lets you manage multiple input
 * devices and action sets, and is the only supported method for natively using 
 * the Steam Controller API.
 * 
 * Once you've set up `FlxActionManager`, you can let flixel handle it globally
 * with: `FlxG.inputs.add(myFlxActionManager)`;
 * 
 * If you don't add it globally, you will have to call `update()` on it yourself.
 * 
 * If you are using the steamwrap library, `FlxActionManager` can automatically 
 * create action sets from a steamwrap object derived from the master vdf game 
 * actions file that Steam makes you set up for native controller support. 
 * You must then ACTIVATE one of those action sets for any connected steam 
 * controllers, which will automatically attach the proper steam action inputs 
 * to the actions in the set. You can also add as many regular `FlxActionInput`s 
 * as you like to any actions in the sets.
 * 
 */
class FlxActionManager implements IFlxInputManager implements IFlxDestroyable
{
	private var sets:Array<FlxActionSet>;
	private var register:ActionSetRegister;
	
	/**
	 * The number of registered action sets
	 */
	public var numSets(get, null):Int;
	
	/**
	 * A signal fired when a device currently in use is suddenly disconnected. Returns the device type, handle/id, and a string identifier for the device model (if applicable)
	 */
	public var deviceDisconnected(default, null):FlxTypedSignal<FlxInputDevice->Int->String->Void>;
	
	/**
	 * A signal fired when a device is connected. Returns the device type, handle/id, and a string identifier for the device model (if applicable)
	 */
	public var deviceConnected(default, null):FlxTypedSignal<FlxInputDevice->Int->String->Void>;
	
	/**
	 * A signal fired when an action's inputs have been externally changed. Returns a list of all actions whose inputs have changed. For now only used for Steam Controllers.
	 */
	public var inputsChanged(default, null):FlxTypedSignal<Array<FlxAction>->Void>;
	
	public function new() 
	{
		sets = [];
		register = new ActionSetRegister();
		deviceConnected = new FlxTypedSignal<FlxInputDevice->Int->String->Void>();
		deviceDisconnected = new FlxTypedSignal<FlxInputDevice->Int->String->Void>();
		inputsChanged = new FlxTypedSignal<Array<FlxAction>->Void>();
		#if FLX_GAMEPAD
		FlxG.gamepads.deviceConnected.add(onDeviceConnected);
		FlxG.gamepads.deviceDisconnected.add(onDeviceDisconnected);
		#end
		FlxSteamController.onControllerConnect = updateSteamControllers;
		FlxSteamController.onOriginUpdate = updateSteamOrigins;
	}
	
	/**
	 * Activate an action set for a particular device
	 * @param	ActionSet	The integer ID for the Action Set you want to activate
	 * @param	Device		The device type (Mouse, Keyboard, Gamepad, SteamController, etc)
	 * @param	DeviceID	FlxGamepad ID or a Steam Controller Handle (ignored for Mouse/Keyboard)
	 */
	public function activateSet(ActionSet:Int, Device:FlxInputDevice, ?DeviceID:Int = FlxInputDeviceID.ALL)
	{
		register.activate(ActionSet, Device, DeviceID);
		onChange();
	}
	
	/**
	 * Add an action to a particular action set
	 * @param	Action		The FlxActionDigital you want to add
	 * @param	ActionSet	The index of the FlxActionSet you want to add
	 * @return	whether it was successfully added
	 */
	public function addDigitalAction(Action:FlxActionDigital, ActionSet:Int):Bool
	{
		return addAction(Action, ActionSet, FlxInputType.DIGITAL);
	}
	
	/**
	 * Add an action to a particular action set
	 * @param	Action		The FlxActionAnalog you want to add
	 * @param	ActionSet	The index of the FlxActionSet you want to add
	 * @return	whether it was successfully added
	 */
	public function addAnalogAction(Action:FlxActionAnalog, ActionSet:Int):Bool
	{
		return addAction(Action, ActionSet, FlxInputType.ANALOG);
	}
	
	/**
	 * Add a FlxActionSet to the manager
	 * @param	set	The FlxActionSet you want to add
	 * @return	the index of the FlxActionSet
	 */
	public function addSet(set:FlxActionSet):Int
	{
		if (sets.contains(set))
		{
			return -1;
		}
		
		sets.push(set);
		
		onChange();
		
		return sets.length - 1;
	}
	
	/**
	 * Deactivate an action set for any devices it is currently active for
	 * @param	ActionSet	The integer ID for the Action Set you want to deactivate
	 * @param	DeviceID	FlxGamepad ID or a Steam Controller Handle (ignored for Mouse/Keyboard)
	 */
	public function deactivateSet(ActionSet:Int, ?DeviceID:Int = FlxInputDeviceID.ALL)
	{
		register.activate(ActionSet, FlxInputDevice.NONE, DeviceID);
		onChange();
	}
	
	public function destroy():Void
	{
		sets = FlxDestroyUtil.destroyArray(sets);
		register = FlxDestroyUtil.destroy(register);
	}
	
	/**
	 * Get the index of a particular action set
	 * @param	name	Action set name
	 * @return	Index number of that set, -1 if not found
	 */
	public function getSetIndex(Name:String):Int
	{
		for (i in 0...sets.length)
		{
			if (sets[i].name == Name) return i;
		}
		return -1;
	}
	
	/**
	 * Get the name of an action set
	 * @param	Index	Action set index
	 * @return	Name of that set, "" if not found
	 */
	public function getSetName(Index:Int):String
	{
		if (Index >= 0 && Index < sets.length)
			return sets[Index].name;
		return "";
	}
	
	/**
	 * Get an action set
	 * @param	Index	Action set index
	 * @return	The FlxActionSet at that location, or null if not found
	 */
	public function getSet(Index:Int):FlxActionSet
	{
		if (Index >= 0 && Index < sets.length)
			return sets[Index];
		return null;
	}
	
	/**
	 * Returns the action set that has been activated for this specific device
	 * @param	device
	 * @param	deviceID
	 * @return
	 */
	@:access(flixel.input.actions.FlxActionManager.ActionSetRegister)
	public function getSetActivatedForDevice(device:FlxInputDevice, deviceID:Int = FlxInputDeviceID.ALL):FlxActionSet
	{
		var id = -1;
		var index = -1;
		
		switch (device)
		{
			case FlxInputDevice.KEYBOARD: index = register.keyboardSet;
			case FlxInputDevice.MOUSE: index = register.mouseSet;
			case FlxInputDevice.GAMEPAD:
				switch (deviceID)
				{
					case FlxInputDeviceID.ALL: index = register.gamepadAllSet;
					case FlxInputDeviceID.FIRST_ACTIVE: 
						#if FLX_GAMEPAD
						id = FlxG.gamepads.getFirstActiveGamepadID();
						#end
					case FlxInputDeviceID.NONE: index = -1;
					default: 
						if (register.gamepadAllSet != -1)
							index = register.gamepadAllSet;
						else
							id = deviceID;
				}
				if (id >= 0 && id < register.gamepadSets.length)
				{
					index = register.gamepadSets[id];
				}
			case FlxInputDevice.STEAM_CONTROLLER:
				switch (deviceID)
				{
					case FlxInputDeviceID.ALL: index = register.steamControllerAllSet;
					case FlxInputDeviceID.NONE: index = -1;
					default: 
						if (register.steamControllerAllSet != -1)
							index = register.steamControllerAllSet;
						else
							id = deviceID;
				}
				if (id >= 0 && id < register.steamControllerSets.length)
				{
					index = register.steamControllerSets[id];
				}
			case FlxInputDevice.ALL:
				switch (deviceID)
				{
					case FlxInputDeviceID.ALL: index = register.gamepadAllSet;
				}
			default: index = -1;
		}
		
		if (index >= 0 && index < sets.length)
		{
			return sets[index];
		}
		
		return null;
	}
	
	#if FLX_STEAMWRAP
	/**
	 * Load action sets from a steamwrap ControllerConfig object
	 * @param	Config	ControllerConfig object derived from your game's "game_actions_XYZ.vdf" file
	 * @param	CallbackDigital	Callback function for digital actions
	 * @param	CallbackAnalog	Callback function for analog actions
	 * @return	The number of new FlxActionSets created and added. 0 means nothing happened.
	 */
	public function initSteam(Config:ControllerConfig, CallbackDigital:FlxActionDigital->Void, CallbackAnalog:FlxActionAnalog->Void):Int
	{
		var i:Int = 0;
		for (set in Config.actionSets)
		{
			if (addSet(FlxActionSet.fromSteam(set, CallbackDigital, CallbackAnalog)) != -1)
			{
				i++;
			}
		}
		
		onChange();
		
		return i;
	}
	#end
	
	/**
	 * Load action sets from a parsed JSON object
	 * @param	data	JSON object parsed from the same format that "exportToJSON()" outputs
	 * @param	CallbackDigital	Callback function for digital actions
	 * @param	CallbackAnalog	Callback function for analog actions
	 * @return	The number of new FlxActionSets created and added. 0 means nothing happened.
	 */
	public function initFromJSON(data:ActionSetJSONArray, CallbackDigital:FlxActionDigital->Void, CallbackAnalog:FlxActionAnalog->Void):Int
	{
		if (data == null) return 0;
		
		var i:Int = 0;
		var actionSets:Array<ActionSetJSON> = Reflect.hasField(data, "actionSets") ? Reflect.field(data, "actionSets") : null;
		if (actionSets == null) return 0;
		
		for (set in actionSets)
		{
			if (addSet(FlxActionSet.fromJSON(set, CallbackDigital, CallbackAnalog)) != -1)
			{
				i++;
			}
		}
		
		onChange();
		
		return i;
	}
	
	@:access(flixel.input.actions.FlxAction)
	public function exportToJSON():String
	{
		var space:String = "\t";
		return Json.stringify({"actionSets":sets}, 
			function(key:Dynamic, value:Dynamic):Dynamic
			{
				if (Std.is(value, FlxAction))
				{
					var fa:FlxAction = cast value;
					return fa.name;
				}
				if (Std.is(value, FlxActionSet))
				{
					var fas:FlxActionSet = cast value;
					return {
						"name": fas.name,
						"digitalActions": fas.digitalActions,
						"analogActions": fas.analogActions
					}
				}
				
				return value;
				
			},
		space);
	}
	
	/**
	 * Remove a set from the manager
	 * @param	Set	The set you want to remove
	 * @param	Destroy	Whether to also destroy the set or just remove it from the list
	 * @return	whether the action was found & successfully removed
	 */
	public function removeSet(Set:FlxActionSet, Destroy:Bool = true):Bool
	{
		var success = sets.remove(Set);
		if (success)
		{
			if (Destroy)
				FlxDestroyUtil.destroy(Set);
				
			onChange();
		}
		
		return success;
	}
	
	/**
	 * Remove an action from a particular action set
	 * @param	Action		The FlxActionDigital you want to remove
	 * @param	ActionSet	The index of the FlxActionSet you want to remove
	 * @return	whether it was successfully removed
	 */
	public function removeDigitalAction(Action:FlxActionDigital, ActionSet:Int):Bool
	{
		return removeAction(Action, ActionSet, FlxInputType.DIGITAL);
	}
	
	/**
	 * Remove an action to a particular action set
	 * @param	Action		The FlxActionAnalog you want to remove
	 * @param	ActionSet	The index of the FlxActionSet you want to remove
	 * @return	whether it was successfully removed
	 */
	public function removeAnalogAction(Action:FlxActionAnalog, ActionSet:Int):Bool
	{
		return removeAction(Action, ActionSet, FlxInputType.ANALOG);
	}
	
	public function reset():Void {}
	
	private function addAction(Action:FlxAction, ActionSet:Int, type:FlxInputType):Bool
	{
		var success = false;
		
		if (ActionSet >= 0 && ActionSet < sets.length)
		{
			success = (type == FlxInputType.DIGITAL) ? 
						sets[ActionSet].addDigital(cast Action) :
						sets[ActionSet].addAnalog (cast Action);
		}
		
		onChange();
		
		return success;
	}
	
	private function removeAction(Action:FlxAction, ActionSet:Int, type:FlxInputType):Bool
	{
		var success = false;
		
		if (ActionSet >= 0 && ActionSet < sets.length)
		{
			success = (type == FlxInputType.DIGITAL) ? 
						sets[ActionSet].removeDigital(cast Action) :
						sets[ActionSet].removeAnalog (cast Action);
		}
		
		onChange();
		
		return success;
	}
	
	private function get_numSets():Int
	{
		return sets.length;
	}
	
	private function onChange():Void
	{
		register.markActiveSets(sets);
	}
	
	private function onFocus():Void
	{
		//
	}
	
	private function onFocusLost():Void
	{
		//
	}
	
	private function onDeviceConnected(gamepad:FlxGamepad)
	{
		deviceConnected.dispatch(FlxInputDevice.GAMEPAD, gamepad.id, Std.string(gamepad.model).toLowerCase());
	}
	
	private function onDeviceDisconnected(gamepad:FlxGamepad)
	{
		if (gamepad != null)
		{
			var actionSet = getSetActivatedForDevice(FlxInputDevice.GAMEPAD, gamepad.id);
			if (actionSet != null && actionSet.active)
			{
				var id = gamepad.id;
				var model = gamepad.model != null ? Std.string(gamepad.model).toLowerCase() : "";
				deviceDisconnected.dispatch(FlxInputDevice.GAMEPAD, id, model);
			}
		}
	}
	
	private function onSteamConnected(handle:Int)
	{
		var allSetIndex = register.steamControllerAllSet;
		
		if (allSetIndex != -1)
		{
			activateSet(allSetIndex, FlxInputDevice.STEAM_CONTROLLER, FlxInputDeviceID.ALL);
		}
		else
		{
			var actionSet = getSetActivatedForDevice(FlxInputDevice.STEAM_CONTROLLER, handle);
			if (actionSet != null && actionSet.active)
			{
				activateSet(getSetIndex(actionSet.name), FlxInputDevice.STEAM_CONTROLLER, handle);
			}
		}
		
		deviceConnected.dispatch(FlxInputDevice.STEAM_CONTROLLER, handle, "");
	}
	
	private function onSteamDisconnected(handle:Int)
	{
		if (handle >= 0)
		{
			var actionSet = getSetActivatedForDevice(FlxInputDevice.STEAM_CONTROLLER, handle);
			if (actionSet != null && actionSet.active)
			{
				deviceDisconnected.dispatch(FlxInputDevice.STEAM_CONTROLLER, handle, "");
			}
		}
	}
	
	@:access(flixel.input.actions.FlxSteamController)
	private function updateSteamControllers():Void
	{
		#if FLX_STEAMWRAP
		for (i in 0...FlxSteamController.MAX_CONTROLLERS)
		{
			if (FlxSteamController.controllers[i].connected.justReleased)
			{
				onSteamDisconnected(FlxSteamController.controllers[i].handle);
			}
			else if (FlxSteamController.controllers[i].connected.justPressed)
			{
				onSteamConnected(FlxSteamController.controllers[i].handle);
			}
		}
		#end
	}
	
	private function updateSteamOrigins():Void
	{
		#if FLX_STEAMWRAP
		var changed = register.updateSteamOrigins(sets);
		if (changed != null)
		{
			inputsChanged.dispatch(changed);
		}
		#end
	}
	
	private function update():Void
	{
		register.update(sets);
	}
}

/**
 * internal helper class
 */
@:allow(flixel.input.actions.FlxActionManager)
class ActionSetRegister implements IFlxDestroyable
{
	/**
	 * The current action set for the mouse
	 */
	private var mouseSet:Int = -1;
	
	/**
	 * The current action set for the keyboard
	 */
	private var keyboardSet:Int = -1;
	
	/**
	 * The current action set for ALL gamepads
	 */
	private var gamepadAllSet:Int = -1;
	
	/**
	 * The current action set for ALL steam controllers
	 */
	private var steamControllerAllSet:Int = -1;
	
	/**
	 * Maps individual gamepad ID's to different action sets
	 */
	private var gamepadSets:Array<Int>;
	
	/**
	 * Maps individual steam controller handles to different action sets
	 */
	private var steamControllerSets:Array<Int>;
	
	private function new()
	{
		FlxSteamController.init();
		gamepadSets = [];
		steamControllerSets = [];
	}
	
	public function destroy()
	{
		gamepadSets = null;
		steamControllerSets = null;
	}
	
	public function activate(ActionSet:Int, Device:FlxInputDevice, DeviceID:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		setActivate(ActionSet, Device, DeviceID);
	}
	
	public function markActiveSets(sets:Array<FlxActionSet>)
	{
		for (i in 0...sets.length)
		{
			sets[i].active = false;
		}
		
		syncDevice(FlxInputDevice.MOUSE, sets);
		syncDevice(FlxInputDevice.KEYBOARD, sets);
		syncDevice(FlxInputDevice.GAMEPAD, sets);
		syncDevice(FlxInputDevice.STEAM_CONTROLLER, sets);
	}
	
	public function update(sets:Array<FlxActionSet>)
	{
		#if FLX_STEAMWRAP
		updateSteam(sets);
		#end
		
		for (i in 0...sets.length)
		{
			sets[i].update();
		}
	}
	
	public function updateSteam(sets:Array<FlxActionSet>)
	{
		#if FLX_STEAMWRAP
		
		//Steam explicitly recommend in their documentation that you should re-activate the current action set every frame
		
		if (steamControllerAllSet != -1)
		{
			var allSet = sets[steamControllerAllSet];
			var allSetHandle = allSet.steamHandle;
			FlxSteamController.activateActionSet(FlxInputDeviceID.ALL, allSetHandle);
		}
		else
		{
			for (i in 0...steamControllerSets.length)
			{
				if (steamControllerSets[i] != -1)
				{
					var theSet = sets[steamControllerSets[i]];
					var theSetHandle = theSet.steamHandle;
					FlxSteamController.activateActionSet(i, theSetHandle);
				}
			}
		}
		
		#end
	}
	
	private function setActivate(ActionSet:Int, Device:FlxInputDevice, DeviceID:Int = FlxInputDeviceID.FIRST_ACTIVE, DoActivate:Bool = true)
	{
		switch (Device)
		{
			case FlxInputDevice.MOUSE: mouseSet = DoActivate ? ActionSet : -1;
			case FlxInputDevice.KEYBOARD: keyboardSet = DoActivate ? ActionSet : -1;  
			case FlxInputDevice.GAMEPAD: 
				switch (DeviceID)
				{
					case FlxInputDeviceID.ALL:
						clearSetFromArray( -1, gamepadSets);
						gamepadAllSet = DoActivate ? ActionSet : -1;
						
					case FlxInputDeviceID.NONE:
						clearSetFromArray(ActionSet, gamepadSets);
						
					#if FLX_GAMEPAD
					case FlxInputDeviceID.FIRST_ACTIVE:
						gamepadSets[FlxG.gamepads.getFirstActiveGamepadID()] = DoActivate ? ActionSet : -1;
					#end
					
					default:
						gamepadSets[DeviceID] = DoActivate ? ActionSet : -1;
				}
			
			case FlxInputDevice.STEAM_CONTROLLER:
				switch (DeviceID)
				{
					case FlxInputDeviceID.ALL:
						steamControllerAllSet = DoActivate ? ActionSet : -1;
						clearSetFromArray( -1, steamControllerSets);
						for (i in 0...FlxSteamController.MAX_CONTROLLERS)
						{
							steamControllerSets[i] = DoActivate ? ActionSet : -1;
						}
						
					case FlxInputDeviceID.NONE:
						clearSetFromArray(ActionSet, steamControllerSets);
						
					case FlxInputDeviceID.FIRST_ACTIVE:
						steamControllerSets[FlxSteamController.getFirstActiveHandle()] = DoActivate ? ActionSet : -1;
						
					default:
						steamControllerSets[DeviceID] = DoActivate ? ActionSet : -1;
				}
				
			case FlxInputDevice.ALL:
				setActivate(ActionSet, FlxInputDevice.MOUSE,    DeviceID, DoActivate);
				setActivate(ActionSet, FlxInputDevice.KEYBOARD, DeviceID, DoActivate);
				setActivate(ActionSet, FlxInputDevice.GAMEPAD,  DeviceID, DoActivate);
				#if FLX_STEAMWRAP
				setActivate(ActionSet, FlxInputDevice.STEAM_CONTROLLER, DeviceID, DoActivate);
				#end
				
			case FlxInputDevice.NONE:
				setActivate(ActionSet, FlxInputDevice.ALL, DeviceID, false);
				
			default:
				
				//do nothing
		}
	}
	
	/**********PRIVATE*********/
	private function updateSteamOrigins(sets:Array<FlxActionSet>):Array<FlxAction>
	{
		#if FLX_STEAMWRAP
		
		var changed:Array<FlxAction> = null;
		
		if (steamControllerAllSet != -1)
		{
			var allSet = sets[steamControllerAllSet];
			var allSetHandle = allSet.steamHandle;
			
			for (dAction in allSet.digitalActions)
			{
				updateDigitalActionOrigins(dAction, FlxInputDeviceID.ALL, allSetHandle);
				if (dAction.steamOriginsChanged) changed = FlxArrayUtil.safePush(changed, dAction);
			}
			for (aAction in allSet.analogActions)
			{
				updateAnalogActionOrigins(aAction, FlxInputDeviceID.ALL, allSetHandle);
				if (aAction.steamOriginsChanged) changed = FlxArrayUtil.safePush(changed, aAction);
			}
		}
		else
		{
			for (i in 0...steamControllerSets.length)
			{
				if (steamControllerSets[i] != -1)
				{
					var theSet = sets[steamControllerSets[i]];
					var theSetHandle = theSet.steamHandle;
					
					for (dAction in theSet.digitalActions)
					{
						updateDigitalActionOrigins(dAction, i, theSetHandle);
						if (dAction.steamOriginsChanged) changed = FlxArrayUtil.safePush(changed, dAction);
					}
					for (aAction in theSet.analogActions)
					{
						updateAnalogActionOrigins(aAction, i, theSetHandle);
						if (aAction.steamOriginsChanged) changed = FlxArrayUtil.safePush(changed, aAction);
					}
				}
			}
		}
		
		return changed;
		#end
		return [];
	}
	
	@:access(flixel.input.actions.FlxAction)
	private function updateDigitalActionOrigins(action:FlxActionDigital, deviceID:Int, setHandle:Int)
	{
		#if FLX_STEAMWRAP
		if (Steam.controllers == null) return;
		var checksum = action._steamOriginsChecksum;
		if (deviceID == FlxInputDeviceID.ALL) deviceID = 0;
		Steam.controllers.getDigitalActionOrigins(deviceID, setHandle, action.steamHandle, action._steamOrigins);
		var newChecksum = cheapChecksum(cast action._steamOrigins);
		
		if (checksum != newChecksum)
		{
			action.steamOriginsChanged = true;
		}
		else
		{
			action.steamOriginsChanged = false;
		}
		action._steamOriginsChecksum = newChecksum;
		#end
	}
	
	@:access(flixel.input.actions.FlxAction)
	private function updateAnalogActionOrigins(action:FlxActionAnalog, deviceID:Int, setHandle:Int)
	{
		#if FLX_STEAMWRAP
		if (Steam.controllers == null) return;
		var checksum = action._steamOriginsChecksum;
		if (deviceID == FlxInputDeviceID.ALL) deviceID = 0;
		Steam.controllers.getAnalogActionOrigins(deviceID, setHandle, action.steamHandle, cast action._steamOrigins);
		var newChecksum = cheapChecksum(cast action._steamOrigins);
		if (checksum != newChecksum)
		{
			action.steamOriginsChanged = true;
		}
		else
		{
			action.steamOriginsChanged = false;
		}
		action._steamOriginsChecksum = newChecksum;
		#end
	}
	
	private function cheapChecksum(arr:Array<Int>):Int
	{
		//Fletcher's algorithm:
		
		var sum1 = 0;
		var sum2 = 0;
		
		if (arr != null)
		{
			for (n in arr)
			{
				sum1 = (sum1 + n) % 255;
				sum2 = (sum2 + sum1) % 255;
			}
		}
		
		return (sum2 << 8) | sum1;
	}
	
	/**********PRIVATE*********/
	/**
	 * Helper function to properly update the action sets with proper steam inputs
	 */
	private function updateSteamInputs(sets:Array<FlxActionSet>):Void
	{
		#if FLX_STEAMWRAP
		if (steamControllerAllSet != -1)
		{
			for (i in 0...steamControllerSets.length)
			{
				changeSteamControllerActionSet(i, steamControllerAllSet, sets);
			}
		}
		else
		{
			for (i in 0...steamControllerSets.length)
			{
				if (steamControllerSets[i] != -1)
				{
					changeSteamControllerActionSet(i, steamControllerSets[i], sets);
				}
			}
		}
		updateSteam(sets);
		updateSteamOrigins(sets);
		#end
	}
	
	/**
	 * Attach this controller to a new action set, remove it from the old action set, update internal steam inputs accordingly
	 * @param	controllerHandle steam controller handle (guaranteed not to be FlxInputDeviceID.ALL or FlxInputDeviceID.FIRST_ACTIVE)
	 * @param	newSet	the action set handle of the new set to attach to
	 */
	private function changeSteamControllerActionSet(controllerHandle:Int, newSet:Int, sets:Array<FlxActionSet>)
	{
		var lastSet = FlxSteamController.getCurrentActionSet(controllerHandle);
		if (lastSet == newSet) return;
		
		if (sets == null)
		{
			return;
		}
		
		if (lastSet != -1)
		{
			if (lastSet < sets.length)
			{
				//detach inputs for this controller from any steam-aware actions in the old set
				sets[lastSet].attachSteamController(controllerHandle, false);
			}
		}
		
		//attach inputs for this controller to any steam-aware actions in the new set
		sets[newSet].attachSteamController(controllerHandle);
	}
	
	/**
	 * Go through all action sets and mark them as active if any device is 
	 * subscribed to one of their actions. (Assumes you've previously set
	 * them all to active=false earlier in the udpate loop)
	 * @param	device
	 * @param	sets
	 */
	private function syncDevice(device:FlxInputDevice, sets:Array<FlxActionSet>)
	{
		switch (device)
		{
			case FlxInputDevice.MOUSE:
				if (mouseSet >= 0 && mouseSet < sets.length)
					sets[mouseSet].active = true;
				
			case FlxInputDevice.KEYBOARD:
				if (keyboardSet >= 0 && keyboardSet < sets.length)
					sets[keyboardSet].active = true;
				
			case FlxInputDevice.GAMEPAD:
				if (gamepadAllSet >= 0 && gamepadAllSet < sets.length)
				{
					sets[gamepadAllSet].active = true;
				}
				else
				{
					for (i in 0...gamepadSets.length)
					{
						var gset = gamepadSets[i];
						if (gset >= 0 && gset < sets.length)
						{
							sets[gset].active = true;
						}
					}
				}
				
			case FlxInputDevice.STEAM_CONTROLLER:
				updateSteamInputs(sets);
				if (steamControllerAllSet >= 0 && steamControllerAllSet < sets.length)
				{
					sets[steamControllerAllSet].active = true;
				}
				else
				{
					for (i in 0...steamControllerSets.length)
					{
						var sset = steamControllerSets[i];
						if (sset >= 0 && sset < sets.length)
						{
							sets[sset].active = true;
						}
					}
				}
			default:
				//do nothing
		}
	}
	
	private function clearSetFromArray(ActionSet:Int = -1, array:Array<Int>)
	{
		for (i in 0...array.length)
		{
			if (ActionSet == -1 || array[i] == ActionSet)
			{
				array[i] = -1;
			}
		}
	}
}

typedef ActionSetJSONArray = 
{
	@:optional var actionSets:Array<ActionSetJSON>;
}

typedef ActionSetJSON =
{
	@:optional var name:String;
	@:optional var analogActions:Array<String>;
	@:optional var digitalActions:Array<String>;
}
