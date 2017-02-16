package;

import flixel.FlxSprite;

class PBullet extends FlxSprite
{
	public function new() 
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