package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;

class Gamepad extends FlxTypedGroup<FlxSprite>
{
	static inline var STICK_MOVEMENT_RANGE = 10;
	static inline var TRIGGER_MOVEMENT_RANGE = 20;
	
	static inline var ALPHA_OFF = 0.5;
	static inline var ALPHA_ON = 1;
	
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
	
	var backButton:FlxSprite;
	var guideButton:FlxSprite;
	var startButton:FlxSprite;
	
	var leftShoulder:FlxSprite;
	var rightShoulder:FlxSprite;
	var leftTrigger:FlxSprite;
	var rightTrigger:FlxSprite;
	
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
		
		backButton = createSprite(199, 93, "Back");
		guideButton = createSprite(235, 73, "Guide");
		startButton = createSprite(306, 93, "Start");
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
		
		updateButton(startButton, pressed.START);
		updateButton(guideButton, pressed.GUIDE);
		updateButton(backButton, pressed.BACK);
		
		updateShoulderButton(leftShoulder, pressed.LEFT_SHOULDER, LB_Y);
		updateShoulderButton(rightShoulder, pressed.RIGHT_SHOULDER, RB_Y);
		
		updateDpad();
		
		var value = gamepad.analog.value;
		
		updateTrigger(value.LEFT_TRIGGER, leftTrigger, LT_Y);
		updateTrigger(value.RIGHT_TRIGGER, rightTrigger, RT_Y);
		
		updateStick(leftStick, value.LEFT_STICK_X, value.LEFT_STICK_Y, LEFT_STICK_POS);
		updateStick(rightStick, value.RIGHT_STICK_X, value.RIGHT_STICK_Y, RIGHT_STICK_POS);
		
		if (leftStick.alpha == ALPHA_OFF)
			updateButton(leftStick, pressed.LEFT_STICK_CLICK);
		if (rightStick.alpha == ALPHA_OFF)
			updateButton(rightStick, pressed.RIGHT_STICK_CLICK);
	}
	
	function updateButton(button:FlxSprite, pressed:Bool)
	{
		button.alpha = pressed ? ALPHA_ON : ALPHA_OFF;
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