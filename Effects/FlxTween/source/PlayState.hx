package;

import flixel.effects.FlxTrail;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.AngleTween;
import flixel.tweens.misc.ColorTween;
import flixel.tweens.misc.MultiVarTween;
import flixel.tweens.misc.NumTween;
import flixel.tweens.misc.VarTween;
import flixel.tweens.motion.CircularMotion;
import flixel.tweens.motion.CubicMotion;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.motion.LinearPath;
import flixel.tweens.motion.QuadMotion;
import flixel.tweens.motion.QuadPath;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.util.FlxStringUtil;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween.TweenOptions;

/**
 * Tweening demo.
 *
 * @author Devolonter
 * @link https://github.com/devolonter/flixel-monkey-bananas/tree/master/tweening
 */
class PlayState extends FlxState
{
	inline static private var MAX_TWEEN:Int = 8;
	/**
	 * The duration of the tween
	 */
	inline static private var DURATION:Float = 1;
	inline static private var INSTRUCTIONS:String = "Press UP or DOWN keys to change tweening. Press SPACE to change current ease function";

	/**
	 * The tween types
	 */
	inline static private var VAR:Int = 0;
	inline static private var MULTI_VAR:Int = 1;
	inline static private var ANGLE:Int = 2;
	inline static private var LINEAR_MOTION:Int = 3;
	inline static private var LINEAR_PATH:Int = 4;
	inline static private var CIRCULAR_MOTION:Int = 5;
	inline static private var CUBIC_MOTION:Int = 6;
	inline static private var QUAD_MOTION:Int = 7;
	inline static private var QUAD_PATH:Int = 8;

	private var _easeInfo:Array<EaseInfo>;
	private var _currentEaseIndex:Int;
	private var _tween:FlxTween;
	private var _currentTweenIndex:Int;
	private var _sprite:FlxSprite;
	private var _trail:FlxTrail;
	private var _min:FlxPoint;
	private var _max:FlxPoint;
	private var _easeText:FlxText;
	private var _tweenText:FlxText;
	private var _helpText:FlxText;
	private var _toggleButton:FlxButton;

	override public function create():Void
	{
		FlxG.cameras.bgColor = FlxColor.BLACK;
		FlxG.mouse.show();

		// Set up an array containing all the different ease functions there are
		_easeInfo = new Array<EaseInfo>();

		_easeInfo.push( { name: "quadIn",  		ease: FlxEase.quadIn 		} );
		_easeInfo.push( { name: "quadOut",  	ease: FlxEase.quadOut 		} );
		_easeInfo.push( { name: "cubeIn",  		ease: FlxEase.cubeIn 		} );
		_easeInfo.push( { name: "cubeOut",  	ease: FlxEase.cubeOut 		} );
		_easeInfo.push( { name: "cubeInOut", 	ease: FlxEase.cubeInOut 	} );
		_easeInfo.push( { name: "quartIn",  	ease: FlxEase.quartIn 		} );
		_easeInfo.push( { name: "quartOut",  	ease: FlxEase.quartOut 		} );
		_easeInfo.push( { name: "quartInOut",  	ease: FlxEase.quartInOut 	} );
		_easeInfo.push( { name: "quintIn",  	ease: FlxEase.quintIn 		} );
		_easeInfo.push( { name: "quintOut",  	ease: FlxEase.quintOut 		} );
		_easeInfo.push( { name: "quintInOut",  	ease: FlxEase.quintInOut 	} );
		_easeInfo.push( { name: "sineIn", 	 	ease: FlxEase.sineIn 		} );
		_easeInfo.push( { name: "sineOut",  	ease: FlxEase.sineOut 		} );
		_easeInfo.push( { name: "sineInOut",  	ease: FlxEase.sineInOut 	} );
		_easeInfo.push( { name: "bounceIn",  	ease: FlxEase.bounceIn 		} );
		_easeInfo.push( { name: "bounceOut",  	ease: FlxEase.bounceOut 	} );
		_easeInfo.push( { name: "bounceInOut",  ease: FlxEase.bounceInOut 	} );
		_easeInfo.push( { name: "circIn",  		ease: FlxEase.circIn 		} );
		_easeInfo.push( { name: "circOut",  	ease: FlxEase.circOut 		} );
		_easeInfo.push( { name: "circInOut",  	ease: FlxEase.circInOut 	} );
		_easeInfo.push( { name: "expoIn",  		ease: FlxEase.expoIn 		} );
		_easeInfo.push( { name: "expoOut",  	ease: FlxEase.expoOut 		} );
		_easeInfo.push( { name: "expoInOut",  	ease: FlxEase.expoInOut 	} );
		_easeInfo.push( { name: "backIn",  		ease: FlxEase.backIn 		} );
		_easeInfo.push( { name: "backOut",  	ease: FlxEase.backOut 		} );
		_easeInfo.push( { name: "backInOut",  	ease: FlxEase.backInOut 	} );

		_sprite = new FlxSprite();
		_sprite.loadGraphic(FlxAssets.IMG_LOGO, true);
		_sprite.antialiasing = true;

		// Add a trail
		_trail = new FlxTrail(_sprite, FlxAssets.IMG_LOGO, 12, 0, 0.4, 0.02);

		add(_trail);
		add(_sprite);

		_currentEaseIndex = 0;
		// multi var tween shows off effect nicely, so start with that
		_currentTweenIndex = 1;

		_min = new FlxPoint(FlxG.width * 0.1, FlxG.height * 0.2);
		_max = new FlxPoint(FlxG.width * 0.7, FlxG.height * 0.55);

		var textColor:Int = FlxColor.WHITE;

		_tweenText = new FlxText(10, 10, FlxG.width - 20);
		_tweenText.size = 16;

		_easeText = new FlxText(10, 35, FlxG.width - 20);
		_easeText.size = 16;

		_helpText = new FlxText(0, FlxG.height - 20, FlxG.width, INSTRUCTIONS);
		_helpText.color = textColor;
		_helpText.alignment = "center";

		add(_tweenText);
		add(_easeText);
		add(_helpText);

		// Create a button to toggle the trail
		_toggleButton = new FlxButton(10, 65, "FlxTrail: On", onToggleTrail);
		add(_toggleButton);

		// Start the tween
		startTween();
	}

