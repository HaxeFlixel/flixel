package flixel.input.mouse;

import flixel.input.mouse.FlxMouseEventManager;
import massive.munit.Assert;

class FlxMouseEventManagerTest
{
	@Before
	function before()
	{
		FlxMouseEventManager.removeAll();
	}
	
	@Test
	@:access(flixel.input.mouse.FlxMouseEventManager)
	function testMouseChildrenOrder()
	{
		var sprite0 = new FlxSprite();
		var sprite1 = new FlxSprite();
		var sprite2 = new FlxSprite();
		var sprite3 = new FlxSprite();
		
		FlxMouseEventManager.add(sprite0, null, null, null, null, true);
		FlxMouseEventManager.add(sprite1, null, null, null, null, false);
		FlxMouseEventManager.add(sprite2, null, null, null, null, true);
		FlxMouseEventManager.add(sprite3, null, null, null, null, false);
		
		// mouseChildren false comes before mouseChildren true, and more recently added comes before existing
		var sprites = [sprite3, sprite1, sprite2, sprite0];
		for (i in 0...sprites.length)
		{
			Assert.areEqual(sprites[i], FlxMouseEventManager._registeredObjects[i].object);
		}
	}
	
	@Test
	@:access(flixel.input.mouse.FlxMouseEventManager)
	function testSetMouseChildrenOrder()
	{
		var sprite0 = new FlxSprite();
		var sprite1 = new FlxSprite();
		
		FlxMouseEventManager.add(sprite0, null, null, null, null, true);
		FlxMouseEventManager.add(sprite1, null, null, null, null, false);
		
		FlxMouseEventManager.setObjectMouseChildren(sprite1, true);
		
		var sprites = [sprite1, sprite0];
		for (i in 0...sprites.length)
		{
			Assert.areEqual(sprites[i], FlxMouseEventManager._registeredObjects[i].object);
		}
	}
}