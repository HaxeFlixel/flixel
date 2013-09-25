package flixel.util.helpers;

import flixel.FlxObject;
import flixel.util.FlxPool;

class FlickerData
{
	private static var _pool:FlxPool<FlickerData> = new FlxPool<FlickerData>();

	public var object:FlxObject;
	public var endVisibility:Bool;

	private function new() {  }

	public static function recycle(Object:FlxObject, EndVisibility:Bool = true):FlickerData
	{
		var data:FlickerData = _pool.get();
		data.reset(Object, EndVisibility);
		return data;
	}
	
	public static function put(Data:FlickerData):Void
	{
		_pool.put(Data);
	}
	
	public function destroy():Void
	{
		object = null;
	}
	
	public function reset(Object:FlxObject, EndVisibility:Bool = true):Void
	{
		this.object = Object;
		if (Object != null)
		{
			endVisibility = EndVisibility;
		}
	}
}