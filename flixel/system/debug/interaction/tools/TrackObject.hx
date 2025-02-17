package flixel.system.debug.interaction.tools;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.system.debug.interaction.Interaction;
import openfl.display.Graphics;
import openfl.display.BitmapData;

using flixel.util.FlxArrayUtil;

/**
 * A tool to open a tracker for the selected object
 *
 * @author George
 */
class TrackObject extends Tool
{
	override function init(brain:Interaction):Tool
	{
		super.init(brain);
		
		_name = "Track object";
		setButton(Icon.watch);
		button.toggleMode = true;
		
		setCursor(Icon.watch, -5, -5);
		
		return this;
	}
	
	#if FLX_DEBUG
	override function update():Void
	{
		if (isActive() && _brain.pointerJustPressed)
		{
			final rect = FlxRect.get(_brain.flixelPointer.x, _brain.flixelPointer.y, 1, 1);
			final item = _brain.getTopItemWithinState(FlxG.state, rect);
			if (item != null)
			{
				FlxG.debugger.track(item);
				_brain.selectedItems.clear();
				_brain.selectedItems.add(item);
			}
			rect.put();
		}
	}
	#end
}
