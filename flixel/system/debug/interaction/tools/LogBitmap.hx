package flixel.system.debug.interaction.tools;

import flixel.FlxG;
import flixel.FlxG;
import openfl.display.Graphics;
import openfl.display.BitmapData;
import flixel.system.debug.interaction.Interaction;
// import flixel.system.debug.Tooltip;

using flixel.util.FlxArrayUtil;

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/bitmapLog.png") #end
private class GraphicLogBitmapTool extends BitmapData {}

/**
 * A tool to add selected sprites to the BitmapLog window
 *
 * @author George
 */
class LogBitmap extends Tool
{
	override function init(brain:Interaction):Tool
	{
		super.init(brain);
		
		_name = "Log Bitmaps";
		setButton(GraphicLogBitmapTool);
		button.toggleMode = false;
		
		// _tooltip = Tooltip.add(null, "");
		// _tooltip.textField.wordWrap = false;
		
		return this;
	}
	
	override function update():Void
	{
		button.enabled = _brain.selectedItems.countLiving() > 0;
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
			if (member != null && member is FlxSprite)
			{
				final sprite:FlxSprite = cast member;
				if (sprite.graphic != null && sprite.graphic.bitmap != null)
					FlxG.bitmapLog.add(sprite.graphic);
			}
		}
		#end
	}
}
