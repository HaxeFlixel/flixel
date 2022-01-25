package flixel.input.keyboard;

import massive.munit.Assert;

class FlxKeyTest extends FlxTest
{
	@Before
	function before() {}
	
	@Test
	function testNone():Void
	{
		Assert.isTrue(FlxG.keys.pressed.NONE);
	}
	
	@Test
	function testAny():Void
	{
		Assert.isFalse(FlxG.keys.pressed.ANY);
	}
}