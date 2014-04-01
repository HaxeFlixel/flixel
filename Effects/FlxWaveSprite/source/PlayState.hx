package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.touch.FlxTouch;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxSpriteUtil;
import flixel.addons.effects.FlxWaveSprite;

class PlayState extends FlxState
{

	private var _wavLogo:FlxWaveSprite;
	
	private var modes:Array<String>;
	private var mode:Int = 0;
	private var strength:Int = 20;
	private var center:Int = 0;
	private var speed:Float = 4;
	
	private var _txtMode:FlxText;
	private var _txtStr:FlxText;
	private var _txtCenter:FlxText;
	private var _txtSpeed:FlxText;
	
	override public function create():Void
	{
		modes =  ["ALL", "BOTTOM", "TOP"];
		var _sprLogo:FlxSprite = new FlxSprite(0, 0, "assets/images/HaxeFlixel.png");
		FlxSpriteUtil.screenCenter(_sprLogo);
		
		strength = 20;
		mode = 0;
		
		_wavLogo = new FlxWaveSprite(_sprLogo, FlxWaveSprite.MODE_ALL, strength);
		add(_wavLogo);
		center = Std.int( _wavLogo.height / 2);
		_wavLogo.center = center;
		
		var _txtInstruct:FlxText;
		
		#if !FLX_NO_KEYBOARD
		_txtInstruct = new FlxText(0, 0, FlxG.width, "Space to Cycle Modes", 8);
		_txtInstruct.alignment = "center";
		add(_txtInstruct);
		_txtInstruct = new FlxText(0, _txtInstruct.y+_txtInstruct.height-4, FlxG.width, "Left/Right to adjust strength", 8);
		_txtInstruct.alignment = "center";
		add(_txtInstruct);
		_txtInstruct = new FlxText(0, _txtInstruct.y+_txtInstruct.height-4, FlxG.width, "Up/Down to adjust center", 8);
		_txtInstruct.alignment = "center";
		add(_txtInstruct);
		_txtInstruct = new FlxText(0, _txtInstruct.y+_txtInstruct.height-4, FlxG.width, "W/S to adjust speed", 8);
		_txtInstruct.alignment = "center";
		add(_txtInstruct);
		#else
		_txtInstruct = new FlxText(0, 0, FlxG.width, "Touch to Cycle Modes", 8);
		_txtInstruct.alignment = "center";
		add(_txtInstruct);
		#end
		
		var w:Int = Std.int((FlxG.width) / 4);
		var a:Array<FlxObject> = [];
		
		_txtMode = new FlxText(0, 0, w, "Mode: " + modes[mode]);
		_txtMode.alignment = "center";
		add(_txtMode);
		a.push(_txtMode);
		
		_txtStr = new FlxText(0, 0, w, "Strength: " + Std.string(strength));
		_txtStr.alignment = "center";
		add(_txtStr);
		a.push(_txtStr);
		
		_txtCenter = new FlxText(0, 0, w, "Center: " + Std.string(center));
		_txtCenter.alignment = "center";
		add(_txtCenter);
		a.push(_txtCenter);
		
		_txtSpeed = new FlxText(0, 0, w, "Speed: " + Std.string(speed));
		_txtSpeed.alignment = "center";
		add(_txtSpeed);
		a.push(_txtSpeed);
		
		FlxSpriteUtil.space(a, 0, Std.int(FlxG.height - _txtSpeed.height),w);

		super.create();
		
	}
	
	override public function update():Void
	{
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.anyJustReleased(["SPACE"]))
		{
			mode++;
			if (mode > 2)
				mode = 0;
			_txtMode.text = "Mode: " + modes[mode];
			_wavLogo.mode = mode;
		}
		if (FlxG.keys.anyPressed(["RIGHT"]))
		{
			strength += 5;
			if (strength > 500)
				strength = 500;
			_txtStr.text = "Strength: " + Std.string(strength);
			_wavLogo.strength = strength;
		}
		if (FlxG.keys.anyPressed(["LEFT"]))
		{
			strength -= 5;
			if (strength < 0)
				strength = 0;
			_txtStr.text = "Strength: " + Std.string(strength);
			_wavLogo.strength = strength;
		}
		
		if (FlxG.keys.anyPressed(["UP"]))
		{
			center--;
			if (center < 0)
				center = 0;
			_txtCenter.text = "Center: " + Std.string(center);
			_wavLogo.center = center;
		}
		if (FlxG.keys.anyPressed(["DOWN"]))
		{
			center++;
			if (center > _wavLogo.height)
				center = Std.int(_wavLogo.height);
			_txtCenter.text = "Center: " + Std.string(center);
			_wavLogo.center = center;
		}
		if (FlxG.keys.anyPressed(["W"]))
		{
			speed++;
			if (speed > 80)
				speed = 80;
			_txtSpeed.text = "Speed: " + Std.string(speed);
			_wavLogo.speed = speed;
		}
		if (FlxG.keys.anyPressed(["S"]))
		{
			speed--;
			if (speed < 0)
				speed = 0;
			_txtSpeed.text = "Speed: " + Std.string(speed);
			_wavLogo.speed = speed;
		}
		#end
		
		#if !FLX_NO_TOUCH
		if (FlxG.touches.justStarted().length > 0)
		{
			mode++;
			if (mode > 2)
				mode = 0;
			_txtMode.text = "Mode: " + modes[mode];
			_wavLogo.mode = mode;
		}
		#end
		
		super.update();
		
		
	}	
}