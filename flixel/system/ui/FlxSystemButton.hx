package flixel.system.ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flixel.system.FlxAssets;

/**
* A basic button for the debugger, extends flash.display.Sprite.
* Cannot be used in a FlxState.
*/
class FlxSystemButton extends Sprite
{
	/**
	 * The function to be called when the button is pressed.
	 */
	public var downHandler:Dynamic;
	/**
	 * Whether or not the downHandler function will be called when 
	 * the button is clicked.
	 */
	public var enabled:Bool = true;
	/**
	 * The icon this button uses.
	 */
	private var icon:Bitmap;
	/**
	 * Whether this is a toggle button or not. If so, a Boolean representing the current
	 * state will be passed to the callback function, and the alpha value will be lowered when toggled.
	 */
	public var toggleMode:Bool = false;
	/**
	 * Whether the button has been toggled in toggleMode.
	 */
	public var toggled(default, set):Bool = false;
	
	private function set_toggled(Value:Bool):Bool
	{
		if (toggleMode)
		{
			if (Value)
			{
				alpha = 0.3;
			}
			else
			{
				alpha = 1;
			}
		}
		return toggled = Value;
	}
	
	/**
	 * Create a new FlxSystemButton
	 * @param	IconPath	The path to the icon to use for the button.
	 * @param	DownHandler	The function to be called when the button is pressed.
	 * @param	ToggleMode	Whether this is a toggle button or not.
	 */
	public function new(IconPath:String, ?DownHandler:Dynamic, ToggleMode:Bool = false)
	{
		super();
		
		if (IconPath != null)
		{
			icon = new Bitmap(FlxAssets.getBitmapData(IconPath));
			addChild(icon);
		}
		
		buttonMode = true;
		downHandler = DownHandler;
		toggleMode = ToggleMode;
		
		addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
	}

	/**
	 * Change the Icon of the button
	 * @param	IconPath The path to the icon to use for the button.
 	 */
	public function changeIcon (IconPath:String):Void
	{
		if (icon != null)
		{
			removeChild(icon);
		}
		
		icon = new Bitmap(FlxAssets.getBitmapData(IconPath));
		addChild(icon);
	}

	inline private function onMouseUp(?E:MouseEvent):Void
	{
		if (downHandler != null && enabled)
		{
			toggled = !toggled;
			Reflect.callMethod (null, downHandler, []);
		}
	}

	inline private function onMouseOver(?E:MouseEvent):Void
	{
		alpha -= 0.2;
	}

	inline private function onMouseOut(?E:MouseEvent):Void
	{
		alpha += 0.2;
	}

	public function destroy():Void
	{
		removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		icon = null;
		downHandler = null;
	}
}
