package flixel.util;

import massive.munit.Assert;
import flixel.util.FlxDirections;

/**
 * A bulk of these tests are copied from `FlxColor`.
 */
class FlxDirectionsTest extends FlxTest
{
	var dirs:FlxDirections;
	
	@Test
	function isNull()
	{
		var dirs:Null<FlxDirections> = null;
		Assert.isNull(dirs);
	}
	
	@Test
	function isNullFunction()
	{
		var f = function(?c:FlxDirections)
		{
			return c == null;
		};
		
		Assert.isTrue(f(null));
		Assert.isFalse(f(0));
		Assert.isFalse(f(LEFT));
	}
	
	@Test
	function equalityToNull()
	{
		var dirs1:Null<FlxDirections> = null;
		var dirs2:FlxDirections = LEFT;
		Assert.isFalse(dirs1 == dirs2);
	}
	
	@Test
	function equalityToSame()
	{
		var dirs1:FlxDirections = LEFT;
		var dirs2:FlxDirections = LEFT;
		Assert.isTrue(dirs1 == dirs2);
	}
	
	@Test
	function equalityNotSame()
	{
		var dirs1:FlxDirections = LEFT;
		var dirs2:FlxDirections = RIGHT;
		Assert.isFalse(dirs1 == dirs2);
	}
	
	@Test
	function addSame()
	{
		Assert.areEqual(LEFT, (LEFT + LEFT));
		Assert.areEqual(RIGHT, (RIGHT + RIGHT));
	}
	
	@Test
	function addNotSame()
	{
		Assert.areEqual(WALL, (LEFT + RIGHT));
		Assert.areEqual(WALL, (RIGHT + LEFT));
	}
	
	@Test
	function orSame()
	{
		Assert.areEqual(LEFT, (LEFT | LEFT));
		Assert.areEqual(RIGHT, (RIGHT | RIGHT));
	}
	
	@Test
	function orNotSame()
	{
		Assert.areEqual(WALL, (LEFT | RIGHT));
		Assert.areEqual(WALL, (RIGHT | LEFT));
	}
	
	@Test
	function andSame()
	{
		Assert.areEqual(LEFT, (LEFT & LEFT));
		Assert.areEqual(RIGHT, (RIGHT & RIGHT));
	}
	
	@Test
	function andNotSame()
	{
		Assert.areEqual(NONE, (LEFT & RIGHT));
		Assert.areEqual(NONE, (RIGHT & LEFT));
	}
	
	@Test
	function subtractNotSame()
	{
		Assert.areEqual(LEFT , (LEFT - RIGHT));
		Assert.areEqual(RIGHT, (RIGHT - LEFT));
	}
	
	@Test
	function hasAny()
	{
		Assert.isTrue(WALL.hasAny(LEFT));
		Assert.isTrue(LEFT.hasAny(WALL));
		Assert.isFalse(UP.hasAny(WALL));
		Assert.isFalse(WALL.hasAny(UP));
		Assert.isFalse(LEFT.hasAny(RIGHT));
	}
	
	@Test
	function hasAll()
	{
		Assert.isTrue(WALL.hasAll(LEFT));
		Assert.isTrue(WALL.hasAll(LEFT | RIGHT));
		Assert.isFalse(LEFT.hasAll(WALL));
		Assert.isFalse(WALL.hasAll(UP));
		Assert.isFalse(WALL.hasAll(LEFT | RIGHT | DOWN));
	}
	
	@Test
	function specials()
	{
		Assert.areEqual(DOWN, FLOOR);
		Assert.areEqual(UP, CEILING);
		Assert.areEqual(LEFT | RIGHT, WALL);
		Assert.areEqual(0, NONE);
		Assert.areEqual(LEFT | RIGHT | UP | DOWN, ANY);
	}
	
	@Test
	function strings()
	{
		Assert.areEqual("NONE", NONE.toString());
		Assert.areEqual("L", LEFT.toString());
		Assert.areEqual("R", RIGHT.toString());
		Assert.areEqual("U", UP.toString());
		Assert.areEqual("D", DOWN.toString());
		Assert.areEqual("L | R", (LEFT | RIGHT).toString());
		Assert.areEqual("L | R", WALL.toString());
		Assert.areEqual("L | R | U | D", ANY.toString());
	}
	
	@Test
	function addRemove()
	{
		dirs = WALL;
		dirs.remove(LEFT);
		Assert.areEqual(RIGHT, dirs);
		dirs.add(UP);
		Assert.areEqual(RIGHT | UP, dirs);
		dirs -= UP;
		Assert.areEqual(RIGHT, dirs);
		dirs += LEFT;
		Assert.areEqual(WALL, dirs);
		dirs += NONE;
		Assert.areEqual(WALL, dirs);
		dirs += ANY;
		Assert.areEqual(ANY, dirs);
	}
	
	@Test
	function addRemoveNew()
	{
		dirs = WALL;
		Assert.areEqual(RIGHT, dirs.removeNew(LEFT));
		Assert.areEqual(RIGHT, dirs - LEFT);
		Assert.areEqual(0x0111, dirs.addNew(UP));
		Assert.areEqual(0x0111, dirs + UP);
		Assert.areEqual(WALL, dirs.add(NONE));
		Assert.areEqual(WALL, dirs + NONE);
		Assert.areEqual(ANY, dirs.add(ANY));
		Assert.areEqual(ANY, dirs + ANY);
	}
	
	@Test
	function operatorInts()
	{
		dirs = WALL;
		Assert.isTrue((dirs & LEFT) > 0);
		Assert.isTrue((dirs & LEFT) > NONE);
		Assert.isTrue((dirs & 0x0001) > 0);
		Assert.isTrue((dirs & 0x0001) > NONE);
		Assert.isTrue((dirs & LEFT) >= 0x1);
		Assert.isTrue((dirs & LEFT) >= LEFT);
		Assert.isTrue((dirs & 0x0001) >= 0x1);
		Assert.isTrue((dirs & 0x0001) >= LEFT);
		Assert.isTrue((dirs & LEFT) == LEFT);
		Assert.isTrue((dirs & LEFT) == 0x1);
		Assert.isTrue((dirs & 0x0001) == LEFT);
		Assert.isTrue((dirs & 0x0001) == 0x1);
		
		Assert.isFalse((dirs & LEFT) <= 0);
		Assert.isFalse((dirs & LEFT) <= NONE);
		Assert.isFalse((dirs & 0x0001) <= 0);
		Assert.isFalse((dirs & 0x0001) <= NONE);
		
		dirs = NONE;
		Assert.isTrue((dirs | LEFT) > 0);
		Assert.isTrue((dirs | LEFT) > NONE);
		Assert.isTrue((dirs | 0x0001) > 0);
		Assert.isTrue((dirs | 0x0001) > NONE);
		Assert.isTrue((dirs | LEFT) >= 0x1);
		Assert.isTrue((dirs | LEFT) >= LEFT);
		Assert.isTrue((dirs | 0x0001) >= 0x1);
		Assert.isTrue((dirs | 0x0001) >= LEFT);
		Assert.isTrue((dirs | LEFT) == LEFT);
		Assert.isTrue((dirs | LEFT) == 0x1);
		Assert.isTrue((dirs | 0x0001) == LEFT);
		Assert.isTrue((dirs | 0x0001) == 0x1);
		
		Assert.isFalse((dirs | LEFT) <= 0);
		Assert.isFalse((dirs | LEFT) <= NONE);
		Assert.isFalse((dirs | 0x0001) <= 0);
		Assert.isFalse((dirs | 0x0001) <= NONE);
	}
}