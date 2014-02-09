package flixel;

import TestMain;
import flixel.FlxG;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class FlxStateTest
{
	public function new() {}
	
	@AsyncTest
	public function switchState(factory:AsyncFactory):Void
	{
		FlxG.switchState(new TestState2());
		
		var resultHandler:Dynamic = factory.createHandler(this, testStateChange);
		TestMain.addAsync(resultHandler, 100);
	}

	function testStateChange(?e:Dynamic):Void
	{
		Assert.isTrue(FlxG.cameras.bgColor == 0xff131c1c);
	}

}