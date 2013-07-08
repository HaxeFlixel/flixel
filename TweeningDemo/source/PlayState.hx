package;

/**
 * Tween demo. Port of: https://github.com/devolonter/flixel-monkey-bananas/tree/master/tweening demo made by Devolonter
 */

import flash.ui.Mouse;
import org.flixel.FlxG;
import org.flixel.util.FlxColor;
import org.flixel.util.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.misc.AngleTween;
import org.flixel.tweens.misc.ColorTween;
import org.flixel.tweens.misc.MultiVarTween;
import org.flixel.tweens.misc.NumTween;
import org.flixel.tweens.misc.VarTween;
import org.flixel.tweens.motion.CircularMotion;
import org.flixel.tweens.motion.CubicMotion;
import org.flixel.tweens.motion.LinearMotion;
import org.flixel.tweens.motion.LinearPath;
import org.flixel.tweens.motion.QuadMotion;
import org.flixel.tweens.motion.QuadPath;
import org.flixel.util.FlxString;

import org.flixel.tweens.util.Ease;

class PlayState extends FlxState
{
	static var MAX_TWEEN:Int = 10;
	static var DURATION:Float = 1;
	
	var easeInfo:Array<EaseInfo>;
	var currentEaseIndex:Int;
	var tween:FlxTween;
	var currentTweenIndex:Int;
	var sprite:FlxSprite;
	var min:FlxPoint;
	var max:FlxPoint;
	var easeText:FlxText;
	var tweenText:FlxText;
	var helpText:FlxText;
	
