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
	function testCallbacks():Void
	{
		var addCalled = false;
		var removeCalled = false;
		group.memberAdded.add((obj)->addCalled = true);
		group.memberRemoved.add((obj)->removeCalled = true);
		
		final basic = new FlxBasic();
		group.add(basic);
		
		Assert.isTrue(addCalled);
		Assert.isFalse(removeCalled);
		
		addCalled = false;
		removeCalled = false;
		
		group.remove(basic, true);
		
		Assert.isFalse(addCalled);
		Assert.isTrue(removeCalled);
		
		addCalled = false;
		removeCalled = false;
		
		group.replace(group.getFirstAlive(), basic);
		
		Assert.isTrue(addCalled);
		Assert.isTrue(removeCalled);
	}
	
	@Test
	function testAddExisting():Void
	{
		final oldLength = group.length;
		group.add(group.members[0]);
		
		Assert.areEqual(oldLength, group.length);
	}
	
	@Test
	function testAddMaxSize():Void
	{
		final oldLength = group.length;
		group.maxSize = group.length;
		group.add(new FlxBasic());
		
		Assert.areEqual(oldLength, group.length);
	}
	
	@Test
	function testReduceMaxSize():Void
	{
		Assert.isTrue(group.length > 5);
		group.maxSize = 5;
		
		Assert.areEqual(5, group.length);
	}
	
	@Test
	function testInsert()
	{
		final oldLength = group.length;
		group.insert(1, new FlxBasic());
		
		Assert.areEqual(oldLength + 1, group.length);
	}
	
	@Test
	function testInsertExisting()
	{
		final oldLength = group.length;
		group.insert(1, group.members[0]);
		
		Assert.areEqual(oldLength, group.length);
	}
	
	@Test
	function testInsertLast()
	{
		final oldLength = group.length;
		final basic = new FlxBasic();
		group.insert(group.length, basic);
		
		Assert.areEqual(oldLength + 1, group.length);
		Assert.areEqual(basic, group.members[group.length - 1]);
	}
	
	@Test
	function testInsertAtNull()
	{
		group.remove(group.members[0]);
		final oldLength = group.length;
		final basic = new FlxBasic();
		group.insert(0, basic);
		
		Assert.areEqual(oldLength, group.length);
		Assert.areEqual(basic, group.members[0]);
	}
	
	@Test
	function testInsertMaxSize()
	{
		group.maxSize = group.length;
		final basic = new FlxBasic();
		group.insert(0, basic);
		
		Assert.areEqual(group.maxSize, group.length);
		Assert.isFalse(group.members.contains(basic));
	}
	
	@Test
	function testRecycleClassAtNull()
	{
		final basic = group.getFirstAlive();
		basic.kill();
		Assert.areEqual(basic, group.recycle(FlxBasic));
	}
	
	@Test
	function testRecycleFuncAtNull()
	{
		final basic = group.getFirstAlive();
		basic.kill();
		Assert.areEqual(basic, group.recycle(FlxBasic.new));
	}
	
	@Test
	function testRecycleClassLast()
	{
		final oldLength = group.length;
		group.recycle(FlxBasic);
		Assert.areEqual(oldLength + 1, group.length);
	}
	
	@Test
	function testRecycleFuncLast()
	{
		final oldLength = group.length;
		group.recycle(null, FlxBasic.new);
		Assert.areEqual(oldLength + 1, group.length);
	}
	
	@Test
	function testRecycleClassRotating()
	{
		group.maxSize = group.length;
		final first = group.members[0];
		Assert.areEqual(first, group.recycle(FlxBasic));
		Assert.areEqual(group.maxSize, group.length);
	}
	
	@Test
	function testRecycleFuncClass()
	{
		var called = false;
		function createObject()
		{
			called = true;
			return new FlxBasic();
		}
		
		final oldLength = group.length;
		group.recycle(FlxBasic, createObject);
		Assert.areEqual(oldLength + 1, group.length);
		Assert.isTrue(called);
	}
	
	@Test
	function testRecycleFuncRotating()
	{
		group.maxSize = group.length;
		final first = group.members[0];
		Assert.areEqual(first, group.recycle(null, FlxBasic.new));
		Assert.areEqual(group.maxSize, group.length);
	}
	
	@Test
	function testRecycleFuncClassRotating()
	{
		group.maxSize = group.length;
		final first = group.members[0];
		Assert.areEqual(first, group.recycle(FlxBasic, FlxBasic.new));
		Assert.areEqual(group.maxSize, group.length);
	}
	
	@Test
	function testRecycleRotateAll()
	{
		group.maxSize = group.length;
		final copy = group.members.copy();
		group.killMembers();
		for (i in 0...group.length)
			group.recycle(FlxBasic);
		FlxAssert.arraysEqual(copy, group.members);
		group.forEach((basic)->Assert.isTrue(basic.exists));
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
		
		group.killMembers();
		group.forEach(function(each)
		{
			Assert.isFalse(each.exists);
		});
		group.reviveMembers();
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
		final oldlength = group.length;
		
		group.remove(group.members[0], true);
		Assert.areEqual(oldlength - 1, group.length);
		Assert.isNotNull(group.members[0]);
	}

	@Test
	function testRemoveNoSplice()
	{
		final oldlength = group.length;
		
		group.remove(group.members[0], false);
		Assert.areEqual(oldlength, group.length);
		Assert.isNull(group.members[0]);
	}

	@Test // #2111
	function testAddedSignal()
	{
		var group = new FlxGroup();
		Assert.isNotNull(group.memberAdded);

		var success = false;
		var child = new FlxBasic();

		group.memberAdded.add(function(basic:FlxBasic)
		{
			success = child == basic;
		});

		group.add(child);

		if (!success)
		{
			Assert.fail("FlxGroupTest#testAddedSignal has failed.");
		}

		child = new FlxBasic();
		group.add(child);

		if (!success)
		{
			Assert.fail("FlxGroupTest#testAddedSignal has failed.");
		}
	}

	@Test // #2111
	function testRemovedSignal()
	{
		var group = new FlxGroup();
		Assert.isNotNull(group.memberRemoved);

		var success = false;
		var child = new FlxBasic();
		group.add(child);

		group.memberRemoved.add(function(basic:FlxBasic)
		{
			success = child == basic;
		});

		group.remove(child);

		if (!success)
		{
			Assert.fail("FlxGroupTest#testRemovedSignal has failed.");
		}

		child = new FlxBasic();
		group.add(child);
		group.remove(child);

		if (!success)
		{
			Assert.fail("FlxGroupTest#testRemovedSignal has failed.");
		}
	}
	
	function isKilled(basic:FlxBasic)
	{
		return basic.alive == false;
	}
	
	function isAlive(basic:FlxBasic)
	{
		return basic.alive;
	}
	
	@Test
	function testGetFirst()
	{
		group.remove(group.members[0]); // make first member null
		group.members[3].kill(); // desired
		group.members[6].kill();
		
		Assert.areEqual(group.members[3], group.getFirst(isKilled));
	}
	
	@Test
	function testGetLast()
	{
		group.remove(group.members[0]); // make first member null
		group.members[3].kill();
		group.members[6].kill(); // desired
		
		Assert.areEqual(group.members[6], group.getLast(isKilled));
	}
	
	@Test
	function testGetFirstIndex()
	{
		group.remove(group.members[0]); // make first member null
		group.members[3].kill(); // desired
		group.members[6].kill();
		
		function isKilled(basic) 
		{
			return basic.exists == false;
		}
		
		Assert.areEqual(3, group.getFirstIndex(isKilled));
	}
	
	@Test
	function testGetLastIndex()
	{
		group.remove(group.members[0]); // make first member null
		group.members[3].kill();
		group.members[6].kill(); // desired
		
		Assert.areEqual(6, group.getLastIndex(isKilled));
	}
	
	@Test
	function testAny()
	{
		group.remove(group.members[0]); // make first member null
		group.members[3].kill();
		group.members[6].kill(); // desired
		
		Assert.isTrue(group.any(isKilled));
	}
	
	@Test
	function testEvery()
	{
		group.remove(group.members[0]); // make first member null
		
		Assert.isTrue(group.every(isAlive));
	}
	
	@Test
	function testGetFirstNull()
	{
		Assert.isTrue(group.length >= 6);
	}
	
	@Test
	function testGetFirstMisc()
	{
		Assert.isTrue(group.length > 6);
		group.members[0].kill();
		group.members[1].kill();
		group.members[2].kill();
		group.remove(group.members[3]); // make null
		group.remove(group.members[5]); // make null
		Assert.areEqual(3, group.getFirstNull());
		Assert.areEqual(group.members[4], group.getFirstExisting());
		Assert.areEqual(group.members[4], group.getFirstAlive());
		Assert.areEqual(group.members[0], group.getFirstDead());
		Assert.areEqual(group.members[0], group.getFirstAvailable());
		final nullCount = 2;
		final deadCount = 3;
		Assert.areEqual(deadCount, group.countDead());
		Assert.areEqual(group.length - nullCount - deadCount, group.countLiving());
	}
	
	@Test
	function testIterator()
	{
		var count = 0;
		for (member in group) // array iterator
			count++;
		
		Assert.areEqual(group.length, count);
		
		group.remove(group.members[0]);
		group.members[1].kill();
		
		count = 0;
		for (i=>member in group) // keyValueIterator
			count++;
		
		Assert.areEqual(group.length, count);
	}
}
