package flixel.system.debug.interaction.tools;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.ui.Keyboard;
import flixel.FlxBasic;
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
	var _selectionStartPoint:FlxPoint = new FlxPoint();
	var _selectionEndPoint:FlxPoint = new FlxPoint();
	var _selectionHappening:Bool = false;
	var _selectionArea:FlxRect = new FlxRect();

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
		if (!_selectionHappening)
			return;
		
		final selectedItems = stopSelectionAndFindItems();
		final drewRect = _selectionArea.width != 0 || _selectionArea.height != 0;
		// If we have items in the selection area, handle them
		updateSelectedItems(selectedItems, drewRect);
	}

	function calculateSelectionArea():Void
	{
		final start = _selectionStartPoint;
		final end = _selectionEndPoint;
		_selectionArea.x = start.x < end.x ? start.x : end.x;
		_selectionArea.y = start.y < end.y ? start.y : end.y;
		_selectionArea.right = start.x > end.x ? start.x : end.x;
		_selectionArea.bottom = start.y > end.y ? start.y : end.y;
	}

	/**
	 * Start a selection area. A selection area is a rectangular shaped area
	 * whose boundaries will be used to select game elements.
	 */
	public function startSelection():Void
	{
		_selectionHappening = true;
		_selectionStartPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);
	}

	/**
	 * Cancel any selection activity that is happening, removing the selection rectangle from the screen.
	 * Any item within the (canceled) selection area will be ignored. If you want to stop the selection
	 * and actually process the action/items, use `stopSelection()`.
	 */
	public function cancelSelection():Void
	{
		if (!_selectionHappening)
			return;

		stopSelection();
	}

	/**
	 * Stop any selection activity that is happening.
	 */
	public function stopSelection():Void
	{
		// Clear everything
		_selectionHappening = false;
		_selectionArea.set(0, 0, 0, 0);
	}
	
	/**
	 * Stop any selection activity that is happening.
	 */
	public function stopSelectionAndFindItems():Array<FlxObject>
	{
		if (!_selectionHappening)
			throw "stopSelectionAndFindItems called when not selecting";

		_selectionEndPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);
		calculateSelectionArea();

		var items:Array<FlxObject> = null;
		if (_selectionArea.width != 0 || _selectionArea.height != 0)
		{
			items = _brain.getItemsWithinState(FlxG.state, _selectionArea);
		}
		else
		{
			// if not using the selection rect then select the top-most item
			final topItem = _brain.getTopItemWithinState(FlxG.state, _selectionArea);
			if (topItem != null)
				items = [topItem];
		}
		
		updateConsoleSelection(items);

		// Clear everything
		stopSelection();
		
		return items;
	}

	/**
	 * We register the current selection to the console for easy interaction.
	 */
	function updateConsoleSelection(items:Array<FlxObject>)
	{
		FlxG.console.registerObject("selection", switch (items)
		{
			case null | []: null;
			case [lone]: lone;
			default: items;
		});
	}

	function updateSelectedItems(items:Array<FlxObject>, drewRect:Bool):Void
	{
		// We add things to the selection list if the user is pressing the "add-new-item" key
		final adding = _brain.keyPressed(Keyboard.SHIFT);
		final removing = _brain.keyPressed(Keyboard.ALTERNATE) && !adding;
		
		// If we are not selectively adding items, just clear
		// the brain's list of selected items.
		if (!adding && !removing)
			_brain.clearSelection();
		
		if (items == null || items.length == 0)
			return;
		
		final prevSelectedItems = _brain.selectedItems;
		if (adding && !drewRect && items.length == 1)
		{
			final item = items[0];
			// if they click a single item, toggle it from the selection
			if (prevSelectedItems.members.contains(item))
				prevSelectedItems.remove(item);
			else
				prevSelectedItems.add(item);
		}
		else if (removing)
		{
			for (item in items)
				prevSelectedItems.remove(item);
		}
		else
		{
			// add them all
			for (item in items)
				prevSelectedItems.add(item);
		}
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
