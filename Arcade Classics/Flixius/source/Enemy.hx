package ;
import flixel.FlxG;
import flixel.FlxSprite;

class Enemy extends FlxSprite
{
	
	private var _shootTimer:Float = 6;
	private var _parent:PlayState;
	private var _dying:Float = 2;
	
	public function new(X:Float, Y:Float, ParentState:PlayState):Void
	{
		super(X, Y, AssetPaths.enemy_destroyer__png);
		_parent = ParentState;
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
					_dying -= FlxG.elapsed * 4;
			}
			else
			{
				if (isOnScreen())
				{	
					velocity.x = -20;
					velocity.y = Math.sin(x / 10) * 20;
					_shootTimer -= FlxG.elapsed*4;
					if (_shootTimer < 4 && _shootTimer > 3)
					{
						_shootTimer = 3;
						_parent.shootEBullet(this);
						
					}
					else if (_shootTimer < 2 && _shootTimer > 1)
					{
						_shootTimer = 1;
						_parent.shootEBullet(this);
					}
					else if (_shootTimer < 0)
					{
						_shootTimer = 8;
						_parent.shootEBullet(this);
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