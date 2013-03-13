package org.flixel.system.input;

import nme.events.TouchEvent;
import nme.geom.Point;

import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxPoint;

/**
 * Helper class, contains and track touch points in your game.
 * Automatically accounts for parallax scrolling, etc.
 */
class FlxTouch extends FlxPoint
{
	
	/**
	 * A unique identification number (as an Int) assigned to the touch point. 
	 */
	private var _touchPointID:Int;
	
	/**
	 * Current X position of the touch point on the screen.
	 */
	public var screenX:Int;
	/**
	 * Current Y position of the touch point on the screen.
	 */
	public var screenY:Int;
	
	/**
	 * Helper variable for tracking whether the touch was just began or just ended.
	 */
	public var _current:Int;
	/**
	 * Helper variable for tracking whether the touch was just began or just ended.
	 */
	public var _last:Int;
	/**
	 * Helper variables for recording purposes.
	 */
	private var _point:FlxPoint;
	private var _globalScreenPosition:FlxPoint;
	
	public var _flashPoint:Point;
	
	/**
	 * Constructor
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageX touch coordinate
	 * @param	PointID		touchPointID of the touch
	 */
	public function new(X:Float = 0, Y:Float = 0, PointID:Int = 0)
	{
		super();
		screenX = 0;
		screenY = 0;
		_current = 0;
		_last = 0;
		_point = new FlxPoint();
		_globalScreenPosition = new FlxPoint();
		
		_flashPoint = new Point();
		updateTouchPosition(X, Y);
		_touchPointID = PointID;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_point = null;
		_globalScreenPosition = null;
		_flashPoint = null;
	}
	
	/**
	 * A unique identification number (as an Int) assigned to the touch point. 
	 */
	public var touchPointID(get_touchPointID, null):Int;
	
	private function get_touchPointID():Int 
	{
		return _touchPointID;
	}

	/**
	 * Called by the internal game loop to update the just pressed/just released flags.
	 */
	public function update():Void
	{
		if ((_last == -1) && (_current == -1))
		{
			_current = 0;
		}
		else if ((_last == 2) && (_current == 2))
		{
			_current = 1;
		}
		_last = _current;
	}
	
	/**
	 * Function for updating touch coordinates. Called by the TouchManager.
	 * @param	X	stageX touch coordinate
	 * @param	Y	stageY touch coordinate
	 */
	public function updateTouchPosition(X:Float, Y:Float):Void
	{
		_flashPoint.x = X;
		_flashPoint.y = Y;
		_flashPoint = FlxG._game.globalToLocal(_flashPoint);
		
		_globalScreenPosition.x = _flashPoint.x;
		_globalScreenPosition.y = _flashPoint.y;
		updateCursor();
	}
	
	/**
	 * Internal function for helping to update world coordinates.
	 */
	private function updateCursor():Void
	{
		//update the x, y, screenX, and screenY variables based on the default camera.
		//This is basically a combination of getWorldPosition() and getScreenPosition()
		var camera:FlxCamera = FlxG.camera;
		screenX = Math.floor((_globalScreenPosition.x - camera.x)/camera.zoom);
		screenY = Math.floor((_globalScreenPosition.y - camera.y)/camera.zoom);
		x = screenX + camera.scroll.x;
		y = screenY + camera.scroll.y;
	}
	
	/**
	 * Fetch the world position of the touch on any given camera.
	 * NOTE: Touch.x and Touch.y also store the world position of the touch point on the main camera.
	 * @param Camera	If unspecified, first/main global camera is used instead.
	 * @param point		An existing point object to store the results (if you don't want a new one created). 
	 * @return The touch point's location in world space.
	 */
	public function getWorldPosition(Camera:FlxCamera = null, point:FlxPoint = null):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = new FlxPoint();
		}
		getScreenPosition(Camera,_point);
		point.x = _point.x + Camera.scroll.x;
		point.y = _point.y + Camera.scroll.y;
		return point;
	}
	
	/**
	 * Fetch the screen position of the touch on any given camera.
	 * NOTE: Touch.screenX and Touch.screenY also store the screen position of the touch point on the main camera.
	 * @param Camera	If unspecified, first/main global camera is used instead.
	 * @param point		An existing point object to store the results (if you don't want a new one created). 
	 * @return The touch point's location in screen space.
	 */
	public function getScreenPosition(Camera:FlxCamera = null, point:FlxPoint = null):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = new FlxPoint();
		}
		point.x = (_globalScreenPosition.x - Camera.x) / Camera.zoom;
		point.y = (_globalScreenPosition.y - Camera.y) / Camera.zoom;
		return point;
	}
	
	/**
	 * Resets the just pressed/just released flags and sets touch to not pressed.
	 */
	public function reset(X:Float, Y:Float, PointID:Int):Void
	{
		updateTouchPosition(X, Y);
		_touchPointID = PointID;
		_current = 0;
		_last = 0;
	}
	
	public function deactivate():Void
	{
		_current = 0;
		_last = 0;
	}
	
	/**
	 * Check to see if the touch is pressed.
	 * @return	Whether the touch is pressed.
	 */
	public function pressed():Bool { return _current > 0; }
	
	/**
	 * Check to see if the touch was just began.
	 * @return Whether the touch was just began.
	 */
	public function justPressed():Bool { return _current == 2; }
	
	/**
	 * Check to see if the touch was just ended.
	 * @return	Whether the touch was just ended.
	 */
	public function justReleased():Bool { return _current == -1; }
	
	/**
	 * Check to see if the touch is active.
	 * @return	Whether the touch is active.
	 */
	public function isActive():Bool { return _current != 0; }
	
}