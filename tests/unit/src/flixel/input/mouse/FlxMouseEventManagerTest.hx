package flixel.input.mouse;

import flixel.input.mouse.FlxMouseEvent;
import massive.munit.Assert;

class FlxMouseEventManagerTest extends FlxTest
{
	var sprite0:FlxSprite;
	var sprite1:FlxSprite;

	@Before
	function before()
	{
		FlxMouseEvent.removeAll();
		FlxG.mouse.setGlobalScreenPositionUnsafe(75, 75); // causes a mouse over callback for each test

		sprite0 = new FlxSprite(0, 0);
		sprite0.makeGraphic(100, 100, 0xffffffff, false);

		sprite1 = new FlxSprite(50, 50);
		sprite1.loadGraphicFromSprite(sprite0);
	}

	@Ignore @Test
	function testMouseChildrenAddOrder()
	{
		var count = 0;

		FlxMouseEvent.add(sprite0, null, null, function(_) Assert.fail(""), null, true, true, false);
		FlxMouseEvent.add(sprite1, null, null, function(_) count++, null, false, true, false);

		step();

		Assert.areEqual(1, count);
	}

	@Ignore @Test
	function testSetMouseChildrenOrder()
	{
		var count = 0;

		FlxMouseEvent.add(sprite1, null, null, function(_) count++, null, false, true, false);
		FlxMouseEvent.add(sprite0, null, null, function(_) Assert.fail(""), null, true, true, false);

		FlxMouseEvent.setObjectMouseChildren(sprite0, true);
		FlxMouseEvent.setObjectMouseChildren(sprite1, false);

		step();

		Assert.areEqual(1, count);
	}

	@Ignore @Test
	function testResetMouseChildrenOrder()
	{
		var count = 0;

		FlxMouseEvent.add(sprite1, null, null, function(_) count++, null, false, true, false);
		FlxMouseEvent.add(sprite0, null, null, function(_) Assert.fail(""), null, false, true, false);

		FlxMouseEvent.setObjectMouseChildren(sprite1, false); // brings sprite1 to the front

		step();

		Assert.areEqual(1, count);
	}

	@Ignore @Test
	function testMultipleFalseMouseChildren()
	{
		var count = 0;

		FlxMouseEvent.add(sprite0, null, null, function(_) Assert.fail(""), null, false, true, false);
		FlxMouseEvent.add(sprite1, null, null, function(_) count++, null, false, true, false);

		step();

		Assert.areEqual(1, count);
	}

	@Ignore @Test
	function testMultipleTrueMouseChildren()
	{
		var count = 0;

		FlxMouseEvent.add(sprite0, null, null, function(_) count++, null, true, true, false);
		FlxMouseEvent.add(sprite1, null, null, function(_) count++, null, true, true, false);

		step();

		Assert.areEqual(2, count);
	}
}
