package org.flixel.system.input;

import nme.ui.MultitouchInputMode;
import nme.ui.Multitouch;
import org.flixel.FlxG;
import nme.Lib;
import nme.geom.Point;
import org.flixel.FlxGame;
import nme.events.TouchEvent;

/**
 * ...
 * @author Zaphod
 */

class FlxTouchManager implements IFlxInput
{
	
	/**
	 * The maximum number of concurrent touch points supported by the current device.
	 */
	public static var maxTouchPoints:Int = 0;
	
	/**
	 * All active touches including just created, moving and just released.
	 */
	public var touches:Array<FlxTouch>;
	
	/**
	 * Storage for inactive touches (some sort of cache for them).
	 */
	private var _inactiveTouches:Array<FlxTouch>;
	
	/**
	 * Helper storage for active touches (for faster access)
	 */
	private var _touchesCache:IntHash<FlxTouch>;
	
	/**
	 * Constructor
	 */
	public function new() 
	{
		touches = new Array<FlxTouch>();
		_inactiveTouches = new Array<FlxTouch>();
		_touchesCache = new IntHash<FlxTouch>();
		maxTouchPoints = Multitouch.maxTouchPoints;
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		FlxG.supportsTouchEvents = true;
		
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, handleTouchBegin);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, handleTouchEnd);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, handleTouchMove);
	}
	
	/**
	 * Return the first touch if there is one, beware of null
	 */
	public function getFirstTouch():FlxTouch
	{
		if (touches[0] != null)
			return touches[0];
		else
			return null;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		for (touch in touches)
		{
			touch.destroy();
		}
		touches = null;
		
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
		var i:Int = touches.length - 1;
		var touch:FlxTouch;
		while (i >= 0)
		{
			touch = touches[i];
			
			// Touch ended at previous frame
			if (touch._current == 0)
			{
				touch.deactivate();
				_touchesCache.remove(touch.touchPointID);
				touches.splice(i, 1);
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
		
		for (touch in touches)
		{
			touch.deactivate();
			_inactiveTouches.push(touch);
		}
		
		touches.splice(0, touches.length);
	}
	
	/**
	 * Event handler so FlxGame can update touches.
	 * @param	FlashEvent	A <code>TouchEvent</code> object.
	 */
	public function handleTouchBegin(FlashEvent:TouchEvent):Void
	{
		var touch:FlxTouch = _touchesCache.get(FlashEvent.touchPointID);
		if (touch != null)
		{
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
	public function handleTouchEnd(FlashEvent:TouchEvent):Void
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
	public function handleTouchMove(FlashEvent:TouchEvent):Void
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
	public function justStartedTouches(TouchArray:Array<FlxTouch> = null):Array<FlxTouch>
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
		
		for (touch in touches)
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
	public function justReleasedTouches(TouchArray:Array<FlxTouch> = null):Array<FlxTouch>
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
		
		for (touch in touches)
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
	 * @param	touch	new touch object
	 * @return			added touch object
	 */
	private function add(touch:FlxTouch):FlxTouch
	{
		touches.push(touch);
		_touchesCache.set(touch.touchPointID, touch); 
		return touch;
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