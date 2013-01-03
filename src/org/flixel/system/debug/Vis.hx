package org.flixel.system.debug;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import org.flixel.FlxAssets;

import org.flixel.FlxG;

/**
 * This control panel has all the visual debugger toggles in it, in the debugger overlay.
 * Currently there is only one toggle that flips on all the visual debug settings.
 * This panel is heavily based on the VCR panel.
 */
class Vis extends Sprite
{
	private var _bounds:Bitmap;
	private var _overBounds:Bool;
	private var _pressingBounds:Bool;
	
	/**
	 * Instantiate the visual debugger panel.
	 */
	public function new()
	{
		super();
		
		var spacing:Int = 7;
		
		_bounds = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgBounds));
		addChild(_bounds);
		
		unpress();
		checkOver();
		updateGUI();
		
		addEventListener(Event.ENTER_FRAME, init);
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		removeChild(_bounds);
		_bounds = null;
		
		parent.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		parent.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		parent.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
	}
	
	//***ACTUAL BUTTON BEHAVIORS***//
	
	/**
	 * Called when the bounding box toggle is pressed.
	 */
	public function onBounds():Void
	{
		FlxG.visualDebug = !FlxG.visualDebug;
	}
	
	//***EVENT HANDLERS***//
	
	/**
	 * Just sets up basic mouse listeners, a la FlxWindow.
	 * @param	E	Flash event.
	 */
	private function init(E:Event = null):Void
	{
		#if flash
		if (root == null)
		#else
		if (stage == null)
		#end
		{
			return;
		}
		removeEventListener(Event.ENTER_FRAME,init);
		
		parent.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		parent.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		parent.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
	}
	
	/**
	 * If the mouse moves, check to see if any buttons should be highlighted.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseMove(E:MouseEvent = null):Void
	{
		if (!checkOver())
		{
			unpress();
		}
		updateGUI();
	}
	
	/**
	 * If the mouse is pressed down, check to see if the user started pressing down a specific button.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseDown(E:MouseEvent = null):Void
	{
		unpress();
		if (_overBounds)
		{
			_pressingBounds = true;
		}
	}
	
	/**
	 * If the mouse is released, check to see if it was released over a button that was pressed.
	 * If it was, take the appropriate action based on button state and visibility.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseUp(E:MouseEvent = null):Void
	{
		if (_overBounds && _pressingBounds)
		{
			onBounds();
		}
		unpress();
		checkOver();
		updateGUI();
	}
	
	//***MISC GUI MGMT STUFF***//
	
	/**
	 * This function checks to see what button the mouse is currently over.
	 * Has some special behavior based on whether a recording is happening or not.
	 * @return	Whether the mouse was over any buttons or not.
	 */
	private function checkOver():Bool
	{
		_overBounds = false;
		if ((mouseX < 0) || (mouseX > width) || (mouseY < 0) || (mouseY > height))
		{
			return false;
		}
		if ((mouseX > _bounds.x) || (mouseX < _bounds.x + _bounds.width))
		{
			_overBounds = true;
		}
		return true;
	}
	
	/**
	 * Sets all the pressed state variables for the buttons to false.
	 */
	private function unpress():Void
	{
		_pressingBounds = false;
	}
	
	/**
	 * Figures out what buttons to highlight based on the _overWhatever and _pressingWhatever variables.
	 */
	private function updateGUI():Void
	{
		if(FlxG.visualDebug)
		{
			if (_overBounds && (_bounds.alpha != 1.0))
			{
				_bounds.alpha = 1.0;
			}
			else if (!_overBounds && (_bounds.alpha != 0.9))
			{
				_bounds.alpha = 0.9;
			}
		}
		else
		{
			if (_overBounds && (_bounds.alpha != 0.6))
			{
				_bounds.alpha = 0.6;
			}
			else if (!_overBounds && (_bounds.alpha != 0.5))
			{
				_bounds.alpha = 0.5;
			}
		}
	}
}