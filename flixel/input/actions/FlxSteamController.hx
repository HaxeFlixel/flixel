package flixel.input.actions;

import flixel.input.IFlxInputManager;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
#if FLX_STEAMWRAP
import steamwrap.api.Steam;
import steamwrap.api.Controller.ControllerDigitalActionData;
import steamwrap.api.Controller.ControllerAnalogActionData;
#end

/**
 * Helper class that wraps steam API so that flixel can do some basic
 * book-keeping on top of it
 *
 * Also cuts down a bit on the (cpp && steamwrap) clutter by letting me stuff
 * all those conditionals and imports over here and just letting them
 * resolve to no-ops if steamwrap isn't detected.
 *
 * Not meant to be exposed to end users, just for internal use by
 * FlxGamepadManager. If a user wants to use the Steam API directly
 * they should just be making naked calls to steamwrap themselves.
 *
 * @since 4.6.0
 */
@:allow(flixel.input.actions)
class FlxSteamController
{
	/**
	 * The maximum number of controllers that can be connected
	 */
	public static var MAX_CONTROLLERS(get, never):Int;

	/**
	 * The maximum number of origins (input glyphs, basically) that can be assigned to an action
	 */
	public static var MAX_ORIGINS(get, never):Int;

	/**
	 * The wait time between polls for connected controllers
	 */
	public static var CONTROLLER_CONNECT_POLL_TIME(default, null):Float = 0.25;

	/**
	 * The wait time between polls for action origins (checking which input glyphs are associated with an action, in case the player has re-configured them)
	 */
	public static var ORIGIN_DATA_POLL_TIME(default, null):Float = 1.0;

	static var controllers:Array<FlxSteamControllerMetadata>;

	static var onControllerConnect(default, null):Void->Void = null;
	static var onOriginUpdate(default, null):Void->Void = null;

	static inline function get_MAX_CONTROLLERS():Int
	{
		#if FLX_STEAMWRAP
		if (Steam.controllers == null)
			return 0;
		return Steam.controllers.MAX_CONTROLLERS;
		#else
		return 0;
		#end
	}

	static inline function get_MAX_ORIGINS():Int
	{
		#if FLX_STEAMWRAP
		if (Steam.controllers == null)
			return 0;
		return Steam.controllers.MAX_ORIGINS;
		#else
		return 0;
		#end
	}

	static function clear()
	{
		#if FLX_STEAMWRAP
		if (controllers == null)
			return;
		for (i in 0...controllers.length)
		{
			controllers[i].active = false;
			controllers[i].connected.release();
		}
		#end
	}

	static function init()
	{
		controllers = [];
		#if FLX_STEAMWRAP
		if (Steam.controllers == null)
			return;

		for (i in 0...Steam.controllers.MAX_CONTROLLERS)
		{
			controllers.push(new FlxSteamControllerMetadata());
		}

		// If the FlxSteamUpdater hasn't been added to FlxG.inputs yet,
		// we need to do so now to ensure that steam controllers will
		// be properly updated every frame
		var steamExists = false;
		for (input in FlxG.inputs.list)
		{
			if ((input is FlxSteamUpdater))
			{
				steamExists = true;
				break;
			}
		}
		if (!steamExists)
		{
			FlxG.inputs.add(new FlxSteamUpdater());
		}
		#end
	}

	static function getActionSetHandle(name:String):Int
	{
		#if FLX_STEAMWRAP
		if (Steam.controllers == null)
			return -1;
		return Steam.controllers.getActionSetHandle(name);
		#end
		return -1;
	}

	static function getCurrentActionSet(SteamControllerHandle:Int):Int
	{
		#if FLX_STEAMWRAP
		if (controllers == null)
			return -1;
		if (SteamControllerHandle >= 0 && SteamControllerHandle < controllers.length)
		{
			return controllers[SteamControllerHandle].actionSet;
		}
		#end
		return -1;
	}

	static function activateActionSet(SteamControllerHandle:Int, ActionSetHandle:Int)
	{
		#if FLX_STEAMWRAP
		if (Steam.controllers == null)
			return;
		if (SteamControllerHandle == FlxInputDeviceID.NONE)
			return;
		if (SteamControllerHandle == FlxInputDeviceID.ALL)
		{
			for (i in 0...controllers.length)
			{
				controllers[i].actionSet = ActionSetHandle;
				Steam.controllers.activateActionSet(controllers[i].handle, ActionSetHandle);
			}
		}
		else if (SteamControllerHandle == FlxInputDeviceID.FIRST_ACTIVE)
		{
			// TODO: not sure FIRST_ACTIVE will be very reliable in a steam controller context... I might consider dropping support for this handle in the future
			for (i in 0...controllers.length)
			{
				if (controllers[i].active)
				{
					controllers[i].actionSet = ActionSetHandle;
					Steam.controllers.activateActionSet(controllers[i].handle, ActionSetHandle);
					break;
				}
			}
		}
		else
		{
			Steam.controllers.activateActionSet(SteamControllerHandle, ActionSetHandle);
		}
		#end
	}

