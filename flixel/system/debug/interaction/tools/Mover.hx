package flixel.system.debug.interaction.tools;

import flixel.*;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.debug.interaction.Interaction;

/**
 * A tool to move selected items.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Mover extends Tool
{		
	private var _dragging:Bool;
	private var _lastCursorPosition:FlxPoint;
	
	public function new()
	{
		super();
		_dragging = false;
		_lastCursorPosition = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
	}
	
	override public function update():Void 
	{
		var brain :Interaction = getBrain();
		
		super.update();
		
		if (!isActive() && !FlxG.keys.pressed.SHIFT)
		{
			// Tool is not active nor its hotkey is pressed.
			// Nothing to do here.
			return;
		}
		
		if (brain.pointerJustPressed && !_dragging)
		{
			startDragging();
		}
		else if (brain.pointerPressed && _dragging)
		{
			doDragging();
		}
		else if (brain.pointerJustReleased)
		{
			stopDragging();
		}
		
		_lastCursorPosition.x = brain.flixelPointer.x;
		_lastCursorPosition.y = brain.flixelPointer.y;
	}
	
	private function doDragging():Void
	{
		var brain :Interaction = getBrain();
		var i:Int = 0;
		var members:Array<FlxBasic> = brain.getSelectedItems().members;
		var l:Int = members.length;
		var item:FlxObject;
		var dx:Float = brain.flixelPointer.x - _lastCursorPosition.x;
		var dy:Float = brain.flixelPointer.y - _lastCursorPosition.y;
		
		while (i < l)
		{
			item = cast members[i++];
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
}
