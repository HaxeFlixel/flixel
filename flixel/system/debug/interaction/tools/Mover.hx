package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.ui.Keyboard;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.system.debug.interaction.Interaction;

@:bitmap("assets/images/debugger/buttons/mover.png")
private class GraphicMoverTool extends BitmapData {}

/**
 * A tool to move selected items.
 *
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Mover extends Tool
{
	var _dragging:Bool = false;
	var _lastCursorPosition:FlxPoint;

	override public function init(brain:Interaction):Tool
	{
		super.init(brain);
		_lastCursorPosition = new FlxPoint(brain.flixelPointer.x, brain.flixelPointer.x);

		_name = "Mover";
		_shortcut = "Shift";
		setButton(GraphicMoverTool);
		setCursor(new GraphicMoverTool(0, 0));

		return this;
	}

	override public function update():Void
	{
		// Is the tool active or its hotkey pressed?
		if (!isActive() && !_brain.keyPressed(Keyboard.SHIFT))
			return;

		if (_brain.pointerPressed && !_dragging)
			startDragging();
		else if (_brain.pointerPressed && _dragging)
			doDragging();
		else if (_brain.pointerJustReleased)
			stopDragging();

		_lastCursorPosition.x = _brain.flixelPointer.x;
		_lastCursorPosition.y = _brain.flixelPointer.y;
	}

	function stopDragging():Void
	{
		_dragging = false;
	}

	function startDragging():Void
	{
		if (_dragging)
			return;

		_dragging = true;

		// If we are not active, it means things are being moved around using
		// the mover's shortcut key. If the pointer is the active tool, it should
		// not do any selection of items while things are being moved/dragged.
		if (!isActive() && (_brain.activeTool is Pointer))
			(cast _brain.activeTool : Pointer).cancelSelection();
	}

	function doDragging():Void
	{
		var dx:Float = _brain.flixelPointer.x - _lastCursorPosition.x;
		var dy:Float = _brain.flixelPointer.y - _lastCursorPosition.y;

		for (member in _brain.selectedItems.members)
		{
			if (!(member is FlxObject))
				continue;

			var object:FlxObject = cast member;
			if (object != null)
			{
				object.x += dx;
				object.y += dy;
			}
		}
	}
}
