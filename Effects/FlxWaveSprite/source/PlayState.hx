package;

import flixel.addons.effects.FlxWaveSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
using StringTools;

class PlayState extends FlxState
{
	private static inline var INSTRUCTIONS = #if !mobile
	                                         "Space to cycle Directions\n" +
	                                         "Enter to cycle Modes\n" +
	                                         "Left/Right to adjust strength\n" +
	                                         "Up/Down to adjust center\n" +
	                                         "W/S to adjust speed\n" +
	                                         "A/D to adjust wavelength"; 
	                                         #else
	                                         "1 Touches to cycle Directions\n" +
	                                         "2 Touch to cycle Modes";
	                                         #end
	
	private static inline var STATUS = "Direction: [dir]    Mode: [mode]\nStrength: [strength]    Center: [center]    Speed: [speed]    Wavelength: [wave]";
	
	private var _waveSprite:FlxWaveSprite;
	private var _statusText:FlxText;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		var _sprite = new FlxSprite(0, 0, FlxGraphic.fromClass(GraphicLogo));
		_sprite.screenCenter();
		_sprite.y += 10;
		
		_waveSprite = new FlxWaveSprite(_sprite);
		add(_waveSprite);
		
		var _txtInstruct:FlxText = new FlxText(0, 5, FlxG.width, INSTRUCTIONS);
		_txtInstruct.alignment = CENTER;
		add(_txtInstruct);
		
		_statusText = new FlxText(0, FlxG.height - 25, FlxG.width);
		_statusText.alignment = CENTER;
		add(_statusText);
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void
	{
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justReleased.SPACE)
			incrementDirection();
			
		if (FlxG.keys.justReleased.ENTER)
			incrementMode();
		
		// control center
		if (FlxG.keys.pressed.UP)
			_waveSprite.center++;
		if (FlxG.keys.pressed.DOWN)
			_waveSprite.center--;
			
		// control strength
		if (FlxG.keys.pressed.LEFT)
			_waveSprite.strength -= 5;
		if (FlxG.keys.pressed.RIGHT)
			_waveSprite.strength += 5;
		
		// control speed
		if (FlxG.keys.pressed.W)
			_waveSprite.speed++;
		if (FlxG.keys.pressed.S)
			_waveSprite.speed--;
		
		//control wavelength
		if (FlxG.keys.pressed.D)
			_waveSprite.wavelength++;
		if (FlxG.keys.pressed.A)
			_waveSprite.wavelength--;
		#end
		
		#if !FLX_NO_TOUCH
		if (FlxG.touches.justStarted().length > 0)
		{
			if (FlxG.touches.justStarted().length == 1)
				incrementDirection();
			else
				incrementMode();
		}
		#end
		
		boundValues();
		updateStatusText();
		super.update(elapsed);
	}
	
	private function boundValues():Void
	{
		_waveSprite.center = Std.int(FlxMath.bound(_waveSprite.center, 0, _waveSprite.height));
		_waveSprite.strength = Std.int(FlxMath.bound(_waveSprite.strength, 0, 500));
		_waveSprite.speed = FlxMath.bound(_waveSprite.speed, 0, 80);
		_waveSprite.wavelength = Std.int(FlxMath.bound(_waveSprite.wavelength, 1, 20));
	}
	
	private function incrementDirection():Void
	{
		_waveSprite.direction = switch (_waveSprite.direction)
		{
			case VERTICAL: HORIZONTAL;
			case HORIZONTAL: VERTICAL;
		}
	}
	
	private function incrementMode():Void
	{
		_waveSprite.mode = switch (_waveSprite.mode)
		{
			case ALL: START;
			case START: END;
			case END: ALL;
		}
	}
	
	private function updateStatusText():Void 
	{
		_statusText.text = STATUS.replace("[dir]", Std.string(_waveSprite.direction))
		                         .replace("[mode]", Std.string(_waveSprite.mode))
		                         .replace("[strength]", Std.string(_waveSprite.strength))
		                         .replace("[center]",  Std.string(_waveSprite.center))
		                         .replace("[speed]",  Std.string(_waveSprite.speed))
		                         .replace("[wave]",  Std.string(_waveSprite.wavelength));
	}
}
