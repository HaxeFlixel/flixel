package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.id.XBox360ID;
import flixel.input.gamepad.id.OUYAID;

class PlayState extends FlxState
{
	private static inline var STICK_MOVEMENT_RANGE:Float = 10;
	private static inline var TRIGGER_MOVEMENT_RANGE:Float = 20;
	
	private static inline var ALPHA_OFF:Float = 0.5;
	private static inline var ALPHA_ON:Float = 1;
	
	private static inline var LB_Y:Float = 16;
	private static inline var RB_Y:Float = 16;
	
	private static inline var LT_Y:Float = -6;
	private static inline var RT_Y:Float = -6;
	
	private static var LEFT_STICK_POS:FlxPoint = FlxPoint.get(80, 62);
	private static var RIGHT_STICK_POS:FlxPoint = FlxPoint.get(304, 150);
	
	private var _controllerBg:FlxSprite;
	private var _leftStick:FlxSprite;
	private var _rightStick:FlxSprite;
	private var _dPad:FlxSprite;
	
	private var _xButton:FlxSprite;
	private var _yButton:FlxSprite;
	private var _aButton:FlxSprite;
	private var _bButton:FlxSprite;
	
	private var _backButton:FlxSprite;
	private var _startButton:FlxSprite;
	
	private var _LB:FlxSprite;
	private var _RB:FlxSprite;
	private var _LTrigger:FlxSprite;
	private var _RTrigger:FlxSprite;
	private var _gamePad:FlxGamepad;

	override public function create():Void 
	{
		FlxG.mouse.visible = false;
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		_LTrigger = createSprite(128, LT_Y, "assets/LTrigger.png", 1);
		_RTrigger = createSprite(380, RT_Y, "assets/RTrigger.png", 1);
		
		_LB = createSprite(71, LB_Y, "assets/LB.png", 1);
		_RB = createSprite(367, RB_Y, "assets/RB.png", 1);
		
		_controllerBg = createSprite(0, 0, "assets/xbox360_gamepad.png", 1);
		
		_leftStick = createSprite(LEFT_STICK_POS.x, LEFT_STICK_POS.y, "assets/Stick.png");
		_rightStick = createSprite(RIGHT_STICK_POS.x, RIGHT_STICK_POS.y, "assets/Stick.png");
		
		_dPad = new FlxSprite(144, 140);
		_dPad.loadGraphic("assets/DPad.png", true, 87, 87);
		_dPad.alpha = ALPHA_OFF;
		add(_dPad);
		
		_xButton = createSprite(357, 84, "assets/X.png");
		_yButton = createSprite(395, 48, "assets/Y.png");
		_aButton = createSprite(395, 123, "assets/A.png");
		_bButton = createSprite(433, 84, "assets/B.png");
		
		_backButton = createSprite(199, 93, "assets/Back.png");
		_startButton = createSprite(306, 93, "assets/Start.png");
		
		_startButton.alpha = ALPHA_OFF;
		_backButton.alpha = ALPHA_OFF;
	}

