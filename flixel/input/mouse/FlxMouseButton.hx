package flixel.input.mouse;

#if FLX_MOUSE
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
	
	private var _currentSwipe:FlxSwipe;
	
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
			#if FLX_POINTER_INPUT 
			FlxG.swipes.push(_currentSwipe = new FlxSwipe(ID, justPressedPosition, justPressedTimeInTicks)); 
			#end 
		}
		#if FLX_POINTER_INPUT
		else if (pressed)
		{
			_currentSwipe.path.addPoint(FlxG.mouse.getScreenPosition());
		}
		else if (justReleased)
		{
			if (_currentSwipe != null)
				_currentSwipe.release();
		}
		#end
	}
	
	public inline function destroy():Void
	{
		justPressedPosition = FlxDestroyUtil.put(justPressedPosition);
	}
	
	public function onDown(_):Void
	{
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
		}
		#end
		
		if (FlxG.mouse.enabled)
			press();
	}
	
	public function onUp(?_):Void
	{
		if (FlxG.mouse.enabled)
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