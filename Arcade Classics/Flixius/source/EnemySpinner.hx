package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class EnemySpinner extends FlxSprite
{
	private var _shootTimer:Float = 2;
	private var _parent:PlayState;
	private var _dying:Float = 2;
	
	public function new(X:Float = 0, Y:Float = 0, ParentState:PlayState) 
	{
		super(X, Y, AssetPaths.enemy_spinner__png);
		_parent = ParentState;
		_dying = 2;
		angularVelocity = 250;
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
					_dying -= FlxG.elapsed * 4;
			}
			else
			{
				if (isOnScreen())
				{	
					
					_shootTimer -= FlxG.elapsed*6;
					if (_shootTimer < 0)
					{
						_shootTimer = 8;
						_parent.shootEBulletBubble(this);
					}
				}
			}
		}
	}
	
	override public function kill():Void 
	{
		_dying = 1;
		velocity.set( -20, 40);	
	}
}