package flixel.input.touch;

#if FLX_TOUCH
import flixel.util.FlxDestroyUtil;
import openfl.Lib;
import openfl.events.TouchEvent;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;

/**
 * @author Zaphod
 */
@:nullSafety(Strict)
class FlxTouchManager implements IFlxInputManager
{
	/**
	 * The maximum number of concurrent touch points supported by the current device.
	 */
	public static var maxTouchPoints(default, null):Int = 0;

	/**
	 * All active touches including just created, moving and just released.
	 */
	public final list:Array<FlxTouch> = [];

	/**
	 * Storage for inactive touches (some sort of cache for them).
	 */
	final _inactiveTouches:Array<FlxTouch> = [];

	/**
	 * Helper storage for active touches (for faster access)
	 */
	final _touchesCache:Map<Int, FlxTouch> = [];

	/**
	 * WARNING: can be null if no active touch with the provided ID could be found
	 */
	public inline function getByID(TouchPointID:Int):Null<FlxTouch>
	{
		return _touchesCache.get(TouchPointID);
	}

	/**
	 * Return the first touch if there is one, beware of null
	 */
	public function getFirst():Null<FlxTouch>
	{
		return list[0];
	}

	/**
	 * Clean up memory. Internal use only.
	 */
	@:noCompletion
	public function destroy():Void
	{
		_touchesCache.clear();
		FlxDestroyUtil.destroyArray(list);
		FlxDestroyUtil.destroyArray(_inactiveTouches);
	}

	/**
	 * Gets all touches which were just started
	 *
	 * @param	TouchArray	Optional array to fill with touch objects
	 * @return	Array with touches
	 */
	public function justStarted(?TouchArray:Array<FlxTouch>):Array<FlxTouch>
	{
		if (TouchArray == null)
		{
			TouchArray = new Array<FlxTouch>();
		}

		final touchLen:Int = TouchArray.length;
		if (touchLen > 0)
		{
			TouchArray.resize(0);
		}

		for (touch in list)
		{
			if (touch.justPressed)
			{
				TouchArray.push(touch);
			}
		}

		return TouchArray;
	}

	/**
	 * Gets all touches which were just ended
	 *
	 * @param	TouchArray	Optional array to fill with touch objects
	 * @return	Array with touches
	 */
	public function justReleased(?TouchArray:Array<FlxTouch>):Array<FlxTouch>
	{
		if (TouchArray == null)
		{
			TouchArray = new Array<FlxTouch>();
		}

		final touchLen:Int = TouchArray.length;
		if (touchLen > 0)
		{
			TouchArray.resize(0);
		}

		for (touch in list)
		{
			if (touch.justReleased)
			{
				TouchArray.push(touch);
			}
		}

		return TouchArray;
	}

	/**
	 * Resets all touches to inactive state.
	 */
	public function reset():Void
	{
		_touchesCache.clear();

		for (touch in list)
		{
			touch.input.reset();
			_inactiveTouches.push(touch);
		}

		list.resize(0);
	}

	@:allow(flixel.FlxG)
	function new()
	{
		maxTouchPoints = Multitouch.maxTouchPoints;
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

		Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, handleTouchBegin);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, handleTouchEnd);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, handleTouchMove);
	}

	/**
	 * Event handler so FlxGame can update touches.
	 */
	function handleTouchBegin(FlashEvent:TouchEvent):Void
	{
		var touch:Null<FlxTouch> = _touchesCache.get(FlashEvent.touchPointID);
		if (touch != null)
		{
			touch.setXY(Std.int(FlashEvent.stageX), Std.int(FlashEvent.stageY));
			touch.pressure = FlashEvent.pressure;
		}
		else
		{
			touch = recycle(Std.int(FlashEvent.stageX), Std.int(FlashEvent.stageY), FlashEvent.touchPointID, FlashEvent.pressure);
		}
		touch.input.press();
	}

	/**
	 * Event handler so FlxGame can update touches.
	 */
	function handleTouchEnd(FlashEvent:TouchEvent):Void
	{
		final touch:Null<FlxTouch> = _touchesCache.get(FlashEvent.touchPointID);

		if (touch != null)
		{
			touch.input.release();
		}
	}

	/**
	 * Event handler so FlxGame can update touches.
	 */
	function handleTouchMove(FlashEvent:TouchEvent):Void
	{
		final touch:Null<FlxTouch> = _touchesCache.get(FlashEvent.touchPointID);

		if (touch != null)
		{
			touch.setXY(Std.int(FlashEvent.stageX), Std.int(FlashEvent.stageY));
			touch.pressure = FlashEvent.pressure;
		}
	}

	/**
	 * Internal function for adding new touches to the manager
	 *
	 * @param	Touch	A new FlxTouch object
	 * @return	The added FlxTouch object
	 */
	function add(Touch:FlxTouch):FlxTouch
	{
		list.push(Touch);
		_touchesCache.set(Touch.touchPointID, Touch);
		return Touch;
	}

	/**
	 * Internal function for touch reuse
	 *
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageY touch coordinate
	 * @param	PointID		id of the touch
	 * @return	A recycled touch object
	 */
	function recycle(X:Int, Y:Int, PointID:Int, pressure:Float):FlxTouch
	{
		if (_inactiveTouches.length > 0)
		{
			@:nullSafety(Off)
			final touch:FlxTouch = _inactiveTouches.pop();
			touch.recycle(X, Y, PointID, pressure);
			return add(touch);
		}
		return add(new FlxTouch(X, Y, PointID, pressure));
	}

	/**
	 * Called by the internal game loop to update the touch position in the game world.
	 * Also updates the just pressed/just released flags.
	 */
	function update():Void
	{
		var i:Int = list.length - 1;
		var touch:FlxTouch;

		while (i >= 0)
		{
			touch = list[i];

			// Touch ended at previous frame
			if (touch.released && !touch.justReleased)
			{
				touch.input.reset();
				_touchesCache.remove(touch.touchPointID);
				list.splice(i, 1);
				_inactiveTouches.push(touch);
			}
			else // Touch is active currently
			{
				touch.update();
			}

			i--;
		}
	}

	function onFocus():Void {}

	function onFocusLost():Void
	{
		reset();
	}
}
#end
