package flixel;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxArrayUtil;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import TestMain;

class FlxSpriteTest extends FlxTest
{
	var sprite1:FlxSprite;
	var sprite2:FlxSprite;
	
	@BeforeClass function beforeClass():Void 
	{
		sprite1 = new FlxSprite();
		sprite1.makeGraphic(100, 80);
		
		sprite2 = new FlxSprite();
		sprite2.makeGraphic(100, 80);
	}
	
	@Test function size():Void 
	{
		Assert.areEqual(sprite1.width, 100);
		Assert.areEqual(sprite1.height, 80);
	}
	
	@Test function sprites():Void 
	{
		Assert.isNotNull(sprite1);
		Assert.isNotNull(sprite2);
		
		Assert.isTrue(sprite1.active);
		Assert.isTrue(sprite1.visible);
		Assert.isTrue(sprite1.alive);
		Assert.isTrue(sprite1.exists);
		
		Assert.isTrue(sprite2.active);
		Assert.isTrue(sprite2.visible);
		Assert.isTrue(sprite2.alive);
		Assert.isTrue(sprite2.exists);
	}
	
	@Test function add():Void 
	{
		FlxG.state.add(sprite1);
		FlxG.state.add(sprite2);
		
		var sprite1Index:Int = FlxArrayUtil.indexOf(FlxG.state.members, sprite1);
		Assert.areNotEqual(sprite1Index, -1);
		
		var sprite2Index:Int = FlxArrayUtil.indexOf(FlxG.state.members, sprite2);
		Assert.areNotEqual(sprite2Index, -1);
	}

	@Test function remove():Void 
	{
		FlxG.state.remove(sprite1);
		
		var sprite1Index:Int = FlxArrayUtil.indexOf(FlxG.state.members, sprite1);
		Assert.areEqual(sprite1Index, -1);
		
		FlxG.state.add(sprite1);
		
		var sprite1Index:Int = FlxArrayUtil.indexOf(FlxG.state.members, sprite1);
		Assert.areNotEqual(sprite1Index, -1);
	}
	
	@AsyncTest function overlap(factory:AsyncFactory):Void
	{
		Assert.isTrue(FlxG.overlap(sprite1, sprite2));
		
		//Move the sprites away from eachother
		sprite1.velocity.x = 2000;
		sprite2.velocity.x = -2000;
		
		var resultHandler:Dynamic = factory.createHandler(this, testOverlap);
		TestMain.addAsync(resultHandler, 100);
	}

	function testOverlap(?e:Dynamic):Void
	{
		Assert.isFalse(FlxG.overlap(sprite1, sprite2));
	}
}