package flixel.util;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import haxe.PosInfos;
import massive.munit.Assert;

using flixel.util.FlxSpriteUtil;

class FlxSpriteUtilTest extends FlxTest
{
	var sprite:FlxSprite;

	@Before
	function before()
	{
		sprite = new FlxSprite();
	}

	@Test
	function testDrawCircleDefaultPosition()
	{
		var size = 10;
		var halfSize = 5;

		sprite.setPosition(100, 100);
		sprite.makeGraphic(size, size, FlxColor.TRANSPARENT);
		sprite.drawCircle(-1, -1, halfSize, FlxColor.WHITE);

		Assert.areEqual(0xffffff, sprite.pixels.getPixel(halfSize, halfSize));
	}

	@Test // #1314
	function testDrawPolygonUnmodifiedArray()
	{
		sprite.makeGraphic(10, 10);
		var vertices = [FlxPoint.get(0, 0), FlxPoint.get(10, 10)];
		sprite.drawPolygon(vertices);

		Assert.isTrue(vertices[0].equals(FlxPoint.get(0, 0)));
		Assert.isTrue(vertices[1].equals(FlxPoint.get(10, 10)));
	}
	
	@Test // #2851
	function testCameraWrap()
	{
		final cam = FlxG.camera;
		final offscreenBounds = FlxRect.get();
		final screenCenter = FlxPoint.get();
		
		// reusable points
		final pExpected = FlxPoint.get();
		final pActual = FlxPoint.get();
		
		cam.scroll.x = 250;
		cam.scroll.y = 100;
		
		offscreenBounds.x = cam.scroll.x - sprite.width;
		offscreenBounds.y = cam.scroll.y - sprite.height;
		offscreenBounds.width = cam.width + sprite.width;
		offscreenBounds.height = cam.height + sprite.height;
		
		screenCenter.set(cam.scroll.x + (cam.width - sprite.width) / 2, cam.scroll.y + (cam.height - sprite.height) / 2);
		
		function assertWrapTo(startX:Float, startY:Float, expectedX:Float, expectedY:Float, margin = 0.001, ?info:PosInfos)
		{
			pExpected.set(expectedX, expectedY);
			// check just outside, and just inside
			sprite.x = startX;
			sprite.y = startY;
			sprite.cameraWrap(cam);
			final msg = 'Wrapping (x:$startX | y:$startY): expected [$pExpected], got [$pActual]';
			pActual.set(sprite.x, sprite.y);
			FlxAssert.pointsNear(pExpected, pActual, margin, info);
			// wrap again and assert that it doesn't move
			startX = sprite.x;
			startY = sprite.y;
			sprite.cameraWrap(cam);
			final msg = 'RE-Wrapping (x:$startX | y:$startY): expected [$pExpected], got [$pActual]';
			pActual.set(sprite.x, sprite.y);
			FlxAssert.pointsNear(pExpected, pActual, margin, info);
		}
		
		// left
		assertWrapTo(offscreenBounds.left - 1, screenCenter.y, offscreenBounds.right, screenCenter.y);
		// right
		assertWrapTo(offscreenBounds.right + 1, screenCenter.y, offscreenBounds.left, screenCenter.y);
		// top
		assertWrapTo(screenCenter.x, offscreenBounds.top - 1, screenCenter.x, offscreenBounds.bottom);
		// bottom
		assertWrapTo(screenCenter.x, offscreenBounds.bottom + 1, screenCenter.x, offscreenBounds.top);
		// top-left
		assertWrapTo(offscreenBounds.left - 1, offscreenBounds.top - 1, offscreenBounds.right, offscreenBounds.bottom);
		// top-right
		assertWrapTo(offscreenBounds.right + 1, offscreenBounds.top - 1, offscreenBounds.left, offscreenBounds.bottom);
		// bottom-left
		assertWrapTo(offscreenBounds.left - 1, offscreenBounds.bottom + 1, offscreenBounds.right, offscreenBounds.top);
		// bottom-right
		assertWrapTo(offscreenBounds.right + 1, offscreenBounds.bottom + 1, offscreenBounds.left, offscreenBounds.top);
		// center
		assertWrapTo(screenCenter.x, screenCenter.y, screenCenter.x, screenCenter.y);
	}
	
	@Test // #2851
	function testCameraBound()
	{
		final cam = FlxG.camera;
		final offscreenBounds = FlxRect.get();
		final screenCenter = FlxPoint.get();
		
		// reusable points
		final pExpected = FlxPoint.get();
		final pActual = FlxPoint.get();
		
		cam.scroll.x = 250;
		cam.scroll.y = 100;
		
		offscreenBounds.x = cam.scroll.x - sprite.width;
		offscreenBounds.y = cam.scroll.y - sprite.height;
		offscreenBounds.width = cam.width + sprite.width;
		offscreenBounds.height = cam.height + sprite.height;
		
		screenCenter.set(cam.scroll.x + (cam.width - sprite.width) / 2, cam.scroll.y + (cam.height - sprite.height) / 2);
		
		function assertBoundTo(startX:Float, startY:Float, expectedX:Float, expectedY:Float, margin = 0.001, ?info:PosInfos)
		{
			pExpected.set(expectedX, expectedY);
			// check just outside, and just inside
			sprite.x = startX;
			sprite.y = startY;
			sprite.cameraBound(cam);
			pActual.set(sprite.x, sprite.y);
			final msg = 'Binding (x:$startX | y:$startY): expected [$pExpected], got [$pActual]';
			FlxAssert.pointsNear(pExpected, pActual, margin, msg, info);
			// bind again and assert that it doesn't move
			startX = sprite.x;
			startY = sprite.y;
			sprite.cameraBound(cam);
			pActual.set(sprite.x, sprite.y);
			final msg = 'RE-binding (x:$startX | y:$startY): expected [$pExpected], got [$pActual]';
			FlxAssert.pointsNear(pExpected, pActual, margin, msg, info);
		}
		
		// left
		assertBoundTo(offscreenBounds.left - 1, screenCenter.y, offscreenBounds.left, screenCenter.y);
		// right
		assertBoundTo(offscreenBounds.right + 1, screenCenter.y, offscreenBounds.right, screenCenter.y);
		// top
		assertBoundTo(screenCenter.x, offscreenBounds.top - 1, screenCenter.x, offscreenBounds.top);
		// bottom
		assertBoundTo(screenCenter.x, offscreenBounds.bottom + 1, screenCenter.x, offscreenBounds.bottom);
		// top-left
		assertBoundTo(offscreenBounds.left - 1, offscreenBounds.top - 1, offscreenBounds.left, offscreenBounds.top);
		// top-right
		assertBoundTo(offscreenBounds.right + 1, offscreenBounds.top - 1, offscreenBounds.right, offscreenBounds.top);
		// bottom-left
		assertBoundTo(offscreenBounds.left - 1, offscreenBounds.bottom + 1, offscreenBounds.left, offscreenBounds.bottom);
		// bottom-right
		assertBoundTo(offscreenBounds.right + 1, offscreenBounds.bottom + 1, offscreenBounds.right, offscreenBounds.bottom);
		// center
		assertBoundTo(screenCenter.x, screenCenter.y, screenCenter.x, screenCenter.y);
	}
}