	private function createSprite(X:Float, Y:Float, Graphic:String, Alpha:Float = -1):FlxSprite
	{
		if (Alpha == -1)
		{
			Alpha = ALPHA_OFF;
		}
		
		var button:FlxSprite = new FlxSprite(X, Y, Graphic);
		button.alpha = Alpha;
		add(button);
		
		return button;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		_gamePad = FlxG.gamepads.lastActive;
		
		if (_gamePad == null)
		{
			return;
		}
		
		#if !FLX_NO_DEBUG
		FlxG.watch.addQuick("pressed ID", _gamePad.firstPressedButtonID());
		FlxG.watch.addQuick("released ID", _gamePad.firstJustReleasedButtonID());
		FlxG.watch.addQuick("justPressed ID", _gamePad.firstJustPressedButtonID());
		#end
		
		if (_gamePad.pressed.A)
			_aButton.alpha = ALPHA_ON;
		else
			_aButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed.B)
			_bButton.alpha = ALPHA_ON;
		else
			_bButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed.X)
			_xButton.alpha = ALPHA_ON;
		else
			_xButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed.Y)
			_yButton.alpha = ALPHA_ON;
		else
			_yButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed.START)
			_startButton.alpha = ALPHA_ON;
		else
			_startButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed.BACK)
			_backButton.alpha = ALPHA_ON;
		else
			_backButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed.LEFT_SHOULDER)
			_LB.y = LB_Y + 5;
		else
			_LB.y = LB_Y;
		
		if (_gamePad.pressed.RIGHT_SHOULDER)
			_RB.y = RB_Y + 5;
		else
			_RB.y = RB_Y;
			
		if (_gamePad.pressed.LEFT_STICK_CLICK)
			_leftStick.color = FlxColor.RED;
		else
			_leftStick.color = FlxColor.WHITE;
		
		if (_gamePad.pressed.RIGHT_STICK_CLICK)
			_rightStick.color = FlxColor.RED;
		else
			_rightStick.color = FlxColor.WHITE;
		
		updateAxis(_gamePad.analog.LEFT_STICK_X, _gamePad.analog.LEFT_STICK_Y, _leftStick, LEFT_STICK_POS);
		updateAxis(_gamePad.analog.RIGHT_STICK_X, _gamePad.analog.RIGHT_STICK_Y, _rightStick, RIGHT_STICK_POS);
		
		updateTrigger(_gamePad.analog.LEFT_TRIGGER, _LTrigger, LT_Y);
		updateTrigger(_gamePad.analog.RIGHT_TRIGGER, _RTrigger, RT_Y);
		
		updateDpad();
	}
	
	private function updateAxis(xAxisValue:Float, yAxisValue:Float, stickSprite:FlxSprite, stickPosition:FlxPoint):Void
	{
		var angle:Float=0;
		
		if ((xAxisValue != 0) || (yAxisValue != 0))
		{
			angle = Math.atan2(yAxisValue, xAxisValue);
			stickSprite.x = stickPosition.x + STICK_MOVEMENT_RANGE * Math.cos(angle);
			stickSprite.y = stickPosition.y + STICK_MOVEMENT_RANGE * Math.sin(angle);
			stickSprite.alpha = ALPHA_ON;
		}
		else
		{
			stickSprite.x = stickPosition.x;
			stickSprite.y = stickPosition.y;
			stickSprite.alpha = ALPHA_OFF;
		}
	}
	
	private function updateTrigger(yAxisValue:Float, sprite:FlxSprite, pos:Float):Void
	{
		yAxisValue = (yAxisValue+1) / 2;
		sprite.y = pos + (TRIGGER_MOVEMENT_RANGE * yAxisValue);
	}
	
	private function updateDpad():Void
	{
		var dpadLeft = _gamePad.pressed.DPAD_LEFT;
		var dpadRight = _gamePad.pressed.DPAD_RIGHT;
		var dpadUp = _gamePad.pressed.DPAD_UP;
		var dpadDown = _gamePad.pressed.DPAD_DOWN;
		
		var newIndex:Int = 0;
		var newAlpha:Float = ALPHA_OFF;
		
		if (dpadLeft || dpadRight || dpadUp || dpadDown)
		{
			newAlpha = ALPHA_ON;
			
			if (dpadRight && dpadUp)
				newIndex = 5;
			else if (dpadRight && dpadDown)
				newIndex = 6;
			else if (dpadLeft && dpadDown)
				newIndex = 7;
			else if (dpadLeft && dpadUp)
				newIndex = 8;
			else if (dpadUp)
				newIndex = 1;
			else if (dpadRight)
				newIndex = 2;
			else if (dpadDown)
				newIndex = 3;
			else if (dpadLeft)
				newIndex = 4;
		}
		
		_dPad.animation.frameIndex = newIndex;
		_dPad.alpha = newAlpha;
	}
}
