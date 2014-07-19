package flixel.input.mouse;

#if !FLX_NO_MOUSE
import flash.events.MouseEvent;
import flixel.FlxG;
import flixel.input.FlxSwipe;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;

class FlxMouseButton extends FlxInput<Int> implements IFlxDestroyable
{
	/**
	 * These IDs are negative to avoid overlaps with possible touch point IDs.
	 */
	public static inline var LEFT:Int = -1;
	public static inline var MIDDLE:Int = -2;
	public static inline var RIGHT:Int = -3;
	
	private var justPressedPosition = FlxPoint.get();
	private var justPressedTimeInTicks:Float;
	
	/**
	 * Upates the last and current state of this mouse button.
	 */
	override public function update():Void
	{
		super.update();
		
		if (justPressed)
		{
			justPressedPosition.set(FlxG.mouse.screenX, FlxG.mouse.screenY);
			justPressedTimeInTicks = FlxG.game.ticks;
		}
		else if (justReleased)
		{
			FlxG.swipes.push(new FlxSwipe(ID, justPressedPosition, FlxG.mouse.getScreenPosition(), justPressedTimeInTicks));
		}
	}
	
	public inline function destroy():Void
	{
		justPressedPosition = FlxDestroyUtil.put(justPressedPosition);
	}
	
	public function onDown(_):Void
	{
		#if !FLX_NO_DEBUG
		if (ID == LEFT && FlxG.debugger.visible)
		{
			if (FlxG.game.debugger.hasMouse)
			{
				return;
			}
			if (FlxG.game.debugger.watch.editing)
			{
				FlxG.game.debugger.watch.submit();
			}
		}
		#end
		
		// Check for replay cancel keys
		#if FLX_RECORD
		if (FlxG.game.replaying && FlxG.vcr.cancelKeys != null)
		{
			for (key in FlxG.vcr.cancelKeys)
			{
				if (key == "MOUSE" || key == "ANY")
				{
					FlxG.vcr.cancelReplay();
					break;
				}
			}
			return;
		}
		#end
		
		press();
	}
	
	public function onUp(?_):Void
	{
		#if !FLX_NO_DEBUG
		if ((FlxG.debugger.visible && FlxG.game.debugger.hasMouse) 
			#if (FLX_RECORD) || FlxG.game.replaying #end)
		{
			return;
		}
		#end

		release();
	}
}
#end