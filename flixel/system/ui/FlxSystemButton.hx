package flixel.system.ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;

/**
* A basic button for the debugger, extends flash.display.Sprite
* Cannot be used in a FlxState
*
*/
class FlxSystemButton extends Sprite
{
	private var downHandler:Dynamic;
	private var enabled:Bool = true;
	private var icon:Bitmap;

	public function new(?Icon:BitmapData, ?DownHandler:Dynamic)
	{
		super();

		if(Icon != null)
		{
			this.icon = new Bitmap(Icon);
			addChild(this.icon);
		}

		if(DownHandler != null)
		{
			this.downHandler = DownHandler;
		}

		addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);

		alpha = 0.8;
	}

	/**
	* Change the Icon of a button
	*
	* @NewIcon:Bitmap pass a new bitmap for the icon to be changed
	*
	**/
	public function changeIcon (NewIcon:BitmapData):Void
	{
		if (this.icon != null)
			removeChild(this.icon);

		this.icon = new Bitmap(NewIcon);
		addChild(this.icon);
	}

	/**
	* Change the Button action Handler
	*
	* @NewHandler:Dynamic the new function to change for the button's action
	*
	**/
	public function changeHandler (NewHandler:Dynamic):Void
	{
		this.downHandler = NewHandler;
	}

	public function enable():Void
	{
		enabled = true;
	}

	public function disable():Void
	{
		enabled = false;
	}

	private function onMouseUp(E:MouseEvent = null):Void
	{
		if (downHandler != null && enabled)
			Reflect.callMethod (this, downHandler, []);
	}

	private function onMouseOver(E:MouseEvent = null):Void
	{
		alpha = 1;
	}

	private function onMouseOut(E:MouseEvent = null):Void
	{
		alpha = 0.8;
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