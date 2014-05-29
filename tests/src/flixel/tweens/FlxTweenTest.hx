package flixel.tweens;

import flixel.tweens.FlxTween;
import haxe.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class FlxTweenTest extends FlxTest
{
	var value:Int = 0;
	
	@AsyncTest
	function testIssue1104(factory:AsyncFactory):Void
	{
		FlxTween.tween(this, { value:  1000 }, 1);
		FlxTween.tween(this, { value: -1000 }, 1,  { startDelay: 1 } );
		
		// check that there is actually some tweening going on
		var value1:Int;
		
		Timer.delay(function() {
			value1 = value;
		}, 50);
		
		delay(this, factory, function() {
			Assert.areNotEqual(value, value1);
		}, 100);
	}
}