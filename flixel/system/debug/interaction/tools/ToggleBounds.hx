package flixel.system.debug.interaction.tools;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.LineScaleMode;
import openfl.display.CapsStyle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.system.debug.interaction.Interaction;
import flixel.system.debug.Tooltip;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;

using flixel.util.FlxArrayUtil;

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/drawDebug.png") #end
private class GraphicToggleBoundsTool extends BitmapData {}

/**
 * A tool to toggle `ignoreDrawDebug` on objects
 *
 * @author George
 */
class ToggleBounds extends Tool
{
	override function init(brain:Interaction):Tool
	{
		super.init(brain);
		
		_name = "Toggle Debug Draw";
		setButton(GraphicToggleBoundsTool);
		button.toggleMode = false;
		
		// _tooltip = Tooltip.add(null, "");
		// _tooltip.textField.wordWrap = false;
		
		return this;
	}
	
	override function update():Void
	{
		button.enabled = FlxG.debugger.drawDebug && _brain.selectedItems.countLiving() > 0;
		button.mouseEnabled = button.enabled; 
		button.alpha = button.enabled ? 0.3 : 0.1;
	}
	
	override function onButtonClicked()
	{
		#if FLX_DEBUG // needed for coverage tests
		// super.onButtonClicked();
		if (_brain.selectedItems.length == 0)
			return;
		
		// get whether any selected object is being debug drawn
		var anyEnabled = false;
		for (member in _brain.selectedItems)
		{
			if (member != null && !member.ignoreDrawDebug)
			{
				anyEnabled = true;
				break;
			}
		}
		
		for (member in _brain.selectedItems)
		{
			if (member != null)
			{
				// If any were debug drawn, set all to not draw, otherwise set all to draw
				member.ignoreDrawDebug = anyEnabled;
			}
		}
		// _brain.selectedItems.clear();
		#end
	}
}