	override public function create():Void 
	{
		super.create();
		
		FlxG.bgColor = 0xFF01355F;
		
		easeInfo = new Array<EaseInfo>();
		
		easeInfo.push(new EaseInfo("quadIn", Ease.quadIn));
		easeInfo.push(new EaseInfo("quadOut", Ease.quadOut));
		easeInfo.push(new EaseInfo("cubeIn", Ease.cubeIn));
		easeInfo.push(new EaseInfo("cubeOut", Ease.cubeOut));
		easeInfo.push(new EaseInfo("cubeInOut", Ease.cubeInOut));
		easeInfo.push(new EaseInfo("quartIn", Ease.quartIn));
		easeInfo.push(new EaseInfo("quartOut", Ease.quartOut));
		easeInfo.push(new EaseInfo("quartInOut", Ease.quartInOut));
		easeInfo.push(new EaseInfo("quintIn", Ease.quintIn));
		easeInfo.push(new EaseInfo("quintOut", Ease.quintOut));
		easeInfo.push(new EaseInfo("quintInOut", Ease.quintInOut));
		easeInfo.push(new EaseInfo("sineIn", Ease.sineIn));
		easeInfo.push(new EaseInfo("sineOut", Ease.sineOut));
		easeInfo.push(new EaseInfo("sineInOut", Ease.sineInOut));
		easeInfo.push(new EaseInfo("bounceIn", Ease.bounceIn));
		easeInfo.push(new EaseInfo("bounceOut", Ease.bounceOut));
		easeInfo.push(new EaseInfo("bounceInOut", Ease.bounceInOut));
		easeInfo.push(new EaseInfo("circIn", Ease.circIn));
		easeInfo.push(new EaseInfo("circOut", Ease.circOut));
		easeInfo.push(new EaseInfo("circInOut", Ease.circInOut));
		easeInfo.push(new EaseInfo("expoIn", Ease.expoIn));
		easeInfo.push(new EaseInfo("expoOut", Ease.expoOut));
		easeInfo.push(new EaseInfo("expoInOut", Ease.expoInOut));
		easeInfo.push(new EaseInfo("backIn", Ease.backIn));
		easeInfo.push(new EaseInfo("backOut", Ease.backOut));
		easeInfo.push(new EaseInfo("backInOut", Ease.backInOut));
		
		sprite = new FlxSprite().makeGraphic(100, 100);
		sprite.offset.make(sprite.width * 0.5, sprite.height * 0.5);
		add(sprite);
		
		currentEaseIndex = 0;
		currentTweenIndex = 0;
		
		min = new FlxPoint(FlxG.width * 0.25, FlxG.height * 0.25);
		max = new FlxPoint(FlxG.width * 0.75, FlxG.height * 0.75);
		
		tweenText = new FlxText(10, 10, FlxG.width - 20, "");
		tweenText.size = 12;
		easeText = new FlxText(10, 30, FlxG.width - 20, "");
		easeText.size = 12;
		
		helpText = new FlxText(10, FlxG.height - 20, FlxG.width - 20, "");
		helpText.alignment = "center";
		helpText.text = "Press UP or DOWN keys to change tweening. Press SPACE to change current ease function";
		
		add(tweenText);
		add(easeText);
		add(helpText);
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (Std.is(tween, AngleTween))
		{
			sprite.angle = cast(tween, AngleTween).angle;
		}
		else if (Std.is(tween, ColorTween))
		{
			sprite.color = cast(tween, ColorTween).color;
		}
		else if (Std.is(tween, NumTween))
		{
			sprite.alpha = cast(tween, NumTween).value;
		}
		
		if (FlxG.keys.justPressed("SPACE"))
		{
			currentEaseIndex++;
			if (currentEaseIndex == easeInfo.length) currentEaseIndex = 0;
			if (hasTween) tween.cancel();
		}
		
		if (FlxG.keys.justPressed("UP"))
		{
			currentTweenIndex++;
			if (currentTweenIndex == MAX_TWEEN + 1) currentTweenIndex = 0;
			if (hasTween) tween.cancel();
		}
		
		if (FlxG.keys.justPressed("DOWN"))
		{
			currentTweenIndex--;
			if (currentTweenIndex < 0) currentTweenIndex = MAX_TWEEN;
			if (hasTween) tween.cancel();
		}
		
		if (!hasTween || !tween.active)
		{
			sprite.reset(min.x, min.y + (max.y - min.y) * 0.5);
			sprite.angle = 0;
			sprite.color = FlxColor.WHITE;
			sprite.alpha = 1;
			
			switch (currentTweenIndex)
			{
				case 0:
					var varTween:VarTween = new VarTween(null, FlxTween.PINGPONG);
					varTween.tween(sprite, "x", max.x, DURATION, easeInfo[currentEaseIndex].ease);
					tween = addTween(varTween);
				case 1:
					var multiVarTween:MultiVarTween = new MultiVarTween(null, FlxTween.PINGPONG);
					var properties:Dynamic = { x: max.x, angle: 180 };
					multiVarTween.tween(sprite, properties, DURATION, easeInfo[currentEaseIndex].ease);
					tween = addTween(multiVarTween);
				case 2:
					sprite.reset(FlxG.width * 0.5, FlxG.height * 0.5);
					var angleTween:AngleTween = new AngleTween(null, FlxTween.PINGPONG);
					angleTween.tween(0, 90, DURATION, easeInfo[currentEaseIndex].ease);
					tween = addTween(angleTween);
				case 3:
					sprite.reset(FlxG.width * 0.5, FlxG.height * 0.5);
					var colorTween:ColorTween = new ColorTween(null, FlxTween.PINGPONG);
					colorTween.tween(DURATION, 0x0090E9, 0xF01EFF, 1, 1, easeInfo[currentEaseIndex].ease);
					tween = addTween(colorTween);
				case 4:
					sprite.reset(FlxG.width * 0.5, FlxG.height * 0.5);
					var numTween:NumTween = new NumTween(null, FlxTween.PINGPONG);
					numTween.tween(1, 0, DURATION, easeInfo[currentEaseIndex].ease);
					tween = addTween(numTween);
				case 5:
					var linearMotionTween:LinearMotion = new LinearMotion(null, FlxTween.PINGPONG);
					linearMotionTween.setMotion(sprite.x, sprite.y, max.x, sprite.y, DURATION, easeInfo[currentEaseIndex].ease);
					linearMotionTween.setObject(sprite);
					tween = addTween(linearMotionTween);
				case 6:
					var linearPath:LinearPath = new LinearPath(null, FlxTween.PINGPONG);
					linearPath.addPoint(sprite.x, sprite.y);
					linearPath.addPoint(sprite.x + (max.x - min.x) * 0.5, min.y);
					linearPath.addPoint(max.x, sprite.y);
					linearPath.setMotion(DURATION, easeInfo[currentEaseIndex].ease);
					linearPath.setObject(sprite);
					tween = addTween(linearPath, true);
				case 7:
					var circularMotion:CircularMotion = new CircularMotion(null, FlxTween.PINGPONG);
					circularMotion.setMotion(FlxG.width * 0.5, FlxG.height * 0.5, sprite.width, 359, true, DURATION, easeInfo[currentEaseIndex].ease);
					circularMotion.setObject(sprite);
					tween = addTween(circularMotion);
				case 8:
					var cubicMotion:CubicMotion = new CubicMotion(null, FlxTween.PINGPONG);
					cubicMotion.setMotion(sprite.x, sprite.y, sprite.x + (max.x - min.x) * 0.25, max.y, sprite.x + (max.x - min.x) * 0.75, max.y, max.x, sprite.y, DURATION, easeInfo[currentEaseIndex].ease);
					cubicMotion.setObject(sprite);
					tween = addTween(cubicMotion);
				case 9:
					var quadMotion:QuadMotion = new QuadMotion(null, FlxTween.PINGPONG);
					quadMotion.setMotion(sprite.x, sprite.y, sprite.x + (max.x - min.x) * 0.5, min.y, max.x, sprite.y, DURATION, easeInfo[currentEaseIndex].ease);
					quadMotion.setObject(sprite);
					tween = addTween(quadMotion);
				case 10:
					var quadPath:QuadPath = new QuadPath(null, FlxTween.PINGPONG);
					quadPath.addPoint(sprite.x, sprite.y);
					quadPath.addPoint(sprite.x + (max.x - min.x) * 0.5, min.y);
					quadPath.addPoint(sprite.x + (max.x - min.x) * 0.5, max.y);
					quadPath.addPoint(max.x, sprite.y);
					quadPath.setMotion(DURATION * 1.5, easeInfo[currentEaseIndex].ease);
					quadPath.setObject(sprite);
					tween = addTween(quadPath);
			}
			
			tweenText.text = "Current tweening: " + FlxString.getClassName(tween, true);
			easeText.text = "Current ease function: " + easeInfo[currentEaseIndex].name;
		}
	}
}

class EaseInfo
{
	public var name:String;
	public var ease:EaseFunction;
	
	public function new(name:String, ease:EaseFunction)
	{
		this.name = name;
		this.ease = ease;
	}
}