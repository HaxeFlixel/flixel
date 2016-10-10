package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	private var _activeSprites:Map<Int, TouchSprite>;
	private var _inactiveSprites:Array<TouchSprite>;
	private var _touchSprite:TouchSprite;
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		
		_activeSprites = new Map<Int, TouchSprite>();
		_inactiveSprites = new Array<TouchSprite>();
	}

	#if FLX_TOUCH
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		for (touch in FlxG.touches.list)
		{
			_touchSprite = null;
			
			if (touch.justPressed && !_activeSprites.exists(touch.touchPointID))
			{
				if (_inactiveSprites.length > 0)
				{
					_touchSprite = _inactiveSprites.pop();
					_touchSprite.visible = true;
				}
				else
				{
					_touchSprite = new TouchSprite();
					add(_touchSprite);
				}
				
				_touchSprite.color = FlxG.random.color();
				_activeSprites.set(touch.touchPointID, _touchSprite);
			}
			else if (touch.justReleased && _activeSprites.exists(touch.touchPointID))
			{
				_touchSprite = _activeSprites.get(touch.touchPointID);
				_touchSprite.visible = false;
				_activeSprites.remove(touch.touchPointID);
				_inactiveSprites.push(_touchSprite);
				_touchSprite = null;
			}
			else
			{
				_touchSprite = _activeSprites.get(touch.touchPointID);
			}
			
			if (_touchSprite != null)
			{
				_touchSprite.setPosition(touch.x - (_touchSprite.width / 2), touch.y - (_touchSprite.height / 2));
			}
		}
	}
	#end
}

class TouchSprite extends FlxSprite
{
	public function new()
	{
		super(0, 0);
		var size:Int = 70;
		makeGraphic(size, size, FlxColor.TRANSPARENT);
		antialiasing = true;
		drawCircle();
	}
}