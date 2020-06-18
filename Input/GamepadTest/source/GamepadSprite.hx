package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID as InputID;
import flixel.math.FlxMath;
import flixel.math.FlxVector;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

class GamepadSprite extends FlxSpriteGroup
{
	static inline var STICK_MOVEMENT_RANGE = 20;
	static inline var TRIGGER_MOVEMENT_RANGE = 20;
	static inline var BUMPER_MOVEMENT = 5;

	static inline var ALPHA_OFF = 0.5;
	static inline var ALPHA_ON = 1;

	static inline var LABEL_OFF = 0xFF808080;
	static inline var LABEL_ON = 0xFF000000;

	public var inputLabels = new FlxSpriteGroup();

	var inputSprites:Array<InputSprite> = [];

	var dpad:FlxSprite;
	var dpadArrow:FlxSprite;

	var motionPitch:Bar;
	var motionRoll:Bar;

	var crosshairs:FlxSprite;

	public var gamepad(default, null):FlxGamepad;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		createInputSprite(128, -7, "LTrigger", LEFT_TRIGGER, Trigger);
		createInputSprite(380, -7, "RTrigger", RIGHT_TRIGGER, Trigger);
		createInputSprite(71, 16, "LB", LEFT_SHOULDER, Bumper);
		createInputSprite(367, 16, "RB", RIGHT_SHOULDER, Bumper);

		createSprite(0, 0, "gamepad");

		createStick(80, 62, LEFT_ANALOG_STICK);
		createStick(304, 150, RIGHT_ANALOG_STICK);

		var dpad = createSprite(144, 140, "DPad");
		createDirectionArrows(dpad.x - x, dpad.y - y, dpad.width * 0.35, DPAD_UP, DPAD_DOWN, DPAD_LEFT, DPAD_RIGHT);

		createInputSprite(357, 84, "X", X);
		createInputSprite(395, 48, "Y", Y);
		createInputSprite(395, 123, "A", A);
		createInputSprite(433, 84, "B", B);

		createInputSprite(357, 234, "Extra0", EXTRA_0, Invisible);
		createInputSprite(395, 234, "Extra1", EXTRA_1, Invisible);
		createInputSprite(433, 234, "Extra2", EXTRA_2, Invisible);
		createInputSprite(471, 234, "Extra3", EXTRA_3, Invisible);

		createInputSprite(199, 93, "Back", BACK);
		createInputSprite(235, 73, "Guide", GUIDE, FlxVector.weak(0, -40));
		createInputSprite(306, 93, "Start", START);

		motionPitch = createBar(534, 310, "Pitch");
		motionRoll = createBar(534, 330, "Roll");

		crosshairs = createSprite(0, 0, "crosshairs");
		crosshairs.visible = false;

