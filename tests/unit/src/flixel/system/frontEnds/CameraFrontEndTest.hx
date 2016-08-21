package flixel.system.frontEnds;

import flixel.FlxCamera;
import massive.munit.Assert;

class CameraFrontEndTest
{
	@Test
	public function testCameraAdded()
	{
		var success = false;
		var newCamara = new FlxCamera();
		FlxG.cameras.cameraAdded.add(function(camera)
		{
			success = camera == newCamara;
		});
		FlxG.cameras.add(newCamara);
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
}