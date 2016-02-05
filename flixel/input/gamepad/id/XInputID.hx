package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepad;

/**
 * IDs for generic XInput controllers
 * 
 * Compatible with the Xbox 360 controller, the Xbox One controller, and anything that masquerades as either of those.
 *
 *-------
 * NOTES
 *-------
 *
 * WINDOWS: we assume the user is using the default drivers that ship with windows.
 *
 * LINUX: we assume the user is using the xpad driver, specifically Valve's version, steamos-xpad-dkms
 * (we got weird errors when using xboxdrv). For full instructions on installation, see:
 * http://askubuntu.com/questions/165210/how-do-i-get-an-xbox-360-controller-working/441548#441548
 *
 * MAC: we assume the user is using the 360 Controller driver, specifically this one:
 * https://github.com/360Controller/360Controller/releases
 */


class XInputID
{
	public static inline var SUPPORTS_MOTION = false;
	public static inline var SUPPORTS_POINTER = false;
	
	public static inline function getFlipAxis(AxisID:Int):Int 
	{ 
		#if flash
			return switch(AxisID) {
				case LEFT_ANALOG_STICK_V: -1;
				case RIGHT_ANALOG_STICK_V: -1;
				default: 1;
			}
		#else
			return 1; 
		#end
	}

	public static function isAxisForMotion(ID:FlxGamepadInputID):Bool { return false; }
	
	#if flash
		
		// Button IDs
		public static inline var A:Int = 4;
		public static inline var B:Int = 5;
		public static inline var X:Int = 6;
		public static inline var Y:Int = 7;
		public static inline var LB:Int = 8;
		public static inline var RB:Int = 9;
		
		public static inline var BACK:Int = 12;
		public static inline var GUIDE:Int = -1;
		public static inline var START:Int = 13;
		
		public static inline var LEFT_STICK_CLICK:Int = 14;
		public static inline var RIGHT_STICK_CLICK:Int = 15;
		
		public static inline var DPAD_UP:Int = 16;
		public static inline var DPAD_DOWN:Int = 17;
		public static inline var DPAD_LEFT:Int = 18;
		public static inline var DPAD_RIGHT:Int = 19;
		
		// Axis indices
		public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
		public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);
		
		public static inline var LEFT_TRIGGER:Int = 10;
		public static inline var RIGHT_TRIGGER:Int = 11;
		
		public static inline var LEFT_ANALOG_STICK_H = 0;
		public static inline var LEFT_ANALOG_STICK_V = 1;
		public static inline var RIGHT_ANALOG_STICK_H = 2;
		public static inline var RIGHT_ANALOG_STICK_V = 3;
		
	#elseif FLX_GAMEINPUT_API
		
		// Button IDs
		public static inline var A:Int = 6;
		public static inline var B:Int = 7;
		public static inline var X:Int = 8;
		public static inline var Y:Int = 9;
	
		public static inline var BACK:Int = 10;
		#if mac
		public static inline var GUIDE:Int = 11;
		#else
		public static inline var GUIDE:Int = -1;
		#end
		public static inline var START:Int = 12;
	
		public static inline var LEFT_STICK_CLICK:Int = 13;
		public static inline var RIGHT_STICK_CLICK:Int = 14;
	
		public static inline var LB:Int = 15;
		public static inline var RB:Int = 16;
	
		public static inline var DPAD_UP:Int = 17;
		public static inline var DPAD_DOWN:Int = 18;
		public static inline var DPAD_LEFT:Int = 19;
		public static inline var DPAD_RIGHT:Int = 20;
	
		// Axis indices
		public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
		public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);
	
		public static inline var LEFT_TRIGGER:Int = 4;
		public static inline var RIGHT_TRIGGER:Int = 5;
	
		
	#elseif FLX_JOYSTICK_API
		
		#if (windows || linux)
		
			// Button IDs
			public static inline var A:Int = 0;
			public static inline var B:Int = 1;
			public static inline var X:Int = 2;
			public static inline var Y:Int = 3;
			
			public static inline var LB:Int = 4;
			public static inline var RB:Int = 5;
			
			public static inline var BACK:Int = 6;
			public static inline var START:Int = 7;
			
			#if linux

			public static inline var LEFT_STICK_CLICK:Int = 9;
			public static inline var RIGHT_STICK_CLICK:Int = 10;
			public static inline var GUIDE:Int = 8;

			#elseif windows

			public static inline var LEFT_STICK_CLICK:Int = 8;
			public static inline var RIGHT_STICK_CLICK:Int = 9;
			public static inline var GUIDE:Int = 10;

			#end
			
			//"fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
			public static inline var DPAD_UP:Int = 11;
			public static inline var DPAD_DOWN:Int = 12;
			public static inline var DPAD_LEFT:Int = 13;
			public static inline var DPAD_RIGHT:Int = 14;
			
			// Axis indices
			public static inline var LEFT_TRIGGER:Int = 2;
			public static inline var RIGHT_TRIGGER:Int = 5;
			
			public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
			public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(3, 4);
		
		#elseif mac
			
			// Button IDs
			public static inline var A:Int = 0;
			public static inline var B:Int = 1;
			public static inline var X:Int = 2;
			public static inline var Y:Int = 3;
			
			public static inline var LB:Int = 4;
			public static inline var RB:Int = 5;
			
			public static inline var LEFT_STICK_CLICK:Int = 6;
			public static inline var RIGHT_STICK_CLICK:Int = 7;
			
			public static inline var BACK:Int = 9;
			public static inline var START:Int = 8;
			
			public static inline var GUIDE:Int = 10;
			
			public static inline var DPAD_UP:Int = 11;
			public static inline var DPAD_DOWN:Int = 12;
			public static inline var DPAD_LEFT:Int = 13;
			public static inline var DPAD_RIGHT:Int = 14;
			
			// Axis indices
			public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
			public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(3, 4);
			public static inline var LEFT_TRIGGER:Int = 2;
			public static inline var RIGHT_TRIGGER:Int = 5;
		
		#end
		
		//Analog stick and trigger values overlap with regular buttons so we remap to "fake" button ID's
		public static function axisIndexToRawID(index:Int):Int
		{
			return   if (index == LEFT_ANALOG_STICK.x) LEFT_ANALOG_STICK_FAKE_X;
				else if (index == LEFT_ANALOG_STICK.y) LEFT_ANALOG_STICK_FAKE_Y;
				else if (index == RIGHT_ANALOG_STICK.x) RIGHT_ANALOG_STICK_FAKE_X;
				else if (index == RIGHT_ANALOG_STICK.y) RIGHT_ANALOG_STICK_FAKE_Y;
				else if (index == LEFT_TRIGGER) LEFT_TRIGGER_FAKE;
				else if (index == RIGHT_TRIGGER) RIGHT_TRIGGER_FAKE;
				else index;
		}
		
		//"fake" IDs
		public static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 15;
		public static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 16;
		
		public static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 17;
		public static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 18;
		
		public static inline var LEFT_TRIGGER_FAKE:Int = 19;
		public static inline var RIGHT_TRIGGER_FAKE:Int = 20;
		
	#end
}
