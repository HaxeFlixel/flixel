package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.input.gamepad.OUYAButtonID;

class PlayState extends FlxState
{
	private static inline var STICK_MOVEMENT_RANGE:Float = 10;
	
	private static inline var ALPHA_OFF:Float = 0.5;
	private static inline var ALPHA_ON:Float = 1;
	
	private static inline var LB_Y:Float = 2;
	private static inline var RB_Y:Float = 2;
	
	private static var LEFT_STICK_POS:FlxPoint = FlxPoint.get(80, 48);
	private static var RIGHT_STICK_POS:FlxPoint = FlxPoint.get(304, 136);
	
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
	private var _gamePad:FlxGamepad;

	override public function create():Void 
	{
		FlxG.mouse.visible = false;
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		_LB = createSprite(71, LB_Y, "assets/LB.png", 0.8);
		_RB = createSprite(367, RB_Y, "assets/RB.png", 0.8);
		
		_controllerBg = createSprite(0, 0, "assets/xbox360_gamepad.png", 1);
		
		_leftStick = createSprite(LEFT_STICK_POS.x, LEFT_STICK_POS.y, "assets/Stick.png");
		_rightStick = createSprite(RIGHT_STICK_POS.x, RIGHT_STICK_POS.y, "assets/Stick.png");
		
		_dPad = new FlxSprite(144, 126);
		_dPad.loadGraphic("assets/DPad.png", true, 87, 87);
		_dPad.alpha = ALPHA_OFF;
		add(_dPad);
		
		_xButton = createSprite(357, 70, "assets/X.png");
		_yButton = createSprite(395, 34, "assets/Y.png");
		_aButton = createSprite(395, 109, "assets/A.png");
		_bButton = createSprite(433, 70, "assets/B.png");
		
		_backButton = createSprite(199, 79, "assets/Back.png");
		_startButton = createSprite(306, 79, "assets/Start.png");
		
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
		
		if (_gamePad.pressed(GamepadIDs.A))
			_aButton.alpha = ALPHA_ON;
		else
			_aButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed(GamepadIDs.B))
			_bButton.alpha = ALPHA_ON;
		else
			_bButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed(GamepadIDs.X))
			_xButton.alpha = ALPHA_ON;
		else
			_xButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed(GamepadIDs.Y))
			_yButton.alpha = ALPHA_ON;
		else
			_yButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed(GamepadIDs.START))
			_startButton.alpha = ALPHA_ON;
		else
			_startButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed(GamepadIDs.SELECT))
			_backButton.alpha = ALPHA_ON;
		else
			_backButton.alpha = ALPHA_OFF;
		
		if (_gamePad.pressed(GamepadIDs.LB))
			_LB.y = LB_Y + 5;
		else
			_LB.y = LB_Y;
		
		if (_gamePad.pressed(GamepadIDs.RB))
			_RB.y = RB_Y + 5;
		else
			_RB.y = RB_Y;
		
		updateAxis(GamepadIDs.LEFT_ANALOG_STICK, _leftStick, LEFT_STICK_POS);
		updateAxis(GamepadIDs.RIGHT_ANALOG_STICK, _rightStick, RIGHT_STICK_POS);
		
		updateDpad();
	}
	
	private function updateAxis(axes:FlxGamepadAnalogStick, stickSprite:FlxSprite, stickPosition:FlxPoint):Void
	{
		var xAxisValue = _gamePad.getXAxis(axes);
		var yAxisValue = _gamePad.getYAxis(axes);
		var angle:Float;
		
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
	
	private function updateDpad():Void
	{
		var dpadLeft = _gamePad.pressed(XboxButtonID.DPAD_LEFT);
		var dpadRight = _gamePad.pressed(XboxButtonID.DPAD_RIGHT);
		var dpadUp = _gamePad.pressed(XboxButtonID.DPAD_UP);
		var dpadDown = _gamePad.pressed(XboxButtonID.DPAD_DOWN);
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
