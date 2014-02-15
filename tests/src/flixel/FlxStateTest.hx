package flixel;

import flixel.FlxG;
import flixel.util.FlxColor;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import TestMain;

class FlxStateTest extends FlxTest
{
	@AsyncTest
	public function switchState(factory:AsyncFactory):Void
	{
		FlxG.switchState(new TestState());
		
		var resultHandler:Dynamic = factory.createHandler(this, testStateChange);
		TestMain.addAsync(resultHandler, 100);
	}

	private function testStateChange(?e:Dynamic):Void
	{
		Assert.isTrue(FlxG.cameras.bgColor == FlxColor.RED);
	}
}

class TestState extends FlxState
{
	override public function create():Void
	{
		bgColor = FlxColor.RED;
	}
}