package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.ui.Keyboard;
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
	var _selectionCancelled:Bool = false;
	var _selectionArea:FlxRect = new FlxRect();
	var _itemsInSelectionArea:Array<FlxBasic> = [];

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
			handleItemAddition(_itemsInSelectionArea);
		}
		else if (!_brain.keyPressed(Keyboard.CONTROL) && !_selectionCancelled)
			// User clicked an empty space without holding the "add more items" key,
			// so it's time to unselect everything.
			_brain.clearSelection();
	}

	function calculateSelectionArea():Void
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
		_selectionCancelled = false;
		_selectionStartPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);
		_itemsInSelectionArea.clearArray();
		updateConsoleSelection();
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

		_selectionCancelled = true;
		stopSelection(false);
	}

	/**
	 * Stop any selection activity that is happening.
	 *
	 * @param	findItems	If `true` (default), all items within the (stopped) selection area will be included in the list of selected items of the tool.
	 */
	public function stopSelection(findItems:Bool = true):Void
	{
		if (!_selectionHappening)
			return;

		_selectionEndPoint.set(_brain.flixelPointer.x, _brain.flixelPointer.y);
		calculateSelectionArea();

		if (findItems)
		{
			_brain.findItemsWithinState(_itemsInSelectionArea, FlxG.state, _selectionArea);
			updateConsoleSelection();
		}

		// Clear everything
		_selectionHappening = false;
		_selectionArea.set(0, 0, 0, 0);
	}

	/**
	 * We register the current selection to the console for easy interaction.
	 */
	function updateConsoleSelection()
	{
		FlxG.console.registerObject("selection", switch (_itemsInSelectionArea.length)
		{
			case 0: null;
			case 1: _itemsInSelectionArea[0];
			case _: _itemsInSelectionArea;
		});
	}

	function handleItemAddition(itemsInSelectionArea:Array<FlxBasic>):Void
	{
		// We add things to the selection list if the user is pressing the "add-new-item" key
		var adding = _brain.keyPressed(Keyboard.CONTROL);
		var selectedItems = _brain.selectedItems;

		if (itemsInSelectionArea.length == 0)
			return;

		// If we are not selectively adding items, just clear
		// the brain's list of selected items.
		if (!adding)
			_brain.clearSelection();

		for (item in itemsInSelectionArea)
		{
			if (selectedItems.members.contains(cast item) && adding)
				selectedItems.remove(cast item);
			else
				selectedItems.add(cast item);
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
