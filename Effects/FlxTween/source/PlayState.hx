package;

import flixel.addons.effects.FlxTrail;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.system.FlxAssets;
import haxe.EnumTools;

/**
 * Tweening demo.
 *
 * @author Gama11
 * @author Devolonter
 * @link https://github.com/devolonter/flixel-monkey-bananas/tree/master/tweening
 */
class PlayState extends FlxState
{
	private static inline var DURATION:Float = 1;

	private var _easeInfo:Array<EaseInfo>;
	
	private var _currentEaseIndex:Int = 0;
	private var _currentEaseType:String = "quad";
	private var _currentEaseDirection:String = "In";
	private var _currentTween:TweenType = TWEEN; // Start with tween() tween, it's used most commonly.
	
	private var _tween:FlxTween;
	private var _sprite:FlxSprite;
	private var _trail:FlxTrail;
	private var _min:FlxPoint;
	private var _max:FlxPoint;
	
	private var _currentEase(get, never):EaseFunction;

	override public function create():Void
	{
		FlxG.autoPause = false;
		
		// Set up an array containing all the different ease functions there are
		_easeInfo = [
			{ name: "quadIn",       ease: FlxEase.quadIn       },
			{ name: "quadOut",      ease: FlxEase.quadOut      },
			{ name: "quadInOut",    ease: FlxEase.quadInOut    },
			
			{ name: "cubeIn",       ease: FlxEase.cubeIn       },
			{ name: "cubeOut",      ease: FlxEase.cubeOut      },
			{ name: "cubeInOut",    ease: FlxEase.cubeInOut    },
		    
			{ name: "quartIn",      ease: FlxEase.quartIn      },
			{ name: "quartOut",     ease: FlxEase.quartOut     },
			{ name: "quartInOut",   ease: FlxEase.quartInOut   },
			
			{ name: "quintIn",      ease: FlxEase.quintIn      },
			{ name: "quintOut",     ease: FlxEase.quintOut     },
			{ name: "quintInOut",   ease: FlxEase.quintInOut   },
		    
			{ name: "sineIn",       ease: FlxEase.sineIn       },
			{ name: "sineOut",      ease: FlxEase.sineOut      },
			{ name: "sineInOut",    ease: FlxEase.sineInOut    },
			
			{ name: "bounceIn",     ease: FlxEase.bounceIn     },
			{ name: "bounceOut",    ease: FlxEase.bounceOut    },
			{ name: "bounceInOut",  ease: FlxEase.bounceInOut  },
		    
			{ name: "circIn",       ease: FlxEase.circIn       },
			{ name: "circOut",      ease: FlxEase.circOut      },
			{ name: "circInOut",    ease: FlxEase.circInOut    },
			
			{ name: "expoIn",       ease: FlxEase.expoIn       },
			{ name: "expoOut",      ease: FlxEase.expoOut      },
			{ name: "expoInOut",    ease: FlxEase.expoInOut    },
			
			{ name: "backIn",       ease: FlxEase.backIn       },
			{ name: "backOut",      ease: FlxEase.backOut      },
			{ name: "backInOut",    ease: FlxEase.backInOut    },
			
			{ name: "elasticIn",    ease: FlxEase.elasticIn    },
			{ name: "elasticOut",   ease: FlxEase.elasticOut   },
			{ name: "elasticInOut", ease: FlxEase.elasticInOut },
		
			{ name: "none",         ease: null                 }];
		
		var title = new FlxText(0, 0, FlxG.width, "FlxTween", 64);
		title.alignment = CENTER;
		title.screenCenter();
		title.alpha = 0.15;
		add(title);
		
		// Create the sprite to tween (flixel logo)
		_sprite = new FlxSprite();
		_sprite.loadGraphic(FlxGraphic.fromClass(GraphicLogo), true);
		_sprite.antialiasing = true;
		
		// force subpixel rendering for smoother movement 
		// - important for movement at low speed (like the end of elasticOut)
		_sprite.pixelPerfectRender = false;
		
		// Add a trail effect
		_trail = new FlxTrail(_sprite, FlxGraphic.fromClass(GraphicLogo), 12, 0, 0.4, 0.02);
		
		add(_trail);
		add(_sprite);
		
		_min = FlxPoint.get(FlxG.width * 0.1, FlxG.height * 0.25);
		_max = FlxPoint.get(FlxG.width * 0.7, FlxG.height * 0.75);
		
		/*** From here on: UI setup ***/
		
		// First row
		
		var yOff = 10;
		var xOff = 10;
		var gutter = 10;
		var headerWidth = 60;
		
		add(new FlxText(xOff, yOff + 3, 200, "Tween:", 12));
		
		xOff = 80;
		
		var tweenTypes:Array<String> =
			["tween", "angle", "color", "linearMotion", "linearPath", "circularMotion", "cubicMotion", "quadMotion", "quadPath"];
		
		var header = new FlxUIDropDownHeader(130);
		var tweenTypeDropDown = new FlxUIDropDownMenu(xOff, yOff,
			FlxUIDropDownMenu.makeStrIdLabelArray(tweenTypes, true), onTweenChange, header);
		tweenTypeDropDown.header.text.text = "tween"; // Initialize header with correct value
		
		// Second row
		
		yOff += 30;
		xOff = 10;
		
		add(new FlxText(10, yOff + 3, 200, "Ease:", 12));
		
		xOff = Std.int(tweenTypeDropDown.x);
		
		var easeTypes:Array<String> = ["quad", "cube", "quart", "quint", "sine", "bounce", "circ", "expo", "back", "elastic", "none"];
		var header = new FlxUIDropDownHeader(headerWidth);
		var easeTypeDropDown = new FlxUIDropDownMenu(xOff, yOff,
			FlxUIDropDownMenu.makeStrIdLabelArray(easeTypes), onEaseTypeChange, header);
		
		xOff += (headerWidth + gutter);
		
		var easeDirections:Array<String> = ["In", "Out", "InOut"];
		var header2 = new FlxUIDropDownHeader(headerWidth);
		var easeDirectionDropDown = new FlxUIDropDownMenu(xOff, yOff, 
			FlxUIDropDownMenu.makeStrIdLabelArray(easeDirections), onEaseDirectionChange, header2);
		
		// Third row
		
		yOff += 30;
		xOff = 80;
		
		var trailToggleButton = new FlxUIButton(xOff, yOff, "Trail", onToggleTrail);
		trailToggleButton.loadGraphicSlice9(null, headerWidth, 0, null, FlxUI9SliceSprite.TILE_NONE, -1, true);
		trailToggleButton.toggled = true;
		
		// Add stuff in correct order - (lower y values first because of the dropdown menus)
		
		add(trailToggleButton);
		
		add(easeTypeDropDown);
		add(easeDirectionDropDown);
		
		add(tweenTypeDropDown);
		
		// Start the tween
		startTween();
		
		#if FLX_DEBUG
		FlxG.watch.add(this, "_currentEaseIndex");
		FlxG.watch.add(this, "_currentEaseType");
		FlxG.watch.add(this, "_currentEaseDirection");
		FlxG.watch.add(this, "_currentTween");
		#end
	}

