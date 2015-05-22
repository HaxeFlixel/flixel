package;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var modelDropDown:FlxUIDropDownMenu;
	
	override public function create() 
	{
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		add(new Gamepad());
		
		add(modelDropDown = new FlxUIDropDownMenu(210, 340,
			FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadModel.getConstructors()),
			function (model)
			{
				var gamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
					gamepad.model = FlxGamepadModel.createByName(model);
			}));
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return;
		
		modelDropDown.selectedLabel = Std.string(gamepad.model);
	}
}