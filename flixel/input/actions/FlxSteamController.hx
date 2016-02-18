package flixel.input.actions;
import flixel.input.actions.FlxActionInput;

#if steamwrap
import steamwrap.api.Controller;
import steamwrap.api.Steam;
#end

/**
 * Helper class that wraps steam API so that flixel can do some basic
 * book-keeping on top of it
 * 
 * Also cuts down a bit on the #if steamwrap clutter by letting me stuff
 * all those conditionals and imports over here and just letting them
 * resolve to no-ops if steamwrap isn't detected.
 * 
 * Not meant to be exposed to end users, just for internal use by
 * FlxGameadManager. If a user wants to use the Steam API directly
 * they should just be making naked calls to steamwrap themselves.
 * 
 */
@:allow(flixel.input.actions)
class FlxSteamController
{

	private static function clear()
	{
		#if steamwrap
		for (i in 0...controllers.length)
		{
			controllers[i].active = false;
		}
		#end
	}
	
	private static function init()
	{
		controllers = [];
		for (i in 0...Steam.controllers.MAX_CONTROLLERS)
		{
			controllers.push(new FlxSteamControllerMetadata());
		}
	}
	
	private static function getActionSetHandle(name:String):Int
	{
		#if steamwrap
		return Steam.controllers.getActionSetHandle(name);
		#end
		return -1;
	}
	
	private static function getCurrentActionSet(SteamControllerHandle:Int):Int
	{
		#if steamwrap
		if (SteamControllerHandle >= 0 && SteamControllerHandle <= controllers.length)
		{
			return controllers[SteamControllerHandle].actionSet;
		}
		#end
		return -1;
	}
	
	private static function activateActionSet(SteamControllerHandle:Int, ActionSetHandle:Int)
	{
		#if steamwrap
		if (SteamControllerHandle == FlxInputDeviceID.NONE) return;
		if (SteamControllerHandle == FlxInputDeviceID.ALL)
		{
			for (i in 0...controllers.length)
			{
				controllers[SteamControllerHandle].actionSet = ActionSetHandle;
			}
		}
		else if (SteamControllerHandle == FlxInputDeviceID.FIRST_ACTIVE)
		{
			controllers[SteamControllerHandle].actionSet = ActionSetHandle;
		}
		Steam.controllers.activateActionSet(SteamControllerHandle, ActionSetHandle);
		#end
	}
	
	
	private static function getFirstActiveHandle():Int
	{
		#if steamwrap
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
	
	private static function getConnectedControllers():Array<Int>
	{
		#if steamwrap
		var arr = Steam.controllers.getConnectedControllers();
		for (i in 0...Steam.controllers.MAX_CONTROLLERS)
		{
			if (arr.length > i)
			{
				controllers[i].handle = arr[i];
			}
		}
		return arr;
		#else
		return [];
		#end
	}
	
	private static function getAnalogActionData(controller:Int, action:Int, ?data:ControllerAnalogActionData):ControllerAnalogActionData
	{
		#if steamwrap
		data = Steam.controllers.getAnalogActionData(controller, action, data);
		if (controller > 0 && controller < controllers.length)
		{
			if (data.bActive > 0 && data.x != 0 || data.y != 0)
			{
				controllers[controller].active = true;
			}
		}
		return data;
		#else
		if (data == null)
		{
			data = new ControllerAnalogActionData();
		}
		data.bActive = false;
		data.x = 0;
		data.y = 0;
		data.eMode = NONE;
		return data;
		#end
	}
	
	private static function getDigitalActionData(controller:Int, action:Int):ControllerDigitalActionData 
	{
		#if steamwrap
		var data = Steam.controllers.getDigitalActionData(controller, action);
		if (controller > 0 && controller < controllers.length)
		{
			if (data.bActive && data.bState)
			{
				controllers[controller].active = true;
			}
		}
		return data;
		#else
		return 0;
		#end
	}
	
	private static inline function getAnalogActionHandle(name:String):Int
	{
		#if steamwrap
		return Steam.controllers.getAnalogActionHandle(name);
		#else
		return -1;
		#end
	}
	
	private static inline function getDigitalActionHandle(name:String):Int
	{
		#if steamwrap
		return Steam.controllers.getDigitalActionHandle(name);
		#else
		return -1;
		#end
	}
	
	private static var controllers:Array<FlxSteamControllerMetadata>;
}

@:noCompletion
class FlxSteamControllerMetadata
{
	public var handle:Int = -1;
	public var actionSet:Int = -1;
	public var active:Bool = false;
	
	public function new():Void{}
}