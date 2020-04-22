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
class FlxTouch extends FlxPointer implements IFlxDestroyable implements IFlxInput
{
	/**
	 * The _unique_ ID of this touch. You should not make not any further assumptions
	 * about this value - IDs are not guaranteed to start from 0 or ascend in order.
	 * The behavior may vary from device to device.
	 */
	public var touchPointID(get, never):Int;

	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;

	var input:FlxInput<Int>;
	var flashPoint = new Point();

	public var justPressedPosition(default, null) = FlxPoint.get();
	public var justPressedTimeInTicks(default, null):Int = -1;

	public function destroy():Void
	{
		input = null;
		justPressedPosition = FlxDestroyUtil.put(justPressedPosition);
		flashPoint = null;
	}

	/**
	 * Resets the justPressed/justReleased flags and sets touch to not pressed.
	 */
	public function recycle(x:Int, y:Int, pointID:Int):Void
	{
		setXY(x, y);
		input.ID = pointID;
		input.reset();
	}

	/**
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageX touch coordinate
	 * @param	PointID		touchPointID of the touch
	 */
	function new(x:Int = 0, y:Int = 0, pointID:Int = 0)
	{
		super();

		input = new FlxInput(pointID);
		setXY(x, y);
	}

	/**
	 * Called by the internal game loop to update the just pressed/just released flags.
	 */
	override function update():Void
	{
		super.update();
		
		input.update();

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
	 * @param	X	stageX touch coordinate
	 * @param	Y	stageY touch coordinate
	 */
	function setXY(X:Int, Y:Int):Void
	{
		flashPoint.setTo(X, Y);
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
	
	@:access(flixel.system.replay.TouchRecord)
	function record():Null<TouchRecord>
	{
		if (!_globalScreenX.changed && !_globalScreenY.changed && !input.changed)
		{
			return null;
		}

		var record:TouchRecord = new TouchRecord(touchPointID);
		if (input.justPressed)
		{
			// Always record x and y when starting a new touch
			record.x = Std.int(_globalScreenX.currentValue);
			record.y = Std.int(_globalScreenY.currentValue);
			record.pressed = input.currentValue;
		}
		else 
		{
			if (_globalScreenX.changed)
				record.x = Std.int(_globalScreenX.currentValue);
			if (_globalScreenY.changed)
				record.y = Std.int(_globalScreenY.currentValue);
			if (input.changed)
				record.pressed = input.currentValue;
		}
		return record;
	}
	
	function playback(record:TouchRecord):Void
	{
		if (record.x != null || record.y != null)
		{
			if (record.x != null) _globalScreenX.change(record.x);
			if (record.y != null) _globalScreenY.change(record.y);
			updatePositions();
		}

		if (record.pressed != null)
		{
			// Manually dispatch a touch event so that, e.g., FlxButtons click correctly on playback.
			// Note: some clicks are fast enough to not pass through a frame where they are PRESSED
			// and JUST_RELEASED is swallowed by FlxButton and others, but not third-party code
			if (input.lastValue == true && record.pressed == false)
			{
				FlxG.stage.dispatchEvent(
					new TouchEvent(TouchEvent.TOUCH_END, true, false, record.id, false, _globalScreenX.currentValue, _globalScreenY.currentValue)
				);
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
#else
class FlxTouch {}
#end
