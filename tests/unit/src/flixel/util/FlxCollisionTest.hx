package flixel.util;

import massive.munit.Assert;

class FlxCollisionTest extends FlxTest
{
        var sprite:FlxSprite = cast add(new FlxSprite(30, 0));
		var sourceSprite = new FlxSprite();
		var animatedSprite:FlxSprite = cast add(new FlxSprite());
		// play smaller-framed anim
		animatedSprite.animation.play("a");
		trace(FlxCollision.pixelPerfectCheck(sprite, animatedSprite));
		// play larger-framed anim
		animatedSprite.animation.play("b");
		// run PPC
		trace(FlxCollision.pixelPerfectCheck(sprite, animatedSprite));
	@Before
	function before():Void 
	{
		sprite.makeGraphic(100, 100, FlxColor.WHITE, true);
 		sourceSprite.makeGraphic(100, 100, FlxColor.RED, true);
		// load animations with varying frame sizes
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
  offset: 40, 0
  index: -1
');
		// add animations
		for (name in ["a","b"])
			animatedSprite.animation.addByPrefix(name, name);
		
		destroyable = sprite;
	}
	
	@Test
	function pPCOnAnim()
	{
		// play smaller-framed anim
		animatedSprite.animation.play("a");
		Assert.isFalse(FlxCollision.pixelPerfectCheck(sprite, animatedSprite));
	}

	@Test
	function pPCOnAnimAfterPlayingBiggerWithOffset()
	{
		// play larger-framed anim
		animatedSprite.animation.play("b");
		// run PPC
		Assert.isTrue(FlxCollision.pixelPerfectCheck(sprite, animatedSprite));
	}

	@After
	public function testTeardown():Void
	{
		animatedSprite.destroy();
	}
}