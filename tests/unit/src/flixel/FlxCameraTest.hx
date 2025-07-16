package flixel;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import haxe.PosInfos;
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
	
	@Test // #3329
	function testCenterGraphic()
	{
		final cam = FlxG.camera;
		cam.scroll.set(100.5, 100.5);
		cam.zoom *= 2;
		
		Assert.areEqual(cam.width, 640);
		Assert.areEqual(cam.height, 480);
		
		final sprite = new FlxSprite();
		sprite.makeGraphic(10, 10);
		sprite.scrollFactor.set(2, 2);
		sprite.origin.set(10, 10);
		sprite.offset.set(10, 10);
		sprite.scale.set(2, 4);
		sprite.angle = 180;
		sprite.pixelPerfectPosition = true;
		sprite.pixelPerfectRender = true;
		
		sprite.setPosition(0, 0);
		cam.centerGraphic(sprite, X);
		assertCenter(sprite, 100.5 + 320 - 10 - (-110.5 + 10), 0);
		
		sprite.setPosition(0, 0);
		cam.centerGraphic(sprite, Y);
		assertCenter(sprite, 0, 100.5 + 240 - 20 - (-110.5 + 10));
		
		sprite.setPosition(0, 0);
		cam.centerGraphic(sprite, XY);
		assertCenter(sprite, 100.5 + 320 - 10 - (-110.5 + 10), 100.5 + 240 - 20 - (-110.5 + 10));
		
		sprite.setPosition(1640, 1480);
		cam.centerGraphic(sprite);
		assertCenter(sprite, 100.5 + 320 - 10 - (-110.5 + 10), 100.5 + 240 - 20 - (-110.5 + 10));
	}
	
	@Test // #3329
	function testCenterHitbox()
	{
		final cam = FlxG.camera;
		cam.scroll.set(100.5, 100.5);
		cam.zoom *= 2;
		
		Assert.areEqual(cam.width, 640);
		Assert.areEqual(cam.height, 480);
		
		final object = new FlxObject(0, 0, 10, 10);
		
		object.setPosition(0, 0);
		cam.centerHitbox(object, X);
		assertCenter(object, 100.5 + 320 - 5, 0);
		
		object.setPosition(0, 0);
		cam.centerHitbox(object, Y);
		assertCenter(object, 0, 100.5 + 240 - 5);
		
		object.setPosition(0, 0);
		cam.centerHitbox(object, XY);
		assertCenter(object, 100.5 + 320 - 5, 100.5 + 240 - 5);
		
		object.setPosition(1640, 1480);
		cam.centerHitbox(object);
		assertCenter(object, 100.5 + 320 - 5, 100.5 + 240 - 5);
	}
	
	function assertCenter(object:FlxObject, expectedX:Float, expectedY:Float, ?info:PosInfos)
	{
		FlxAssert.areNear(object.x, expectedX, info);
		FlxAssert.areNear(object.y, expectedY, info);
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