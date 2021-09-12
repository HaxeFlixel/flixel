package;

import flixel.FlxSprite;

class EBulletBubble extends FlxSprite
{
	var _aliveTimer:Float = 4;

	public function new()
	{
		super(0, 0, AssetPaths.bubble__png);
		elasticity = 1;
		maxVelocity.set(200, 200);
	}

	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);
		_aliveTimer = 4;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!isOnScreen())
			kill();
		else if (_aliveTimer >= 0)
			_aliveTimer -= elapsed;
		else
			kill();
	}
}
