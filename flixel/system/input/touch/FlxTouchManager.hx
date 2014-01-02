package flixel.system.input.touch;

import flash.ui.MultitouchInputMode;
import flash.ui.Multitouch;
import flixel.FlxG;
import flash.Lib;
import flash.geom.Point;
import flixel.FlxGame;
import flash.events.TouchEvent;
import flixel.system.input.IFlxInput;

/**
 * ...
 * @author Zaphod
 */
class FlxTouchManager implements IFlxInput
{
	/**
	 * The maximum number of concurrent touch points supported by the current device.
	 */
	static public var maxTouchPoints:Int = 0;
	
	/**
	 * All active touches including just created, moving and just released.
	 */
	public var list:Array<FlxTouch>;
	
	/**
	 * Storage for inactive touches (some sort of cache for them).
	 */
	private var _inactiveTouches:Array<FlxTouch>;
	/**
	 * Helper storage for active touches (for faster access)
	 */
	private var _touchesCache:Map<Int, FlxTouch>;
	
	/**
	 * Constructor
	 */
	public function new() 
	{
		list = new Array<FlxTouch>();
		_inactiveTouches = new Array<FlxTouch>();
		_touchesCache = new Map<Int, FlxTouch>();
		maxTouchPoints = Multitouch.maxTouchPoints;
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, handleTouchBegin);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, handleTouchEnd);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, handleTouchMove);
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
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		for (touch in list)
		{
			touch.destroy();
		}
		list = null;
		
		for (touch in _inactiveTouches)
		{
			touch.destroy();
		}
		_inactiveTouches = null;
		
		_touchesCache = null;
	}
	
	/**
	 * Called by the internal game loop to update the touch position in the game world.
	 * Also updates the just pressed/just released flags.
	 */
	public function update():Void
	{
		var i:Int = list.length - 1;
		var touch:FlxTouch;
		
		while (i >= 0)
		{
			touch = list[i];
			
			// Touch ended at previous frame
			if (touch._current == 0)
			{
				touch.deactivate();
				_touchesCache.remove(touch.touchPointID);
				list.splice(i, 1);
				_inactiveTouches.push(touch);
			}
			else	// Touch is active currently
			{
				touch.update();
			}
			
			i--;
		}
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
			touch.deactivate();
			_inactiveTouches.push(touch);
		}
		
		list.splice(0, list.length);
	}
	
	/**
	 * Event handler so FlxGame can update touches.
	 * @param	FlashEvent	A <code>TouchEvent</code> object.
	 */
	private function handleTouchBegin(FlashEvent:TouchEvent):Void
	{
		var touch:FlxTouch = _touchesCache.get(FlashEvent.touchPointID);
		if (touch != null)
		{
			touch.updateTouchPosition(FlashEvent.stageX, FlashEvent.stageY); 
			
			if (touch._current > 0) 
			{
				touch._current = 1;
			}
			else 
			{
				touch._current = 2;
			}
		}
		else
		{
			touch = recycle(FlashEvent.stageX, FlashEvent.stageY, FlashEvent.touchPointID);
			touch._current = 2;
		}
	}
	
	/**
	 * Event handler so FlxGame can update touches.
	 * @param	FlashEvent	A <code>TouchEvent</code> object.
	 */
	private function handleTouchEnd(FlashEvent:TouchEvent):Void
	{
		var touch:FlxTouch = _touchesCache.get(FlashEvent.touchPointID);
		
		if (touch != null)
		{
			if (touch._current > 0) 
			{
				touch._current = -1;
			}
			else 
			{
				touch._current = 0;
			}
		}
	}
	
	/**
	 * Event handler so FlxGame can update touches.
	 * @param	FlashEvent	A <code>TouchEvent</code> object.
	 */
	private function handleTouchMove(FlashEvent:TouchEvent):Void
	{
		var touch:FlxTouch = _touchesCache.get(FlashEvent.touchPointID);
		
		if (touch != null)
		{
			touch.updateTouchPosition(FlashEvent.stageX, FlashEvent.stageY); 
		}
	}
	
	/**
	 * Gets all touches which were just started
	 * @param	TouchArray		optional array to fill with touch objects
	 * @return					array with touches
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
			if (touch._current == 2)
			{
				TouchArray.push(touch);
			}
		}
		
		return TouchArray;
	}
	
	/**
	 * Gets all touches which were just ended
	 * @param	TouchArray		optional array to fill with touch objects
	 * @return					array with touches
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
			if (touch._current == -1)
			{
				TouchArray.push(touch);
			}
		}
		
		return TouchArray;
	}
	
	/**
	 * Internal function for adding new touches to the manager
	 * @param	Touch	A new FlxTouch object
	 * @return	The added FlxTouch object
	 */
	private function add(Touch:FlxTouch):FlxTouch
	{
		list.push(Touch);
		_touchesCache.set(Touch.touchPointID, Touch); 
		return Touch;
	}
	
	/**
	 * Internal function for touch reuse
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageY touch coordinate
	 * @param	PointID		id of the touch
	 * @return				recycled touch object
	 */
	private function recycle(X:Float, Y:Float, PointID:Int):FlxTouch
	{
		if (_inactiveTouches.length > 0)
		{
			var touch:FlxTouch = _inactiveTouches.pop();
			touch.reset(X, Y, PointID);
			return add(touch);
		}
		
		return add(new FlxTouch(X, Y, PointID));
	}

	public function onFocus( ):Void
	{
		
	}

	public function onFocusLost( ):Void
	{
		reset();
	}

	public function toString( ):String
	{
		return 'FlxTouchManager';
	}


}