package;

import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;

/**
 * ...
 * @author larsiusprime
 */
class MenuStateB extends MenuState
{
	override function init():Void
	{
		super.init();
		var back:FlxUISprite = cast _ui.getAsset("back");
		back.makeGraphic(FlxG.width, FlxG.height, 0xFF0000AA);
		var welcome:FlxUIText = cast _ui.getAsset("welcome");
		welcome.text = "STATE B";
	}

	override function transition():Void
	{
		FlxG.switchState(new MenuState());
	}
}
