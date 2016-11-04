package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.ui.Keyboard;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.debug.interaction.Interaction;
import flixel.util.FlxSpriteUtil;
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
	private var _selectionStartPoint:FlxPoint = new FlxPoint();
	private var _selectionEndPoint:FlxPoint = new FlxPoint();
	private var _selectionHappening:Bool = false;
	private var _selectionArea:FlxRect = new FlxRect();
	
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
		
		if (_brain.pointerJustPressed && !_selectionHappening)
			startSelection();

		if (_selectionHappening)
			_selectionEndPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);
			
		// Check clicks on the screen
		if (!_brain.pointerJustReleased)
			return;

		// If we made this far, the user just clicked the cursor
		// If we had a selection happening, it's time to end it.
		if (_selectionHappening)
			stopSelection();
			
		var item = pinpointItemInGroup(FlxG.state.members, _brain.flixelPointer);
		if (item != null)
			handleItemClick(item);
		else if (!_brain.keyPressed(Keyboard.CONTROL))
			// User clicked an empty space without holding the "add more items" key,
			// so it's time to unselect everything.
			_brain.clearSelection();
	}
	
	private function startSelection():Void
	{
		var item = pinpointItemInGroup(FlxG.state.members, _brain.flixelPointer);
		
		// Start a selection only if the user clicked within an empty space, not an item
		if (item == null)
		{
			_selectionHappening = true;
			_selectionStartPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);
		}
	}
	
	private function stopSelection():Void
	{
		_selectionHappening = false;
		_selectionEndPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);
	}
	
	private function handleItemClick(item:FlxObject):Void
	{			
		// Is it the first thing selected or are we adding things using Ctrl?
		var selectedItems = _brain.selectedItems;
		if (selectedItems.length == 0 || _brain.keyPressed(Keyboard.CONTROL))
		{
			// Yeah, that's the case. Is the item already in the selection?
			if (selectedItems.members.contains(item))
				// Yep, it's already there. Let's remove it then.
				selectedItems.remove(item);
			else
				// No, so let's add it to the selection.
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
	
	override public function draw():Void 
	{
		var gfx:Graphics = _brain.getDebugGraphics();
		if (gfx == null)
			return;
		
		if (_selectionHappening)
		{
			var x:Float = _selectionStartPoint.x - FlxG.camera.scroll.x;
			var y:Float = _selectionStartPoint.y - FlxG.camera.scroll.y;
			var width:Float = _selectionEndPoint.x - FlxG.camera.scroll.x - x;
			var height:Float = _selectionEndPoint.y - FlxG.camera.scroll.y - y;
			
			if (width < 0)
			{
				width *= -1;
				x -= width;
			}
			
			if (height < 0)
			{
				height *= -1;
				y -= height;
			}
			
			// Render the selection rectangle
			gfx.lineStyle(0.9, 0xbb0000);
			gfx.drawRect(x, y, width, height);
		}

		// Render everything into the camera buffer
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
}
