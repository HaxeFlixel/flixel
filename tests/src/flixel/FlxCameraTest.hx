package flixel;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxColor;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

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
	
	@AsyncTest
	function testDefaultCamerasStateSwitch(factory:AsyncFactory):Void
	{
		FlxCamera.defaultCameras = [FlxG.camera];
		FlxG.switchState(new FlxState());
		
		delay(this, factory, function() {
			Assert.areEqual(FlxG.cameras.list, FlxCamera.defaultCameras);
		});
	}
	
	@Test
	function testAddAndRemoveCamera():Void
	{
		FlxG.cameras.add(camera);
		Assert.areEqual(2, FlxG.cameras.list.length);
		
		FlxG.cameras.remove(camera);
		Assert.areEqual(1, FlxG.cameras.list.length);
	}
}