package flixel.input.touch;

#if FLX_TOUCH
import flash.events.TouchEvent;
import flash.Lib;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flixel.system.replay.TouchRecord;

/**
 * @author Zaphod
 */
class FlxTouchManager implements IFlxInputManager
{
	/**
	 * The maximum number of concurrent touch points supported by the current device.
	 */
	public static var maxTouchPoints:Int = 0;

	/**
	 * All active touches including just created, moving and just released.
	 */
	public var list:Array<FlxTouch>;

	/**
	 * Storage for inactive touches (some sort of cache for them).
	 */
	var _inactiveTouches:Array<FlxTouch>;

	/**
	 * Helper storage for active touches (for faster access)
	 */
	var _touchesCache:Map<Int, FlxTouch>;
	
	/**
	 * Helper for recording, a list of ids the touches that were active in the previously recorded frame.
	 */
	var _lastList:Array<Int>;
	
	/**
	 * WARNING: can be null if no active touch with the provided ID could be found
	 */
	public inline function getByID(TouchPointID:Int):FlxTouch
	{
		return _touchesCache.get(TouchPointID);
	}

	/**
	 * Return the first touch if there is one, beware of null
	 */
	public function getFirst():FlxTouch
	{
		if (list[0] != null)
		{
			return list[0];
		}
		else
		{
			return null;
		}
	}

	/**
	 * Clean up memory. Internal use only.
	 */
	@:noCompletion
	public function destroy():Void
	{
		for (touch in list)
		{
			touch.destroy();
		}
		list = null;
		_lastList = null;

		for (touch in _inactiveTouches)
		{
			touch.destroy();
		}
		_inactiveTouches = null;

		_touchesCache = null;
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

		var touchLen:Int = TouchArray.length;

		if (touchLen > 0)
		{
			TouchArray.splice(0, touchLen);
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

		var touchLen:Int = TouchArray.length;
		if (touchLen > 0)
		{
			TouchArray.splice(0, touchLen);
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
		for (key in _touchesCache.keys())
		{
			_touchesCache.remove(key);
		}

		for (touch in list)
		{
			touch.input.reset();
			_inactiveTouches.push(touch);
		}

		list.splice(0, list.length);
	}

	@:allow(flixel.FlxG)
	function new()
	{
		list = new Array<FlxTouch>();
		_lastList = new Array<Int>();
		_inactiveTouches = new Array<FlxTouch>();
		_touchesCache = new Map<Int, FlxTouch>();
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
		var touch:FlxTouch = _touchesCache.get(FlashEvent.touchPointID);
		if (touch != null)
		{
			touch.setXY(Std.int(FlashEvent.stageX), Std.int(FlashEvent.stageY));
		}
		else
		{
			touch = recycle(Std.int(FlashEvent.stageX), Std.int(FlashEvent.stageY), FlashEvent.touchPointID);
		}
		touch.input.press();
	}

	/**
	 * Event handler so FlxGame can update touches.
	 */
	function handleTouchEnd(FlashEvent:TouchEvent):Void
	{
		var touch:FlxTouch = _touchesCache.get(FlashEvent.touchPointID);

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
		var touch:FlxTouch = _touchesCache.get(FlashEvent.touchPointID);

		if (touch != null)
		{
			touch.setXY(Std.int(FlashEvent.stageX), Std.int(FlashEvent.stageY));
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
	function recycle(X:Int, Y:Int, PointID:Int):FlxTouch
	{
		if (_inactiveTouches.length > 0)
		{
			var touch:FlxTouch = _inactiveTouches.pop();
			touch.recycle(X, Y, PointID);
			return add(touch);
		}

		return add(new FlxTouch(X, Y, PointID));
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
	
	@:allow(flixel.system.replay.FlxReplay)
	function record():Null<Array<TouchRecord>>
	{
		var records:Null<Array<TouchRecord>> = null;
		
		var i:Int = _lastList.length;
		while (--i >= 0)
		{
			if (getByID(_lastList[i]) == null)
			{
				if (records == null)
				{
					records = [];
				}
				// Record the removal from the list
				records.push(new TouchRecord(_lastList[i], false));
				_lastList.splice(i, 1);
			}
		}
		
		i = list.length;
		while (--i >= 0)
		{
			var touch = list[i];
			var record = touch.record();
			if (record != null)
			{
				if (records == null)
				{
					records = [];
				}
				
				records.push(record);
			}
			
			// Save last recorded
			if (_lastList.indexOf(touch.touchPointID) == -1)
			{
				_lastList.push(touch.touchPointID);
			}
		}
		
		return records;
	}
	
	@:allow(flixel.system.replay.FlxReplay)
	function playback(records:Array<TouchRecord>):Void
	{
		var i:Int = records.length;
		
		while (--i >= 0)
		{
			var record = records[i];
			if (!record.active)
			{
				// remove inactive touch
				if (_touchesCache.exists(record.id))
				{
					var touch = getByID(record.id);
					// Copied from update
					touch.input.reset();
					_touchesCache.remove(touch.touchPointID);
					list.splice(i, 1);
					_inactiveTouches.push(touch);
				}
			}
			else
			{
				if (!_touchesCache.exists(record.id))
				{
					recycle(0, 0, record.id);
				}
				
				getByID(record.id).playback(record);
			}
		}
	}
}
#end
