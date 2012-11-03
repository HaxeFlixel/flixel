package org.flixel.system.input;

import nme.geom.Point;
import org.flixel.FlxG;
import nme.events.TouchEvent;

/**
 * ...
 * @author Zaphod
 */

class TouchManager 
{
	
	/**
	 * All active touches including just created, moving and just released.
	 */
	public var touches:Array<Touch>;
	
	/**
	 * Storage for inactive touches (some sort of cache for them).
	 */
	private var _inactiveTouches:Array<Touch>;
	
	/**
	 * Helper storage for active touches (for faster access)
	 */
	private var _touchesCache:IntHash<Touch>;
	
	/**
	 * Constructor
	 */
	public function new() 
	{
		touches = new Array<Touch>();
		_inactiveTouches = new Array<Touch>();
		_touchesCache = new IntHash<Touch>();
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
		var touch:Touch;
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
		var touch:Touch = _touchesCache.get(FlashEvent.touchPointID);
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
		var touch:Touch = _touchesCache.get(FlashEvent.touchPointID);
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
		var touch:Touch = _touchesCache.get(FlashEvent.touchPointID);
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
	public function justStartedTouches(TouchArray:Array<Touch> = null):Array<Touch>
	{
		if (TouchArray == null)
		{
			TouchArray = new Array<Touch>();
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
	public function justReleasedTouches(TouchArray:Array<Touch> = null):Array<Touch>
	{
		if (TouchArray == null)
		{
			TouchArray = new Array<Touch>();
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
	private function add(touch:Touch):Touch
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
	private function recycle(X:Float, Y:Float, PointID:Int):Touch
	{
		if (_inactiveTouches.length > 0)
		{
			var touch:Touch = _inactiveTouches.pop();
			touch.reset(X, Y, PointID);
			return add(touch);
		}
		
		return add(new Touch(X, Y, PointID));
	}
	
}