	override public function update():Void
	{
		super.update();

		if (FlxG.keys.justPressed("SPACE"))
		{
			_currentEaseIndex = FlxMath.wrapValue(_currentEaseIndex, 1, _easeInfo.length - 1);

			if (_tween != null)
			{
				startTween();
			}
		}

		if (FlxG.keys.justPressed("UP"))
		{
			_currentTweenIndex = FlxMath.wrapValue(_currentTweenIndex, 1, MAX_TWEEN);

			if (_tween != null)
			{
				startTween();
			}
		}

		if (FlxG.keys.justPressed("DOWN"))
		{
			_currentTweenIndex = FlxMath.wrapValue(_currentTweenIndex, -1, MAX_TWEEN);

			if (_tween != null)
			{
				startTween();
			}
		}
	}

	private function startTween():Void
	{
		var options:TweenOptions = { type: FlxTween.PINGPONG, ease: _currentEase }
		_trail.resetTrail();
		_sprite.setPosition(_min.x, _min.y + (_max.y - _min.y) * 0.5);
		_sprite.angle = 0;
		_sprite.color = FlxColor.WHITE;
		_sprite.alpha = 1;

		// Cancel the old tween
		if (_tween != null)
		{
			_tween.cancel();
		}

		switch (_currentTweenIndex)
		{
			case VAR:
				_tween = FlxTween.multiVar(_sprite, { x: _max.x }, DURATION, options);

			case MULTI_VAR:
				_tween = FlxTween.multiVar(_sprite, { x: _max.x, angle: 180 }, DURATION, options);

			case ANGLE:
				_tween = FlxTween.multiVar(_sprite, { angle: 90 }, DURATION, options);

			case LINEAR_MOTION:
				_tween = FlxTween.linearMotion(_sprite,
												_sprite.x, _sprite.y,
												_max.x, _sprite.y,
												DURATION, true, options);

			case LINEAR_PATH:
				var path:Array<FlxPoint> = [new FlxPoint(_sprite.x, _sprite.y),
											new FlxPoint(_sprite.x + (_max.x - _min.x) * 0.5, _min.y),
											new FlxPoint(_max.x, _sprite.y)];
				_tween = FlxTween.linearPath(_sprite, path, DURATION, true, options);

			case CIRCULAR_MOTION:
				_tween = FlxTween.circularMotion(_sprite,
													FlxG.width * 0.5, FlxG.height * 0.5,
													_sprite.width, 359,
													true, DURATION, true, options);

			case CUBIC_MOTION:
				_tween = FlxTween.cubicMotion(_sprite,
												_sprite.x, _sprite.y,
												_sprite.x + (_max.x - _min.x) * 0.25, _max.y,
												_sprite.x + (_max.x - _min.x) * 0.75, _max.y,
												_max.x, _sprite.y,
												DURATION, options);

			case QUAD_MOTION:
				_tween = FlxTween.quadMotion(_sprite,
											_sprite.x, _sprite.y,
											_sprite.x + (_max.x - _min.x) * 0.5, _min.y,
											_max.x, _sprite.y,
											DURATION, true, options);

			case QUAD_PATH:
				var path:Array<FlxPoint> = [new FlxPoint(_sprite.x, _sprite.y),
											new FlxPoint(_sprite.x + (_max.x - _min.x) * 0.5, _min.y),
											new FlxPoint(_sprite.x + (_max.x - _min.x) * 0.5, _max.y),
											new FlxPoint(_max.x, _sprite.y)];
				_tween = FlxTween.quadPath(_sprite, path, DURATION, true, options);
		}

		// Update the texts
		_tweenText.text = "Current tweening: " + FlxStringUtil.getClassName(_tween, true);
		_easeText.text = "Current ease function: " + _easeInfo[_currentEaseIndex].name;
	}

	private var _currentEase(get, never):EaseFunction;

	inline private function get__currentEase():EaseFunction
	{
		return _easeInfo[_currentEaseIndex].ease;
	}

	private function onToggleTrail():Void
	{
		_trail.visible = !_trail.visible;

		if (_toggleButton.label.text == "FlxTrail: On")
		{
			_toggleButton.label.text = "FlxTrail: Off";
		}
		else
		{
			_toggleButton.label.text = "FlxTrail: On";
		}
	}
}

typedef EaseInfo = {
	name:String,
	ease:EaseFunction
}