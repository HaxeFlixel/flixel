package flixel.input.touch;

#if FLX_TOUCH
import flash.geom.Point;
import flixel.FlxG;
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
	 * The _unique_ ID of this touch. You should not make not any further assumptions
	 * about this value - IDs are not guaranteed to start from 0 or ascend in order.
	 * The behavior may vary from device to device.
	 */
	public var touchPointID(get, never):Int;

	/**
	 * A value between 0.0 and 1.0 indicating force of the contact with the device. If the device does not support detecting the pressure, the value is 1.0.
	 */
	public var pressure(default, null):Float;

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
	 * Resets the justPressed/justReleased flags, sets touch to not pressed and sets touch pressure to 0.
	 */
	public function recycle(x:Int, y:Int, pointID:Int, pressure:Float):Void
	{
		setXY(x, y);
		input.ID = pointID;
		input.reset();
		this.pressure = pressure;
	}

	/**
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageX touch coordinate
	 * @param	PointID		touchPointID of the touch
	 * @param	pressure	A value between 0.0 and 1.0 indicating force of the contact with the device. If the device does not support detecting the pressure, the value is 1.0.
	 */
	function new(x:Int = 0, y:Int = 0, pointID:Int = 0, pressure:Float = 0)
	{
		super();

		input = new FlxInput(pointID);
		setXY(x, y);
		this.pressure = pressure;
	}

	/**
	 * Called by the internal game loop to update the just pressed/just released flags.
	 */
	function update():Void
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
}
#else
class FlxTouch {}
#end
