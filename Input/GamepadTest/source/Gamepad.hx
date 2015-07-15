package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

class Gamepad extends FlxTypedGroup<FlxSprite>
{
	static inline var STICK_MOVEMENT_RANGE = 10;
	static inline var TRIGGER_MOVEMENT_RANGE = 20;
	
	static inline var ALPHA_OFF = 0.5;
	static inline var ALPHA_ON = 1;
	static inline var ALPHA_INVISIBLE = 0;
	
	static inline var LB_Y = 16;
	static inline var RB_Y = 16;
	
	static inline var LT_Y = -6;
	static inline var RT_Y = -6;
	
	static var LEFT_STICK_POS = FlxPoint.get(80, 62);
	static var RIGHT_STICK_POS = FlxPoint.get(304, 150);
	
	var leftStick:FlxSprite;
	var rightStick:FlxSprite;
	var dpad:FlxSprite;
	
	var aButton:FlxSprite;
	var bButton:FlxSprite;
	var xButton:FlxSprite;
	var yButton:FlxSprite;
	
	var extraButton0:FlxSprite;
	var extraButton1:FlxSprite;
	var extraButton2:FlxSprite;
	var extraButton3:FlxSprite;
	
	var motionPitch:FlxBar;
	var motionRoll:FlxBar;
	
	var labelPitch:FlxText;
	var labelRoll:FlxText;
	
	var backButton:FlxSprite;
	var guideButton:FlxSprite;
	var startButton:FlxSprite;
	
	var leftShoulder:FlxSprite;
	var rightShoulder:FlxSprite;
	var leftTrigger:FlxSprite;
	var rightTrigger:FlxSprite;
	
	var crosshairs:FlxSprite;
	
	public var gamepad:FlxGamepad;
	
	public function new() 
	{
		super();
		
		leftTrigger = createSprite(128, LT_Y, "LTrigger", 1);
		rightTrigger = createSprite(380, RT_Y, "RTrigger", 1);
		updateTrigger(0, leftTrigger, LT_Y); 
		updateTrigger(0, rightTrigger, RT_Y); 
		
		leftShoulder = createSprite(71, LB_Y, "LB", 1);
		rightShoulder = createSprite(367, RB_Y, "RB", 1);
		
		createSprite(0, 0, "gamepad", 1);
		
		leftStick = createSprite(LEFT_STICK_POS.x, LEFT_STICK_POS.y, "Stick");
		rightStick = createSprite(RIGHT_STICK_POS.x, RIGHT_STICK_POS.y, "Stick");
		
		dpad = createSprite(144, 140);
		dpad.loadGraphic("assets/DPad.png", true, 87, 87);
		
		xButton = createSprite(357, 84, "X");
		yButton = createSprite(395, 48, "Y");
		aButton = createSprite(395, 123, "A");
		bButton = createSprite(433, 84, "B");
		
		extraButton0 = createSprite(357, 84+150, "Extra0");
		extraButton1 = createSprite(395, 84+150, "Extra1");
		extraButton2 = createSprite(433, 84+150, "Extra2");
		extraButton3 = createSprite(471, 84 + 150, "Extra3");
		
		backButton = createSprite(199, 93, "Back");
		guideButton = createSprite(235, 73, "Guide");
		startButton = createSprite(306, 93, "Start");
		
		motionPitch =   createBar(534, 310); 
		labelPitch  = createLabel(534, 310, "Pitch");
		motionRoll  =   createBar(534, 330);
		labelRoll   = createLabel(534, 330, "Roll");
		
		crosshairs = createSprite(0, 0, "crosshairs", 1);
		crosshairs.visible = false;
	}
	
	function createSprite(x:Float, y:Float, ?fileName:String, alpha:Float = -1):FlxSprite
	{
		if (alpha == -1)
			alpha = ALPHA_OFF;
		if (fileName != null)
			fileName = 'assets/$fileName.png';
			
		var sprite = new FlxSprite(x, y, fileName);
		sprite.alpha = alpha;
		sprite.antialiasing = true;
		return add(sprite);
	}
	
	function createBar(x:Float, y:Float):FlxBar
	{
		var bar = new FlxBar(x, y, FlxBarFillDirection.LEFT_TO_RIGHT, 100, 14, null, "", 0, 100, true).createGradientBar([FlxColor.BLACK],[FlxColor.RED,FlxColor.BLUE],1,180,true,FlxColor.BLACK);
		return cast add(bar);
	}
	
	function createLabel(x:Float, y:Float, ?label:String):FlxText
	{
		var label = new FlxText(x, y, 0, label);
		label.color = FlxColor.WHITE;
		label.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK, 1, 1);
		add(label);
		return label;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		gamepad = FlxG.gamepads.lastActive;
		
		if (gamepad == null)
			return;
		
