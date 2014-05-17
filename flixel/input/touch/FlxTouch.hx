package flixel.input.touch;

import flash.geom.Point;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxTypedGroup;
import flixel.input.FlxSwipe;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;

/**
 * Helper class, contains and track touch points in your game.
 * Automatically accounts for parallax scrolling, etc.
 */
@:allow(flixel.input.touch.FlxTouchManager)
class FlxTouch extends Flx2DInput implements IFlxDestroyable
{	
#if !FLX_NO_TOUCH
	/**
	 * The unique ID of this touch. Example: if there are 3 concurrently active touches 
	 * (and the device supporst that many), they will have the IDs 0, 1 and 2.
	 */
	public var touchPointID(default, null):Int;
	
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;
	public var justReleased(get, never):Bool;
	public var isActive(get, never):Bool;
	
	private var _current:Int = 0;
	private var _last:Int = 0;
	private var _flashPoint:Point;
	
	private var _justPressedPosition:FlxPoint;
	private var _justPressedTimeInTicks:Float;
	
	public function destroy():Void
	{
		_justPressedPosition = FlxDestroyUtil.put(_justPressedPosition);
		_flashPoint = null;
	}
	
	/**
	 * Resets the just pressed/just released flags and sets touch to not pressed.
	 */
	public function reset(X:Int, Y:Int, PointID:Int):Void
	{
		setXY(X, Y);
		touchPointID = PointID;
		deactivate();
	}
	
	public function deactivate():Void
	{
		_current = 0;
		_last = 0;
	}
	
	/**
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageX touch coordinate
	 * @param	PointID		touchPointID of the touch
	 */
	private function new(X:Int = 0, Y:Int = 0, PointID:Int = 0)
	{
		super();
		_justPressedPosition = FlxPoint.get();
		
		_flashPoint = new Point();
		setXY(X, Y);
		touchPointID = PointID;
	}
	
	/**
	 * Called by the internal game loop to update the just pressed/just released flags.
	 */
	private function update():Void
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
		
		if (justPressed)
		{
			_justPressedPosition.set(screenX, screenY);
			_justPressedTimeInTicks = FlxG.game.ticks;
		}
		else if (justReleased)
		{
			FlxG.swipes.push(new FlxSwipe(touchPointID, _justPressedPosition, getScreenPosition(), _justPressedTimeInTicks));
		}
	}
	
	/**
	 * Function for updating touch coordinates. Called by the TouchManager.
	 * 
	 * @param	X	stageX touch coordinate
	 * @param	Y	stageY touch coordinate
	 */
	private function setXY(X:Int, Y:Int):Void
	{
		_flashPoint.x = X;
		_flashPoint.y = Y;
		_flashPoint = FlxG.game.globalToLocal(_flashPoint);
		
		_globalScreenX = Std.int(_flashPoint.x);
		_globalScreenY = Std.int(_flashPoint.y);
		updatePositions();
	}
	
	private inline function get_pressed()     :Bool { return _current > 0;   }
	private inline function get_justPressed() :Bool { return _current == 2;  }
	private inline function get_justReleased():Bool { return _current == -1; }
	private inline function get_isActive()    :Bool { return _current != 0;  }
#end
}