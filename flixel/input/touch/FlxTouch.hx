package flixel.input.touch;

#if !FLX_NO_TOUCH
import flash.geom.Point;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxInput;
import flixel.input.FlxSwipe;
import flixel.input.IFlxInput;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

/**
 * Helper class, contains and tracks touch points in your game.
 * Automatically accounts for parallax scrolling, etc.
 */
@:allow(flixel.input.touch.FlxTouchManager)
class FlxTouch extends FlxPointer implements IFlxDestroyable implements IFlxInput
{	
	/**
	 * The unique ID of this touch. Example: if there are 3 concurrently active touches 
	 * (and the device supports that many), they will have the IDs 0, 1 and 2.
	 */
	public var touchPointID(get, never):Int;
	
	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;
	
	private var input:FlxInput<Int>;
	private var flashPoint = new Point();
	
	public var justPressedPosition(default, null) = FlxPoint.get();
	public var justPressedTimeInTicks(default, null):Float = -1;

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
	private function new(x:Int = 0, y:Int = 0, pointID:Int = 0)
	{
		super();
		
		input = new FlxInput(pointID);
		setXY(x, y);
	}
	
	/**
	 * Called by the internal game loop to update the just pressed/just released flags.
	 */
	private function update():Void
	{
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
	private function setXY(X:Int, Y:Int):Void
	{
		flashPoint.setTo(X, Y);
		flashPoint = FlxG.game.globalToLocal(flashPoint);
		
		setGlobalScreenPositionUnsafe(flashPoint.x, flashPoint.y);
	}
	
	private inline function get_touchPointID():Int
	{
		return input.ID;
	}
	
	private inline function get_justReleased():Bool
	{
		return input.justReleased;
	}
	
	private inline function get_released():Bool
	{
		return input.released;
	}
	
	private inline function get_pressed():Bool
	{
		return input.pressed;
	}
	
	private inline function get_justPressed():Bool
	{
		return input.justPressed;
	}
}
#else
class FlxTouch {}
#end