		updateInputSprites();
		add(inputLabels);
		inputLabels.x = 0;
		inputLabels.y = 0;
	}

	function createSprite(x:Float, y:Float, ?fileName:String):FlxSprite
	{
		if (fileName != null)
			fileName = 'assets/$fileName.png';

		var sprite = new FlxSprite(x, y, fileName);
		sprite.antialiasing = true;
		sprite.offset.set(sprite.width / 2, sprite.height / 2);
		sprite.x += sprite.offset.x;
		sprite.y += sprite.offset.y;
		add(sprite);
		return sprite;
	}

	function createInputSprite(x:Float, y:Float, ?fileName:String, input:InputID, ?type:InputType, offset:FlxVector = null):FlxSprite
	{
		// haxe 3.4.7 backwards compatibility
		if (type == null)
			type = Digital;

		var sprite = createSprite(x, y, fileName);
		var label = createLabel(sprite.x, sprite.y, "", 16);
		label.borderColor = LABEL_OFF;
		if (offset != null)
		{
			inputLabels.add(drawLine(label.x, label.y, offset, LABEL_OFF));
			label.x += offset.x;
			label.y += offset.y;
			offset.putWeak();
		}
		inputLabels.add(label);

		switch (type)
		{
			case Digital:
				sprite.alpha = ALPHA_OFF;
			case Invisible:
				sprite.visible = false;
			default:
		}

		inputSprites.push({
			sprite: sprite,
			input: input,
			type: type,
			label: label
		});
		return sprite;
	}

	function createBar(x:Float, y:Float, label:String):Bar
	{
		var bar = new FlxBar(x, y, FlxBarFillDirection.LEFT_TO_RIGHT, 100, 14, null, "", 0, 100, true);
		bar.createGradientBar([FlxColor.BLACK], [FlxColor.RED, FlxColor.BLUE], 1, 180, true, FlxColor.BLACK);
		add(bar);
		var label = createLabel(x, y, label);
		add(label);
		return {bar: bar, label: label};
	}

	function createLabel(x:Float, y:Float, label:String, size:Int = 8):FlxText
	{
		var label = new FlxText(x, y, 0, label, size);
		label.color = FlxColor.WHITE;
		label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, size / 8, size / 8);
		label.autoSize = true;
		return label;
	}

	function drawLine(x:Float, y:Float, offset:FlxVector, color:FlxColor):FlxSprite
	{
		var line = new FlxSprite(x, y);
		line.makeGraphic(Math.floor(offset.length), 2, color);
		line.angle = offset.degrees;
		line.origin.set(1, 1);
		return line;
	}

	function createStick(x:Float, y:Float, input:InputID)
	{
		var isLeft = input == InputID.LEFT_ANALOG_STICK;
		var stick = createInputSprite(x, y, "Stick", input, Stick);
		x += stick.width / 2;
		y += stick.height / 2;
		var click = isLeft ? InputID.LEFT_STICK_CLICK : InputID.RIGHT_STICK_CLICK;
		createInputSprite(x - 10, y - 10, "StickClick", click, Invisible, FlxVector.get(isLeft ? -70 : 80, 20));
		if (isLeft)
		{
			createDirectionArrows(x, y, 40, LEFT_STICK_DIGITAL_UP, LEFT_STICK_DIGITAL_DOWN, LEFT_STICK_DIGITAL_LEFT, LEFT_STICK_DIGITAL_RIGHT);
		}
		else
		{
			createDirectionArrows(x, y, 40, RIGHT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_RIGHT);
		}
	}

	function createDirectionArrows(x:Float, y:Float, radius:Float, up:InputID, down:InputID, left:InputID, right:InputID)
	{
		createArrow(x, y - radius, up, -90);
		createArrow(x, y + radius, down, 90);
		createArrow(x - radius, y, left, 180);
		createArrow(x + radius, y, right, 0);
	}

	inline function createArrow(x:Float, y:Float, input:InputID, angle:Float)
	{
		createInputSprite(x - 10, y - 10, "Arrow", input, Invisible).angle = angle;
	}

	public function setActiveGamepad(gamepad:FlxGamepad):Void
	{
		this.gamepad = gamepad;
		updateLabels();
	}

	public function updateLabels():Void
	{
		for (data in inputSprites)
		{
			var label = "";
			if (gamepad != null)
			{
				label = switch (gamepad.getInputLabel(data.input))
				{
					case "square": "[]";
					case "circle": "()";
					case "triangle": "/\\";
					case "plus": "+";
					case "minus": "-";
					case "up": "u";
					case "down": "d";
					case "left": "l";
					case "right": "r";
					case null: null;
					case stick if (~/[rl]s-[udlr]/.match(stick)): stick.substr(0, 4);
					case label: label;
				}
			}
			data.label.text = label != null ? label.toUpperCase() : "";
			data.label.offset.x = data.label.width / 2;
			data.label.offset.y = data.label.height / 2;
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (gamepad != null && FlxG.gamepads.getByID(gamepad.id) == null)
			gamepad = null;

		if (gamepad == null)
			return;

		updateInputSprites();

		var motion = gamepad.motion;

		updateBar(motionPitch, motion.isSupported, motion.TILT_PITCH);
		updateBar(motionRoll, motion.isSupported, motion.TILT_ROLL);

		var pointer = gamepad.pointer;

		updatePointer(crosshairs, pointer.isSupported, pointer.X, pointer.Y);

		#if FLX_DEBUG
		FlxG.watch.addQuick("pressed ID", gamepad.firstJustPressedID());
		FlxG.watch.addQuick("released ID", gamepad.firstJustReleasedID());
		FlxG.watch.addQuick("justPressed ID", gamepad.firstJustPressedID());
		#end
	}

	function updateInputSprites()
	{
		for (data in inputSprites)
		{
			var digital = gamepad == null ? false : gamepad.checkStatus(data.input, PRESSED);
			var analog = gamepad == null ? 0 : gamepad.getAxis(data.input);
			data.label.borderColor = digital || analog != 0 ? LABEL_ON : LABEL_OFF;

			switch (data.type)
			{
				case Digital:
					data.sprite.alpha = digital ? ALPHA_ON : ALPHA_OFF;
				case Invisible:
					data.sprite.visible = digital;
				case Bumper:
					data.sprite.offset.y = data.sprite.origin.y - (digital ? BUMPER_MOVEMENT : 0);
				case Trigger:
					data.sprite.offset.y = data.sprite.origin.y - analog * TRIGGER_MOVEMENT_RANGE;
				case Stick:
					var axes = gamepad == null ? FlxVector.get() : gamepad.getAnalogAxes(data.input);
					data.sprite.alpha = axes.isZero() ? ALPHA_OFF : ALPHA_ON;
					data.sprite.offset.x = data.sprite.origin.x - axes.x * STICK_MOVEMENT_RANGE;
					data.sprite.offset.y = data.sprite.origin.y - axes.y * STICK_MOVEMENT_RANGE;
					axes.put();
			}
		}
	}

	function updatePointer(sprite:FlxSprite, isSupported:Bool, x:Float, y:Float)
	{
		if (!isSupported)
		{
			sprite.visible = false;
		}
		else
		{
			sprite.visible = true;
			sprite.x = FlxG.width * x;
			sprite.y = FlxG.height * y;
		}
	}

	function updateBar(data:Bar, isSupported:Bool, value:Float)
	{
		data.bar.visible = data.label.visible = isSupported;
		if (isSupported)
			data.bar.value = ((value + 1.0) / 2.0) * 100; // motion value range is from -1.0 to 1.0
	}
}

private typedef Bar =
{
	bar:FlxBar,
	label:FlxText
}

private typedef InputSprite =
{
	sprite:FlxSprite,
	input:InputID,
	type:InputType,
	?label:FlxText
}

private enum InputType
{
	Digital;
	Invisible;
	Bumper;
	Trigger;
	Stick;
}
