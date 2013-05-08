package;

import nme.display.BitmapInt32;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.system.input.FlxJoystick;

class PlayState extends FlxState
{	
	private var controllerBg:FlxSprite;
	private var leftStick:FlxSprite;
	private var rightStick:FlxSprite;
	private var dPad:FlxSprite;
	
	private var xButton:FlxSprite;
	private var yButton:FlxSprite;
	private var aButton:FlxSprite;
	private var bButton:FlxSprite;
	
	private var back:FlxSprite;
	private var start:FlxSprite;
	
	private var LB:FlxSprite;
	private var RB:FlxSprite;
	private var gamePad:FlxJoystick;
	
	private var offAlpha:Float = 0.5;
	private var onAlpha:Float = 1.0;
	
	private static var LB_Y:Float = 2;
	private static var RB_Y:Float = 2;
	
	private static var LEFT_STICK_POS:FlxPoint = new FlxPoint(80, 48);
	private static var RIGHT_STICK_POS:FlxPoint = new FlxPoint(304, 136);
	private static var STICK_MOVEMENT_RANGE:Float = 10;
	
	override public function create():Void 
	{
		super.create();
		
		FlxG.bgColor = FlxG.WHITE;
		
		// getting first availble gamepad
		gamePad = FlxG.joystickManager.joystick(0);
		
		LB = new FlxSprite(71, LB_Y, "assets/LB.png");
		LB.alpha = 0.8;
		add(LB);
		
		RB = new FlxSprite(367, RB_Y, "assets/RB.png");
		RB.alpha = 0.8;
		add(RB);
		
		controllerBg = new FlxSprite(0, 0, "assets/xbox360_gamepad.png");
		add(controllerBg);
		
		leftStick = new FlxSprite(LEFT_STICK_POS.x, LEFT_STICK_POS.y, "assets/Stick.png");
		leftStick.alpha = offAlpha;
		add(leftStick);
		
		rightStick = new FlxSprite(RIGHT_STICK_POS.x, RIGHT_STICK_POS.y, "assets/Stick.png");
		rightStick.alpha = offAlpha;
		add(rightStick);
		
		dPad = new FlxSprite(144, 126);
		dPad.loadGraphic("assets/DPad.png", true, false, 87, 87);
		dPad.alpha = offAlpha;
		add(dPad);
		
		xButton = new FlxSprite(357, 70, "assets/X.png");
		xButton.alpha = offAlpha;
		add(xButton);
		
		yButton = new FlxSprite(395, 34, "assets/Y.png");
		yButton.alpha = offAlpha;
		add(yButton);
		
		aButton = new FlxSprite(395, 109, "assets/A.png");
		aButton.alpha = offAlpha;
		add(aButton);
		
		bButton = new FlxSprite(433, 70, "assets/B.png");
		bButton.alpha = offAlpha;
		add(bButton);
		
		back = new FlxSprite(199, 79, "assets/Back.png");
		back.alpha = offAlpha;
		add(back);
		
		start = new FlxSprite(306, 79, "assets/Start.png");
		start.alpha = offAlpha;
		add(start);
	}
	
