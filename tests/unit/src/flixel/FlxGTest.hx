package flixel;

import flixel.math.FlxPoint;
import haxe.PosInfos;
import massive.munit.Assert;

@:access(flixel.FlxG)
class FlxGTest extends FlxTest
{
	@Test function testVERSIONNull():Void
		Assert.isNotNull(FlxG.VERSION);

	@Test function testGameNull():Void
		Assert.isNotNull(FlxG.game);

	@Test function testStageNull():Void
		Assert.isNotNull(FlxG.stage);

	@Test function testStateNull():Void
		Assert.isNotNull(FlxG.state);

	@Test function testWorldBoundsNull():Void
		Assert.isNotNull(FlxG.worldBounds);

	@Test function testSaveNull():Void
		Assert.isNotNull(FlxG.save);

	#if FLX_MOUSE
	@Test function testMouseNull():Void
		Assert.isNotNull(FlxG.mouse);
	#end

	#if FLX_TOUCH
	@Test function testTouchNull():Void
		Assert.isNotNull(FlxG.touches);
	#end

	#if FLX_POINTER_INPUT
	@Test function testSwipesNull():Void
		Assert.isNotNull(FlxG.swipes);
	#end

	#if FLX_KEYBOARD
	@Test function testKeysNull():Void
		Assert.isNotNull(FlxG.keys);
	#end

	#if FLX_GAMEPAD
	@Test function testGamepadsNull():Void
		Assert.isNotNull(FlxG.gamepads);
	#end

	#if android
	@Test function testAndroidNull():Void
		Assert.isNotNull(FlxG.android);
	#end

	#if js
	@Test function testHtml5Null():Void
		Assert.isNotNull(FlxG.html5);
	#end

	@Test function testInputsNull():Void
		Assert.isNotNull(FlxG.inputs);

	@Test function testConsoleNull():Void
		Assert.isNotNull(FlxG.console);

	@Test function testLogNull():Void
		Assert.isNotNull(FlxG.log);

	@Test function testWatchNull():Void
		Assert.isNotNull(FlxG.watch);

	@Test function testDebuggerNull():Void
		Assert.isNotNull(FlxG.debugger);

	@Test function testVcrNull():Void
		Assert.isNotNull(FlxG.vcr);

	@Test function testBitmapNull():Void
		Assert.isNotNull(FlxG.bitmap);

	@Test function testCamerasNull():Void
		Assert.isNotNull(FlxG.cameras);

	@Test function testPluginsNull():Void
		Assert.isNotNull(FlxG.plugins);

	#if FLX_SOUND_SYSTEM
	@Test function testSoundNull():Void
		Assert.isNotNull(FlxG.sound);
	#end

	@Test function testScaleModeNull():Void
		Assert.isNotNull(FlxG.scaleMode);

	@Test
	function testDefaultWidth():Void
	{
		Assert.areEqual(640, FlxG.width);
	}

	@Test
	function testDefaultHeight():Void
	{
		Assert.areEqual(480, FlxG.height);
	}
	
	@Test // #3329
	function testCenterGraphic()
	{
		Assert.areEqual(FlxG.width, 640);
		Assert.areEqual(FlxG.height, 480);
		
		final sprite = new FlxSprite();
		sprite.makeGraphic(10, 10);
		sprite.origin.set(10, 10);
		sprite.offset.set(10, 10);
		sprite.scale.set(2, 4);
		sprite.angle = 180;
		sprite.pixelPerfectPosition = true;
		
		sprite.setPosition(0, 0);
		FlxG.centerGraphic(sprite, X);
		assertCenter(sprite, 320 - 10 - (-10 + 10), 0);
		
		sprite.setPosition(0, 0);
		FlxG.centerGraphic(sprite, Y);
		assertCenter(sprite, 0, 240 - 20 - (-10 + 10));
		
		sprite.setPosition(0, 0);
		FlxG.centerGraphic(sprite, XY);
		assertCenter(sprite, 320 - 10 - (-10 + 10), 240 - 20 - (-10 + 10));
		
		sprite.setPosition(1640, 1480);
		FlxG.centerGraphic(sprite);
		assertCenter(sprite, 320 - 10 - (-10 + 10), 240 - 20 - (-10 + 10));
	}
	
	@Test // #3329
	function testCenterHitbox()
	{
		Assert.areEqual(FlxG.width, 640);
		Assert.areEqual(FlxG.height, 480);
		
		final object = new FlxObject(0, 0, 10, 10);
		
		object.setPosition(0, 0);
		FlxG.centerHitbox(object, X);
		assertCenter(object, 320 - 5, 0);
		
		object.setPosition(0, 0);
		FlxG.centerHitbox(object, Y);
		assertCenter(object, 0, 240 - 5);
		
		object.setPosition(0, 0);
		FlxG.centerHitbox(object, XY);
		assertCenter(object, 320 - 5, 240 - 5);
		
		object.setPosition(1640, 1480);
		FlxG.centerHitbox(object);
		assertCenter(object, 320 - 5, 240 - 5);
	}
	
	function assertCenter(object:FlxObject, expectedX:Float, expectedY:Float, ?info:PosInfos)
	{
		FlxAssert.areNear(object.x, expectedX, info);
		FlxAssert.areNear(object.y, expectedY, info);
	}
}
