package flixel.group;

import flixel.FlxSprite;
import massive.munit.Assert;

class FlxSpriteGroupTest extends FlxTest
{
	var group:FlxSpriteGroup;
	
	@Before
	function before()
	{
		group = new FlxSpriteGroup();
		for (i in 0...10)
			group.add(new FlxSprite());
	}
	
	@Test // #1368
	function testExistsTransform()
	{
		Assert.isTrue(existsHasValue(true));
		
		group.exists = false;
		Assert.isTrue(existsHasValue(false));
		
		group.exists = true;
		Assert.isTrue(existsHasValue(true));
	}
	
	function existsHasValue(b:Bool)
	{
		for (member in group)
		{
			if (member.exists != b)
				return false;
		}
		return true;
	}
	
	@Test // #1891
	function testKillRevive()
	{
		Assert.areEqual(group.length, group.countLiving());
		Assert.areEqual(0, group.countDead());
		
		group.kill();
		Assert.areEqual(0, group.countLiving());
		Assert.areEqual(group.length, group.countDead());
		
		group.revive();
		Assert.areEqual(group.length, group.countLiving());
		Assert.areEqual(0, group.countDead());
	}
}