package flixel;

import flixel.math.FlxPoint;
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
	
	@Test
	function testCenter()
	{
		final sprite = new FlxSprite();
		sprite.makeGraphic(100, 100);
		sprite.origin.set(100, 100);
		sprite.offset.set(100, 100);
		sprite.scale.set(2, 4);
		sprite.angle = 180;
		final graphicBounds = sprite.getGraphicBounds();
		final offset = FlxPoint.get(sprite.x - graphicBounds.x, sprite.y - graphicBounds.y);
		final center = FlxPoint.get((FlxG.width - graphicBounds.width) / 2 + offset.x, (FlxG.height - graphicBounds.height) / 2 + offset.y);
		final offCenter = center.copyTo().add(1000, 1000);
		
		sprite.setPosition(offCenter.x, offCenter.y);
		FlxG.center(sprite, X);
		FlxAssert.areNear(sprite.x, center.x);
		FlxAssert.areNear(sprite.y, offCenter.y);
		
		sprite.setPosition(offCenter.x, offCenter.y);
		FlxG.center(sprite, Y);
		FlxAssert.areNear(sprite.x, offCenter.x);
		FlxAssert.areNear(sprite.y, center.y);
		
		sprite.setPosition(offCenter.x, offCenter.y);
		FlxG.center(sprite, XY);
		FlxAssert.areNear(sprite.x, center.x);
		FlxAssert.areNear(sprite.y, center.y);
		
		sprite.setPosition(offCenter.x, offCenter.y);
		FlxG.center(sprite);
		FlxAssert.areNear(sprite.x, center.x);
		FlxAssert.areNear(sprite.y, center.y);
		
		offset.put();
		graphicBounds.put();
		offCenter.put();
		center.put();
	}
	
	@Test
	function testCenterHitbox()
	{
		final object = new FlxObject(0, 0, 10, 10);
		final hitbox = object.getHitbox();
		final offset = FlxPoint.get(object.x - hitbox.x, object.y - hitbox.y);
		final center = FlxPoint.get((FlxG.width - hitbox.width) / 2 + offset.x, (FlxG.height - hitbox.height) / 2 + offset.y);
		final offCenter = center.copyTo().add(1000, 1000);
		
		object.setPosition(offCenter.x, offCenter.y);
		FlxG.centerHitbox(object, X);
		Assert.areEqual(object.x, center.x);
		Assert.areEqual(object.y, offCenter.y);
		
		object.setPosition(offCenter.x, offCenter.y);
		FlxG.centerHitbox(object, Y);
		Assert.areEqual(object.x, offCenter.x);
		Assert.areEqual(object.y, center.y);
		
		object.setPosition(offCenter.x, offCenter.y);
		FlxG.centerHitbox(object, XY);
		Assert.areEqual(object.x, center.x);
		Assert.areEqual(object.y, center.y);
		
		object.setPosition(offCenter.x, offCenter.y);
		FlxG.centerHitbox(object);
		Assert.areEqual(object.x, center.x);
		Assert.areEqual(object.y, center.y);
		
		offset.put();
		hitbox.put();
		offCenter.put();
		center.put();
	}
}
