package flixel.util.helpers;

import flixel.FlxObject;
import flixel.util.FlxPool;

class FlickerData
{
	private static var _pool:FlxPool<FlickerData> = new FlxPool<FlickerData>();
	
	public static function recycle(Object:FlxObject, ?ForceVisible:Bool):FlickerData
	{
		var data:FlickerData = _pool.get();
		data.reset(Object, ForceVisible);
		return data;
	}
	
	public static function put(Data:FlickerData):Void
	{
		_pool.put(Data);
	}
	
	public var object:FlxObject;
	public var startVisibility:Bool;
	
	private function new() {  }
	
	public function destroy():Void
	{
		object = null;
	}
	
	public function reset(Object:FlxObject, ?ForceVisible:Bool):Void
	{
		this.object = Object;
		if (Object != null)
		{
			if(ForceVisible == null)
			{
				startVisibility = Object.visible;
			}
			else
			{
				ForceVisible ? startVisibility = true : startVisibility = Object.visible;
			}
		}
	}
}