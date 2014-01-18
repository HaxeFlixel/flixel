package flixel.system;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class FlxSplash extends FlxState
{
	private var _nextState:Class<FlxState>;

	private var _sprite:Sprite;
	private var _gfx:Graphics;
	private var _text:TextField;
	
	private var _times:Array<Float>;
	private var _colors:Array<Int>;
	private var _functions:Array<Void->Void>;
	private var _curPart:Int = 0;
	private var _cachedBgColor:Int;
	private var _cachedTimestep:Bool;
	private var _cachedAutoPause:Bool;
	
	public function new(NextState:Class<FlxState>)
	{
		_nextState = NextState;
		super();
	}
	
	override public function create():Void
	{
		_cachedBgColor = FlxG.cameras.bgColor;
		FlxG.cameras.bgColor = FlxColor.BLACK;
		
		// This is required for sound and animation to synch up properly
		_cachedTimestep = FlxG.fixedTimestep;
		FlxG.fixedTimestep = false; 
		
		_cachedAutoPause = FlxG.autoPause;
		FlxG.autoPause = false;
		
		#if !FLX_NO_KEYBOARD
			FlxG.keyboard.enabled = false;
		#end
		
		_times = [0.041, 0.184, 0.334, 0.495, 0.636];
		_colors = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb];
		_functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue];
		
		for (time in _times)
		{
			FlxTimer.start(time, timerCallback);
		}
		
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		_sprite = new Sprite();
		_sprite.x = (stageWidth / 2) - 50;
		_sprite.y = (stageHeight / 2) - 70;
		FlxG.stage.addChild(_sprite);
		_gfx = _sprite.graphics;
		
		_text = new TextField();
		_text.selectable = false;
		_text.embedFonts = true;
		_text.width = stageWidth;
		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 16, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		_text.defaultTextFormat = dtf;
		_text.text = "HaxeFlixel";
		_text.y = _sprite.y + 130;
		FlxG.stage.addChild(_text);
		
		#if !FLX_NO_SOUND_SYSTEM
		FlxG.sound.play(FlxAssets.SND_FLIXEL);
		#end
	}
	
	private function timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();
		_text.textColor = _colors[_curPart];
		_text.text = "HaxeFlixel";
		_curPart ++;
		
		if (_curPart == 5)
		{
			// Make the logo a tad bit longer, so our users fully appreciate our hard work :D
			FlxTween.multiVar(_sprite, { alpha: 0 }, 3.0, { ease: FlxEase.quadOut, complete: onComplete } );
			FlxTween.multiVar(_text, { alpha: 0 }, 3.0, { ease: FlxEase.quadOut } );
		}
	}
	
	private function drawGreen():Void
	{
		_gfx.beginFill(0x00b922);
		_gfx.moveTo(50, 13);
		_gfx.lineTo(51, 13);
		_gfx.lineTo(87, 50);
		_gfx.lineTo(87, 51);
		_gfx.lineTo(51, 87);
		_gfx.lineTo(50, 87);
		_gfx.lineTo(13, 51);
		_gfx.lineTo(13, 50);
		_gfx.lineTo(50, 13);
		_gfx.endFill();
	}
	
	private function drawYellow():Void
	{
		_gfx.beginFill(0xffc132);
		_gfx.moveTo(0, 0);
		_gfx.lineTo(25, 0);
		_gfx.lineTo(50, 13);
		_gfx.lineTo(13, 50);
		_gfx.lineTo(0, 25);
		_gfx.lineTo(0, 0);
		_gfx.endFill();
	}
	
	private function drawRed():Void
	{
		_gfx.beginFill(0xf5274e);
		_gfx.moveTo(100, 0);
		_gfx.lineTo(75, 0);
		_gfx.lineTo(51, 13);
		_gfx.lineTo(87, 50);
		_gfx.lineTo(100, 25);
		_gfx.lineTo(100, 0);
		_gfx.endFill();
	}
	
	private function drawBlue():Void
	{
		_gfx.beginFill(0x3641ff);
		_gfx.moveTo(0, 100);
		_gfx.lineTo(25, 100);
		_gfx.lineTo(50, 87);
		_gfx.lineTo(13, 51);
		_gfx.lineTo(0, 75);
		_gfx.lineTo(0, 100);
		_gfx.endFill();
	}
	
	private function drawLightBlue():Void
	{
		_gfx.beginFill(0x04cdfb);
		_gfx.moveTo(100, 100);
		_gfx.lineTo(75, 100);
		_gfx.lineTo(51, 87);
		_gfx.lineTo(87, 51);
		_gfx.lineTo(100, 75);
		_gfx.lineTo(100, 100);
		_gfx.endFill();
	}
	
	private function onComplete(Tween:FlxTween):Void
	{
		FlxG.cameras.bgColor = _cachedBgColor;
		FlxG.fixedTimestep = _cachedTimestep;
		FlxG.autoPause = _cachedAutoPause;
		#if !FLX_NO_KEYBOARD
			FlxG.keyboard.enabled = true;
		#end
		FlxG.stage.removeChild(_sprite);
		FlxG.stage.removeChild(_text);
		FlxG.switchState(Type.createInstance(_nextState, []));
	}
}