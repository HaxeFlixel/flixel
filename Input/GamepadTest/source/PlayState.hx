package;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	override public function create() 
	{
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		add(new Gamepad());
		
		var models = FlxGamepadModel.getConstructors();
		models.sort(function (i, j) // move Xbox360 to top
		{
			return i == FlxGamepadModel.XBox360.getName() ? -1 : 1;
		});
		
		add(new FlxUIDropDownMenu(210, 340,
			FlxUIDropDownMenu.makeStrIdLabelArray(models),
			function (model)
			{
				var gamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
					gamepad.model = FlxGamepadModel.createByName(model);
			}));
	}
}