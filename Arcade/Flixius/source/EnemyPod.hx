package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class EnemyPod extends FlxSprite
{
	var _parent:PlayState;
	var _dying:Float = 2;
	
	public function new(X:Float=0, Y:Float=0, ParentState:PlayState) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.enemy_pod__png, true, 16, 16);
		animation.add("pod", [0, 1, 2], 12, true);
		animation.play("pod");
		_dying = 2;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (alive)
		{
			if (_dying <= 1)
			{
				alpha = _dying;
				if (_dying <= 0)
				{
					
					velocity.set();
					alive = false;
					exists = false;
				}
				else
					_dying -= elapsed * 4;
			}
			else if (isOnScreen())
			{
				velocity.x = -40;	
			}
		}
	}
	
	override public function kill():Void 
	{
		_dying = 1;
		velocity.set( -20, 40);
	}
}