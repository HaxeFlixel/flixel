package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.input.gamepad.FlxGamepad;
import flixel.system.input.gamepad.XboxButtonID;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

class PlayState extends FlxState
{	
	inline static private var STICK_MOVEMENT_RANGE:Float = 10;
	
	inline static private var ALPHA_OFF:Float = 0.5;
	inline static private var ALPHA_ON:Float = 1;
	
	inline static private var LB_Y:Float = 2;
	inline static private var RB_Y:Float = 2;
	
	static private var LEFT_STICK_POS:FlxPoint = new FlxPoint(80, 48);
	static private var RIGHT_STICK_POS:FlxPoint = new FlxPoint(304, 136);
	
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
		FlxG.cameras.bgColor = FlxColor.GRAY;
		
		// Getting first availble gamepad
		_gamePad = FlxG.gamepads.get(0);
		
		_LB = createSprite(71, LB_Y, "assets/LB.png", 0.8);
		_RB = createSprite(367, RB_Y, "assets/RB.png", 0.8);
		
		_controllerBg = createSprite(0, 0, "assets/xbox360_gamepad.png", 1);
		
		_leftStick = createSprite(LEFT_STICK_POS.x, LEFT_STICK_POS.y, "assets/Stick.png");
		_rightStick = createSprite(RIGHT_STICK_POS.x, RIGHT_STICK_POS.y, "assets/Stick.png");
		
		_dPad = new FlxSprite(144, 126);
		_dPad.loadGraphic("assets/DPad.png", true, false, 87, 87);
		_dPad.alpha = ALPHA_OFF;
		add(_dPad);
		
		_xButton = createSprite(357, 70, "assets/X.png");
		_yButton = createSprite(395, 34, "assets/Y.png");
		_aButton = createSprite(395, 109, "assets/A.png");
		_bButton = createSprite(433, 70, "assets/B.png");	
		
		_backButton = createSprite(199, 79, "assets/Back.png");
		_startButton = createSprite(306, 79, "assets/Start.png");
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
	
	override public function update():Void 
	{
		super.update();
		
		if (_gamePad.pressed(XboxButtonID.A))
		{
			_aButton.alpha = ALPHA_ON;
		}
		else
		{
			_aButton.alpha = ALPHA_OFF;
		}
		
		if (_gamePad.pressed(XboxButtonID.B))
		{
			_bButton.alpha = ALPHA_ON;
		}
		else
		{
			_bButton.alpha = ALPHA_OFF;
		}
		
		if (_gamePad.pressed(XboxButtonID.X))
		{
			_xButton.alpha = ALPHA_ON;
		}
		else
		{
			_xButton.alpha = ALPHA_OFF;
		}
		
		if (_gamePad.pressed(XboxButtonID.Y))
		{
			_yButton.alpha = ALPHA_ON;
		}
		else
		{
			_yButton.alpha = ALPHA_OFF;
		}
		
		if (_gamePad.pressed(XboxButtonID.LB))
		{
			_LB.y = LB_Y + 5;
		}
		else
		{
			_LB.y = LB_Y;
		}
		
		if (_gamePad.pressed(XboxButtonID.RB))
		{
			_RB.y = RB_Y + 5;
		}
		else
		{
			_RB.y = RB_Y;
		}
		
		if (_gamePad.pressed(XboxButtonID.START))
		{
			_startButton.alpha = ALPHA_ON;
		}
		else
		{
			_startButton.alpha = ALPHA_OFF;
		}
		
		if (_gamePad.pressed(XboxButtonID.BACK))
		{
			_backButton.alpha = ALPHA_ON;
		}
		else
		{
			_backButton.alpha = ALPHA_OFF;
		}
		
		var angle:Float = 0;
		
		if (Math.abs(_gamePad.getAxis(XboxButtonID.LEFT_ANALOGUE_X)) > _gamePad.deadZone || Math.abs(_gamePad.getAxis(XboxButtonID.LEFT_ANALOGUE_Y)) > _gamePad.deadZone)
		{
			angle = Math.atan2(_gamePad.getAxis(XboxButtonID.LEFT_ANALOGUE_Y), _gamePad.getAxis(XboxButtonID.LEFT_ANALOGUE_X));
			_leftStick.x = LEFT_STICK_POS.x + STICK_MOVEMENT_RANGE * Math.cos(angle);
			_leftStick.y = LEFT_STICK_POS.y + STICK_MOVEMENT_RANGE * Math.sin(angle);
			_leftStick.alpha = ALPHA_ON;
		}
		else
		{
			_leftStick.x = LEFT_STICK_POS.x;
			_leftStick.y = LEFT_STICK_POS.y;
			_leftStick.alpha = ALPHA_OFF;
		}
		
		if (Math.abs(_gamePad.getAxis(XboxButtonID.RIGHT_ANALOGUE_X)) > _gamePad.deadZone || Math.abs(_gamePad.getAxis(XboxButtonID.RIGHT_ANALOGUE_Y)) > _gamePad.deadZone)
		{
			angle = Math.atan2(_gamePad.getAxis(XboxButtonID.RIGHT_ANALOGUE_Y), _gamePad.getAxis(XboxButtonID.RIGHT_ANALOGUE_X));
			_rightStick.x = RIGHT_STICK_POS.x + STICK_MOVEMENT_RANGE * Math.cos(angle);
			_rightStick.y = RIGHT_STICK_POS.y + STICK_MOVEMENT_RANGE * Math.sin(angle);
			_rightStick.alpha = ALPHA_ON;
		}
		else
		{
			_rightStick.x = RIGHT_STICK_POS.x;
			_rightStick.y = RIGHT_STICK_POS.y;
			_rightStick.alpha = ALPHA_OFF;
		}
		
		if (_gamePad.hat.x != 0 || _gamePad.hat.y != 0)
		{
			if (_gamePad.hat.x > 0)
			{
				if (_gamePad.hat.y > 0)
				{
					_dPad.frame = 6;
				}
				else if (_gamePad.hat.y < 0)
				{
					_dPad.frame = 5;
				}
				else	// gamePad.hat.y == 0
				{
					_dPad.frame = 2;
				}
			}
			else if (_gamePad.hat.x < 0)
			{
				if (_gamePad.hat.y > 0)
				{
					_dPad.frame = 7;
				}
				else if (_gamePad.hat.y < 0)
				{
					_dPad.frame = 8;
				}
				else	// gamePad.hat.y == 0
				{
					_dPad.frame = 4;
				}
			}
			else	// gamePad.hat.x == 0
			{
				if (_gamePad.hat.y > 0)
				{
					_dPad.frame = 3;
				}
				else if (_gamePad.hat.y < 0)
				{
					_dPad.frame = 1;
				}
			}
			_dPad.alpha = ALPHA_ON;
		}
		else
		{
			_dPad.frame = 0;
			_dPad.alpha = ALPHA_OFF;
		}
	}
}