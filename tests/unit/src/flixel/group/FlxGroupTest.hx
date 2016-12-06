package flixel.group;

import flixel.FlxBasic;
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
		group.forEach(function(basic) basic.exists = false, false);
		
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
		group.forEach(function(basic) basic.exists = false, true);
		
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
	function testForEachOfTypeRecurseTrue():Void
	{
		forEachOfTypeGroupSetup(group);
		forEachOfTypeGroupSetup(subGroup);
		
		var timesCalled:Int = 0;
		group.forEachOfType(FlxObject, function(_) timesCalled++, true);
		
		Assert.areEqual(6, timesCalled);
	}
	
	@Test
	function testForEachOfTypeRecurseFalse():Void
	{
		forEachOfTypeGroupSetup(group);
		forEachOfTypeGroupSetup(subGroup);
		
		var timesCalled:Int = 0;
		group.forEachOfType(FlxObject, function(_) timesCalled++, false);
		
		Assert.areEqual(3, timesCalled);
	}
	
	function forEachOfTypeGroupSetup(group:FlxGroup):Void
	{
		for (i in 0...3)
			group.add(new FlxObject());
	}
	
	@Test
	function testForEachExistsRecurseFalse():Void
	{
		forEachExistsGroupSetup(group);
		forEachExistsGroupSetup(subGroup);
		
		var timesCalled:Int = 0;
		group.forEachExists(function(_) timesCalled++, false);
		
		Assert.areEqual(1, timesCalled);
	}
	
	@Test
	function testForEachExistsRecurseTrue():Void
	{
		forEachExistsGroupSetup(group);
		forEachExistsGroupSetup(subGroup);
		subGroup.exists = true;
		
		var timesCalled:Int = 0;
		group.forEachExists(function(_) timesCalled++, true);
		
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

	@Test // #2010
	function testRemoveSplice()
	{
		var group = new FlxGroup();
		group.add(new FlxBasic());
		Assert.areEqual(1, group.length);

		group.remove(group.members[0], true);
		Assert.areEqual(0, group.length);
	}

	function testRemoveNoSplice()
	{
		var group = new FlxGroup();
		group.add(new FlxBasic());
		Assert.areEqual(1, group.length);

		group.remove(group.members[0], false);
		Assert.areEqual(1, group.length);
		Assert.isNull(group.members[0]);
	}
}
