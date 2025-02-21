package flixel.system.debug.interaction.tools;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.ui.Keyboard;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.debug.Icon;
import flixel.system.debug.interaction.Interaction;
import flixel.util.FlxSpriteUtil;

using flixel.util.FlxArrayUtil;

/**
 * A tool to use the mouse cursor to select game elements.
 *
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Pointer extends Tool
{
	var state = IDLE;
	
	override public function init(brain:Interaction):Tool
	{
		super.init(brain);
		
		_name = "Pointer";
		setButton(Icon.cross);
		setCursor(Icon.cross, -5, -5);
		
		return this;
	}
	
	override public function update():Void
	{
		// If the tool is active, update the custom cursor cursor
		if (!isActive())
			return;
		
		switch state
		{
			case IDLE:
				
				if (_brain.pointerJustPressed)
					state = PRESS(_brain.flixelPointer.x, _brain.flixelPointer.y);
			
			case PRESS(startX, startY):
				if (_brain.pointerJustReleased)
				{
					final selection = FlxRect.get(startX, startY);
					final topItem = _brain.getTopItemWithinState(FlxG.state, selection);
					updateSelected(TOP(topItem));
					selection.put();
					
					state = IDLE;
				}
				else if (_brain.flixelPointer.x != startX || _brain.flixelPointer.y != startY)
					state = DRAG(startX, startY);
				
			case DRAG(startX, startY):
				if (_brain.pointerJustReleased)
				{
					final selection = FlxRect.get(startX, startY);
					setAbsRect(selection, startX, startY, _brain.flixelPointer.x, _brain.flixelPointer.y);
					final items = _brain.getItemsWithinState(FlxG.state, selection);
					updateSelected(ALL(items));
					selection.put();
					
					state = IDLE;
				}
		}
	}
	
	function updateSelected(selection:Selection)
	{
		// We add things to the selection list if the user is pressing the "add-new-item" key
		final alt = _brain.keyPressed(Keyboard.ALTERNATE);
		final shift = _brain.keyPressed(Keyboard.SHIFT);
		
		final selected = _brain.selectedItems;
		inline function wasSelected(o) return _brain.selectedItems.members.contains(o);
		
		switch selection
		{
			case TOP(null) | ALL([]) if (alt || shift):
				// Shift/alt click or select nothing: do nothing
			case TOP(null) | ALL([]):
				// Normal click or select nothing: deselect all
				_brain.clearSelection();
			case TOP(item) if (alt):
				// Alt-click a single item: remove it
				if (wasSelected(item))
					selected.remove(item);
			case TOP(item) if (shift):
				// Shift-click a single item: toggle it from the selection
				if (wasSelected(item))
					selected.remove(item);
				else
					selected.add(item);
			case TOP(item):
				// Click sigle item: deselect all, select item
				_brain.clearSelection();
				selected.add(item);
			case ALL(items) if (alt):
				// Alt-select many items: toggle it from the selection
				for (item in items)
				{
					if (wasSelected(item))
						selected.remove(item);
				}
			case ALL(items) if (shift):
				// Shift-select many items, toggle it from the selection
				for (item in items)
				{
					if (wasSelected(item))
						selected.add(item);
				}
			case ALL(items):
				// Normal-select many items: deelect all, select the new
				_brain.clearSelection();
				for (item in items)
					selected.add(item);
		}
		
		FlxG.console.registerObject("selection", _brain.selectedItems.members);
	}
	
	public function cancelSelection()
	{
		state = IDLE;
	}
	
	override public function draw():Void
	{
		var gfx:Graphics = _brain.getDebugGraphics();
		if (gfx == null)
			return;
		
		switch state
		{
			case IDLE | PRESS(_, _):
			case DRAG(startX, startY):
				final rect = FlxRect.get();
				setAbsRect(rect, startX, startY, _brain.flixelPointer.x, _brain.flixelPointer.y);
				// Render the selection rectangle
				gfx.lineStyle(0.9, 0xbb0000);
				gfx.drawRect(FlxG.camera.scroll.x + rect.x, FlxG.camera.scroll.y + rect.y, rect.width, rect.height);
				rect.put();
		}
		
		// Render everything into the camera buffer
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
	
	static function setAbsRect(rect:FlxRect, x1:Float, y1:Float, x2:Float, y2:Float)
	{
		rect.x = x1 < x2 ? x1 : x2;
		rect.y = y1 < y2 ? y1 : y2;
		rect.width = x1 < x2 ? x2 - x1 : x1 - x2;
		rect.height = y1 < y2 ? y2 - y1 : y1 - y2;
	}
}

private enum State
{
	IDLE;
	PRESS(startX:Float, startY:Float);
	DRAG(startX:Float, startY:Float);
}

private enum Selection
{
	TOP(obj:Null<FlxObject>);
	ALL(objs:Array<FlxObject>);
}