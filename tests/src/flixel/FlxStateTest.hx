package flixel;

import flixel.FlxG;
import helper.TestState;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import TestMain;

class FlxStateTest extends FlxTest
{
	@AsyncTest
	function switchState(factory:AsyncFactory):Void
	{
		FlxG.switchState(new TestState());
		
		var resultHandler:Dynamic = factory.createHandler(this, testStateChange);
		TestMain.addAsync(resultHandler, 100);
	}

	function testStateChange(?e:Dynamic):Void
	{
		Assert.isTrue(Std.is(FlxG.state, TestState));
	}
}