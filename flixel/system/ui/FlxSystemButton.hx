package flixel.system.ui;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import flixel.system.debug.DebuggerUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * A basic button for the debugger, extends openfl.display.Sprite.
 * Cannot be used in a FlxState.
 */
class FlxSystemButton extends Sprite implements IFlxDestroyable
{
	/**
	 * The function to be called when the button is pressed.
	 */
	public var upHandler:Void->Void;

	/**
	 * Whether or not the downHandler function will be called when
	 * the button is clicked.
	 */
	public var enabled:Bool = true;

	/**
	 * Whether this is a toggle button or not. If so, a Boolean representing the current
	 * state will be passed to the callback function, and the alpha value will be lowered when toggled.
	 */
	public var toggleMode:Bool = false;

	/**
	 * Whether the button has been toggled in toggleMode.
	 */
	public var toggled(default, set):Bool = false;

	/**
	 * The icon this button uses.
	 */
	var _icon:Bitmap;

	/**
	 * Whether the mouse has been pressed while over this button.
	 */
	var _mouseDown:Bool = false;

	/**
	 * Create a new FlxSystemButton
	 *
	 * @param	Icon		The icon to use for the button.
	 * @param	UpHandler	The function to be called when the button is pressed.
	 * @param	ToggleMode	Whether this is a toggle button or not.
	 */
	public function new(Icon:BitmapData, ?UpHandler:Void->Void, ToggleMode:Bool = false)
	{
		super();

		if (Icon != null)
			changeIcon(Icon);

		#if flash
		tabEnabled = false;
		#end

		upHandler = UpHandler;
		toggleMode = ToggleMode;

		addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
	}

	/**
	 * Change the Icon of the button
	 *
	 * @param	Icon	The new icon to use for the button.
	 */
	public function changeIcon(Icon:BitmapData):Void
	{
		if (_icon != null)
			removeChild(_icon);

		DebuggerUtil.fixSize(Icon);
		_icon = new Bitmap(Icon);
		addChild(_icon);
	}

	public function destroy():Void
	{
		removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		_icon = null;
		upHandler = null;
	}

	function onMouseUp(_):Void
	{
		if (enabled && _mouseDown)
		{
			toggled = !toggled;
			_mouseDown = false;

			if (upHandler != null)
				upHandler();
		}
	}

	function onMouseDown(_):Void
	{
		_mouseDown = true;
	}

	inline function onMouseOver(_):Void
	{
		if (enabled)
			alpha -= 0.2;
	}

	inline function onMouseOut(_):Void
	{
		if (enabled)
			alpha += 0.2;
	}

	function set_toggled(Value:Bool):Bool
	{
		if (toggleMode)
			alpha = Value ? 0.3 : 1;
		return toggled = Value;
	}
}
