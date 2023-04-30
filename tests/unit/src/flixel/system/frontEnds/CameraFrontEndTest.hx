package flixel.system.frontEnds;

import flixel.FlxCamera;
import massive.munit.Assert;

class CameraFrontEndTest extends FlxTest
{
	@Test
	public function testCameraAdded()
	{
		var success = false;
		var newCamera = new FlxCamera();
		FlxG.cameras.cameraAdded.add(function(camera)
		{
			success = camera == newCamera;
		});
		FlxG.cameras.add(newCamera);
		Assert.isTrue(success);

		FlxG.cameras.cameraAdded.removeAll();
	}

	@Test
	public function testCameraRemoved()
	{
		var success = false;
		var cameraToRemove = new FlxCamera();
		FlxG.cameras.add(cameraToRemove);

		FlxG.cameras.cameraRemoved.add(function(camera)
		{
			success = camera == cameraToRemove;
		});
		FlxG.cameras.remove(cameraToRemove);
		Assert.isTrue(success);

		FlxG.cameras.cameraRemoved.removeAll();
	}

	@Test
	public function testCameraResized()
	{
		var success = false;
		FlxG.cameras.cameraResized.add(function(camera)
		{
			success = camera == FlxG.camera;
		});
		FlxG.camera.width = 500;
		Assert.isTrue(success);

		FlxG.cameras.cameraResized.removeAll();
	}

	@Test // #2016
	function testResetRemoveAllCameras()
	{
		Assert.areEqual(1, FlxG.cameras.list.length);

		FlxG.cameras.add(new FlxCamera());
		Assert.areEqual(2, FlxG.cameras.list.length);

		var calls = 0;
		FlxG.cameras.cameraRemoved.add(function(_) calls++);
		FlxG.cameras.reset();
		Assert.areEqual(2, calls);

		FlxG.cameras.cameraRemoved.removeAll();
	}
}
