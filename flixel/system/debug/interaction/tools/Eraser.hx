package flixel.system.debug.interaction.tools;

import openfl.display.BitmapData;
import openfl.ui.Keyboard;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.system.debug.interaction.Interaction;

@:bitmap("assets/images/debugger/buttons/eraser.png")
private class GraphicEraserTool extends BitmapData {}

/**
 * A tool to delete items from the screen.
 *
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Eraser extends Tool
{
	override public function init(Brain:Interaction):Tool
	{
		super.init(Brain);
		_name = "Eraser";
		return this;
	}

	override public function update():Void
	{
		if (_brain.keyJustPressed(Keyboard.DELETE))
			doDeletion(_brain.keyPressed(Keyboard.SHIFT));
	}

	override public function activate():Void
	{
		doDeletion(_brain.keyPressed(Keyboard.SHIFT));

		// No need to stay active
		_brain.setActiveTool(null);
	}

	function doDeletion(remove:Bool):Void
	{
		var selectedItems = _brain.selectedItems;
		if (selectedItems != null)
		{
			findAndDelete(selectedItems, remove);
			selectedItems.clear();
		}
	}

	function findAndDelete(items:FlxTypedGroup<FlxObject>, remove:Bool = false):Void
	{
		for (member in items)
		{
			if (member == null)
				continue;

			if ((member is FlxTypedGroup))
			{
				// TODO: walk in the group, removing all members.
			}
			else
			{
				member.kill();
				if (remove)
					removeFromMemory(member, FlxG.state);
			}
		}
	}

	function removeFromMemory(item:FlxBasic, parentGroup:FlxGroup):Void
	{
		for (member in parentGroup.members)
		{
			if (member == null)
				continue;

			if ((member is FlxTypedGroup))
				removeFromMemory(item, cast member);
			else if (member == item)
				parentGroup.remove(member);
		}
	}
}
