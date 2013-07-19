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
import flixel.util.FlxPoint;
import flixel.tweens.util.Ease;
import flixel.util.FlxStringUtil;

/**
 * Tweening demo. 
 * 
 * @author Devolonter
 * @link https://github.com/devolonter/flixel-monkey-bananas/tree/master/tweening
 */
class PlayState extends FlxState
{
	static private var MAX_TWEEN:Int = 8;
	static private var DURATION:Float = 1;
	
	private var _easeInfo:Array<EaseInfo>;
	private var _currentEaseIndex:Int;
	private var _tweener:FlxTween;
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
		FlxG.cameras.bgColor = FlxColor.ROYAL_BLUE;
		FlxG.mouse.show();
		
		_easeInfo = new Array<EaseInfo>();
		
		_easeInfo.push(new EaseInfo("quadIn", Ease.quadIn));
		_easeInfo.push(new EaseInfo("quadOut", Ease.quadOut));
		_easeInfo.push(new EaseInfo("cubeIn", Ease.cubeIn));
		_easeInfo.push(new EaseInfo("cubeOut", Ease.cubeOut));
		_easeInfo.push(new EaseInfo("cubeInOut", Ease.cubeInOut));
		_easeInfo.push(new EaseInfo("quartIn", Ease.quartIn));
		_easeInfo.push(new EaseInfo("quartOut", Ease.quartOut));
		_easeInfo.push(new EaseInfo("quartInOut", Ease.quartInOut));
		_easeInfo.push(new EaseInfo("quintIn", Ease.quintIn));
		_easeInfo.push(new EaseInfo("quintOut", Ease.quintOut));
		_easeInfo.push(new EaseInfo("quintInOut", Ease.quintInOut));
		_easeInfo.push(new EaseInfo("sineIn", Ease.sineIn));
		_easeInfo.push(new EaseInfo("sineOut", Ease.sineOut));
		_easeInfo.push(new EaseInfo("sineInOut", Ease.sineInOut));
		_easeInfo.push(new EaseInfo("bounceIn", Ease.bounceIn));
		_easeInfo.push(new EaseInfo("bounceOut", Ease.bounceOut));
		_easeInfo.push(new EaseInfo("bounceInOut", Ease.bounceInOut));
		_easeInfo.push(new EaseInfo("circIn", Ease.circIn));
		_easeInfo.push(new EaseInfo("circOut", Ease.circOut));
		_easeInfo.push(new EaseInfo("circInOut", Ease.circInOut));
		_easeInfo.push(new EaseInfo("expoIn", Ease.expoIn));
		_easeInfo.push(new EaseInfo("expoOut", Ease.expoOut));
		_easeInfo.push(new EaseInfo("expoInOut", Ease.expoInOut));
		_easeInfo.push(new EaseInfo("backIn", Ease.backIn));
		_easeInfo.push(new EaseInfo("backOut", Ease.backOut));
		_easeInfo.push(new EaseInfo("backInOut", Ease.backInOut));
		
		_sprite = new FlxSprite();
		_sprite.loadGraphic(FlxAssets.IMG_LOGO, true);
		// Make it look a bit better
		_sprite.antialiasing = true;
		_sprite.forceComplexRender = true;
		
		// Add a trail
		_trail = new FlxTrail(_sprite, FlxAssets.IMG_LOGO, 12, 0, 0.4, 0.02);
		
		add(_trail);
		add(_sprite);
		
		_currentEaseIndex = 0;
		// multi var tween shows off effect nicely
		_currentTweenIndex = 1; 
		
		_min = new FlxPoint(FlxG.width * 0.25, FlxG.height * 0.25);
		_max = new FlxPoint(FlxG.width * 0.6, FlxG.height * 0.6);
		
		_tweenText = new FlxText(10, 10, FlxG.width - 20, "");
		_tweenText.size = 12;
		_easeText = new FlxText(10, 30, FlxG.width - 20, "");
		_easeText.size = 12;
		
		_helpText = new FlxText(10, FlxG.height - 20, FlxG.width - 20, "");
		_helpText.alignment = "center";
		_helpText.text = "Press UP or DOWN keys to change tweening. Press SPACE to change current ease function";
		
		add(_tweenText);
		add(_easeText);
		add(_helpText);
		
		// Create a button to toggle the trail
		_toggleButton = new FlxButton(10, 55, "FlxTrail: On", onToggleTrail);
		add(_toggleButton);
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (Std.is(_tweener, AngleTween))
		{
			_sprite.angle = cast(_tweener, AngleTween).angle;
		}
		else if (Std.is(_tweener, ColorTween))
		{
			_sprite.color = cast(_tweener, ColorTween).color;
		}
		else if (Std.is(_tweener, NumTween))
		{
			_sprite.alpha = cast(_tweener, NumTween).value;
		}
		
		if (FlxG.keys.justPressed("SPACE"))
		{
			_currentEaseIndex++;
			
			if (_currentEaseIndex == _easeInfo.length) 
			{
				_currentEaseIndex = 0;
			}
			
			if (hasTween) 
			{
				_tweener.cancel();
			}
		}
		
