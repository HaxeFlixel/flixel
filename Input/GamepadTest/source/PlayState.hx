package;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxArrayUtil;

class PlayState extends FlxState
{
	var modelDropDown:FlxUIDropDownMenu;
	var deadZoneStepper:FlxUINumericStepper;
	var connectedGamepads:FlxUIRadioGroup;
	var gamepads:Array<FlxGamepad> = [];
	
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
				updateConnectedGamepads(true);
			}));
		
		var label = new FlxText(209, 365, 0, "Deadzone: ");
		label.setFormat(null, 8, FlxColor.BLACK);
		add(label);
		add(deadZoneStepper = new FlxUINumericStepper(272, 365, 0.1, 0.5, 0,
			1, 1, FlxUINumericStepper.STACK_HORIZONTAL));
			
		add(connectedGamepads = new FlxUIRadioGroup(550, 10));
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		updateConnectedGamepads();
		
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return;
		
		modelDropDown.selectedLabel = gamepad.model.getName();
		gamepad.deadZone = deadZoneStepper.value;
		connectedGamepads.selectedIndex = getGamepadIndex(gamepad);
	}
	
	function getGamepadIndex(gamepad:FlxGamepad)
	{
		var gamepads = [for (i in 0...10) FlxG.gamepads.getByID(i)];
		return gamepads.indexOf(gamepad);
	}
	
	function updateConnectedGamepads(force:Bool = false)
	{
		var gamepads = [for (i in 0...10) FlxG.gamepads.getByID(i)];
		var maxIndex = gamepads.length;
		var i = gamepads.length;
		while (maxIndex-- > 0)
		{
			if (gamepads[maxIndex] != null)
				break;
		}
		
		gamepads.splice(maxIndex + 1, gamepads.length);
		
		if (force || !this.gamepads.equals(gamepads))
		{
			this.gamepads = gamepads;
			updateGamepadRadioGroup();
		}
	}
	
	function updateGamepadRadioGroup()
	{
		var gamepadNames = [];
		for (i in 0...gamepads.length)
		{
			var gamepad = gamepads[i];
			var name = (gamepad == null) ? "None" : gamepad.model.getName();
			gamepadNames.push('$i - $name');
		}
		
		connectedGamepads.updateRadios(gamepadNames, gamepadNames);
		setRadioGroupLabelStyle();
	}
	
	function setRadioGroupLabelStyle()
	{
		for (button in connectedGamepads.getRadios())
		{
			button.button.up_color = FlxColor.BLACK;
			button.button.over_color = FlxColor.BLACK;
			button.button.down_color = FlxColor.BLACK;
			button.button.getLabel().color = FlxColor.BLACK;
			button.textY = -4;
		}
	}
}