package flixel;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxColor;
import massive.munit.Assert;

class FlxCameraTest extends FlxTest
{
	var camera:FlxCamera;
	
	@Before
	function before()
	{
		camera = new FlxCamera();
		destroyable = camera;
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
	}
	
	@Test
	function testDefaultCameras():Void
	{
		Assert.areEqual(FlxG.cameras.list, FlxCamera.defaultCameras);
	}
	
	@Test
	function testDefaultCamerasStateSwitch():Void
	{
		FlxCamera.defaultCameras = [FlxG.camera];
		FlxG.switchState(new FlxState());
		
		step();
		Assert.areEqual(FlxG.cameras.list, FlxCamera.defaultCameras);
	}
	
	@Test
	function testAddAndRemoveCamera():Void
	{
		FlxG.cameras.add(camera);
		Assert.areEqual(2, FlxG.cameras.list.length);
		
		FlxG.cameras.remove(camera);
		Assert.areEqual(1, FlxG.cameras.list.length);
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
}