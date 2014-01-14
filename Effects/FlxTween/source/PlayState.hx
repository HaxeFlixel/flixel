package;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownHeader;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.StrIdLabel;
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
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween.TweenOptions;

/**
 * Tweening demo.
 *
 * @author Gama11
 * @author Devolonter
 * @link https://github.com/devolonter/flixel-monkey-bananas/tree/master/tweening
 */
class PlayState extends FlxState
{
	/**
	 * The duration of the tween
	 */
	inline static private var DURATION:Float = 1;

	/**
	 * The tween types
	 */
	inline static private var VAR				:Int = 0;
	inline static private var MULTI_VAR			:Int = 1;
	inline static private var ANGLE				:Int = 2;
	inline static private var COLOR				:Int = 3;
	inline static private var LINEAR_MOTION		:Int = 4;
	inline static private var LINEAR_PATH		:Int = 5;
	inline static private var CIRCULAR_MOTION	:Int = 6;
	inline static private var CUBIC_MOTION		:Int = 7;
	inline static private var QUAD_MOTION		:Int = 8;
	inline static private var QUAD_PATH			:Int = 9;

	private var _easeInfo:Array<EaseInfo>;
	
	private var _currentEaseIndex:Int = 0;
	private var _currentEaseType:String;
	private var _currentEaseDirection:String;
	private var _currentTweenIndex:Int = MULTI_VAR; // Start with multiVar tween, it's used most commonly.
	
	private var _tween:FlxTween;
	private var _sprite:FlxSprite;
	private var _trail:FlxTrail;
	private var _min:FlxPoint;
	private var _max:FlxPoint;

	override public function create():Void
	{
		FlxG.cameras.bgColor = FlxColor.BLACK;
		FlxG.mouse.show();
		FlxG.autoPause = false;
		
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
		_easeInfo.push( { name: "none",  		ease: null 					} );
		
		var title = new FlxText(0, 0, FlxG.width, "FlxTween", 64);
		title.alignment = "center";
		FlxSpriteUtil.screenCenter(title);
		title.alpha = 0.15;
		add(title);
		
		// Create the sprite to tween (flixel logo)
		_sprite = new FlxSprite();
		_sprite.loadGraphic(FlxAssets.IMG_LOGO, true);
		_sprite.antialiasing = true; // subpixel-rendering for smoother movement
		
		// Add a trail effect
		_trail = new FlxTrail(_sprite, FlxAssets.IMG_LOGO, 12, 0, 0.4, 0.02);
		
		add(_trail);
		add(_sprite);
		
		_min = new FlxPoint(FlxG.width * 0.1, FlxG.height * 0.25);
		_max = new FlxPoint(FlxG.width * 0.7, FlxG.height * 0.75);
		
		/*** From here on: UI setup ***/
		
		// First row
		
		var yOff = 10;
		var xOff = 10;
		var gutter = 10;
		var headerWidth = 60;
		
		add(new FlxText(xOff, yOff + 3, 200, "Tween:", 12));
		
		xOff = 80;
		
		var tweenTypes:Array<String> = [ "singleVar", "multiVar", "angle", "color", "linearMotion", "linearPath", "circularMotion", "cubicMotion",
										 "quadMotion", "quadPath" ];
		
		var header = new FlxUIDropDownHeader(130);
		var tweenTypeDropDown = new FlxUIDropDownMenu(xOff, yOff, FlxUIDropDownMenu.makeStrIdLabelArray(tweenTypes, true), onTweenChange, header);
		tweenTypeDropDown.header.text.text = "multiVar"; // Initialize header with correct value
		
		// Second row
		
		yOff += 30;
		xOff = 10;
		
		add(new FlxText(10, yOff + 3, 200, "Ease:", 12));
		
		xOff = Std.int(tweenTypeDropDown.x);
		
		var easeTypes:Array<String> = [ "quad", "cube", "quart", "quint", "sine", "bounce", "circ", "expo", "back", "none" ];
		var header = new FlxUIDropDownHeader(headerWidth);
		var easeTypeDropDown = new FlxUIDropDownMenu(xOff, yOff, FlxUIDropDownMenu.makeStrIdLabelArray(easeTypes), onEaseTypeChange, header);
		
		xOff += (headerWidth + gutter);
		
		var easeDirections:Array<String> = [ "In", "Out", "InOut" ];
		var header2 = new FlxUIDropDownHeader(headerWidth);
		var easeDirectionDropDown = new FlxUIDropDownMenu(xOff, yOff, 
									FlxUIDropDownMenu.makeStrIdLabelArray(easeDirections), onEaseDirectionChange, header2);
		
		// Third row
		
		yOff += 30;
		xOff = 80;
		
		var trailToggleButton = new FlxUIButton(xOff, yOff, "Trail", onToggleTrail);
		trailToggleButton.loadGraphicSlice9(null, headerWidth, 0, null, -1, true);
		
		// Add stuff in correct order - (lower y values first because of the dropdown menus)
		
		add(trailToggleButton);
		
		add(easeTypeDropDown);
		add(easeDirectionDropDown);
		
		add(tweenTypeDropDown);
		
		// Start the tween
		startTween();
	}

