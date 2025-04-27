package flixel;

import flixel.FlxSprite;
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
	
	@Test
	function testCoordinateConverters()
	{
		Assert.areEqual(camera.width, 640);
		Assert.areEqual(camera.height, 480);
		
		final world = FlxPoint.get();
		final view = FlxPoint.get();
		final game = FlxPoint.get();
		
		#if FLX_POINT_POOL
		// track leaked points
		@:privateAccess
		final pointPool = FlxBasePoint.pool;
		pointPool.preAllocate(100);
		final startingPoolLength = pointPool.length;
		#end
		
		function assertWorldToView(worldX:Float, worldY:Float, expectedX:Float, expectedY:Float, margin = 0.001, ?posInfo:PosInfos)
		{
			function getViewMsg(prefix:String)
			{
				return '[$prefix] - ViewPos [$view] is not within [$margin] of [( x:$expectedX | y:$expectedY )]';
			}
			
			function getWorldMsg(prefix:String)
			{
				return '[$prefix] - WorldPos [$world] is not within [$margin] of [( x:$worldX | y:$worldY )]';
			}
			
			world.set(worldX, worldY);
			// test overload (point, point)
			camera.worldToViewPosition(world, null, view);
			FlxAssert.pointNearXY(expectedX, expectedY, view, margin, getViewMsg('p,p'), posInfo);
			
			camera.viewToWorldPosition(view, null, world);
			FlxAssert.pointNearXY(worldX, worldY, world, margin, getWorldMsg('p,p'), posInfo);
			
			// test overload (point, x,y)
			camera.worldToViewPosition(world, 1.0, 1.0, view);
			FlxAssert.pointNearXY(expectedX, expectedY, view, margin, getViewMsg('p,xy'), posInfo);
			
			camera.viewToWorldPosition(view, 1.0, 1.0, world);
			FlxAssert.pointNearXY(worldX, worldY, world, margin, getWorldMsg('p,xy'), posInfo);
			
			// test overload (x,y, x,y)
			camera.worldToViewPosition(worldX, worldY, 1.0, 1.0, view);
			FlxAssert.pointNearXY(expectedX, expectedY, view, margin, getViewMsg('xy,xy'), posInfo);
			
			camera.viewToWorldPosition(view.x, view.y, 1.0, 1.0, world);
			FlxAssert.pointNearXY(worldX, worldY, world, margin, getWorldMsg('xy,xy'), posInfo);
			
			// test overload (x,y, point)
			camera.worldToViewPosition(worldX, worldY, null, view);
			FlxAssert.pointNearXY(expectedX, expectedY, view, margin, getViewMsg('xy,p'), posInfo);
			
			camera.viewToWorldPosition(view.x, view.y, null, world);
			FlxAssert.pointNearXY(worldX, worldY, world, margin, getWorldMsg('xy,p'), posInfo);
			
			// test view to game and back
			function getGameMsg(prefix:String)
			{
				return '[$prefix] - Game<->View [$view] is not within [$margin] of [( x:$expectedX | y:$expectedY )]';
			}
			
			camera.viewToGamePosition(view.x, view.y, game);
			camera.gameToViewPosition(game.x, game.y, view);
			FlxAssert.pointNearXY(expectedX, expectedY, view, margin, getGameMsg('xy'), posInfo);
			
			camera.viewToGamePosition(view, game);
			camera.gameToViewPosition(game, view);
			FlxAssert.pointNearXY(expectedX, expectedY, view, margin, getGameMsg('p'), posInfo);
		}
		
		assertWorldToView(320, 240, 320, 240);
		
		camera.zoom = 2.0;
		assertWorldToView(320, 240, 160, 120);
		
		camera.scroll.set(5, 10);
		assertWorldToView(320, 240, 155, 110);
		
		camera.zoom = 1.0;
		assertWorldToView(320, 240, 315, 230);
		
		// test view to game
		FlxAssert.pointNearXY(320, 240, camera.viewToGamePosition(320, 240, game));
		
		camera.x += 10;
		camera.y += 20;
		
		FlxAssert.pointNearXY(330, 260, camera.viewToGamePosition(320, 240, game));
		
		camera.zoom = 2.0;
		FlxAssert.pointNearXY(650, 500, camera.viewToGamePosition(320, 240, game));
		
		#if FLX_POINT_POOL
		Assert.areEqual(startingPoolLength, pointPool.length);
		#end
	}
	
	@Test
	function testCoordinateConvertersNullResult()
	{
		// Test that a new point is returned when a result is not supplied (A common dev error)
		try
		{
			final result = camera.viewToWorldPosition(0, 0);
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "viewToWorldPosition", message: "${e.message}", stack:\n${e.stack}');
		}
		
		try
		{
			final result = camera.worldToViewPosition(0, 0);
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "worldToViewPosition", message: "${e.message}", stack:\n${e.stack}');
		}
		
		try
		{
			final result = camera.gameToViewPosition(0, 0);
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "gameToViewPosition", message: "${e.message}", stack:\n${e.stack}');
		}
		
		try
		{
			final result = camera.viewToGamePosition(0, 0);
			Assert.areEqual(0, result.x);
		}
		catch(e)
		{
			Assert.fail('Exception thrown from "viewToGamePosition", message: "${e.message}", stack:\n${e.stack}');
		}
	}
}