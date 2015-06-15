package;

import flixel.addons.effects.FlxGlitchSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.input.touch.FlxTouch;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.geom.Rectangle;

class MessagePopup extends FlxSubState
{
	private var _back:FlxSprite;
	private var _box:FlxUI9SliceSprite;
	private var _face:FlxSprite;
	private var _glitchFace:FlxGlitchSprite;
	private var _glitchAmt:Int;
	private var _glitchTimer:Float;
	private var _talkTimer:Float;
	private var _text:FlxText;
	private var _textContinue:FlxText;
	
	private var _fadingIn:Bool = true;
	private var _alpha:Float = 0;
	private var _fadingOut:Bool = false;
	
	public function new(CloseCallback:Void->Void) 
	{
		super(0);
		
		closeCallback  = CloseCallback;
		
		_back = new FlxSprite(0, 0);
		_back.makeGraphic(FlxG.width, FlxG.height, 0x99000000);
		
		_box = new FlxUI9SliceSprite(0, 0, AssetPaths.border__png,
			new Rectangle(0, 0, FlxG.width - 120, FlxG.height - 100), [3, 3, 9, 9]);
		_box.x = 60;
		_box.y = 50;
		
		_face = new FlxSprite(_box.x  + 8, _box.y + 8);
		_face.loadGraphic(AssetPaths.commander__png, true, 24, 36);
		_face.animation.add("talk", [0, 1], 0);
		_face.animation.play("talk");
		_face.animation.pause();
		_face.animation.randomFrame();
		
		_glitchAmt = Math.floor(FlxG.random.float(0, 10) / 4);
		_talkTimer = Math.floor(FlxG.random.float(0, 10) / 2);
		_glitchTimer = Math.floor(FlxG.random.float(0, 10) / 2);
		
		_glitchFace = new FlxGlitchSprite(_face, _glitchAmt, 1, 0.05, FlxGlitchDirection.HORIZONTAL);
		
		_text = new FlxText(_face.x + _face.width + 8, _face.y, _box.width - 16 - _face.width -8, "Go get 'em, Pilot!\nYou can do it!", 12);
		_text.alignment = FlxTextAlign.CENTER;
		_text.color = 0x99ff99;
		_text.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xff339933, 2, 1);
		
		
		_textContinue = new FlxText(_box.x + 8, _box.y + _box.height - 28, _box.width - 16, "Press X to Start", 12);
		#if FLX_NO_KEYBOARD
		_textContinue.text = "Tap to Start";
		#end
		
		_textContinue.alignment = FlxTextAlign.CENTER;
		_textContinue.color = 0x99ff99;
		_textContinue.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xff339933, 2, 1);
		
		add(_back);
		add(_box);
		add(_glitchFace);
		add(_text);
		add(_textContinue);
		
		forEachOfType(FlxSprite, function(sprite) {
			sprite.alpha = 0;
		});
		
		FlxTween.num(0, 1, .66, { type:FlxTween.ONESHOT, ease:FlxEase.sineOut, onComplete:function(_) {
			_fadingIn = false;
		}}, updateAlpha);
	}
	
	private function updateAlpha(A:Float):Void
	{
		_back.alpha = _box.alpha = _glitchFace.alpha = _text.alpha = _textContinue.alpha = A;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (_glitchTimer <= 0)
		{
			_glitchTimer = Math.floor(FlxG.random.float(0, 5) / 2);
			_glitchAmt = Math.floor(FlxG.random.float(0, 5) / 4);
			_glitchFace.strength = _glitchAmt;
		}
		else
		{
			_glitchTimer -= FlxG.elapsed * 20;
		}
		
		if (_talkTimer <= 0)
		{
			_talkTimer = Math.floor(FlxG.random.float(0, 5) / 2);
			_face.animation.randomFrame();
		}
		else
		{
			_talkTimer -= FlxG.elapsed * 20;
		}
		if (!_fadingIn && !_fadingOut)
		{
			#if !FLX_NO_KEYBOARD
			if (FlxG.keys.anyJustReleased([X]))
			{
				_fadingOut = true;
				FlxTween.num(1, 0, .66, { type:FlxTween.ONESHOT, ease:FlxEase.circOut, onComplete:function(_) {
					close();
				}},updateAlpha);
			}
			#end
			#if android
			var t:FlxTouch = FlxG.touches.getFirst();
			if (t != null)
			{
				if (t.justReleased)
				{
					_fadingOut = true;
					FlxTween.num(1, 0, .66, { type:FlxTween.ONESHOT, ease:FlxEase.circOut, onComplete:function(_) {
						close();
					}}, updateAlpha);
				}
			}
			#end
		}
	}
}