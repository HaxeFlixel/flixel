package flixel;

import massive.munit.Assert;

import flixel.FlxCamera;
import flixel.FlxG;
import massive.munit.Assert;

class FlxCameraTest 
{
	public function new() {}
	
	@Test
	public function cameraNull():Void
	{
		Assert.isNotNull(FlxG.camera);
	}

	@Test
	public function bgColor():Void
	{
		Assert.isTrue(FlxG.cameras.bgColor == 0xff131c1b);
	}

	@Test
	public function zoom():Void
	{
		Assert.isTrue(FlxG.camera.zoom == 1);
		Assert.isTrue(FlxCamera.defaultZoom == 1);
	}

	@Test
	public function length():Void
	{
		Assert.isTrue(FlxG.cameras.list.length == 1);
		
		var camera = new FlxCamera();
		FlxG.cameras.add(camera);

		Assert.isTrue(FlxG.cameras.list.length == 2);

		FlxG.cameras.remove(camera);

		Assert.isTrue(FlxG.cameras.list.length == 1);
	}
}