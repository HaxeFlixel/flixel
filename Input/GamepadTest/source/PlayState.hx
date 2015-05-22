package;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var modelDropDown:FlxUIDropDownMenu;
	var deadZoneStepper:FlxUINumericStepper;
	
	override public function create() 
	{
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		add(new Gamepad());
		
		add(modelDropDown = new FlxUIDropDownMenu(210, 335,
			FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadModel.getConstructors()),
			function (model)
			{
				var gamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
					gamepad.model = FlxGamepadModel.createByName(model);
			}));
		
		var label = new FlxText(209, 365, 0, "Deadzone: ");
		label.setFormat(null, 8, FlxColor.BLACK);
		add(label);
		add(deadZoneStepper = new FlxUINumericStepper(272, 365, 0.1, 0.5, 0,
			1, 1, FlxUINumericStepper.STACK_HORIZONTAL));
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return;
		
		modelDropDown.selectedLabel = Std.string(gamepad.model);
		gamepad.deadZone = deadZoneStepper.value;
	}
}