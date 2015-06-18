package;

import flixel.addons.effects.FlxRainbowSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
using flixel.util.FlxSpriteUtil;
using StringTools;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	#if !FLX_NO_KEYBOARD
	private static inline var INSTRUCTIONS = "Left/Right to adjust change speed\nUp/Down to adjust alpha";
	private static inline var STATUS = "Speed: [speed]    Alpha: [alpha]";
	#end
	
	private var _rainbow:FlxRainbowSprite;
	private var _statusText:FlxText;
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		var target:FlxSprite = new FlxSprite(0, 0, FlxGraphic.fromClass(GraphicLogo));
		target.screenCenter(true, true);
		add(target);
		
		_rainbow = new FlxRainbowSprite(target);
		_rainbow.alpha = .5;
		add(_rainbow);
		#if !FLX_NO_KEYBOARD
		var txtInst:FlxText = new FlxText(0, 5, FlxG.width, INSTRUCTIONS);
		txtInst.alignment = FlxTextAlign.CENTER;
		add(txtInst);
		
		_statusText = new FlxText(0, FlxG.height - 15, FlxG.width, STATUS);
		_statusText.alignment = FlxTextAlign.CENTER;
		add(_statusText);
		#end
		super.create();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.pressed.LEFT)
			_rainbow.changeSpeed--;
		if (FlxG.keys.pressed.RIGHT)
			_rainbow.changeSpeed++;
		if (FlxG.keys.pressed.UP)
			_rainbow.alpha+=.01;
		if (FlxG.keys.pressed.DOWN)
			_rainbow.alpha-=.01;
		
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
								.replace("[alpha]", Std.string(Std.int(_rainbow.alpha * 100)) + '%');
	}
	#end
	
}
