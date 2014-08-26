package flixel.util;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxPath;
import massive.munit.Assert;

class FlxPathTest extends FlxTest
{
	var object:FlxObject;
	var path:FlxPath;
	
	@Before
	function before()
	{
		object = new FlxObject();
		FlxG.state.add(object);
		
		path = new FlxPath();
	}
	
	@Test
	function testImmovableValueAfterCompletionNotModfied()
	{
		Assert.isFalse(object.immovable);
		
		startPath();
		finishPath();
		
		Assert.isFalse(object.immovable);
	}
	
	@Test
	function testImmovableValueAfterCancelNotModfied()
	{
		Assert.isFalse(object.immovable);
		
		startPath();
		path.cancel();
		
		Assert.isFalse(object.immovable);
	}
	
	function finishPath()
	{
		while (!path.finished)
		{
			step();
		}
	}
	
	function startPath()
	{
		path.start(object, [FlxPoint.get(), FlxPoint.get(100, 100)]);
	}
}