		if (FlxG.keys.justPressed("UP"))
		{
			_currentTweenIndex++;
			
			if (_currentTweenIndex == MAX_TWEEN + 1)
			{
				_currentTweenIndex = 0;
			}
			
			if (hasTween) 
			{
				_tweener.cancel();
			}
		}
		
		if (FlxG.keys.justPressed("DOWN"))
		{
			_currentTweenIndex--;
			
			if (_currentTweenIndex < 0) 
			{
				_currentTweenIndex = MAX_TWEEN;
			}
			
			if (hasTween) 
			{
				_tweener.cancel();
			}
		}
		
		if (!hasTween || !_tweener.active)
		{
			_trail.resetTrail();
			_sprite.reset(_min.x, _min.y + (_max.y - _min.y) * 0.5);
			_sprite.angle = 0;
			_sprite.color = FlxColor.WHITE;
			_sprite.alpha = 1;
			
			switch (_currentTweenIndex)
			{
				case 0:
					var varTween:VarTween = new VarTween(null, FlxTween.PINGPONG);
					varTween.tween(_sprite, "x", _max.x, DURATION, _easeInfo[_currentEaseIndex].ease);
					_tweener = addTween(varTween);
				case 1:
					var multiVarTween:MultiVarTween = new MultiVarTween(null, FlxTween.PINGPONG);
					var properties:Dynamic = { x: _max.x, angle: 180 };
					multiVarTween.tween(_sprite, properties, DURATION, _easeInfo[_currentEaseIndex].ease);
					_tweener = addTween(multiVarTween);
				case 2:
					_sprite.reset(FlxG.width * 0.5, FlxG.height * 0.5);
					var angleTween:AngleTween = new AngleTween(null, FlxTween.PINGPONG);
					angleTween.tween(0, 90, DURATION, _easeInfo[_currentEaseIndex].ease);
					_tweener = addTween(angleTween);
				case 3:
					var linearMotionTween:LinearMotion = new LinearMotion(null, FlxTween.PINGPONG);
					linearMotionTween.setMotion(_sprite.x, _sprite.y, _max.x, _sprite.y, DURATION, _easeInfo[_currentEaseIndex].ease);
					linearMotionTween.setObject(_sprite);
					_tweener = addTween(linearMotionTween);
				case 4:
					var linearPath:LinearPath = new LinearPath(null, FlxTween.PINGPONG);
					linearPath.addPoint(_sprite.x, _sprite.y);
					linearPath.addPoint(_sprite.x + (_max.x - _min.x) * 0.5, _min.y);
					linearPath.addPoint(_max.x, _sprite.y);
					linearPath.setMotion(DURATION, _easeInfo[_currentEaseIndex].ease);
					linearPath.setObject(_sprite);
					_tweener = addTween(linearPath, true);
				case 5:
					var circularMotion:CircularMotion = new CircularMotion(null, FlxTween.PINGPONG);
					circularMotion.setMotion(FlxG.width * 0.5, FlxG.height * 0.5, _sprite.width, 359, true, DURATION, _easeInfo[_currentEaseIndex].ease);
					circularMotion.setObject(_sprite);
					_tweener = addTween(circularMotion);
				case 6:
					var cubicMotion:CubicMotion = new CubicMotion(null, FlxTween.PINGPONG);
					cubicMotion.setMotion(_sprite.x, _sprite.y, _sprite.x + (_max.x - _min.x) * 0.25, _max.y, _sprite.x + (_max.x - _min.x) * 0.75, _max.y, _max.x, _sprite.y, DURATION, _easeInfo[_currentEaseIndex].ease);
					cubicMotion.setObject(_sprite);
					_tweener = addTween(cubicMotion);
				case 7:
					var quadMotion:QuadMotion = new QuadMotion(null, FlxTween.PINGPONG);
					quadMotion.setMotion(_sprite.x, _sprite.y, _sprite.x + (_max.x - _min.x) * 0.5, _min.y, _max.x, _sprite.y, DURATION, _easeInfo[_currentEaseIndex].ease);
					quadMotion.setObject(_sprite);
					_tweener = addTween(quadMotion);
				case 8:
					var quadPath:QuadPath = new QuadPath(null, FlxTween.PINGPONG);
					quadPath.addPoint(_sprite.x, _sprite.y);
					quadPath.addPoint(_sprite.x + (_max.x - _min.x) * 0.5, _min.y);
					quadPath.addPoint(_sprite.x + (_max.x - _min.x) * 0.5, _max.y);
					quadPath.addPoint(_max.x, _sprite.y);
					quadPath.setMotion(DURATION * 1.5, _easeInfo[_currentEaseIndex].ease);
					quadPath.setObject(_sprite);
					_tweener = addTween(quadPath);
			}
			
			_tweenText.text = "Current tweening: " + FlxStringUtil.getClassName(_tweener, true);
			_easeText.text = "Current ease function: " + _easeInfo[_currentEaseIndex].name;
		}
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

private class EaseInfo
{
	public var name:String;
	public var ease:EaseFunction;
	
	public function new(Name:String, EaseFunc:EaseFunction)
	{
		name = Name;
		ease = EaseFunc;
	}
}