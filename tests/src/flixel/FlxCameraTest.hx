package flixel;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxColor;
import massive.munit.Assert;

class FlxCameraTest extends FlxTest
{
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
	function testAddAndRemoveCamera():Void
	{
		var camera = new FlxCamera();
		
		FlxG.cameras.add(camera);
		Assert.areEqual(2, FlxG.cameras.list.length);
		
		FlxG.cameras.remove(camera);
		Assert.areEqual(1, FlxG.cameras.list.length);
	}
}