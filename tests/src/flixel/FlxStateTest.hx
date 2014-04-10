package flixel;

import flixel.FlxG;
import helper.TestState;
import massive.munit.Assert;

class FlxStateTest extends FlxTest
{
	@Test
	function testSwitchState():Void
	{
		Assert.isFalse(Std.is(FlxG.state, TestState));
		FlxG.switchState(new TestState());
		delay(function() { Assert.isTrue(Std.is(FlxG.state, TestState)); });
	}
}