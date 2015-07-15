package;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxArrayUtil;

class PlayState extends FlxState
{
	var modelDropDown:FlxUIDropDownMenu;
	var attachmentDropDown:FlxUIDropDownMenu;
	var attachmentLabel:FlxUIText;
	var deadZoneStepper:FlxUINumericStepper;
	var connectedGamepads:FlxUIRadioGroup;
	var disconnectedOverlay:FlxTypedGroup<FlxSprite>;
	var gamepads:Array<FlxGamepad> = [];
	
	var modelDropDownLoc = new FlxPoint(210, 335);
	
	override public function create() 
	{
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		add(new Gamepad());
		
		add(attachmentLabel = new FlxUIText(modelDropDownLoc.x+65, modelDropDownLoc.y-15, 100, "Attachment:"));
		attachmentLabel.color = FlxColor.BLACK;
		
		add(attachmentDropDown = new FlxUIDropDownMenu(modelDropDownLoc.x+65, modelDropDownLoc.y,
			FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadModelAttachment.getConstructors()),
			function (attachment)
			{
				var gamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
					gamepad.attachment = FlxGamepadModelAttachment.createByName(attachment);
				updateConnectedGamepads(true);
			}));
		attachmentDropDown.selectedId = "None";
		
		add(modelDropDown = new FlxUIDropDownMenu(modelDropDownLoc.x, modelDropDownLoc.y,
			FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadModel.getConstructors()),
			function (model)
			{
				var gamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
					gamepad.model = FlxGamepadModel.createByName(model);
				updateConnectedGamepads(true);
				showAttachment(gamepad.model == FlxGamepadModel.WiiRemote);
			}));
		
		showAttachment(false);
		
		var label = new FlxText(209, 365, 0, "Deadzone: ");
		label.setFormat(null, 8, FlxColor.BLACK);
		add(label);
		add(deadZoneStepper = new FlxUINumericStepper(272, 365, 0.05, 0.15, 0,
			1, 2, FlxUINumericStepper.STACK_HORIZONTAL));
		
		add(connectedGamepads = new FlxUIRadioGroup(500, 10, null, null, null, 25, 125, 25, 125));
		
		disconnectedOverlay = new FlxTypedGroup();
		var background = new FlxSprite();
		background.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.alpha = 0.85;
		var disconnectedText = new FlxText(0, (FlxG.height / 2) - 16, FlxG.width, "No gamepads connected!");
		disconnectedText.size = 32;
		disconnectedText.alignment = FlxTextAlign.CENTER;
		disconnectedOverlay.add(background);
		disconnectedOverlay.add(disconnectedText);
		add(disconnectedOverlay);
	}
	
	private function showAttachment(b:Bool):Void
	{
		attachmentLabel.visible = attachmentDropDown.visible = attachmentDropDown.active = b;
		
		if (b)
			modelDropDown.x = modelDropDownLoc.x - 65;
		else
			modelDropDown.x = modelDropDownLoc.x;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		updateConnectedGamepads();
		
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
		{
			setEnabled(false);
			return;
		}
		
		setEnabled(true);
		modelDropDown.selectedLabel = gamepad.model.getName();
		if (gamepad.model == FlxGamepadModel.WiiRemote || gamepad.model == FlxGamepadModel.MayflashWiiRemote)
		{
			showAttachment(true);
		}
		gamepad.deadZone = deadZoneStepper.value;
		connectedGamepads.selectedIndex = getGamepadIndex(gamepad);
	}
	
	function setEnabled(enabled:Bool)
	{
		disconnectedOverlay.visible = !enabled;
		deadZoneStepper.active = enabled;
		modelDropDown.active = enabled;
	}
	
	function getGamepadIndex(gamepad:FlxGamepad)
	{
		return [for (i in 0...10) FlxG.gamepads.getByID(i)].indexOf(gamepad);
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