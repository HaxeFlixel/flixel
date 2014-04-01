package flixel;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxColor;
import massive.munit.Assert;

class FlxCameraTest extends FlxTest
{
	@Test
	function bgColor():Void
	{
		Assert.isTrue(FlxG.cameras.bgColor == FlxColor.BLACK);
	}

	@Test
	function zoom():Void
	{
		Assert.areEqual(1, FlxG.camera.zoom);
		Assert.areEqual(1, FlxCamera.defaultZoom);
	}

	@Test
	function length():Void
	{
		Assert.areEqual(1, FlxG.cameras.list.length);
		
		var camera = new FlxCamera();
		
		FlxG.cameras.add(camera);
		Assert.areEqual(2, FlxG.cameras.list.length);
		
		FlxG.cameras.remove(camera);
		Assert.areEqual(1, FlxG.cameras.list.length);
	}
}