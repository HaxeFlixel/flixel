package flixel.input.actions;
import steamwrap.api.Controller;
import steamwrap.api.Steam;

/**
 * ...
 * @author 
 */
class SteamMock
{

	public static var digitalData:Map<String,ControllerDigitalActionData>;
	public static var analogData:Map<String,ControllerAnalogActionData>;
	
	private static var inited:Bool = false;
	
	@:access(steamwrap.api.Steam)
	public static function init()
	{
		digitalData = new Map<String,ControllerDigitalActionData>();
		analogData = new Map<String,ControllerAnalogActionData>();
		@:privateAccess Steam.controllers = new FakeController(function(str:String){
			trace(str);
		});
		inited = true;
	}
	
	@:access(flixel.input.actions.FlxSteamController)
	public static function setDigitalAction(controller:Int, actionHandle:Int, bool:Bool)
	{
		if (!inited) init();
		
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
	
	public static function setAnalogAction(controller:Int, actionHandle:Int, x:Float, y:Float, active:Bool, eMode:EControllerSourceMode=JOYSTICKMOVE)
	{
		if (!inited) init();
		
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
}

class FakeController extends Controller
{
	function new(CustomTrace:String->Void)
	{
		super(CustomTrace);
	}
	
	override function init() 
	{
		//do nothing
	}
	
	override function get_MAX_ORIGINS():Int 
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
}