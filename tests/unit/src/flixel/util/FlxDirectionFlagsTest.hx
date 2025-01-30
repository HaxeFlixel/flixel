package flixel.util;

import massive.munit.Assert;
import flixel.util.FlxDirectionFlags;
import haxe.PosInfos;

/**
 * A bulk of these tests are copied from `FlxColor`.
 */
class FlxDirectionFlagsTest extends FlxTest
{
	var dirs:FlxDirectionFlags;

	@Test
	function isNull()
	{
		var dirs:Null<FlxDirectionFlags> = null;
		Assert.isNull(dirs);
	}

	@Test
	function isNullFunction()
	{
		function f(dirs:Null<FlxDirectionFlags>)
		{
			return dirs == null;
		}

		Assert.isTrue(f(null));
		Assert.isFalse(f(cast 0));
		Assert.isFalse(f(LEFT));
	}

	@Test
	function equalityToNull()
	{
		var dirs1:Null<FlxDirectionFlags> = null;
		var dirs2:FlxDirectionFlags = LEFT;
		Assert.isFalse(dirs1 == dirs2);
	}

	@Test
	function equalityToSame()
	{
		var dirs1:FlxDirectionFlags = LEFT;
		var dirs2:FlxDirectionFlags = LEFT;
		Assert.isTrue(dirs1 == dirs2);
	}

	@Test
	function equalityNotSame()
	{
		var dirs1:FlxDirectionFlags = LEFT;
		var dirs2:FlxDirectionFlags = RIGHT;
		Assert.isFalse(dirs1 == dirs2);
	}

	@Test
	function withSame()
	{
		Assert.areEqual(LEFT, LEFT.with(LEFT));
		Assert.areEqual(RIGHT, RIGHT.with(RIGHT));
	}

	@Test
	function withNotSame()
	{
		Assert.areEqual(WALL, LEFT.with(RIGHT));
		Assert.areEqual(WALL, RIGHT.with(LEFT));
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
	function withoutSame()
	{
		Assert.areEqual(NONE, LEFT.without(LEFT));
		Assert.areEqual(NONE, RIGHT.without(RIGHT));
	}

	@Test
	function withoutNotSame()
	{
		Assert.areEqual(LEFT, LEFT.without(RIGHT));
		Assert.areEqual(RIGHT, RIGHT.without(LEFT));
	}

	@Test
	function hasAll()
	{
		Assert.isTrue(WALL.has(LEFT));
		Assert.isTrue(WALL.has(LEFT | RIGHT));
		Assert.isFalse(LEFT.has(WALL));
		Assert.isFalse(WALL.has(UP));
		Assert.isFalse(WALL.has(LEFT | RIGHT | DOWN));
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
	function withWithoutNew()
	{
		dirs = WALL;
		Assert.areEqual(RIGHT, dirs.without(LEFT));
		Assert.areEqual(0x0111, dirs.with(UP));
		Assert.areEqual(WALL, dirs.with(NONE));
		Assert.areEqual(ANY, dirs.with(ANY));
	}

	@Test
	function testAngles()
	{
		function assertDegrees(flags:FlxDirectionFlags, degrees:Float, margin = 0.001, ?pos:PosInfos)
		{
			FlxAssert.areNear(flags.degrees, degrees, margin, null, pos);
			FlxAssert.areNear(flags.radians, degrees / 180 * Math.PI, margin, null, pos);
		}
		
		assertDegrees(RIGHT       , 0  );
		assertDegrees(RIGHT | DOWN, 45 );
		assertDegrees(DOWN        , 90 );
		assertDegrees(DOWN | LEFT , 135);
		assertDegrees(LEFT        , 180);
		assertDegrees(LEFT | UP   ,-135);
		assertDegrees(UP          ,-90 );
		assertDegrees(UP | RIGHT  ,-45 );
	}
	
	@Test
	function testNot()
	{
		inline function assertNot(a:FlxDirectionFlags, b:FlxDirectionFlags, ?pos:PosInfos)
		{
			Assert.areEqual(a.not(), b, 'Value ${a.toInt()}:[$a].not() was not equal to expected value ${b.toInt()}:[$b]', pos);
			Assert.areEqual(b.not(), a, 'Value ${b.toInt()}:[$b].not() was not equal to expected value ${a.toInt()}:[$a]', pos);
		}
		
		assertNot(RIGHT | DOWN, LEFT | UP);
		assertNot(RIGHT, LEFT | UP | DOWN);
		assertNot(ANY, NONE);
	}
	
	@Test
	@:haxe.warning("-WDeprecated")
	function implicitBackwardsCompat()
	{
		
		Assert.isTrue(FlxDirectionFlags.NONE == 0);
		Assert.isTrue(0 == FlxDirectionFlags.NONE);
		Assert.isTrue(flixel.util.FlxDirection.LEFT == 0x0001);
		Assert.isTrue(0x0001 == flixel.util.FlxDirection.LEFT);
	}
}
