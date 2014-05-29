package flixel.animation;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import FlxTest;
import massive.munit.Assert;

@:bitmap("assets/spritesheet.png")
private class GraphicSpriteSheet extends BitmapData {}

class FlxAnimationControllerTest extends FlxTest
{
	var sprite:FlxSprite;
	
	@Before
	function before():Void
	{
		sprite = new FlxSprite();
	}
	
	@Test
	function testSetFrameIndex():Void
	{
		sprite.loadGraphic(GraphicSpriteSheet, true, 1, 1);
		sprite.drawFrame();
		Assert.areEqual(2, sprite.animation.frames);
		Assert.areEqual(0xffffff, sprite.framePixels.getPixel(0, 0));
		
		sprite.animation.frameIndex = 1;
		sprite.drawFrame();
		Assert.areEqual(0x000000, sprite.framePixels.getPixel(0, 0));
	}
	
	@Test
	function testCallbackAfterFirstLoadGraphic():Void
	{
		var timesCalled:Int = 0;
		var callbackFrameIndex:Int = -1;
		sprite.animation.callback = function(s:String, n:Int, i:Int) {
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
		sprite.animation.callback = function(s:String, n:Int, i:Int) {
			timesCalled++;
		};
		
		sprite.animation.frameIndex = 0;
		sprite.animation.frameIndex = 0;
		sprite.animation.frameIndex = 0;
		
		Assert.areEqual(0, timesCalled);
	}
	
	function loadSpriteSheet():Void
	{
		sprite.loadGraphic(GraphicSpriteSheet, true, 1, 1);
	}
}