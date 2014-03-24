package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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
	
	private var _txtMode:FlxText;
	private var _txtStr:FlxText;
	private var _txtCenter:FlxText;
	
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
		_txtInstruct = new FlxText(0, 0, FlxG.width, "Space to Cycle Modes", 12);
		_txtInstruct.alignment = "center";
		add(_txtInstruct);
		_txtInstruct = new FlxText(0, _txtInstruct.y+_txtInstruct.height, FlxG.width, "Left/Right to adjust strength", 12);
		_txtInstruct.alignment = "center";
		add(_txtInstruct);
		_txtInstruct = new FlxText(0, _txtInstruct.y+_txtInstruct.height, FlxG.width, "Up/Down to adjust center", 12);
		_txtInstruct.alignment = "center";
		add(_txtInstruct);
		
		_txtMode = new FlxText(10, 0, 200, "Mode: " + modes[mode]);
		_txtMode.y = FlxG.height - _txtMode.height - 4;
		add(_txtMode);
		
		_txtStr = new FlxText(0, 0, 200, "Strength: " + Std.string(strength));
		_txtStr.alignment = "center";
		_txtStr.y = FlxG.height - _txtStr.height - 4;
		FlxSpriteUtil.screenCenter(_txtStr, true, false);
		add(_txtStr);
		
		_txtCenter = new FlxText(FlxG.width-210, 0, 200, "Center: " + Std.string(center));
		_txtCenter.alignment = "right";
		_txtCenter.y = FlxG.height - _txtCenter.height - 4;
		
		add(_txtCenter);
		
		
		
		
		super.create();
		
	}
	
	override public function update():Void
	{
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
		
		super.update();
	}	
}