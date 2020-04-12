package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * @author Zaphod
 */
class MySpriteGroup extends FlxTypedGroup<FlxSprite>
{
	public function new(numSprites:Int = 50)
	{
		super();

		for (i in 0...numSprites)
		{
			var sprite = new FlxSprite(FlxG.random.float(0, FlxG.width), FlxG.random.float(0, FlxG.height));
			sprite.velocity.set(FlxG.random.float(-50, 50), FlxG.random.float(-50, 50));
			add(sprite);
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (sprite in members)
		{
			if (sprite.x < 0)
			{
				sprite.x = 0;
				sprite.velocity.x *= -1;
			}
			else if (sprite.x + sprite.width > FlxG.width)
			{
				sprite.x = FlxG.width - sprite.width;
				sprite.velocity.x *= -1;
			}
			if (sprite.y < 0)
			{
				sprite.y = 0;
				sprite.velocity.y *= -1;
			}
			else if (sprite.y + sprite.height > FlxG.height)
			{
				sprite.y = FlxG.height - sprite.height;
				sprite.velocity.y *= -1;
			}
		}
	}
}
