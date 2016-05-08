package flixel.system.debug.interaction.tools;

import flixel.*;
import flixel.math.FlxPoint;
import flixel.system.debug.interaction.Interaction;

/**
 * A tool to move selected items.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Mover extends Tool
{		
	private var _dragging:Boolean;
	private var _lastCursorPosition:FlxPoint;
	
	public function new()
	{
		_dragging = false;
		_lastCursorPosition = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (!isActive() && !FlxG.keys.SHIFT)
		{
			// Tool is not active nor its hotkey is pressed.
			// Nothing to do here.
			return;
		}
		
		if (FlxG.mouse.justPressed() && !_dragging)
		{
			startDragging();
		}
		else if (FlxG.mouse.pressed() && _dragging)
		{
			doDragging();
		}
		else if (FlxG.mouse.justReleased())
		{
			stopDragging();
		}
		
		_lastCursorPosition.x = FlxG.mouse.x;
		_lastCursorPosition.y = FlxG.mouse.y;
	}
	
	private function doDragging():Void
	{
		var selectedItems:FlxGroup = findSelectedItemsByPointer();
		var i:uint;
		var members:Array = selectedItems.members; // TODO: implement some dependency? If Pointer is not loaded, this line will crash.
		var l:uint = members.length;
		var item:FlxObject;
		var dx:Number = FlxG.mouse.x - _lastCursorPosition.x;
		var dy:Number = FlxG.mouse.y - _lastCursorPosition.y;
		
		while (i < l)
		{
			item = members[i++];
			if (item != null)
			{
				item.x += dx;
				item.y += dy;
			}
		}
	}
	
	private function startDragging():Void
	{
		_dragging = true;	
	}
	
	private function stopDragging():Void
	{
		_dragging = false;
	}
	
	private function findSelectedItemsByPointer():FlxGroup
	{
		var tool:Pointer = brain.getTool(Pointer) as Pointer;
		return tool != null ? tool.selectedItems : null;
	}
}
