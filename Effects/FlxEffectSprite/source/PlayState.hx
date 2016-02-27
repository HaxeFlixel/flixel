package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.addons.effects.chainable.FlxTrailEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.IFlxEffect;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var _sprite:FlxSprite;
	private var _effectSprite:FlxEffectSprite;
	
	private var _rainbow:FlxRainbowEffect;
	private var _outline:FlxOutlineEffect;
	private var _wave:FlxWaveEffect;
	private var _glitch:FlxGlitchEffect;
	private var _trail:FlxTrailEffect;
	private var _shake:FlxShakeEffect;
	
	private var _tween:FlxTween;
	
	override public function create():Void
	{
		super.create();
		
		// Target Sprite
		_sprite = new FlxSprite();
		_sprite.loadGraphic("assets/flags.png", true, 140, 140);
		_sprite.animation.add("anim", [0, 1, 2, 3], 3, true);
		_sprite.animation.play("anim");
		_sprite.screenCenter();
		
		// Effect Sprite
		add(_effectSprite = new FlxEffectSprite(_sprite));
		
		// Effects
		_rainbow = new FlxRainbowEffect(0.5);
		_outline = new FlxOutlineEffect(FlxColor.RED, 8);
		_wave = new FlxWaveEffect(FlxWaveMode.ALL);
		_glitch = new FlxGlitchEffect(10, 2, 0.1);
		_trail = new FlxTrailEffect(_effectSprite, 10, 0.5, 8);
		_shake = new FlxShakeEffect(10, 1);
		
		_effectSprite.effects = [_rainbow, _outline, _wave, _glitch, _trail, _shake];
		
		createButtons();
		
		_tween = FlxTween.circularMotion(_effectSprite,
			(FlxG.width * 0.5) - (_sprite.width / 2), 
			(FlxG.height * 0.5) - (_sprite.height / 2),
			_sprite.width, 359,
			true, 3, true, { type: FlxTween.PINGPONG });
	}	
	
	function createButtons() 
	{
		addToggleActiveButton(30, 400, "Rainbow", _rainbow);
		addToggleActiveButton(130, 400, "Outline", _outline);
		addToggleActiveButton(230, 400, "Wave", _wave);
		addToggleActiveButton(330, 400, "Glitch", _glitch);
		addToggleActiveButton(430, 400, "Trail", _trail);
		add(new FlxButton(530, 400, "Shake", function() _shake.start()));
		
		add(new FlxButton(230, 425, "Direction", function()
		{
			_wave.direction = switch (_wave.direction) 
			{
				case FlxWaveDirection.VERTICAL: FlxWaveDirection.HORIZONTAL;
				default: FlxWaveDirection.VERTICAL;
			}
		}));
		add(new FlxButton(230, 450, "Mode", function()
		{
			_wave.mode = switch (_wave.mode) 
			{
				case FlxWaveMode.ALL: FlxWaveMode.START;
				case FlxWaveMode.START: FlxWaveMode.END;
				default: FlxWaveMode.ALL;
			}
		}));
		add(new FlxButton(330, 425, "Direction", function()
		{
			_glitch.direction = switch (_glitch.direction) 
			{
				case FlxGlitchDirection.VERTICAL: FlxGlitchDirection.HORIZONTAL;
				default: FlxGlitchDirection.VERTICAL;
			}
		}));
	}
	
	function addToggleActiveButton(x:Float, y:Float, label:String, effect:IFlxEffect):Void
	{
		var button = new FlxButton(x, y, label);
		button.onUp.callback = function()
		{
			effect.active = !effect.active;
			button.alpha = effect.active ? 1 : 0.6;
		}
		add(button);
	}

	override public function update(elapsed:Float):Void
	{
		_tween.active = _trail.active;
		if (!_trail.active)
		{
			_effectSprite.setPosition(_sprite.x, _sprite.y);
		}
		
		super.update(elapsed);
	}
}
