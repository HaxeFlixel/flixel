package;

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
	var connectedGamepads:FlxUIRadioGroup;
	var disconnectedOverlay:FlxTypedGroup<FlxSprite>;
	var gamepads:Array<FlxGamepad> = [];
	
	var modelDropDownLoc = new FlxPoint(210, 345);
	
	override public function create() 
	{
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		add(new Gamepad());
		
		createAttachmentControls();
		createModelControls();
		showAttachment(false);
		
		createDeadZoneControls();
		nameLabel = addLabel(175, 418);
		
		createDisconnectedOverlay();
		add(connectedGamepads = new FlxUIRadioGroup(500, 10, null, null, null, 25, 125, 25, 125));
	}
	
	function createAttachmentControls():Void
	{
		add(attachmentLabel = addLabel(modelDropDownLoc.x, modelDropDownLoc.y - 45, "Attachment:"));
		
		add(attachmentDropDown = new FlxUIDropDownMenu(modelDropDownLoc.x, modelDropDownLoc.y - 30,
			FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadAttachment.getConstructors()),
			function (attachment)
			{
				var gamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
					gamepad.attachment = FlxGamepadAttachment.createByName(attachment);
				updateConnectedGamepads(true);
			},
			new FlxUIDropDownHeader(150)));
		attachmentDropDown.selectedId = "None";
		attachmentDropDown.dropDirection = Up;
	}
	
	function createModelControls():Void
	{
		add(modelDropDown = new FlxUIDropDownMenu(modelDropDownLoc.x, modelDropDownLoc.y,
			FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadModel.getConstructors()),
			function (model)
			{
				var gamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
					gamepad.model = FlxGamepadModel.createByName(model);
				updateConnectedGamepads(true);
				showAttachment(gamepad.model == FlxGamepadModel.WII_REMOTE);
			},
			new FlxUIDropDownHeader(150)));
	}
	
	function createDeadZoneControls():Void
	{
		var x = 175;
		addLabel(x, 375, "Deadzone:");
		add(deadZoneStepper = new FlxUINumericStepper(x, 395, 0.05, 0.15, 0,
			1, 2, FlxUINumericStepper.STACK_HORIZONTAL));
		
		x += 70;
		addLabel(x, 375, "Deadzone Mode:");
		add(deadZoneModeDropDown = new FlxUIDropDownMenu(x, 391,
			FlxUIDropDownMenu.makeStrIdLabelArray(FlxGamepadDeadZoneMode.getConstructors()),
			function (mode)
			{
				var gamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
					gamepad.deadZoneMode = FlxGamepadDeadZoneMode.createByName(mode);
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
		if (gamepad.model == FlxGamepadModel.WII_REMOTE ||
			gamepad.model == FlxGamepadModel.MAYFLASH_WII_REMOTE)
		{
			showAttachment(true);
		}
		gamepad.deadZone = deadZoneStepper.value;
		deadZoneModeDropDown.selectedLabel = gamepad.deadZoneMode.getName();
		connectedGamepads.selectedIndex = getGamepadIndex(gamepad);
		
		#if FLX_GAMEINPUT_API
		nameLabel.text = 'Name: "${gamepad.name}"';
		#end
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