	static function getFirstActiveHandle():Int
	{
		#if FLX_STEAMWRAP
		if (controllers == null)
			return -1;
		for (i in 0...controllers.length)
		{
			if (controllers[i].active)
			{
				return controllers[i].handle;
			}
		}
		#end
		return -1;
	}

	static function getConnectedControllers():Array<Int>
	{
		#if FLX_STEAMWRAP
		if (Steam.controllers == null)
			return [];
		var arr = Steam.controllers.getConnectedControllers();

		for (i in 0...Steam.controllers.MAX_CONTROLLERS)
		{
			if (i < arr.length && arr[i] >= 0)
			{
				var index = arr[i];
				controllers[index].handle = index;
			}

			controllers[i].connected.update();
			if (arr.indexOf(controllers[i].handle) != -1)
			{
				controllers[i].connected.press();
			}
			else
			{
				controllers[i].connected.release();
			}
		}

		return arr;
		#else
		return [];
		#end
	}

	#if FLX_STEAMWRAP
	static function getAnalogActionData(controller:Int, action:Int, ?data:ControllerAnalogActionData):ControllerAnalogActionData
	{
		if (Steam.controllers == null)
			return data;
		data = Steam.controllers.getAnalogActionData(controller, action, data);
		if (controller >= 0 && controller < controllers.length)
		{
			if (data.bActive > 0 && data.x != 0 || data.y != 0)
			{
				controllers[controller].active = true;
			}
		}
		return data;
	}
	#else
	static function getAnalogActionData(controller:Int, action:Int, ?data:Dynamic):Dynamic
	{
		return null;
	}
	#end

	#if FLX_STEAMWRAP
	private static function getDigitalActionData(controller:Int, action:Int):ControllerDigitalActionData
	{
		if (Steam.controllers == null)
			return 0;
		var data = Steam.controllers.getDigitalActionData(controller, action);
		if (controller >= 0 && controller < controllers.length)
		{
			if (data.bActive && data.bState)
			{
				controllers[controller].active = true;
			}
		}
		return data;
	}
	#else
	static function getDigitalActionData(controller:Int, action:Int):DigitalActionData
	{
		return new DigitalActionData(false, false);
	}
	#end

	static inline function getAnalogActionHandle(name:String):Int
	{
		#if FLX_STEAMWRAP
		if (Steam.controllers == null)
			return -1;
		return Steam.controllers.getAnalogActionHandle(name);
		#else
		return -1;
		#end
	}

	static inline function getDigitalActionHandle(name:String):Int
	{
		#if FLX_STEAMWRAP
		if (Steam.controllers == null)
			return -1;
		return Steam.controllers.getDigitalActionHandle(name);
		#else
		return -1;
		#end
	}
}

private class DigitalActionData
{
	public var bActive:Bool;
	public var bState:Bool;

	public function new(bActive:Bool, bState:Bool)
	{
		this.bActive = bActive;
		this.bState = bState;
	}
}

@:allow(flixel.input.actions)
#if !FLX_UNIT_TEST private #end class FlxSteamControllerMetadata
{
	public var handle:Int = -1;
	public var actionSet:Int = -1;
	public var active:Bool = false;
	public var connected:FlxInput<Int> = new FlxInput<Int>(0);

	function new():Void {}
}

@:allow(flixel.input.actions)
private class FlxSteamUpdater implements IFlxInputManager
{
	var controllerTime:Float = 0.0;
	var originTime:Float = 0.0;

	function new() {};

	public function destroy():Void {}

	public function reset():Void {}

	// run the steam API every frame if steam is detected
	function update():Void
	{
		#if FLX_STEAMWRAP
		Steam.onEnterFrame();

		controllerTime += FlxG.elapsed;
		originTime += FlxG.elapsed;

		if (controllerTime > FlxSteamController.CONTROLLER_CONNECT_POLL_TIME)
		{
			controllerTime -= FlxSteamController.CONTROLLER_CONNECT_POLL_TIME;
			FlxSteamController.getConnectedControllers();
			if (FlxSteamController.onControllerConnect != null)
				FlxSteamController.onControllerConnect();
		}

		if (originTime > FlxSteamController.ORIGIN_DATA_POLL_TIME)
		{
			originTime -= FlxSteamController.ORIGIN_DATA_POLL_TIME;
			if (FlxSteamController.onOriginUpdate != null)
				FlxSteamController.onOriginUpdate();
		}
		#end
	}

	function onFocus():Void {}

	function onFocusLost():Void {}
}
