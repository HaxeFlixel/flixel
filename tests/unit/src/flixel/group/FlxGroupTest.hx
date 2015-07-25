package flixel.group;

import flixel.FlxBasic;
import flixel.group.FlxGroup;
import massive.munit.Assert;

class FlxGroupTest extends FlxTest
{
	var group:FlxGroup;
	var subGroup:FlxGroup;
	
	@Before
	function before():Void
	{
		group = makeGroup();
		group.add(subGroup = makeGroup());
		
		destroyable = group;
	}
	
	function makeGroup():FlxGroup
	{
		var group = new FlxGroup();
		for (i in 0...10)
		{
			group.add(new FlxBasic());
		}
		return group;
	}
	
	@Test
	function testForEachRecurseFalse():Void
	{
		group.forEach(function(b:FlxBasic)
		{
			b.exists = false;
		}, false);
		
		for (basic in group)
		{
			Assert.isFalse(basic.exists);
		}
		
		for (basic in subGroup)
		{
			Assert.isTrue(basic.exists);
		}
	}
	
	@Test
	function testForEachRecurseTrue():Void
	{
		group.forEach(function(b:FlxBasic)
		{
			b.exists = false;
		}, true);
		
		for (basic in group)
		{
			Assert.isFalse(basic.exists);
		}
		
		for (basic in subGroup)
		{
			Assert.isFalse(basic.exists);
		}
	}
	
	@Test
	function testForEachExistsRecurseFalse():Void
	{
		forEachExistsGroupSetup(group);
		forEachExistsGroupSetup(subGroup);
		
		var timesCalled:Int = 0;
		group.forEachExists(function(b:FlxBasic)
		{
			timesCalled++;
		}, false);
		
		Assert.areEqual(1, timesCalled);
	}
	
	@Test
	function testForEachExistsRecurseTrue():Void
	{
		forEachExistsGroupSetup(group);
		forEachExistsGroupSetup(subGroup);
		subGroup.exists = true;
		
		var timesCalled:Int = 0;
		group.forEachExists(function(b:FlxBasic)
		{
			timesCalled++;
		}, true);
		
		Assert.areEqual(3, timesCalled);
	}
	
	function forEachExistsGroupSetup(group:FlxGroup):Void
	{
		for (basic in group)
		{
			basic.exists = false;
		}
		group.members[0].exists = true;
	}

	@Test
	function testKillAndRevive():Void
	{
		group.kill();
		group.forEach(function(each)
		{
			Assert.isFalse(each.exists);
		});
		group.revive();
		group.forEach(function(each)
		{
			Assert.isTrue(each.exists);
		});
	}
}