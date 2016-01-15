package;

import flixel.addons.effects.FlxRainbowSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.GraphicLogo;
import flixel.text.FlxText;
using StringTools;

class PlayState extends FlxState
{
	#if !FLX_NO_KEYBOARD
	private static inline var INSTRUCTIONS = "Left/Right to adjust change speed\nUp/Down to adjust alpha";
	private static inline var STATUS = "Speed: [speed]    Alpha: [alpha]";
	#end
	
	private var _rainbow:FlxRainbowSprite;
	private var _statusText:FlxText;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		var target = new FlxSprite(0, 0, FlxGraphic.fromClass(GraphicLogo));
		target.screenCenter();
		add(target);
		
		_rainbow = new FlxRainbowSprite(target);
		_rainbow.alpha = .5;
		add(_rainbow);
		
		#if !FLX_NO_KEYBOARD
		var txtInst = new FlxText(0, 5, FlxG.width, INSTRUCTIONS);
		txtInst.alignment = FlxTextAlign.CENTER;
		add(txtInst);
		
		_statusText = new FlxText(0, FlxG.height - 15, FlxG.width, STATUS);
		_statusText.alignment = FlxTextAlign.CENTER;
		add(_statusText);
		#end
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.pressed.LEFT)
			_rainbow.changeSpeed--;
		if (FlxG.keys.pressed.RIGHT)
			_rainbow.changeSpeed++;
		if (FlxG.keys.pressed.UP)
			_rainbow.alpha += .01;
		if (FlxG.keys.pressed.DOWN)
			_rainbow.alpha -= .01;
		
		boundValues();
		updateStatusText();
		#end
		
		super.update(elapsed);
	}

	#if !FLX_NO_KEYBOAD
	private function boundValues():Void
	{
		_rainbow.changeSpeed = Std.int(FlxMath.bound(_rainbow.changeSpeed, 1, 10));
	}

	private function updateStatusText():Void
	{
		_statusText.text = STATUS.replace("[speed]", Std.string(_rainbow.changeSpeed))
		                         .replace("[alpha]", Std.int(_rainbow.alpha * 100) + '%');
	}
	#end
}
