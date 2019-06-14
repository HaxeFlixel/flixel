package flixel.util;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import massive.munit.Assert;

class FlxCollisionTest extends FlxTest
{
	var sprite:FlxSprite;
	var sourceSprite:FlxSprite;
	var animatedSprite:FlxSprite;

	@Before
	function before():Void
	{
		sprite = new FlxSprite(30, 0);
		sprite.makeGraphic(100, 100, FlxColor.WHITE, true);
		sourceSprite = new FlxSprite();
		sourceSprite.makeGraphic(100, 100, FlxColor.RED, true);
		animatedSprite = new FlxSprite();
		// load animations with varying frame sizes, such that the second has a bigger original size and offsets such that it will overlap with the white sprite
		animatedSprite.frames = FlxAtlasFrames.fromLibGdx(sourceSprite.pixels, '
test.png
size: 100,100
format: RGBA8888
filter: Nearest,Nearest
repeat: none
a/0
  rotate: false
  xy: 0, 0
  size: 10, 10
  orig: 10, 10
  offset: 0, 0
  index: -1
b/0
  rotate: false
  xy: 90, 90
  size: 20, 20
  orig: 50, 50
  offset: 30, 0
  index: -1
');
		// add animations
		for (name in ["a", "b"])
			animatedSprite.animation.addByPrefix(name, name);

		destroyable = sprite;
	}

	@Test
	function pixelPerfectCheckWithAnim()
	{
		// play smaller-framed anim
		animatedSprite.animation.play("a");
		Assert.isFalse(FlxCollision.pixelPerfectCheck(sprite, animatedSprite));
	}

	@Test
	function pixelPerfectCheckWithAnimAfterPlayingBiggerWithOffset()
	{
		// play larger-framed anim
		animatedSprite.animation.play("b");
		// run PPC
		Assert.isTrue(FlxCollision.pixelPerfectCheck(sprite, animatedSprite));
	}
}
