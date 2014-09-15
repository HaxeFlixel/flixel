package flixel.animation;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.util.FlxColor;
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
		Assert.areEqual(2, sprite.animation.frames);
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
		sprite.animation.callback = function(s:String, n:Int, i:Int)
		{
			timesCalled++;
		};
		
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
		
		FlxAssert.arraysAreEqual([0, 1, 2], animation);
	}
	
	@Test // issue 1284
	function testFinishedInCallback():Void
	{
		var animation:Array<Int> = [1, 0];
		loadSpriteSheet();
		
		sprite.animation.callback = function(s:String, n:Int, i:Int)
		{
			if (i == 0) // last frame
			{
				Assert.isTrue(sprite.animation.curAnim.finished);
				Assert.isTrue(sprite.animation.finished);
			}
		};
		
		sprite.animation.add("animation", animation, 30, false);
		sprite.animation.play("animation");
		finishAnimation();
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