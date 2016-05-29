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
		super.update();
		
		if (!isActive() && !FlxG.keys.pressed.SHIFT)
		{
			// Tool is not active nor its hotkey is pressed.
			// Nothing to do here.
			return;
		}
		
		if (FlxG.mouse.justPressed && !_dragging)
		{
			startDragging();
		}
		else if (FlxG.mouse.pressed && _dragging)
		{
			doDragging();
		}
		else if (FlxG.mouse.justReleased)
		{
			stopDragging();
		}
		
		_lastCursorPosition.x = FlxG.mouse.x;
		_lastCursorPosition.y = FlxG.mouse.y;
	}
	
	private function doDragging():Void
	{
		var selectedItems:FlxGroup = getBrain().getSelectedItems();
		var i:Int = 0;
		var members:Array<FlxBasic> = selectedItems.members; // TODO: implement some dependency? If Pointer is not loaded, this line will crash.
		var l:Int = members.length;
		var item:FlxObject;
		var dx:Float = FlxG.mouse.x - _lastCursorPosition.x;
		var dy:Float = FlxG.mouse.y - _lastCursorPosition.y;
		
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
