package flixel.util;

import massive.munit.Assert;

class FlxColorTest extends FlxTest
{
	var color:FlxColor;

	@Test
	function isNull()
	{
		var color:Null<FlxColor> = null;
		Assert.isNull(color);
	}

	@Test
	function isNullFunction()
	{
		var f = function(?c:FlxColor)
		{
			return c == null;
		};

		Assert.isTrue(f(null));
		Assert.isFalse(f(0));
		Assert.isFalse(f(FlxColor.RED));
	}

	@Test
	function equalityToNull()
	{
		var color1:Null<FlxColor> = null;
		var color2:FlxColor = FlxColor.BLACK;
		Assert.isFalse(color1 == color2);
	}

	@Test
	function equalityToSame()
	{
		var color1:FlxColor = FlxColor.BLACK;
		var color2:FlxColor = FlxColor.BLACK;
		Assert.isTrue(color1 == color2);
	}

	@Test
	function equalityNotSame()
	{
		var color1:FlxColor = FlxColor.RED;
		var color2:FlxColor = FlxColor.BLUE;
		Assert.isFalse(color1 == color2);
	}

	@Test
	function addNotSame()
	{
		Assert.areEqual(0xFFFF8000, (FlxColor.RED + FlxColor.GREEN)); // 0xFFFF0000 + 0xFF008000
		Assert.areEqual(0xFFFF8000, (FlxColor.GREEN + FlxColor.RED));
	}

	@Test
	function subtractNotSame()
	{
		Assert.areEqual(FlxColor.RED, (FlxColor.RED - FlxColor.GREEN));
		Assert.areEqual(FlxColor.GREEN, (FlxColor.GREEN - FlxColor.RED));
	}

	@Test
	function multiplyNotSame()
	{
		Assert.areEqual(FlxColor.BLACK, (FlxColor.RED * FlxColor.GREEN));
		Assert.areEqual(FlxColor.BLACK, (FlxColor.GREEN * FlxColor.RED));
	}

	@Test // #1609
	function testReflectionInvalidOperation()
	{
		color = FlxColor.WHITE;

		// shouldn't cause an invalid operation exception
		asFloat(function(c) c.red);
		asFloat(function(c) c.green);
		asFloat(function(c) c.blue);
		asFloat(function(c) c.alpha);

		asFloat(function(c) c.red += 1);
		asFloat(function(c) c.green += 1);
		asFloat(function(c) c.blue += 1);
		asFloat(function(c) c.alpha += 1);
	}

	function asFloat(f:FlxColor->Void)
	{
		Reflect.setProperty(this, "color", 0.2);
		f(color);
	}
}
