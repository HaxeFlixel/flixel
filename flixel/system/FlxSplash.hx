package flixel.system;

import flash.display.Graphics;
import flash.display.Sprite;
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
	
	public function new(NextState:Class<FlxState>)
	{
		_nextState = NextState;
		super();
	}
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = FlxColor.BLACK;
		FlxG.fixedTimestep = false;
		FlxG.autoPause = false;
		FlxG.keys.enabled = false;
		
		_times = [0.041, 0.184, 0.334, 0.495, 0.636];
		_colors = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb];
		_functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue];
		
		for (time in _times)
		{
			FlxTimer.start(time, timerCallback);
		}
		
		_sprite = new Sprite();
		_sprite.x = FlxG.width * FlxCamera.defaultZoom / 2 - 50;
		_sprite.y = FlxG.height * FlxCamera.defaultZoom / 2 - 70;
		FlxG.stage.addChild(_sprite);
		_gfx = _sprite.graphics;
		
		_text = new TextField();
		_text.selectable = false;
		_text.embedFonts = true;
		_text.width = FlxG.width * FlxCamera.defaultZoom;
		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 16, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		_text.defaultTextFormat = dtf;
		_text.text = "HaxeFlixel";
		_text.y = _sprite.y + 130;
		_text.alpha = 0;
		FlxG.stage.addChild(_text);
		
		FlxTween.varTween(_text, { alpha: 1 }, 1 );
		FlxG.sound.play(FlxAssets.SND_FLIXEL);
	}
	
	inline private function timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();
		_text.textColor = _colors[_curPart];
		_curPart ++;
		
		if (_curPart == 5)
		{
			FlxTween.varTween(_sprite, { alpha: 0 }, 2.3, { ease: FlxEase.quadOut, complete: onComplete } );
			FlxTween.varTween(_text, { alpha: 0 }, 2.3, { ease: FlxEase.quadOut } );
		}
	}
	
	inline private function drawGreen():Void
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
	
	inline private function drawYellow():Void
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
	
	inline private function drawRed():Void
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
	
	inline private function drawBlue():Void
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
	
	inline private function drawLightBlue():Void
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
	
	inline private function onComplete(Tween:FlxTween):Void
	{
		FlxG.fixedTimestep = true;
		FlxG.autoPause = true;
		FlxG.keys.enabled = true;
		FlxG.stage.removeChild(_sprite);
		FlxG.stage.removeChild(_text);
		FlxG.switchState(Type.createInstance(_nextState, []));
	}
}