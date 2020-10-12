package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.display.Sprite;
import flixel.system.debug.interaction.Interaction;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * The base class of all tools in the interactive debug.
 *
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Tool extends Sprite implements IFlxDestroyable
{
	public var button(default, null):FlxSystemButton;
	public var cursor(default, null):BitmapData;
	public var cursorInUse(default, null):String = "";

	var _name:String = "(Unknown tool)";
	var _shortcut:String;
	var _brain:Interaction;

	public function init(brain:Interaction):Tool
	{
		_brain = brain;
		return this;
	}

	public function update():Void {}

	public function draw():Void {}

	public function activate():Void {}

	public function deactivate():Void {}

	public function destroy():Void {}

	public function isActive():Bool
	{
		return _brain.activeTool == this && _brain.visible;
	}

	function setButton(Icon:Class<BitmapData>):Void
	{
		button = new FlxSystemButton(Type.createInstance(Icon, [0, 0]), onButtonClicked, true);
		button.toggled = true;

		var tooltip = _name;
		if (_shortcut != null)
			tooltip += ' ($_shortcut)';
		Tooltip.add(button, tooltip);
	}

	/**
	 * Set the default icon for the tool. The default icon is used when
	 * the tool is selected in the interaction window toolbar. Tools
	 * can have more than one cursor, e.g. a custom cursor to indicate
	 * that a specific action is happening. Use `setCursorInUse()` to
	 * learn more about custom cursors.
	 */
	function setCursor(Icon:BitmapData):Void
	{
		cursor = Icon;
		_brain.registerCustomCursor(_name, cursor);
	}

	/**
	 * Make the tool use a custom cursor that it is not its default one.
	 * This is  particularly useful to indicate to users that a particular
	 * action of the tool is happening, e.g. rotating something.
	 * Any custom cursor to be used must be previously registed via
	 * `Interaction#registerCustomCursor()`.
	 *
	 * @param	customCursorName	Name of the custom cursor that will be used from now on for the tool. If an empty string is informed, the tool's default icon (informed via `setCursor()`) will be used.
	 */
	function setCursorInUse(customCursorName:String):Void
	{
		cursorInUse = customCursorName;
	}

	/**
	 * Make the tool use its default cursor, which was informed via `setCursor()`.
	 */
	function useDefaultCursor():Void
	{
		if (cursorInUse != "")
			cursorInUse = "";
	}

	function onButtonClicked():Void
	{
		_brain.setActiveTool(this);
	}

	public function getName():String
	{
		return _name;
	}
}
