package flixel.input.actions;

import flixel.input.actions.FlxSteamController.FlxSteamControllerMetadata;
import flixel.util.FlxArrayUtil;
#if FLX_STEAMWRAP
import steamwrap.api.Controller;
import steamwrap.api.Steam;
#end

class SteamMock
{
	#if FLX_STEAMWRAP
	public static var digitalData:Map<String, ControllerDigitalActionData>;
	public static var analogData:Map<String, ControllerAnalogActionData>;

	public static var digitalOrigins:Map<String, Array<EControllerActionOrigin>>;
	public static var analogOrigins:Map<String, Array<EControllerActionOrigin>>;

	static var inited:Bool = false;
	static var flxInited:Bool = false;

	@:access(steamwrap.api.Steam)
	public static function init()
	{
		if (inited)
			return;

		digitalData = new Map<String, ControllerDigitalActionData>();
		analogData = new Map<String, ControllerAnalogActionData>();

		digitalOrigins = new Map<String, Array<EControllerActionOrigin>>();
		analogOrigins = new Map<String, Array<EControllerActionOrigin>>();

		Steam.controllers = new FakeController(function(str:String)
		{
			trace(str);
		});

		inited = true;
	}

	public static function initFlx()
	{
		if (flxInited)
			return;

		var metaData = new FlxSteamControllerMetadata();

		metaData.handle = 0;
		metaData.actionSet = -1;
		metaData.active = false;
		metaData.connected.press();

		@:privateAccess FlxSteamController.controllers = [metaData];

		flxInited = true;
	}

	@:access(flixel.input.actions.FlxSteamController)
	public static function setDigitalAction(controller:Int, actionHandle:Int, bool:Bool)
	{
		if (!inited)
			init();

		var key = controller + "_" + actionHandle;

		var data;
		if (!digitalData.exists(key))
		{
			data = new ControllerDigitalActionData(0);
			digitalData.set(key, data);
		}
		data = digitalData.get(key);

		var newData = new ControllerDigitalActionData(bool ? 0x11 : 0x10);

		digitalData.set(key, newData);
	}

	public static function setAnalogAction(controller:Int, actionHandle:Int, x:Float, y:Float, active:Bool, eMode:EControllerSourceMode = JOYSTICKMOVE)
	{
		if (!inited)
			init();

		var key = controller + "_" + actionHandle;

		var data;
		if (!analogData.exists(key))
		{
			data = new ControllerAnalogActionData();
			analogData.set(key, data);
		}
		data = analogData.get(key);

		data.bActive = active ? 1 : 0;
		data.eMode = eMode;
		data.x = x;
		data.y = y;
	}

	public static function setDigitalActionOrigins(controller:Int, actionSet:Int, action:Int, origins:Array<EControllerActionOrigin>)
	{
		if (!inited)
			init();

		var key = controller + "_" + actionSet + "_" + action;
		digitalOrigins.set(key, origins);
	}

	public static function setAnalogActionOrigins(controller:Int, actionSet:Int, action:Int, origins:Array<EControllerActionOrigin>)
	{
		if (!inited)
			init();

		var key = controller + "_" + actionSet + "_" + action;
		analogOrigins.set(key, origins);
	}
	#end
}

#if FLX_STEAMWRAP
class FakeController extends Controller
{
	public function new(CustomTrace:String->Void)
	{
		super(CustomTrace);
	}

	override function init() {}

	override function get_MAX_ORIGINS():Int
	{
		return 16;
	}

	override function get_MAX_CONTROLLERS():Int
	{
		return 16;
	}

	override public function getDigitalActionData(controller:Int, action:Int):ControllerDigitalActionData
	{
		var key = controller + "_" + action;

		return SteamMock.digitalData.get(key);
	}

	override public function getAnalogActionData(controller:Int, action:Int, ?data:ControllerAnalogActionData):ControllerAnalogActionData
	{
		var key = controller + "_" + action;

		if (data == null)
		{
			data = new ControllerAnalogActionData();
		}

		var result = SteamMock.analogData.get(key);

		if (result == null)
		{
			return data;
		}

		data.bActive = result.bActive;
		data.eMode = result.eMode;
		data.x = result.x;
		data.y = result.y;

		return data;
	}

	override public function getDigitalActionOrigins(controller:Int, actionSet:Int, action:Int, ?originsOut:Array<EControllerActionOrigin>):Int
	{
		var key = controller + "_" + actionSet + "_" + action;

		var first:Int = 0;

		if (SteamMock.digitalOrigins == null)
			return first;
		var result = SteamMock.digitalOrigins.get(key);
		if (result == null)
			return first;

		if (originsOut != null)
		{
			FlxArrayUtil.clearArray(originsOut);
		}
		else
		{
			originsOut = [];
		}

		for (r in result)
		{
			originsOut.push(r);
		}

		return originsOut.length;
	}

	override public function getAnalogActionOrigins(controller:Int, actionSet:Int, action:Int, ?originsOut:Array<EControllerActionOrigin>):Int
	{
		var key = controller + "_" + actionSet + "_" + action;

		var first:Int = 0;

		if (SteamMock.analogOrigins == null)
			return first;
		var result = SteamMock.analogOrigins.get(key);
		if (result == null)
			return first;

		if (originsOut != null)
		{
			FlxArrayUtil.clearArray(originsOut);
		}
		else
		{
			originsOut = [];
		}

		for (r in result)
		{
			originsOut.push(r);
		}

		return originsOut.length;
	}
}
#end
