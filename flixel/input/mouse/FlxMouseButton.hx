package flixel.input.mouse;

#if !FLX_NO_MOUSE
import flash.events.MouseEvent;
import flixel.FlxG;
import flixel.input.FlxSwipe;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;

class FlxMouseButton extends FlxInput<Int> implements IFlxDestroyable
{
	public static function getByID(id:FlxMouseButtonID):FlxMouseButton
	{
		return switch (id)
		{
			case LEFT: FlxG.mouse._leftButton;
			
			#if FLX_MOUSE_ADVANCED
				case MIDDLE: FlxG.mouse._middleButton;
				case RIGHT: FlxG.mouse._rightButton;
			#else
				case _: return null;
			#end
		}
	}
	
	public var justPressedPosition(default, null) = FlxPoint.get();
	public var justPressedTimeInTicks(default, null):Float = -1;
	
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
		#if FLX_POINTER_INPUT
		else if (justReleased)
		{
			FlxG.swipes.push(new FlxSwipe(ID, justPressedPosition, FlxG.mouse.getScreenPosition(), justPressedTimeInTicks));
		}
		#end
	}
	
	public inline function destroy():Void
	{
		justPressedPosition = FlxDestroyUtil.put(justPressedPosition);
	}
	
	public function onDown(_):Void
	{
		#if !FLX_NO_DEBUG
		if (ID == FlxMouseButtonID.LEFT && FlxG.debugger.visible)
		{
			if (FlxG.game.debugger.hasMouse)
			{
				return;
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

/**
 * These IDs are negative to avoid overlaps with possible touch point IDs.
 */
@:enum
abstract FlxMouseButtonID(Int) to Int
{
	var LEFT   = -1;
	var MIDDLE = -2;
	var RIGHT  = -3;
}