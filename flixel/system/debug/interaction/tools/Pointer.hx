package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.ui.Keyboard;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.debug.interaction.Interaction;
using flixel.util.FlxArrayUtil;

@:bitmap("assets/images/debugger/cursorCross.png") 
class GraphicCursorCross extends BitmapData {}

/**
 * A tool to use the mouse cursor to select game elements.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Pointer extends Tool
{		
	override public function init(brain:Interaction):Tool 
	{
		super.init(brain);
		
		_name = "Pointer";
		setButton(GraphicCursorCross);
		setCursor(new GraphicCursorCross(0, 0));
		
		return this;
	}
	
	override public function update():Void 
	{
		// If the tool is active, update the custom cursor cursor
		if (!isActive())
			return;
		
		// Check clicks on the screen
		if (!_brain.pointerJustPressed && !_brain.pointerJustReleased)
			return;
		
		var item = pinpointItemInGroup(FlxG.state.members, _brain.flixelPointer);
		if (item != null)
			handleItemClick(item);
		else if (_brain.pointerJustPressed)
			// User clicked an empty space, so it's time to unselect everything.
			_brain.clearSelection();
	}
	
	private function handleItemClick(item:FlxObject):Void
	{			
		// Is it the first thing selected or are we adding things using Ctrl?
		var selectedItems = _brain.selectedItems;
		if (selectedItems.length == 0 || _brain.keyPressed(Keyboard.CONTROL))
		{
			// Yeah, that's the case. Just add the new thing to the selection.
			selectedItems.add(item);
		}
		else
		{
			// There is something already selected
			if (!selectedItems.members.contains(item))
				_brain.clearSelection();
			selectedItems.add(item);
		}
	}
	
	private function pinpointItemInGroup(members:Array<FlxBasic>, cursor:FlxPoint):FlxObject
	{
		var target:FlxObject = null;

		// we iterate backwards to get the sprites on top first
		var i = members.length;
		while (i-- > 0)
		{
			var member = members[i];
			// Ignore invisible or non-existent entities
			if (member == null || !member.visible || !member.exists)
				continue;

			if (Std.is(member, FlxTypedGroup))
				target = pinpointItemInGroup((cast member).members, cursor);
			else if (Std.is(member, FlxSprite) &&
				(cast(member, FlxSprite).overlapsPoint(cursor, true)))
				target = cast member;
			
			if (target != null)
				break;
		}
		return target;
	}
}
