package flixel.group;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import massive.munit.Assert;

class FlxSpriteContainerTest extends FlxSpriteGroupTest
{
	override function before()
	{
		group = new FlxSpriteContainer();
		for (i in 0...10)
			group.add(new FlxSpriteContainer());
		destroyable = group;
	}
}