	private function startTween():Void
	{
		var options:TweenOptions = { type: FlxTween.PINGPONG, ease: _currentEase };
		
		_sprite.screenCenter(FlxAxes.Y);
		_sprite.x = _min.x;
		
		_sprite.angle = 0;
		_sprite.color = FlxColor.WHITE;
		_sprite.alpha = 0.8; // Lowered alpha looks neat
		
		// Cancel the old tween
		if (_tween != null)
		{
			_tween.cancel();
		}
		
		switch (_currentTween)
		{
			case TWEEN:
				_tween = FlxTween.tween(_sprite, { x: _max.x, angle: 180 }, DURATION, options);
				
			case ANGLE:
				_tween = FlxTween.angle(_sprite, 0, 90, DURATION, options);
				_sprite.screenCenter(FlxAxes.X);
				
			case COLOR:
				_tween = FlxTween.color(_sprite, DURATION, FlxColor.BLACK, FlxColor.fromRGB(0, 0, 255, 0), options);
				_sprite.screenCenter(FlxAxes.X);
				
			case LINEAR_MOTION:
				_tween = FlxTween.linearMotion(_sprite,
				                               _sprite.x, _sprite.y,
				                               _max.x, _sprite.y,
				                               DURATION, true, options);
				
			case LINEAR_PATH:
				_sprite.y = (_max.y - _sprite.height);
				var path:Array<FlxPoint> = [FlxPoint.get(_sprite.x, _sprite.y),
				                            FlxPoint.get(_sprite.x + (_max.x - _min.x) * 0.5, _min.y),
				                            FlxPoint.get(_max.x, _sprite.y)];
				_tween = FlxTween.linearPath(_sprite, path, DURATION, true, options);
				
			case CIRCULAR_MOTION:
				_tween = FlxTween.circularMotion(_sprite,
				                                 (FlxG.width * 0.5) - (_sprite.width / 2), 
				                                 (FlxG.height * 0.5) - (_sprite.height / 2),
				                                 _sprite.width, 359,
				                                 true, DURATION, true, options);
				
			case CUBIC_MOTION:
				_sprite.y = _min.y;
				_tween = FlxTween.cubicMotion(_sprite,
				                              _sprite.x, _sprite.y,
				                              _sprite.x + (_max.x - _min.x) * 0.25, _max.y,
				                              _sprite.x + (_max.x - _min.x) * 0.75, _max.y,
				                              _max.x, _sprite.y,
				                              DURATION, options);
					
			case QUAD_MOTION:
				var rangeModifier = 100;
				_tween = FlxTween.quadMotion(_sprite,
				                             _sprite.x,                 // start x
				                             _sprite.y + rangeModifier, // start y
				                             _sprite.x + (_max.x - _min.x) * 0.5, // control x
				                             _min.y - rangeModifier,    // control y 
				                             _max.x,                    // end x
				                             _sprite.y + rangeModifier, // end y
				                             DURATION, true, options);
	
			case QUAD_PATH:
				var path:Array<FlxPoint> = [FlxPoint.get(_sprite.x, _sprite.y),
				                            FlxPoint.get(_sprite.x + (_max.x - _min.x) * 0.5, _max.y),
				                            FlxPoint.get(_max.x - (_max.x / 2) + (_sprite.width / 2), _sprite.y), 
				                            FlxPoint.get(_max.x - (_max.x / 2) + (_sprite.width / 2), _min.y),
				                            FlxPoint.get(_max.x, _sprite.y)];
				_tween = FlxTween.quadPath(_sprite, path, DURATION, true, options);
		}
		
		_trail.resetTrail();
	}

	private inline function get__currentEase():EaseFunction
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
		var foundEase:Bool = false;
		
		// Find the ease info in the array with the right name
		for (i in 0..._easeInfo.length)
		{
			if (curEase == _easeInfo[i].name)
			{
				_currentEaseIndex = i;
				foundEase = true;
			}
		}
		
		if (!foundEase)
		{
			_currentEaseIndex = _easeInfo.length - 1; // last entry is "none"
		}
		
		// Need to restart the tween now
		startTween();
	}
	
	private function onTweenChange(ID:String):Void
	{
		_currentTween = EnumTools.createByIndex(TweenType, Std.parseInt(ID));
		startTween();
	}
	
	private function onToggleTrail():Void
	{
		_trail.visible = !_trail.visible;
		_trail.resetTrail();
	}
}

typedef EaseInfo =
{
	name:String,
	ease:EaseFunction
}

enum TweenType
{
	TWEEN;
	ANGLE;
	COLOR;
	LINEAR_MOTION;
	LINEAR_PATH;
	CIRCULAR_MOTION;
	CUBIC_MOTION;
	QUAD_MOTION;
	QUAD_PATH;
}