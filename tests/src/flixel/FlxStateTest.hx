package flixel;

import flixel.FlxG;
import helper.TestState;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class FlxStateTest extends FlxTest
{
	@AsyncTest
	function testSwitchState(factory:AsyncFactory):Void
	{
		Assert.isFalse(Std.is(FlxG.state, TestState));
		FlxG.switchState(new TestState());
		
		delay(this, factory, function() { 
			Assert.isTrue(Std.is(FlxG.state, TestState)); 
		});
	}
}