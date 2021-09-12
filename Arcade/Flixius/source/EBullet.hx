package;

import flixel.FlxSprite;

class EBullet extends FlxSprite
{
	public function new()
	{
		super(0, 0, AssetPaths.bullet_enemy__png);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!isOnScreen())
			kill();
		else
			velocity.x = -200;
	}
}