	override public function update():Void 
	{
		super.update();
		
		#if neko
		var gray:BitmapInt32 = { a: 0xff, rgb: 0xcccccc };
		#else
		var gray:Int = 0xffcccccc;
		#end
		
		if (gamePad.pressed(XBOX_BUTTON_IDS.A_BUTTON))
		{
			aButton.alpha = onAlpha;
		}
		else
		{
			aButton.alpha = offAlpha;
		}
		
		if (gamePad.pressed(XBOX_BUTTON_IDS.B_BUTTON))
		{
			bButton.alpha = onAlpha;
		}
		else
		{
			bButton.alpha = offAlpha;
		}
		
		if (gamePad.pressed(XBOX_BUTTON_IDS.X_BUTTON))
		{
			xButton.alpha = onAlpha;
		}
		else
		{
			xButton.alpha = offAlpha;
		}
		
		if (gamePad.pressed(XBOX_BUTTON_IDS.Y_BUTTON))
		{
			yButton.alpha = onAlpha;
		}
		else
		{
			yButton.alpha = offAlpha;
		}
		
		if (gamePad.pressed(XBOX_BUTTON_IDS.LB_BUTTON))
		{
			LB.y = LB_Y + 5;
		}
		else
		{
			LB.y = LB_Y;
		}
		
		if (gamePad.pressed(XBOX_BUTTON_IDS.RB_BUTTON))
		{
			RB.y = RB_Y + 5;
		}
		else
		{
			RB.y = RB_Y;
		}
		
		if (gamePad.pressed(XBOX_BUTTON_IDS.START_BUTTON))
		{
			start.alpha = onAlpha;
		}
		else
		{
			start.alpha = offAlpha;
		}
		
		if (gamePad.pressed(XBOX_BUTTON_IDS.BACK_BUTTON))
		{
			back.alpha = onAlpha;
		}
		else
		{
			back.alpha = offAlpha;
		}
		
		var angle:Float = 0;
		
		if (Math.abs(gamePad.getAxis(XBOX_BUTTON_IDS.LEFT_ANALOGUE_X)) > gamePad.deadZone || Math.abs(gamePad.getAxis(XBOX_BUTTON_IDS.LEFT_ANALOGUE_Y)) > gamePad.deadZone)
		{
			angle = Math.atan2(gamePad.getAxis(XBOX_BUTTON_IDS.LEFT_ANALOGUE_Y), gamePad.getAxis(XBOX_BUTTON_IDS.LEFT_ANALOGUE_X));
			leftStick.x = LEFT_STICK_POS.x + STICK_MOVEMENT_RANGE * Math.cos(angle);
			leftStick.y = LEFT_STICK_POS.y + STICK_MOVEMENT_RANGE * Math.sin(angle);
			leftStick.alpha = onAlpha;
		}
		else
		{
			leftStick.x = LEFT_STICK_POS.x;
			leftStick.y = LEFT_STICK_POS.y;
			leftStick.alpha = offAlpha;
		}
		
		if (Math.abs(gamePad.getAxis(XBOX_BUTTON_IDS.RIGHT_ANALOGUE_X)) > gamePad.deadZone || Math.abs(gamePad.getAxis(XBOX_BUTTON_IDS.RIGHT_ANALOGUE_Y)) > gamePad.deadZone)
		{
			angle = Math.atan2(gamePad.getAxis(XBOX_BUTTON_IDS.RIGHT_ANALOGUE_Y), gamePad.getAxis(XBOX_BUTTON_IDS.RIGHT_ANALOGUE_X));
			rightStick.x = RIGHT_STICK_POS.x + STICK_MOVEMENT_RANGE * Math.cos(angle);
			rightStick.y = RIGHT_STICK_POS.y + STICK_MOVEMENT_RANGE * Math.sin(angle);
			rightStick.alpha = onAlpha;
		}
		else
		{
			rightStick.x = RIGHT_STICK_POS.x;
			rightStick.y = RIGHT_STICK_POS.y;
			rightStick.alpha = offAlpha;
		}
		
		if (gamePad.hat.x != 0 || gamePad.hat.y != 0)
		{
			if (gamePad.hat.x > 0)
			{
				if (gamePad.hat.y > 0)
				{
					dPad.frame = 6;
				}
				else if (gamePad.hat.y < 0)
				{
					dPad.frame = 5;
				}
				else	// gamePad.hat.y == 0
				{
					dPad.frame = 2;
				}
			}
			else if (gamePad.hat.x < 0)
			{
				if (gamePad.hat.y > 0)
				{
					dPad.frame = 7;
				}
				else if (gamePad.hat.y < 0)
				{
					dPad.frame = 8;
				}
				else	// gamePad.hat.y == 0
				{
					dPad.frame = 4;
				}
			}
			else	// gamePad.hat.x == 0
			{
				if (gamePad.hat.y > 0)
				{
					dPad.frame = 3;
				}
				else if (gamePad.hat.y < 0)
				{
					dPad.frame = 1;
				}
			}
			dPad.alpha = onAlpha;
		}
		else
		{
			dPad.frame = 0;
			dPad.alpha = offAlpha;
		}
	}
}