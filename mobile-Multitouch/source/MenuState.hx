package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.input.FlxTouch;

class MenuState extends FlxState
{
	private var _activeSprites:Map<Int, FlxSprite>;
	private var _inactiveSprites:Array<FlxSprite>;
	
	private var _touchSprite:FlxSprite;
	private var _touch:FlxTouch;
	private var _touches:Array<FlxTouch>;
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		
		_activeSprites = new Map<Int, FlxSprite>();
		_inactiveSprites = new Array<FlxSprite>();
	}

	override public function update():Void
	{
		super.update();
		
		_touches = FlxG.touchManager.touches;
		
		for (_touch in _touches)
		{
			_touchSprite = null;
			
			if (_touch.justPressed() == true && _activeSprites.exists(_touch.touchPointID) == false)
			{
				if (_inactiveSprites.length > 0)
				{
					_touchSprite = _inactiveSprites.pop();
					_touchSprite.visible = true;
				}
				else
				{
					_touchSprite = new FlxSprite();
					_touchSprite.makeGraphic(50, 50);
					add(_touchSprite);
				}
				
				_touchSprite.color = Std.int(Math.random() * 0xffffff);
				_activeSprites.set(_touch.touchPointID, _touchSprite);
			}
			else if (_touch.justReleased() == true && _activeSprites.exists(_touch.touchPointID) == true)
			{
				_touchSprite = _activeSprites.get(_touch.touchPointID);
				_touchSprite.visible = false;
				_activeSprites.remove(_touch.touchPointID);
				_inactiveSprites.push(_touchSprite);
				_touchSprite = null;
			}
			else
			{
				_touchSprite = _activeSprites.get(_touch.touchPointID);
			}
			
			if (_touchSprite != null)
			{
				_touchSprite.x = _touch.x;
				_touchSprite.y = _touch.y;
			}
		}
	}
}