package;

import flixel.FlxSprite;

class PBullet extends FlxSprite
{
	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(0, 0, AssetPaths.bullet__png);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (!isOnScreen())
			kill();
		else
			velocity.x = 300;
	}
}