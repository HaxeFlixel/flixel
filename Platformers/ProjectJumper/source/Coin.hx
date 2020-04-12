package;

import flixel.FlxG;
import flixel.FlxSprite;

/**
 * @author David Bell
 */
class Coin extends FlxSprite
{
	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);

		loadGraphic("assets/art/coinspin.png", true);
		animation.add("spinning", [0, 1, 2, 3, 4, 5], 10, true);
		animation.play("spinning");
	}

	override public function kill():Void
	{
		super.kill();

		FlxG.sound.play("assets/sounds/coin" + Reg.SoundExtension, 3, false);
		Reg.score++;
	}
}
