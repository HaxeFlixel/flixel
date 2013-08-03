package flixel.util.helpers;

import flixel.FlxObject;
import flixel.util.FlxPool;

class FlickerData
{
	private static var _pool:FlxPool<FlickerData> = new FlxPool<FlickerData>();
	
	public static function recycle(object:FlxObject):FlickerData
	{
		var data:FlickerData = _pool.get();
		data.reset(object);
		return data;
	}
	
	public static function put(data:FlickerData):Void
	{
		_pool.put(data);
	}
	
	public var object:FlxObject;
	public var startVisibility:Bool;
	
	private function new() {  }
	
	public function destroy():Void
	{
		object = null;
	}
	
	public function reset(object:FlxObject):Void
	{
		this.object = object;
		if (object != null)	this.startVisibility = object.visible;
	}
}