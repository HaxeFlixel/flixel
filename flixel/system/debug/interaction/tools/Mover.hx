package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.ui.Keyboard;
import flixel.math.FlxPoint;
import flixel.system.debug.interaction.Interaction;

@:bitmap("assets/images/debugger/buttons/mover.png") 
class GraphicMoverTool extends BitmapData {}

/**
 * A tool to move selected items.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Mover extends Tool
{		
	private var _dragging:Bool;
	private var _lastCursorPosition:FlxPoint;
	
	override public function init(Brain:Interaction):Tool 
	{
		super.init(Brain);
		_dragging = false;
		_lastCursorPosition = new FlxPoint(Brain.flixelPointer.x, Brain.flixelPointer.x);

		setName("Mover");
		setButton(GraphicMoverTool);
		setCursor(new GraphicMoverTool(0, 0));

		return this;
	}
	
	override public function update():Void 
	{
		var brain :Interaction = getBrain();
		
		super.update();
		
		if (!isActive() && !brain.keyPressed(Keyboard.SHIFT))
		{
			// Tool is not active nor its hotkey is pressed.
			// Nothing to do here.
			return;
		}
		
		if (brain.pointerPressed && !_dragging)
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
