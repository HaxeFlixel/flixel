package flixel.animation;

import openfl.display.BitmapData;
import flixel.FlxSprite;
import massive.munit.Assert;

class FlxAnimationControllerTest extends FlxTest
{
	var sprite:FlxSprite;

	@Before
	function before():Void
	{
		sprite = new FlxSprite();
		FlxG.state.add(sprite);

		destroyable = sprite;
	}

	@Test
	function testSetFrameIndex():Void
	{
		#if !js // openfl-html5 doesn't like this test
		loadSpriteSheet();
		sprite.drawFrame();
		Assert.areEqual(2, sprite.animation.numFrames);
		Assert.areEqual(0xffffff, sprite.framePixels.getPixel(0, 0));

		sprite.animation.frameIndex = 1;
		sprite.drawFrame();
		Assert.areEqual(0x000000, sprite.framePixels.getPixel(0, 0));
		#end
	}

	@Test
	function testCallbackAfterFirstLoadGraphic():Void
	{
		var timesCalled:Int = 0;
		var callbackFrameIndex:Int = -1;
		sprite.animation.callback = function(s:String, n:Int, i:Int)
		{
			timesCalled++;
			callbackFrameIndex = i;
		};

		loadSpriteSheet();

		Assert.areEqual(1, timesCalled);
		Assert.areEqual(0, callbackFrameIndex);
	}

	@Test
	function testCallbackNoFrameIndexChange():Void
	{
		var timesCalled:Int = 0;
		sprite.animation.callback = function(_, _, _) timesCalled++;

		sprite.animation.frameIndex = 0;
		sprite.animation.frameIndex = 0;
		sprite.animation.frameIndex = 0;

		Assert.areEqual(0, timesCalled);
	}

	@Test
	function testAddUnmodifiedArray():Void
	{
		// 2 is an invalid frame index and will be spliced
		var animation:Array<Int> = [0, 1, 2];

		loadSpriteSheet();
		sprite.animation.add("animation", animation);

		FlxAssert.arraysEqual([0, 1, 2], animation);
	}

	@Test // #1781
	function testFinishCallbackOnce():Void
	{
		loadSpriteSheet();
		sprite.animation.add("animation", [0, 1, 2], 3000, false);

		var timesCalled = 0;
		sprite.animation.finishCallback = function(_) timesCalled++;
		sprite.animation.play("animation");

		step();
		Assert.areEqual(1, timesCalled);
	}

	@Test // #1786
	function testNullFrameName():Void
	{
		loadSpriteSheet();
		sprite.animation.addByPrefix("Test", "test");

		Assert.isNull(sprite.animation.getByName("Test"));
	}

	@Test // #2027
	function testCopyFrom()
	{
		loadSpriteSheet();
		sprite.animation.add("anim", [0, 1, 0], 15, true, true, false);

		var copy = sprite.clone();
		var anim = copy.animation.getByName("anim");

		FlxAssert.arraysEqual([0, 1, 0], anim.frames);
		Assert.areEqual(15, anim.frameRate);
		Assert.isTrue(anim.looped);
		Assert.isTrue(anim.flipX);
		Assert.isFalse(anim.flipY);
	}

	@Test // #2473
	function testExists()
	{
		loadSpriteSheet();
		sprite.animation.add("anim", [0, 1, 0], 15);

		Assert.isTrue(sprite.animation.exists("anim"));
		Assert.isFalse(sprite.animation.exists("fake"));
	}

	@Test // #2473
	function testNameList()
	{
		loadSpriteSheet();
		sprite.animation.add("anim1", [0, 1, 0], 15);
		sprite.animation.add("anim2", [0, 1, 0], 15);

		var names = sprite.animation.getNameList();
		Assert.isTrue(names.indexOf("anim1") != -1, 'Expected names to contain "anim1"');
		Assert.isTrue(names.indexOf("anim2") != -1, 'Expected names to contain "anim2"');
	}

	@Test // #2473
	function testAnimationList()
	{
		loadSpriteSheet();
		sprite.animation.add("anim1", [0, 1, 0], 15);
		sprite.animation.add("anim2", [0, 1, 0], 15);

		var list = sprite.animation.getAnimationList();
		Assert.areEqual(2, list.length);
	}
	@Test // #2473
	function testRename()
	{
		loadSpriteSheet();
		sprite.animation.add("anim1", [0, 1, 0], 15);
		sprite.animation.add("anim2", [0, 1, 0], 15);
		
		sprite.animation.rename("anim1", "anim3");
		sprite.animation.rename("anim2", "anim4");
		
		Assert.isFalse(sprite.animation.exists("anim1"), 'found "anim1"');
		Assert.isFalse(sprite.animation.exists("anim2"), 'found "anim2"');
		Assert.isTrue (sprite.animation.exists("anim3"), 'missing "anim3"');
		Assert.isTrue (sprite.animation.exists("anim4"), 'missing "anim4"');
	}

	function loadSpriteSheet():Void
	{
		var bitmapData = new BitmapData(2, 1);
		bitmapData.setPixel(0, 0, 0xffffff);
		bitmapData.setPixel(1, 0, 0x000000);
		sprite.loadGraphic(bitmapData, true, 1, 1);
	}

	function finishAnimation():Void
	{
		while (!sprite.animation.finished)
		{
			step();
		}
	}
}
