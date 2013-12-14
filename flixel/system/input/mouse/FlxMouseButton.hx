package flixel.system.input.mouse;

import flash.events.MouseEvent;
import flixel.FlxG;

/**
 * A helper class for mouse input
 */
class FlxMouseButton
{
	inline static public var FAST_PRESS_RELEASE:Int = -2;
	inline static public var JUST_RELEASED:Int = -1;
	inline static public var RELEASED:Int = 0;
	inline static public var PRESSED:Int = 1;
	inline static public var JUST_PRESSED:Int = 2;

	/**
	 * The current state of this mouse button.
	 */
	public var current:Int = RELEASED;
	/**
	 * The last state of this mouse button.
	 */
	public var last:Int = RELEASED;
	
	/**
	 * Whether this is the left mouse button.
	 */
	private var _isLeftMouse:Bool = false;
	
	public function new(IsLeftMouse:Bool = false)
	{
		_isLeftMouse = IsLeftMouse;
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
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param 	FlashEvent Flash mouse event.
	 */
	public function onDown(FlashEvent:MouseEvent):Void
	{
		#if !FLX_NO_DEBUG
		if (_isLeftMouse && FlxG.debugger.visible)
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
	inline public function reset():Void
	{
		current = RELEASED;
		last = RELEASED;
	}
	
	/**
	 * Check to see if the button is pressed.
	 * @return 	Whether the button is pressed.
	 */
	inline public function pressed():Bool { return current > RELEASED; }

	/**
	 * Check to see if the button was just pressed.
	 * @return 	Whether the button was just pressed.
	 */
	inline public function justPressed():Bool { return (current == JUST_PRESSED || current == FAST_PRESS_RELEASE); }

	/**
	 * Check to see if the button was just released.
	 * @return 	Whether the button was just released.
	 */
	inline public function justReleased():Bool { return (current == JUST_RELEASED || current == FAST_PRESS_RELEASE); }
}