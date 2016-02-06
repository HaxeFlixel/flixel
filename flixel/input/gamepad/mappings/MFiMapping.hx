package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.MFiID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;

class MFiMapping extends FlxGamepadMapping
{
	override function initValues():Void 
	{
		leftStick = MFiID.LEFT_ANALOG_STICK;
		rightStick = MFiID.RIGHT_ANALOG_STICK;
	}
	
	override public function getID(rawID:Int):FlxGamepadInputID 
	{
		return switch (rawID)
		{
			case MFiID.A: A;
			case MFiID.B: B;
			case MFiID.X: X;
			case MFiID.Y: Y;
			case MFiID.BACK: BACK;
			case MFiID.GUIDE: GUIDE;
			case MFiID.START: START;
			case MFiID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case MFiID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case MFiID.LB: LEFT_SHOULDER;
			case MFiID.RB: RIGHT_SHOULDER;
			case MFiID.DPAD_UP: DPAD_UP;
			case MFiID.DPAD_DOWN: DPAD_DOWN;
			case MFiID.DPAD_LEFT: DPAD_LEFT;
			case MFiID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	override public function getRawID(ID:FlxGamepadInputID):Int 
	{
		return switch (ID)
		{
			case A: MFiID.A;
			case B: MFiID.B;
			case X: MFiID.X;
			case Y: MFiID.Y;
			case BACK: MFiID.BACK;
			case GUIDE: MFiID.GUIDE;
			case START: MFiID.START;
			case LEFT_STICK_CLICK: MFiID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: MFiID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: MFiID.LB;
			case RIGHT_SHOULDER: MFiID.RB;
			case DPAD_UP: MFiID.DPAD_UP;
			case DPAD_DOWN: MFiID.DPAD_DOWN;
			case DPAD_LEFT: MFiID.DPAD_LEFT;
			case DPAD_RIGHT: MFiID.DPAD_RIGHT;
			case LEFT_TRIGGER:  MFiID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: MFiID.RIGHT_TRIGGER;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: MFiID.LEFT_TRIGGER;
			case RIGHT_TRIGGER_FAKE: MFiID.RIGHT_TRIGGER;
			#end
			default: -1;
		}
	}
	
	#if FLX_JOYSTICK_API
	override public function axisIndexToRawID(axisID:Int):Int 
	{
		//the axis index values for this don't overlap with anything so we can just return the original values!
		return axisID;
	}
	#end
}