	private function startTween():Void
	{
		var options:TweenOptions = { type: FlxTween.PINGPONG, ease: _currentEase }
		
		FlxSpriteUtil.screenCenter(_sprite);
		_sprite.x = _min.x;
		
		_sprite.angle = 0;
		_sprite.color = FlxColor.WHITE;
		_sprite.alpha = 0.8; // Lowered alpha looks neat
		
		// Cancel the old tween
		if (_tween != null) {
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
				FlxSpriteUtil.screenCenter(_sprite);
				
			case COLOR:
				_tween = FlxTween.color(_sprite, DURATION, FlxColor.BLACK, FlxColor.BLUE, 1, 0, options);
				FlxSpriteUtil.screenCenter(_sprite);
				
			case LINEAR_MOTION:
				_tween = FlxTween.linearMotion(	_sprite,
												_sprite.x, _sprite.y,
												_max.x, _sprite.y,
												DURATION, true, options);
				
			case LINEAR_PATH:
				_sprite.y = (_max.y - _sprite.height);
				var path:Array<FlxPoint> = [new FlxPoint(_sprite.x, _sprite.y),
											new FlxPoint(_sprite.x + (_max.x - _min.x) * 0.5, _min.y),
											new FlxPoint(_max.x, _sprite.y)];
				_tween = FlxTween.linearPath(_sprite, path, DURATION, true, options);
				
			case CIRCULAR_MOTION:
				_tween = FlxTween.circularMotion(	_sprite,
													(FlxG.width * 0.5) - (_sprite.width / 2), 
													(FlxG.height * 0.5) - (_sprite.height / 2),
													_sprite.width, 359,
													true, DURATION, true, options);
				
			case CUBIC_MOTION:
				_sprite.y = _min.y;
				_tween = FlxTween.cubicMotion(	_sprite,
												_sprite.x, _sprite.y,
												_sprite.x + (_max.x - _min.x) * 0.25, _max.y,
												_sprite.x + (_max.x - _min.x) * 0.75, _max.y,
												_max.x, _sprite.y,
												DURATION, options);
					
			case QUAD_MOTION:
				var rangeModifier = 100;
				_tween = FlxTween.quadMotion(	_sprite,
												_sprite.x, 					// start x
												_sprite.y + rangeModifier,	// start y
												_sprite.x + (_max.x - _min.x) * 0.5, // control x
												_min.y - rangeModifier, 	// control y 
												_max.x, 					// end x
												_sprite.y + rangeModifier,	// end y
												DURATION, true, options);
	
			case QUAD_PATH:
				var path:Array<FlxPoint> = [new FlxPoint(_sprite.x, _sprite.y),
											new FlxPoint(_sprite.x + (_max.x - _min.x) * 0.5, _max.y),
											new FlxPoint(_max.x - (_max.x / 2) + (_sprite.width / 2), _sprite.y), 
											new FlxPoint(_max.x - (_max.x / 2) + (_sprite.width / 2), _min.y),
											new FlxPoint(_max.x, _sprite.y)];
				_tween = FlxTween.quadPath(_sprite, path, DURATION, true, options);
		}
		
		_trail.resetTrail();
	}

	private var _currentEase(get, never):EaseFunction;

	inline private function get__currentEase():EaseFunction
	{
		return _easeInfo[_currentEaseIndex].ease;
	}
	
	private function onEaseTypeChange(ID:String):Void
	{
		_currentEaseType = ID;
		updateEaseIndex();
	}
	
	private function onEaseDirectionChange(ID:String):Void
	{
		_currentEaseDirection = ID;
		updateEaseIndex();
	}
	
	private function updateEaseIndex():Void
	{
		var curEase = _currentEaseType + _currentEaseDirection;
		
		// Find the ease info in the array with the right name
		for (i in 0..._easeInfo.length)
		{
			if (curEase == _easeInfo[i].name)
			{
				_currentEaseIndex = i;
			}
		}
		
		// Need to restart the tween now
		startTween();
	}
	
	private function onTweenChange(ID:String):Void
	{
		_currentTweenIndex = Std.parseInt(ID);
		startTween();
	}
	
	private function onToggleTrail():Void
	{
		_trail.visible = !_trail.visible;
		_trail.resetTrail();
	}
}

typedef EaseInfo = {
	name:String,
	ease:EaseFunction
}