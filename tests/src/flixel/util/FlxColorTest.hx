package flixel.util;

import flixel.util.FlxColor;
import massive.munit.Assert;

class FlxColorTest extends FlxTest
{
	@Test
	function isNull():Void
	{
		var color:Null<FlxColor> = null;
		Assert.isNull(color);
	}

	@Test
	function isNullFunction():Void
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
	function equalityToNull():Void
	{
		var color1:Null<FlxColor> = null;
		var color2:FlxColor = FlxColor.BLACK;
		Assert.isFalse(color1 == color2);
	}

	@Test
	function equalityToSame():Void
	{
		var color1:FlxColor = FlxColor.BLACK;
		var color2:FlxColor = FlxColor.BLACK;
		Assert.isTrue(color1 == color2);
	}

	@Test
	function equalityNotSame():Void
	{
		var color1:FlxColor = FlxColor.RED;
		var color2:FlxColor = FlxColor.BLUE;
		Assert.isFalse(color1 == color2);
	}

	@Test
	function addNotSame():Void
	{
		Assert.areSame(0xFFFF8000, (FlxColor.RED + FlxColor.GREEN)); // 0xFFFF0000 + 0xFF008000
		Assert.areSame(0xFFFF8000, (FlxColor.GREEN + FlxColor.RED));
	}

	@Test
	function subtractNotSame():Void
	{
		Assert.areSame(FlxColor.RED, (FlxColor.RED - FlxColor.GREEN));
		Assert.areSame(FlxColor.GREEN, (FlxColor.GREEN - FlxColor.RED));
	}

	@Test
	function multiplyNotSame():Void
	{
		Assert.areSame(FlxColor.BLACK, (FlxColor.RED * FlxColor.GREEN));
		Assert.areSame(FlxColor.BLACK, (FlxColor.GREEN * FlxColor.RED));
	}
}