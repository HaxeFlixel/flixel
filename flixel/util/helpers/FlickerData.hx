package flixel.util.helpers;

import flixel.FlxObject;
import flixel.util.FlxPool;

class FlickerData
{
	private static var _pool:FlxPool<FlickerData> = new FlxPool<FlickerData>();
	
	public static function recycle(object:FlxObject):FlickerData
	{
		var data:FlickerData = _pool.get();
		
		if (data == null)	data = new FlickerData(object);
		else				data.reset(object);
		
		return data;
	}
	
	public static function put(data:FlickerData):Void
	{
		data.object = null;
		_pool.put(data);
	}
	
	public var object:FlxObject;
	public var startVisibility:Bool;
	
	private function new(object:FlxObject)
	{
		reset(object);
	}
	
	public function reset(object:FlxObject):Void
	{
		this.object = object;
		if (object != null)	this.startVisibility = object.visible;
	}
}