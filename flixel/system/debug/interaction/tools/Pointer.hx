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
	private var _itemsInSelectionArea:Array<FlxBasic> = [];
	
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
		{
			_selectionEndPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);
			calculateSelectionArea();
		}
			
		// Check clicks on the screen
		if (!_brain.pointerJustReleased)
			return;

		// If we made this far, the user just clicked the cursor
		// If we had a selection happening, it's time to end it.
		if (_selectionHappening)
			stopSelection();

		// If we have items in the selection area, handle them
		if (_itemsInSelectionArea.length > 0)
		{
			for (item in _itemsInSelectionArea)
				handleItemAddition(cast item);
		}
		else if (!_brain.keyPressed(Keyboard.CONTROL))
			// User clicked an empty space without holding the "add more items" key,
			// so it's time to unselect everything.
			_brain.clearSelection();
			
	}
	
	private function calculateSelectionArea():Void
	{
		_selectionArea.x = _selectionStartPoint.x;
		_selectionArea.y = _selectionStartPoint.y;
		_selectionArea.width = _selectionEndPoint.x - _selectionArea.x;
		_selectionArea.height = _selectionEndPoint.y - _selectionArea.y;
		
		if (_selectionArea.width < 0)
		{
			_selectionArea.width *= -1;
			_selectionArea.x = _selectionArea.x - _selectionArea.width;
		}
		
		if (_selectionArea.height < 0)
		{
			_selectionArea.height *= -1;
			_selectionArea.y = _selectionArea.y - _selectionArea.height;
		}
	}
	
	/**
	 * Start a selection area. A selection area is a rectangular shaped area
	 * whose boundaries will be used to select game elements.
	 */
	public function startSelection():Void
	{
		_selectionHappening = true;
		_selectionStartPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);
		_itemsInSelectionArea.clearArray();
	}
	
	/**
	 * Stop any selection activity that is happening. 
	 * 
	 * @param	findItems	If <code>true</code> (default), all items within the (stopped) selection area will be included in the list of selected items of the tool.
	 */
	public function stopSelection(findItems:Bool = true):Void
	{	
		if (!_selectionHappening)
			return;
		
		_selectionEndPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);	
		calculateSelectionArea();

		if(findItems)
			_brain.findItemsWithinArea(_itemsInSelectionArea, FlxG.state.members, _selectionArea);
		
		// Clear everything
		_selectionHappening = false;
		_selectionArea.set(0, 0, 0, 0);
	}
	
	private function handleItemAddition(item:FlxObject):Void
	{
		// We add things to the selection list if the user is pressing the "add-new-item" key
		// or if the user used a selection area (e.g. clicked and dragged to create a rectangle)
		var adding = _brain.keyPressed(Keyboard.CONTROL) || _itemsInSelectionArea.length > 1;
		var selectedItems = _brain.selectedItems;
		
		if (selectedItems.length == 0 || adding)
		{
			// Yeah, that's the case. Is the item already in the selection?
			if (selectedItems.members.contains(item))
			{
				// Yep, it's already there. Let's remove it, but only if
				// it was the only selected item, otherwise the user is
				// batch selecting things. In that case, everything should
				// be included, no questions asked.
				if(_itemsInSelectionArea.length == 1)
					selectedItems.remove(item);
			}
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
	
	@:access(flixel.group.FlxTypedGroup)
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

			var group = FlxTypedGroup.resolveGroup(member);
			if (group != null)
				target = pinpointItemInGroup(group.members, cursor);
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
			// Render the selection rectangle
			gfx.lineStyle(0.9, 0xbb0000);
			gfx.drawRect(_selectionArea.x - FlxG.camera.scroll.x, _selectionArea.y - FlxG.camera.scroll.y, _selectionArea.width, _selectionArea.height);
		}

		// Render everything into the camera buffer
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
}