		#if !FLX_NO_DEBUG
		FlxG.watch.addQuick("pressed ID", gamepad.firstJustPressedID());
		FlxG.watch.addQuick("released ID", gamepad.firstJustReleasedID());
		FlxG.watch.addQuick("justPressed ID", gamepad.firstJustPressedID());
		#end
		
		var pressed = gamepad.pressed;
		
		updateButton(aButton, pressed.A);
		updateButton(bButton, pressed.B);
		updateButton(xButton, pressed.X);
		updateButton(yButton, pressed.Y);
		
		updateButtonInvisible(extraButton0, pressed.EXTRA_0);
		updateButtonInvisible(extraButton1, pressed.EXTRA_1);
		updateButtonInvisible(extraButton2, pressed.EXTRA_2);
		updateButtonInvisible(extraButton3, pressed.EXTRA_3);
		
		updateButton(startButton, pressed.START);
		updateButton(guideButton, pressed.GUIDE);
		updateButton(backButton, pressed.BACK);
		
		updateShoulderButton(leftShoulder, pressed.LEFT_SHOULDER, LB_Y);
		updateShoulderButton(rightShoulder, pressed.RIGHT_SHOULDER, RB_Y);
		updateDpad();
		
		var motion = gamepad.motion;
		
		updateBar(motionPitch, labelPitch, motion.isSupported, motion.TILT_PITCH);
		updateBar(motionRoll, labelRoll, motion.isSupported, motion.TILT_ROLL);
		
		var value = gamepad.analog.value;
		
		updateTrigger(value.LEFT_TRIGGER, leftTrigger, LT_Y);
		updateTrigger(value.RIGHT_TRIGGER, rightTrigger, RT_Y);
		
		updateStick(leftStick, value.LEFT_STICK_X, value.LEFT_STICK_Y, LEFT_STICK_POS);
		updateStick(rightStick, value.RIGHT_STICK_X, value.RIGHT_STICK_Y, RIGHT_STICK_POS);
		
		if (leftStick.alpha == ALPHA_OFF)
			updateButton(leftStick, pressed.LEFT_STICK_CLICK);
		if (rightStick.alpha == ALPHA_OFF)
			updateButton(rightStick, pressed.RIGHT_STICK_CLICK);
		
		var pointer = gamepad.pointer;
		
		updatePointer(crosshairs, pointer.isSupported, pointer.X, pointer.Y);
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
			sprite.x -= Std.int(sprite.width / 2);
			sprite.y -= Std.int(sprite.height / 2);
		}
	}
	
	function updateBar(bar:FlxBar, label:FlxText, isSupported:Bool, value:Float)
	{
		bar.visible = label.visible = isSupported;
		if (isSupported)
			bar.value = ((value + 1.0) / 2.0) * 100;	//motion value range is from -1.0 to 1.0
	}
	
	function updateButton(button:FlxSprite, pressed:Bool)
	{
		button.alpha = pressed ? ALPHA_ON : ALPHA_OFF;
	}
	
	function updateButtonInvisible(button:FlxSprite, pressed:Bool)
	{
		button.alpha = pressed ? ALPHA_ON : ALPHA_INVISIBLE;
	}
	
	function updateShoulderButton(button:FlxSprite, pressed:Bool, pos:Int)
	{
		button.y = pos;
		if (pressed)
			button.y += 5;
	}
	
	function updateStick(stick:FlxSprite, xValue:Float, yValue:Float,  pos:FlxPoint)
	{
		var angle:Float = 0;
		
		if (xValue != 0 || yValue != 0)
		{
			angle = Math.atan2(yValue, xValue);
			stick.x = pos.x + STICK_MOVEMENT_RANGE * Math.cos(angle);
			stick.y = pos.y + STICK_MOVEMENT_RANGE * Math.sin(angle);
			stick.alpha = ALPHA_ON;
		}
		else
		{
			stick.x = pos.x;
			stick.y = pos.y;
			stick.alpha = ALPHA_OFF;
		}
	}
	
	function updateTrigger(yAxisValue:Float, sprite:FlxSprite, pos:Float)
	{
		yAxisValue = (yAxisValue + 1) / 2;
		sprite.y = pos + (TRIGGER_MOVEMENT_RANGE * yAxisValue);
	}
	
	function updateDpad()
	{
		var pressed = gamepad.pressed;
		
		var left = pressed.DPAD_LEFT;
		var right = pressed.DPAD_RIGHT;
		var up = pressed.DPAD_UP;
		var down = pressed.DPAD_DOWN;
		
		dpad.animation.frameIndex =
			if (right && up) 5;
			else if (right && down) 6;
			else if (left && down) 7;
			else if (left && up) 8;
			else if (up) 1;
			else if (right) 2;
			else if (down) 3;
			else if (left) 4;
			else 0;
		
		updateButton(dpad, dpad.animation.frameIndex > 0);
	}
}