package flixel.input.actions;

import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.actions.FlxActionInput.FlxInputType;
import flixel.input.actions.FlxActionManager.ActionSetRegister;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.input.FlxInput;
import flixel.input.IFlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.mouse.FlxMouseButton;
import flixel.input.gamepad.FlxGamepadInputID;
import haxe.Json;

#if steamwrap
import steamwrap.api.Controller;
import steamwrap.api.Steam;
import steamwrap.data.ControllerConfig;
#end

/**
 * High level input manager for FlxActions. This lets you manage multiple input
 * devices and action sets, and is the only supported method for natively
 * handling Steam Controllers.
 * 
 * If you are only using Mouse/Keyboard/Gamepad controls for a fairly simple
 * game, this might be overkill, but if you have more complex needs, are
 * supporting the Steam Controller natively, or need robust and flexibile
 * user-customizable inputs, this is the class for you.
 * 
 * OVERVIEW
 * =============
 * 
 * There are four items to consider:
 * 
 * - FlxAction
 * - FlxActionInput
 * - FlxActionSet
 * - FlxActionManager
 * 
 * The PLAYER cares about ACTIONS:
 * Mario JUMPS, Samus SHOOTS, Captain Falcon TURNS, BRAKES, and ACCELERATES.
 
 * The COMPUTER cares about INPUTS:
 * The W key is PRESSED. The Left Mouse button was JUST_RELEASED. Gamepad #2's
 * analog stick is MOVED with values (x=0.4,y=-0.5).
 *
 * The DESIGNER cares about ACTION SETS:
 * Different parts of the game might need different controls. You (usually)
 * can't JUMP or SHOOT in a store menu, but you CAN perform actions like
 * MENU_UP, MENU_DOWN, MENU_LEFT, MENU_RIGHT, BACK, and SELECT.
 * 
 * 1. FlxActions
 * =============
 * 
 * FlxActions come in two varieties: Digital and Analog. You can only create
 * FlxActionDigital and FlxActionAnalog. Digital is for on/off actions like
 * JUMP and SHOOT. Analog is for things that need a range of values, like
 * jumping with more or less force, or moving a player or camera around.
 * 
 * This lets you just check for: if(SHOOT.check()) in your update loop 
 * rather than some hand-rolled custom input code.
 * 
 * FlxActions don't do anything until you attach FlxActionInputs do them.
 * 
 * 2. FlxInputs
 * =============
 * 
 * FlxActionInputs are divided into digital and analog types, as well as by
 * the kind of input device they use:
 * 
 * - FlxActionInputDigitalKeyboard
 * - FlxActionInputDigitalMouse
 * - FlxActionInputDigitalGamepad
 * - FlxActionInputAnalogMouse
 * - FlxActionInputAnalogGamepad
 * 
 * Create a FlxActionInput subclass with the input values you want, then call
 * myAction.addInput(myInput) to attach it to an action. You can only add
 * digital inputs to digital actions and analog inputs to analog actions.
 * 
 * For digital actions that only have mouse, keyboard, and gamepad input,
 * you're done. You can now call myAction.check() in your update loop to 
 * see if it has fired and then act upon it.
 * 
 * It's best to call update() on all of your actions in your update loop
 * before checking them, but this is strictly speaking only necessary for:
 *
 * - analog actions (to get proper JUST_MOVED / JUST_STOPPED values)
 * - if you want the .fire property to update every frame
 * - actions (digital or analog) with steam controller input
 *
 * 3. FlxActionSet
 * ===============
 * 
 * FlxActionSets are little more than glorified arrays of FlxActions. There's
 * little reason to use them directly unless you are using FlxActionManager,
 * but they can still be a convenient way to call update() on all your actions
 * at once.
 * 
 * 4. FlxActionManager
 * ===================
 * 
 * FlxActionManager lets you manage multiple action sets. When you are using
 * this class, only ONE action set is considered active at a given time for
 * any given device, but multiple devices can be subscribed to the same action
 * set.
 * 
 * For instance, in an asymetrical co-op game where one person drives a tank
 * and the other mans the turret, gamepad #1 could use action set "drive" and
 * gamepad #2 could use action set "gunner". The same could go for the mouse,
 * the keyboard, etc. And in a single-player game you might want to just change
 * the action set of ALL input devices every time you switch to a different
 * screen, such as a menu.
 * 
 * FlxActionManager lets you:
 * - ADD action sets
 * - REMOVE action sets
 * - ACTIVATE an action set for a specific device.
 * - UPDATE all your action sets at once
 * - ENFORCE the "only one action set active per device at a time" rule
 * 
 * Once you've set up FlxActionManager, you can let flixel handle it globally
 * with: FlxG.inputs.add(myFlxActionManager);
 * 
 * If you don't add it globally, you will have to call update() on it yourself.
 * 
 * If you are using the steamwrap library, FlxActionManager gains the ability
 * to automatically create action sets from a steamwrap object derived from the
 * master vdf game actions file that Steam makes you set up for native
 * controller support. You must then ACTIVATE one of those action sets for any
 * connected steam controllers, which will automatically attach the proper
 * steam action inputs to the actions in the set. You can also add as many 
 * regular FlxActionInputs as you like to any actions in the sets.
 * 
 * NOTE:
 * If you are using a Steam Controller, you MUST use FlxActionManager in order
 * to properly process the Steam Controller API via FlxActions. The only other
 * alternative is to directly call the steamwrap functions directly.
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
	
	public function new() 
	{
		sets = [];
		register = new ActionSetRegister();
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
		for (s in sets)
		{
			if (s == set)
			{
				return -1;
			}
		}
		
		sets.push(set);
		
		onChange();
		
		return sets.length - 1;
	}
	
	public function destroy():Void
	{
		FlxDestroyUtil.destroyArray(sets);
		register.destroy();
		register = null;
		sets = null;
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
		
		switch(device)
		{
			case FlxInputDevice.KEYBOARD: index = register.keyboardSet;
			case FlxInputDevice.MOUSE: index = register.mouseSet;
			case FlxInputDevice.GAMEPAD:
				switch(deviceID)
				{
					case FlxInputDeviceID.ALL: index = register.gamepadAllSet;
					case FlxInputDeviceID.FIRST_ACTIVE: id = FlxG.gamepads.getFirstActiveGamepadID();
					case FlxInputDeviceID.NONE: index = -1;
					default: id = deviceID;
				}
				if (id >= 0 && id < register.gamepadSets.length)
				{
					index = register.gamepadSets[id];
				}
			case FlxInputDevice.STEAM_CONTROLLER:
				switch(deviceID)
				{
					case FlxInputDeviceID.ALL: index = register.steamControllerAllSet;
					case FlxInputDeviceID.NONE: index = -1;
					default: id = deviceID;
				}
				if (id >= 0 && id < register.steamControllerSets.length)
				{
					index = register.steamControllerSets[id];
				}
			case FlxInputDevice.ALL:
				switch(deviceID)
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
	
	#if steamwrap
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
	public function initFromJSON(data:Dynamic, CallbackDigital:FlxActionDigital->Void, CallbackAnalog:FlxActionAnalog->Void):Int
	{
		if (data == null) return 0;
		
		var i:Int = 0;
		var actionSets:Array<Dynamic> = Reflect.hasField(data, "actionSets") ? Reflect.field(data, "actionSets") : null;
		if (actionSets == null) return 0;
		
		for (set in actionSets)
		{
			if (addSet(FlxActionSet.fromJSON(set, CallbackDigital, CallbackAnalog)) != -1)
			{
				trace("added set : " + sets[sets.length - 1].name);
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
		return Json.stringify({"actionSets":sets}, function(key:Dynamic, value:Dynamic):Dynamic{
			
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
			
		}, space);
	}
	
	/**
	 * Remove a set from the manager
	 * @param	Set	The set you want to remove
	 * @param	Destroy	Whether to also destroy the set or just remove it from the list
	 * @return	whether the action was found & successfully removed
	 */
	public function removeSet(Set:FlxActionSet, Destroy:Bool = true):Bool
	{
		var success = false;
		for (i in 0...sets.length)
		{
			if (sets[i] == Set)
			{
				if (Destroy)
				{
					sets[i].destroy();
				}
				sets.splice(i, 1);
				success = true;
				break;
			}
		}
		
		if (success)
		{
			onChange();
		}
		
		return success;
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
		switch (Device)
		{
			case FlxInputDevice.MOUSE: mouseSet    = ActionSet;
			case FlxInputDevice.KEYBOARD: keyboardSet = ActionSet;
			
			case FlxInputDevice.GAMEPAD: 
				switch (DeviceID)
				{
					case FlxInputDeviceID.ALL:          gamepadAllSet = ActionSet;
					                                    clearSetFromArray(-1, gamepadSets);
					case FlxInputDeviceID.NONE:         clearSetFromArray(ActionSet, gamepadSets);
					
					#if !FLX_NO_GAMEPAD
					case FlxInputDeviceID.FIRST_ACTIVE: gamepadSets[FlxG.gamepads.getFirstActiveGamepadID()] = ActionSet;
					#end
					
					default:                            gamepadSets[DeviceID] = ActionSet;
				}
			
			case FlxInputDevice.STEAM_CONTROLLER:
				switch (DeviceID)
				{
					case FlxInputDeviceID.ALL:          steamControllerAllSet = ActionSet;
					                                    clearSetFromArray( -1, steamControllerSets);
					case FlxInputDeviceID.NONE:         clearSetFromArray(ActionSet, steamControllerSets);
					case FlxInputDeviceID.FIRST_ACTIVE: steamControllerSets[FlxSteamController.getFirstActiveHandle()] = ActionSet;
					default:                            steamControllerSets[DeviceID] = ActionSet;
				}
			
			case FlxInputDevice.ALL:
				activate(ActionSet, FlxInputDevice.MOUSE,    DeviceID);
				activate(ActionSet, FlxInputDevice.KEYBOARD, DeviceID);
				activate(ActionSet, FlxInputDevice.GAMEPAD,  DeviceID);
				#if steamwrap
				activate(ActionSet, FlxInputDevice.STEAM_CONTROLLER, DeviceID);
				#end
				
			default:
				
				//do nothing
		}
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
		#if steamwrap
		updateSteam(sets);
		#end
		
		for (i in 0...sets.length)
		{
			sets[i].update();
		}
	}
	
	public function updateSteam(sets:Array<FlxActionSet>)
	{
		#if steamwrap
		
		//Steam explicitly recommend in their documentation that you should re-activate the current action set every frame
		//This is allegedly a cheap call, we'll have to see if they're right...
		
		if (steamControllerAllSet != -1)
		{
			FlxSteamController.activateActionSet(FlxInputDeviceID.ALL, sets[steamControllerAllSet].steamHandle);
		}
		else
		{
			for (i in 0...steamControllerSets.length)
			{
				if (steamControllerSets[i] != -1)
				{
					FlxSteamController.activateActionSet(i, sets[steamControllerSets[i]].steamHandle);
				}
			}
		}
		#end
	}
	
	/**********PRIVATE*********/
	
	/**
	 * The current action set for the mouse
	 */
	private var mouseSet:Int = 0;
	
	/**
	 * The current action set for the keyboard
	 */
	private var keyboardSet:Int = 0;
	
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
	
	/**
	 * Helper function to properly update the action sets with proper steam inputs
	 */
	private function updateSteamInputs(sets:Array<FlxActionSet>):Void
	{
		#if steamwrap
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
		if (lastSet != -1)
		{
			//detach inputs for this controller from any steam-aware actions in the old set
			sets[lastSet].attachSteamController(controllerHandle, false);
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


