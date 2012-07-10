package;

import nme.Assets;
import org.flixel.FlxG;
import org.flixel.FlxState;

import org.flixel.FlxSprite;
import org.flixel.system.input.TouchManager;


import org.flixel.system.input.Touch;

class MenuState extends FlxState
{
	private var activeSprites:IntHash<FlxSprite>;
	private var inactiveSprites:Array<FlxSprite>;
	
	private var touchSprite:FlxSprite;
	private var touch:Touch;
	private var touches:Array<Touch>;
	
	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xff131c1b;
		#else
		FlxG.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end
		
		activeSprites = new IntHash<FlxSprite>();
		inactiveSprites = new Array<FlxSprite>();
		
		/*touchSprite = new FlxSprite();
		touchSprite.makeGraphic(50, 50);
		touchSprite.color = Std.int(Math.random() * 0xffffff);
		add(touchSprite);*/
	}

	override public function update():Void
	{
		super.update();
		
		touches = FlxG.touchManager.touches;
		
		for (touch in touches)
		{
			touchSprite = null;
			
			if (touch.justPressed() == true && activeSprites.exists(touch.touchPointID) == false)
			{
				if (inactiveSprites.length > 0)
				{
					touchSprite = inactiveSprites.pop();
					touchSprite.visible = true;
				}
				else
				{
					touchSprite = new FlxSprite();
					touchSprite.makeGraphic(50, 50);
					add(touchSprite);
				}
				
				touchSprite.color = Std.int(Math.random() * 0xffffff);
				activeSprites.set(touch.touchPointID, touchSprite);
			}
			else if (touch.justReleased() == true && activeSprites.exists(touch.touchPointID) == true)
			{
				touchSprite = activeSprites.get(touch.touchPointID);
				touchSprite.visible = false;
				activeSprites.remove(touch.touchPointID);
				inactiveSprites.push(touchSprite);
				touchSprite = null;
			}
			else
			{
				touchSprite = activeSprites.get(touch.touchPointID);
			}
			
			if (touchSprite != null)
			{
				touchSprite.x = touch.x;
				touchSprite.y = touch.y;
			}
			
		}
	}
}