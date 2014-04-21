package flixel.input;

#if mobile
import flash.events.AccelerometerEvent;
import flash.sensors.Accelerometer;

/**
 * A class providing access to the accelerometer data of the mobile device.
 */
class FlxAccelerometer {
	
	/**
	 * The x-axis value, in G (Multiples of 9.8m/s/s)
	 */
	public var x(default, null):Float = 0;
	/**
	 * The y-axis value, in G (Multiples of 9.8m/s/s)
	 */
	public var y(default, null):Float = 0;
	/**
	 * The z-axis value, in G (Multiples of 9.8m/s/s)
	 */
	public var z(default, null):Float = 0;
	
	/**
	 * Wether the accelerometer is supported on this mobile device
	 */
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