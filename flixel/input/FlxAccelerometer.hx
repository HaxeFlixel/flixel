package flixel.system.input;

#if mobile
import flash.events.AccelerometerEvent;
import flash.sensors.Accelerometer;

class FlxAccelerometer {
	public var x(default, null):Float = 0;
	public var y(default, null):Float = 0;
	public var z(default, null):Float = 0;
	public var isSupported(get, never):Bool;
	private var sensor:Accelerometer;
	
	public function new() 
	{
		if (Accelerometer.isSupported) {
			sensor = new Accelerometer();
			sensor.addEventListener(AccelerometerEvent.UPDATE, updateCallback);
		}
	}
	
	inline function get_isSupported():Bool 
	{
		return Accelerometer.isSupported;
	}
	
	
	private function updateCallback(event:AccelerometerEvent):Void 
	{
		x = event.accelerationX;
		y = event.accelerationY;
		z = event.accelerationZ;
	}
}
#end