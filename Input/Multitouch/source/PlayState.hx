package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	private var _activeSprites:Map<Int, FlxSprite>;
	private var _inactiveSprites:Array<FlxSprite>;
	private var _touchSprite:FlxSprite;
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		
		_activeSprites = new Map<Int, FlxSprite>();
		_inactiveSprites = new Array<FlxSprite>();
	}

	override public function update():Void
	{
		super.update();
		
		for (touch in FlxG.touches.list)
		{
			_touchSprite = null;
			
			if (touch.justPressed() == true && _activeSprites.exists(touch.touchPointID) == false)
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
				_activeSprites.set(touch.touchPointID, _touchSprite);
			}
			else if (touch.justReleased() == true && _activeSprites.exists(touch.touchPointID) == true)
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
				_touchSprite.setPosition(touch.x, touch.y);
			}
		}
	}
}