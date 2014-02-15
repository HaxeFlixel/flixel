package flixel;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxColor;
import massive.munit.Assert;

class FlxCameraTest extends FlxTest
{
	@Test function bgColor():Void
	{
		Assert.isTrue(FlxG.cameras.bgColor == FlxColor.BLACK);
	}

	@Test function zoom():Void
	{
		Assert.isTrue(FlxG.camera.zoom == 1);
		Assert.isTrue(FlxCamera.defaultZoom == 1);
	}

	@Test function length():Void
	{
		Assert.isTrue(FlxG.cameras.list.length == 1);
		
		var camera = new FlxCamera();
		
		FlxG.cameras.add(camera);
		Assert.isTrue(FlxG.cameras.list.length == 2);
		
		FlxG.cameras.remove(camera);
		Assert.isTrue(FlxG.cameras.list.length == 1);
	}
}