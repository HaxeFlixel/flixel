package flixel;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import massive.munit.Assert;

@:access(flixel.system.frontEnds.CameraFrontEnd)
@:access(flixel.FlxCamera)
class FlxCameraTest extends FlxTest
{
	var camera:FlxCamera;

	@Before
	function before()
	{
		camera = new FlxCamera();
		destroyable = camera;
		resetGame();
	}

	@Test
	function testDefaultBgColor():Void
	{
		Assert.areEqual(FlxColor.BLACK, FlxG.cameras.bgColor);
	}

	@Test
	function testDefaultZoom():Void
	{
		Assert.areEqual(1, FlxG.camera.zoom);
		Assert.areEqual(1, FlxCamera.defaultZoom);
	}

	@Test
	function testDefaultLength():Void
	{
		Assert.areEqual(1, FlxG.cameras.list.length);
		Assert.areEqual(1, FlxG.cameras.defaults.length);
	}

	@Test
	function testDefaultCameras():Void
	{
		Assert.areEqual(FlxG.cameras.defaults, FlxCamera._defaultCameras);
	}

	@Test
	function testDefaultCamerasStateSwitch():Void
	{
		FlxCamera._defaultCameras = [FlxG.camera];
		switchState(FlxState.new);

		Assert.areEqual(FlxG.cameras.defaults, FlxCamera._defaultCameras);
	}

	@Test
	function testAddAndRemoveCamera():Void
	{
		FlxG.cameras.add(camera);
		Assert.areEqual(2, FlxG.cameras.list.length);
		Assert.areEqual(2, FlxG.cameras.defaults.length);

		FlxG.cameras.remove(camera);
		Assert.areEqual(1, FlxG.cameras.list.length);
		Assert.areEqual(1, FlxG.cameras.defaults.length);
	}

	@Test // #2296
	function testIsDefaultCamera():Void
	{
		FlxG.cameras.add(camera, false);
		Assert.areEqual(2, FlxG.cameras.list.length);
		Assert.areEqual(1, FlxG.cameras.defaults.length);

		FlxG.cameras.setDefaultDrawTarget(camera, true);
		Assert.areEqual(2, FlxG.cameras.defaults.length);

		FlxG.cameras.remove(camera);
		Assert.areEqual(1, FlxG.cameras.list.length);
		Assert.areEqual(1, FlxG.cameras.defaults.length);
	}

	@Test // #1515
	function testFollowNoLerpChange()
	{
		FlxG.updateFramerate = 30;
		camera = new FlxCamera();

		var defaultLerp = camera.followLerp;
		camera.follow(new FlxObject());
		Assert.areEqual(defaultLerp, camera.followLerp);
	}
	
	@Test
	function testCenter()
	{
		final sprite = new FlxSprite();
		sprite.makeGraphic(100, 100);
		sprite.origin.set(100, 100);
		sprite.offset.set(100, 100);
		sprite.scale.set(2, 4);
		// causes fail
		// sprite.angle = 180;
		final cam = FlxG.camera;
		cam.scroll.set(100, 100);
		cam.zoom *= 2;
		final graphicBounds = sprite.getScreenBounds(null, cam);
		final offset = FlxPoint.get(sprite.x - graphicBounds.x, sprite.y - graphicBounds.y);
		final center = FlxPoint.get((cam.width - graphicBounds.width) / 2 + offset.x, (cam.height - graphicBounds.height) / 2 + offset.y);
		final offCenter = center.copyTo().add(1000, 1000);
		
		sprite.setPosition(offCenter.x, offCenter.y);
		cam.center(sprite, X);
		Assert.areEqual(sprite.x, center.x);
		Assert.areEqual(sprite.y, offCenter.y);
		
		sprite.setPosition(offCenter.x, offCenter.y);
		cam.center(sprite, Y);
		Assert.areEqual(sprite.x, offCenter.x);
		Assert.areEqual(sprite.y, center.y);
		
		sprite.setPosition(offCenter.x, offCenter.y);
		cam.center(sprite, XY);
		Assert.areEqual(sprite.x, center.x);
		Assert.areEqual(sprite.y, center.y);
		
		sprite.setPosition(offCenter.x, offCenter.y);
		cam.center(sprite);
		Assert.areEqual(sprite.x, center.x);
		Assert.areEqual(sprite.y, center.y);
		
		offset.put();
		graphicBounds.put();
		offCenter.put();
		center.put();
	}
	
	@Test
	function testCenterHitbox()
	{
		final object = new FlxObject(0, 0, 10, 10);
		final cam = FlxG.camera;
		cam.scroll.set(100, 100);
		cam.zoom *= 2;
		final hitbox = object.getHitbox();
		final offset = FlxPoint.get(object.x - hitbox.x, object.y - hitbox.y);
		final center = FlxPoint.get(cam.scroll.x + (cam.width - hitbox.width) / 2 + offset.x, cam.scroll.y + (cam.height - hitbox.height) / 2 + offset.y);
		final offCenter = center.copyTo().add(1000, 1000);
		
		object.setPosition(offCenter.x, offCenter.y);
		cam.centerHitbox(object, X);
		Assert.areEqual(object.x, center.x);
		Assert.areEqual(object.y, offCenter.y);
		
		object.setPosition(offCenter.x, offCenter.y);
		cam.centerHitbox(object, Y);
		Assert.areEqual(object.x, offCenter.x);
		Assert.areEqual(object.y, center.y);
		
		object.setPosition(offCenter.x, offCenter.y);
		cam.centerHitbox(object, XY);
		Assert.areEqual(object.x, center.x);
		Assert.areEqual(object.y, center.y);
		
		object.setPosition(offCenter.x, offCenter.y);
		cam.centerHitbox(object);
		Assert.areEqual(object.x, center.x);
		Assert.areEqual(object.y, center.y);
		
		offset.put();
		hitbox.put();
		offCenter.put();
		center.put();
	}
	
	@Test
	function testFadeInFadeOut()
	{
		testFadeCallback(true, false);
	}

	@Test // #1666
	function testFadeOutFadeIn()
	{
		testFadeCallback(false, true);
	}

	function testFadeCallback(firstFade:Bool, secondFade:Bool)
	{
		var secondCallback = false;
		fade(firstFade, function()
		{
			fade(secondFade, function()
			{
				secondCallback = true;
			});
		});

		step(10);
		Assert.isTrue(secondCallback);
	}

	@Test
	function testFadeAlreadyStarted()
	{
		testDoubleFade(true, false, false);
	}

	@Test
	function testFadeForce()
	{
		testDoubleFade(false, true, true);
	}

	function testDoubleFade(firstResult:Bool, secondResult:Bool, force:Bool)
	{
		var callback1 = false;
		var callback2 = false;
		fade(false, function() callback1 = true);
		fade(false, function() callback2 = true, force);

		step(20);
		Assert.areEqual(firstResult, callback1);
		Assert.areEqual(secondResult, callback2);
	}

	function fade(fadeIn:Bool = false, ?onComplete:Void->Void, force:Bool = false)
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.05, fadeIn, onComplete, force);
	}
}