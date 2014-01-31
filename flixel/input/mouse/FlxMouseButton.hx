package flixel.input.mouse;

import flash.events.MouseEvent;
import flixel.FlxG;
import flixel.input.FlxSwipe;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxPoint;

class FlxMouseButton implements IFlxDestroyable
{
	/**
	 * These IDs are negative to avoid overlaps with possible touch point IDs.
	 */
	public static inline var LEFT  :Int = -1;
	public static inline var MIDDLE:Int = -2;
	public static inline var RIGHT :Int = -3;
	
	public static inline var FAST_PRESS_RELEASE:Int = -2;
	public static inline var JUST_RELEASED:Int = -1;
	public static inline var RELEASED:Int = 0;
	public static inline var PRESSED:Int = 1;
	public static inline var JUST_PRESSED:Int = 2;

	public var current:Int = RELEASED;
	public var last:Int = RELEASED;
	
	private var _ID:Int;
	
	private var _justPressedPosition:FlxPoint;
	private var _justPressedTimeInTicks:Float;
	
	public function new(ID:Int)
	{
		_ID = ID;
		_justPressedPosition = new FlxPoint();
	}
	
	/**
	 * Upates the last and current state of this mouse button.
	 */
	public function update():Void
	{
		if (last == JUST_RELEASED && current == JUST_RELEASED)
		{
			current = RELEASED;
		}
		else if (last == JUST_PRESSED && current == JUST_PRESSED)
		{
			current = PRESSED;
		}
		else if (last == FAST_PRESS_RELEASE && current == FAST_PRESS_RELEASE)
		{
			current = RELEASED;
		}
		
		last = current;
		
		if (justPressed())
		{
			_justPressedPosition.set(FlxG.mouse.screenX, FlxG.mouse.screenY);
			_justPressedTimeInTicks = FlxG.game.ticks;
		}
		else if (justReleased())
		{
			FlxG.swipes.push(new FlxSwipe(_ID, _justPressedPosition, FlxG.mouse.getScreenPosition(), _justPressedTimeInTicks));
		}
	}
	
	public function destroy():Void
	{
		_justPressedPosition = null;
	}
	
	public function onDown(FlashEvent:MouseEvent):Void
	{
		#if !FLX_NO_DEBUG
		if ((_ID == LEFT) && FlxG.debugger.visible)
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
					if (FlxG.vcr.replayCallback != null)
					{
						FlxG.vcr.replayCallback();
						FlxG.vcr.replayCallback = null;
					}
					else
					{
						FlxG.vcr.stopReplay();
					}
					break;
				}
			}
			return;
		}
		#end
		
		if (current > RELEASED) 
		{
			current = PRESSED;
		}
		else 
		{
			current = JUST_PRESSED;
		}
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param FlashEvent Flash mouse event.
	 */
	public function onUp(?FlashEvent:MouseEvent):Void
	{
		#if !FLX_NO_DEBUG
		if ((FlxG.debugger.visible && FlxG.game.debugger.hasMouse) 
			#if (FLX_RECORD) || FlxG.game.replaying #end)
		{
			return;
		}
		#end

		if (current == JUST_PRESSED)
		{
			current = FAST_PRESS_RELEASE;
		}
		else if (current > RELEASED)
		{
			current = JUST_RELEASED;
		}
		else
		{
			current = RELEASED;
		}
	}
	
	/**
	 * Resets the just pressed/just released flags and sets mouse to not pressed.
	 */
	public inline function reset():Void
	{
		current = RELEASED;
		last = RELEASED;
	}
	
	/**
	 * Check to see if the button is pressed.
	 * @return 	Whether the button is pressed.
	 */
	public inline function pressed():Bool { return current > RELEASED; }

	/**
	 * Check to see if the button was just pressed.
	 * @return 	Whether the button was just pressed.
	 */
	public inline function justPressed():Bool { return (current == JUST_PRESSED || current == FAST_PRESS_RELEASE); }

	/**
	 * Check to see if the button was just released.
	 * @return 	Whether the button was just released.
	 */
	public inline function justReleased():Bool { return (current == JUST_RELEASED || current == FAST_PRESS_RELEASE); }
}