package flixel.input;

#if mobile
import flash.events.AccelerometerEvent;
import flash.sensors.Accelerometer;

/**
 * A class providing access to the accelerometer data of the mobile device.
 */
class FlxAccelerometer 
{
	/**
	 * The x-axis value, in Gs (1G is roughly 9.8m/s/s), usually between -1 and 1.
	 * The x-axis runs from the left to the right of the device in upright position. The acceleration is positive if the device is moving to the right.
	 */
	public var x(default, null):Float = 0;
	/**
	 * The y-axis value, in Gs (1G is roughly 9.8m/s/s), usually between -1 and 1.
	 * The y-axis runs from the bottom to the top of the device in upright position. The acceleration is positive if the device is moving up along this axis.
	 */
	public var y(default, null):Float = 0;
	/**
	 * The z-axis value, in Gs (1G is roughly 9.8m/s/s), usually between -1 and 1.
	 * The z-axis runs perpendicular to the screen of the device. The acceleration is positive if the device is moving the direction the screen is facing.
	 */
	public var z(default, null):Float = 0;
	
	/**
	 * Wether the accelerometer is supported on this mobile device
	 */
	public var isSupported(get, never):Bool;
	
	private var _sensor:Accelerometer;
	
	public function new() 
	{
		if (Accelerometer.isSupported) 
		{
			_sensor = new Accelerometer();
			_sensor.addEventListener(AccelerometerEvent.UPDATE, updateCallback);
		}
	}
	
	inline function get_isSupported():Bool 
	{
		return Accelerometer.isSupported;
	}
	
	private function updateCallback(Event:AccelerometerEvent):Void 
	{
		#if android
		x = Event.accelerationX;
		y = Event.accelerationY;
		z = Event.accelerationZ;
		#else //Values on iOS and BlackBerry are inverted
		x = -Event.accelerationX;
		y = -Event.accelerationY;
		z = -Event.accelerationZ;
		#end
	}
}
#end