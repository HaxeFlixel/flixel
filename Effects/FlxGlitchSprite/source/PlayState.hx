package;

import flixel.addons.effects.FlxGlitchSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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
	private static inline var INSTRUCTIONS = #if !mobile
	                                         "Space to Toggle Direction\n" +
	                                         "Left/Right to adjust strength\n" + 
	                                         "Up/Down to adjust size\n" +
	                                         "W/S to adjust delay";
	                                         #else
	                                         "Touch to Toggle Direction"
	                                         #end
	
	private static inline var STATUS = "Dir: [direction]    Strength: [strength]    Size: [size]    Delay: [delay]";
	
	private var _glitch:FlxGlitchSprite;
	private var _statusText:FlxText;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		var target:FlxSprite = new FlxSprite(0, 0, GraphicLogo);
		target.screenCenter();
		target.y += 10;
		
		_glitch = new FlxGlitchSprite(target);
		add(_glitch);
		
		var txtInst:FlxText = new FlxText(0, 5, FlxG.width, INSTRUCTIONS);
		txtInst.alignment = CENTER;
		add(txtInst);
		
		_statusText = new FlxText(0, FlxG.height - 15, FlxG.width);
		_statusText.alignment = CENTER;
		add(_statusText);
		
		super.create();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justReleased.SPACE)
			toggleMode();
		
		// control size
		if (FlxG.keys.pressed.UP)
			_glitch.size++;
		if (FlxG.keys.pressed.DOWN)
			_glitch.size--;
		
		// control strength
		if (FlxG.keys.pressed.LEFT)
			_glitch.strength -= 2;
		if (FlxG.keys.pressed.RIGHT)
			_glitch.strength += 2;
		
		// control delay
		if (FlxG.keys.pressed.W)
			_glitch.delay += .01;
		if (FlxG.keys.pressed.S)
			_glitch.delay -= .01;
		#end
		
		#if !FLX_NO_TOUCH
		if (FlxG.touches.justStarted().length > 0)
			toggleMode();
		#end
		
		boundValues();
		updateStatusText();
		
		super.update(elapsed);
	}
	
	private function boundValues():Void
	{
		_glitch.size = Std.int(FlxMath.bound(_glitch.size, 1, _glitch.height));
		_glitch.strength = Std.int(FlxMath.bound(_glitch.strength, 0, 80));
		_glitch.delay = FlxMath.bound(_glitch.delay, 0.01, 0.5);
	}
	
	private function toggleMode():Void
	{
		if (_glitch.direction == HORIZONTAL)
			_glitch.direction = VERTICAL;
		else	
			_glitch.direction = HORIZONTAL;
	}
	
	private function updateStatusText():Void
	{
		_statusText.text = STATUS.replace("[direction]", Std.string(_glitch.direction))
	                             .replace("[strength]", Std.string(_glitch.strength))
	                             .replace("[size]", Std.string(_glitch.size))
	                             .replace("[delay]", Std.string(FlxMath.roundDecimal(_glitch.delay,2)));
	}
}