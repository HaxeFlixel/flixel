package flixel.group;

import flixel.FlxSprite;
import flixel.math.FlxRect;
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

	@Test // #2051
	function testClipRect()
	{
		var rect = FlxRect.get(10, 10, 50, 50);
		group.x = group.y = 50;

		var child = group.members[0];
		child.x = child.y = 100;

		group.clipRect = rect;

		Assert.isTrue(child.clipRect.equals(FlxRect.weak(-40, -40, 50, 50))); // child.clipRect should be set

		var group2 = new FlxSpriteGroup();
		group2.add(child);

		Assert.isTrue(child.clipRect.equals(FlxRect.weak(-40, -40, 50, 50))); // child.clipRect should not be overridden by null

		group2.x = group2.y = 50; // child gets offset to 150,150
		group2.clipRect = FlxRect.get(20, 20, 50, 50);

		Assert.isTrue(child.clipRect.equals(FlxRect.weak(-80, -80, 50, 50))); // child.clipRect should be overridden
	}

	@Test // #1353
	function testZeroAlpha()
	{
		group.alpha = 0;
		Assert.areEqual(0, group.members[0].alpha);

		group.alpha = 1;
		Assert.areEqual(1, group.members[0].alpha);
	}
	
	@Test // #2306
	function testReset()
	{
		for (i in 0...group.length)
		{
			var member = group.members[i];
			member.x = i * 5;
		}
		
		group.reset(10, 0);
		
		for (i in 0...group.length)
		{
			var member = group.members[i];
			FlxAssert.areNear(group.x + i * 5, member.x);
		}
	}
	
	@Test
	/** #2306
	 * Make sure members' kill() and revive() are actually called,
	 * rather than just checking their exists/alive values.
	 */
	function testKillRevive2306()
	{
		var member1 = new Member();
		group.add(member1);
		Assert.isFalse(member1.killed);
		Assert.isFalse(member1.revived);
		
		var member2 = new Member();
		Assert.isFalse(member1.killed);
		Assert.isFalse(member1.revived);
		group.add(member2);
		
		member2.exists = false;
		group.kill();
		Assert.isTrue(member1.killed);
		Assert.isFalse(member1.revived);
		Assert.isFalse(member2.killed);
		Assert.isFalse(member2.revived);
		
		member2.exists = true;
		group.revive();
		Assert.isTrue(member1.killed);
		Assert.isTrue(member1.revived);
		Assert.isFalse(member2.killed);
		Assert.isFalse(member2.revived);
		return group;
	}
}

class Member extends FlxSprite
{
	public var killed = false;
	public var revived = false;
	
	override function kill()
	{
		killed = true;
		super.kill();
	}
	
	override function revive()
	{
		revived = true;
		super.revive();
	}
}