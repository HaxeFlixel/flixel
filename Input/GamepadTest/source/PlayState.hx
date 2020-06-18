package;

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIRadioGroup;
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
	var nameLabel:FlxText;
	var modelDropDown:FlxUIDropDownMenu;
	var attachmentDropDown:FlxUIDropDownMenu;
	var attachmentLabel:FlxText;
	var deadZoneStepper:FlxUINumericStepper;
	var deadZoneModeDropDown:FlxUIDropDownMenu;
	var connectedGamepads:GamepadList;
	var disconnectedOverlay:FlxTypedGroup<FlxSprite>;
	var gamepads:Array<FlxGamepad> = [];
	var gamepadSprite:GamepadSprite;
	var useLatest = true;

	var modelDropDownLoc = new FlxPoint(250, 400);

	override public function create()
	{
		FlxG.cameras.bgColor = FlxColor.WHITE;

		add(gamepadSprite = new GamepadSprite(50, 50));

		createLabelToggle();
		createAttachmentControls();
		createModelControls();
		showAttachment(false);

		createDeadZoneControls();
		nameLabel = addLabel(235, 470);

		createDisconnectedOverlay();

		add(connectedGamepads = new GamepadList(FlxG.width - 150, 10, onGamepadChange));
	}

	function createLabelToggle():Void
	{
		gamepadSprite.inputLabels.visible = false;
		var button:FlxButton = null;
		button = new FlxButton(20, 20, "Show Labels", function()
		{
			button.text = gamepadSprite.inputLabels.visible ? "Show Labels" : "Hide Labels";
			gamepadSprite.inputLabels.visible = !gamepadSprite.inputLabels.visible;
		});
		add(button);
	}

	function createAttachmentControls():Void
	{
		add(attachmentLabel = addLabel(modelDropDownLoc.x, modelDropDownLoc.y - 45, "Attachment:"));

		add(attachmentDropDown = new FlxUIDropDownMenu(modelDropDownLoc.x, modelDropDownLoc.y - 30,
			FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadAttachment.getConstructors()), function(attachment)
		{
			if (gamepadSprite.gamepad != null)
				gamepadSprite.gamepad.attachment = FlxGamepadAttachment.createByName(attachment);
		}, new FlxUIDropDownHeader(150)));
		attachmentDropDown.selectedId = "None";
		attachmentDropDown.dropDirection = Up;
	}

	function createModelControls():Void
	{
		add(modelDropDown = new FlxUIDropDownMenu(modelDropDownLoc.x, modelDropDownLoc.y,
			FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadModel.getConstructors()), function(model)
		{
			if (gamepadSprite.gamepad != null)
			{
				gamepadSprite.gamepad.model = FlxGamepadModel.createByName(model);
				gamepadSprite.updateLabels();
			}
			showAttachment(gamepadSprite.gamepad.model == FlxGamepadModel.WII_REMOTE);
		}, new FlxUIDropDownHeader(150)));
	}

	function createDeadZoneControls():Void
	{
		var x = modelDropDownLoc.x;
		var y = modelDropDownLoc.y + 20;
		addLabel(x, y, "Deadzone:");
		add(deadZoneStepper = new FlxUINumericStepper(x, y + 20, 0.05, 0.15, 0, 1, 2, FlxUINumericStepper.STACK_HORIZONTAL));

		x += 70;
		addLabel(x, y, "Deadzone Mode:");
		add(deadZoneModeDropDown = new FlxUIDropDownMenu(x, y + 16, FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadDeadZoneMode.getConstructors()),
			function(mode)
			{
				if (gamepadSprite.gamepad != null)
					gamepadSprite.gamepad.deadZoneMode = FlxGamepadDeadZoneMode.createByName(mode);
			}, new FlxUIDropDownHeader(130)));
	}

	function createDisconnectedOverlay():Void
	{
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

	function addLabel(x:Float, y:Float, ?text:String):FlxText
	{
		var label = new FlxText(x, y, 0, text);
		label.color = FlxColor.BLACK;
		add(label);
		return label;
	}

	function showAttachment(b:Bool):Void
	{
		attachmentLabel.visible = attachmentDropDown.visible = attachmentDropDown.active = b;
	}

	function onGamepadChange(gamepad:FlxGamepad):Void
	{
		if (gamepadSprite.gamepad == null && gamepad != null)
			setEnabled(true);
		else if (FlxG.gamepads.numActiveGamepads == 0)
			setEnabled(false);

		gamepadSprite.setActiveGamepad(gamepad);

		if (gamepad == null)
			return;

		modelDropDown.selectedLabel = gamepad.model.getName();
		if (gamepad.model == FlxGamepadModel.WII_REMOTE || gamepad.model == FlxGamepadModel.MAYFLASH_WII_REMOTE)
		{
			showAttachment(true);
		}
		gamepad.deadZone = deadZoneStepper.value;
		deadZoneModeDropDown.selectedLabel = gamepad.deadZoneMode.getName();

		#if FLX_GAMEINPUT_API
		nameLabel.text = 'Name: "${gamepad.name}"';
		nameLabel.screenCenter(X);
		#end
	}

	function setEnabled(enabled:Bool)
	{
		disconnectedOverlay.visible = !enabled;
		deadZoneStepper.active = enabled;
		modelDropDown.active = enabled;
	}
}
