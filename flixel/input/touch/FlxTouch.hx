package flixel.input.touch;

#if FLX_TOUCH
import flash.events.TouchEvent;
import flash.geom.Point;
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.FlxSwipe;
import flixel.input.IFlxInput;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.system.replay.TouchRecord;

/**
 * Helper class, contains and tracks touch points in your game.
 * Automatically accounts for parallax scrolling, etc.
 */
@:allow(flixel.input.touch.FlxTouchManager)
@:allow(flixel.system.replay.TouchRecord)
class FlxTouch extends FlxPointer implements IFlxDestroyable implements IFlxInput
{
	/**
	 * The _unique_ ID of this touch. You should not make not any further assumptions
	 * about this value - IDs are not guaranteed to start from 0 or ascend in order.
	 * The behavior may vary from device to device.
	 */
	public var touchPointID(get, never):Int;

	/**
	 * A value between 0.0 and 1.0 indicating force of the contact with the device. If the device
	 * does not support detecting the pressure, the value is 1.0.
	 */
	public var pressure(get, never):Float;

	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;

	/**
	 * The digital input. Note: we can't just use pressure because 0 pressure could still be a tap
	 */
	var input:FlxInput<Int>;
	var inputPressure:FlxAnalogInput<Int>;
	var flashPoint = new Point();

	public var justPressedPosition(default, null) = FlxPoint.get();
	public var justPressedTimeInTicks(default, null):Int = -1;

	public function destroy():Void
	{
		input = null;
		inputPressure = null;
		justPressedPosition = FlxDestroyUtil.put(justPressedPosition);
		flashPoint = null;
	}

	/**
	 * Resets the justPressed/justReleased flags, sets touch to not pressed and sets touch pressure to 0.
	 */
	public function recycle(x:Int, y:Int, pointID:Int, pressure:Float):Void
	{
		setXY(x, y);
		input.ID = pointID;
		input.reset();
		inputPressure.reset();
		inputPressure.change(pressure);
	}

	/**
	 * @param   x         stageX touch coordinate
	 * @param   y         stageX touch coordinate
	 * @param   pointID   touchPointID of the touch
	 * @param   pressure  A value between 0.0 and 1.0 indicating force of the contact with the device.
	 *                    If the device does not support detecting the pressure, the value is 1.0.
	 */
	function new(x = 0.0, y = 0.0, pointID = 0, pressure = 0.0)
	{
		super();

		input = new FlxInput(pointID);
		inputPressure = new FlxAnalogInput(pointID, false);
		setData(x, y, pressure);
	}
	
	function setData(x:Float, y:Float, pressure:Float)
	{
		setXY(Std.int(x), Std.int(y));
		inputPressure.change(pressure);
	}

	/**
	 * Called by the internal game loop to update the just pressed/just released flags.
	 */
	override function update()
	{
		super.update();
		
		input.update();
		inputPressure.update();

		if (justPressed)
		{
			justPressedPosition.set(screenX, screenY);
			justPressedTimeInTicks = FlxG.game.ticks;
		}
		#if FLX_POINTER_INPUT
		else if (justReleased)
		{
			FlxG.swipes.push(new FlxSwipe(touchPointID, justPressedPosition, getScreenPosition(), justPressedTimeInTicks));
		}
		#end
	}

	/**
	 * Function for updating touch coordinates. Called by the TouchManager.
	 *
	 * @param   x  stageX touch coordinate
	 * @param   y  stageY touch coordinate
	 */
	function setXY(x:Int, y:Int):Void
	{
		flashPoint.setTo(x, y);
		flashPoint = FlxG.game.globalToLocal(flashPoint);

		setGlobalScreenPositionUnsafe(flashPoint.x, flashPoint.y);
	}

	inline function get_touchPointID():Int
	{
		return input.ID;
	}

	inline function get_justReleased():Bool
	{
		return input.justReleased;
	}

	inline function get_released():Bool
	{
		return input.released;
	}

	inline function get_pressed():Bool
	{
		return input.pressed;
	}

	inline function get_justPressed():Bool
	{
		return input.justPressed;
	}
	
	inline function get_pressure():Float
	{
		return inputPressure.currentValue;
	}
	
	function record():Null<TouchRecord>
	{
		if (!inputX.changed && !inputY.changed && !input.changed)
		{
			return null;
		}
		
		var record = new TouchRecord(touchPointID);
		if (input.justPressed)
		{
			// Always record x and y when starting a new touch
			record.x = Std.int(currentX);
			record.y = Std.int(currentY);
			record.pressed = input.currentValue;
			record.pressure = inputPressure.currentValue;
		}
		else 
		{
			if (inputX.changed)
				record.x = Std.int(currentX);
			
			if (inputY.changed)
				record.y = Std.int(currentY);
			
			if (input.changed)
				record.pressed = input.currentValue;
			
			if (inputPressure.changed)
				record.pressure = inputPressure.currentValue;
		}
		return record;
	}
	
	function playback(record:TouchRecord):Void
	{
		if (record.x != null || record.y != null)
		{
			if (record.x != null) inputX.change(record.x);
			if (record.y != null) inputY.change(record.y);
			updatePositions();
		}
		
		if (record.pressure != null)
			inputPressure.change(record.pressure);
		
		if (record.pressed != null)
		{
			// Manually dispatch a touch event so that, e.g., FlxButtons click correctly on playback.
			// Note: some clicks are fast enough to not pass through a frame where they are PRESSED
			// and JUST_RELEASED is swallowed by FlxButton and others, but not third-party code
			if (input.lastValue && !record.pressed)
			{
				FlxG.stage.dispatchEvent(new FakeTouchEndEvent(record.id, currentX, currentY, pressure));
			}
			
			input.change(record.pressed);
		}
		
		// Copied from update()
		if (justPressed)
		{
			justPressedPosition.set(screenX, screenY);
			justPressedTimeInTicks = FlxG.game.ticks;
		}
		#if FLX_POINTER_INPUT
		else if (justReleased)
		{
			FlxG.swipes.push(new FlxSwipe(touchPointID, justPressedPosition, getScreenPosition(), justPressedTimeInTicks));
		}
		#end
	}
}

abstract FakeTouchEndEvent(TouchEvent) to TouchEvent
{
	inline public function new (id:Int, x:Float, y:Float, pressure:Float)
	{
		this = new TouchEvent(TouchEvent.TOUCH_END, true, false, id, false, x, y, 0, 0, pressure);
	}
}

#else
class FlxTouch {}
#end
